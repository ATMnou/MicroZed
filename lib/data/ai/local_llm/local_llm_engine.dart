import 'dart:async';

import 'package:llamadart/llamadart.dart';

/// 로컬 LLM 다운로드/로딩 진행 상태. UI가 진행률 바를 그릴 때 쓴다.
class LocalModelLoadProgress {
  const LocalModelLoadProgress({required this.stage, this.fraction});

  final ModelDownloadTaskStage stage;
  final double? fraction;
}

/// 현재 로드된 로컬 모델 정보.
class LoadedLocalModel {
  const LoadedLocalModel({required this.label, required this.source});

  final String label;
  final String source;
}

/// 기기에 내장된 llama.cpp(llamadart) 추론 엔진을 감싸는 싱글턴.
/// 앱 전체에서 모델은 한 번에 하나만 로드된 상태를 유지한다(메모리 절약).
class LocalLlmEngine {
  LocalLlmEngine._();

  static final LocalLlmEngine instance = LocalLlmEngine._();

  LlamaEngine? _engine;
  LoadedLocalModel? _current;

  bool get isLoaded => _engine != null;
  LoadedLocalModel? get current => _current;

  /// [source]는 `hf://owner/repo/file.gguf`, `http(s)://...`, 또는 로컬 파일 경로.
  /// 이미 캐시된 모델이면 llamadart가 재다운로드 없이 바로 로드한다.
  Future<void> load({
    required String source,
    required String label,
    void Function(LocalModelLoadProgress progress)? onProgress,
  }) async {
    if (_engine != null) {
      await unload();
    }
    final engine = LlamaEngine(LlamaBackend());
    try {
      await engine.loadModelSource(
        ModelSource.parse(source),
        onProgress: onProgress == null
            ? null
            : (progress) => onProgress(
                  LocalModelLoadProgress(stage: ModelDownloadTaskStage.downloading, fraction: progress.fraction),
                ),
      );
    } catch (_) {
      await engine.dispose();
      rethrow;
    }
    _engine = engine;
    _current = LoadedLocalModel(label: label, source: source);
  }

  Future<void> unload() async {
    final engine = _engine;
    _engine = null;
    _current = null;
    if (engine != null) {
      await engine.dispose();
    }
  }

  /// 채팅 화면과 같은 `{role, content}` 메시지 배열을 받아 스트리밍 응답을 방출한다.
  ///
  /// [reasoningEffort]가 null/빈 문자열이면 사고(thinking) 모드를 끈다 — 이 앱은 추론
  /// 과정을 보여줄 UI가 없던 시절, 사고를 켜두면 추론만 하다가 maxTokens를 다 써버려
  /// 답변이 통째로 비는 문제가 있었다. 값이 있으면(low/medium/high) 그 값에 비례한
  /// 토큰 예산으로 사고를 켜고, 사고 내용은 [onReasoning]으로 실시간으로 흘려보낸다.
  /// 그래도 모델이 예산을 넘겨 끝까지 사고만 하다 끝나면(또는 강제로 사고를 시작해버리면)
  /// content가 끝까지 비므로, 그 경우엔 사고 내용이라도 대신 답변으로 보여준다.
  Stream<String> streamChat({
    required List<Map<String, String>> messages,
    double temperature = 1.0,
    int? topK,
    int? maxTokens,
    String? reasoningEffort,
    void Function(String reasoning)? onReasoning,
  }) async* {
    final engine = _engine;
    if (engine == null) {
      throw StateError('로컬 모델이 로드되어 있지 않아요.');
    }
    final chatMessages = messages
        .map((m) => LlamaChatMessage.fromText(role: _roleFor(m['role']), text: m['content'] ?? ''))
        .toList();
    final thinkingEnabled = reasoningEffort != null && reasoningEffort.isNotEmpty;
    final params = GenerationParams(
      temp: temperature,
      topK: topK ?? 40,
      maxTokens: maxTokens ?? 1024,
      thinkingBudget: thinkingEnabled ? ThinkingBudget(maxTokens: _thinkingBudgetFor(reasoningEffort)) : null,
    );
    final thinkingFallback = StringBuffer();
    var emittedContent = false;
    await for (final chunk in engine.create(chatMessages, params: params, enableThinking: thinkingEnabled)) {
      if (chunk.choices.isEmpty) continue;
      final delta = chunk.choices.first.delta;
      final text = delta.content;
      if (text != null && text.isNotEmpty) {
        emittedContent = true;
        yield text;
        continue;
      }
      final thinking = delta.thinking;
      if (thinking != null && thinking.isNotEmpty) {
        thinkingFallback.write(thinking);
        onReasoning?.call(thinking);
      }
    }
    if (!emittedContent && thinkingFallback.isNotEmpty) {
      yield thinkingFallback.toString();
    }
  }

  int _thinkingBudgetFor(String effort) {
    switch (effort) {
      case 'low':
        return 512;
      case 'high':
        return 4096;
      case 'medium':
      default:
        return 1536;
    }
  }

  LlamaChatRole _roleFor(String? role) {
    switch (role) {
      case 'system':
        return LlamaChatRole.system;
      case 'assistant':
        return LlamaChatRole.assistant;
      case 'tool':
        return LlamaChatRole.tool;
      default:
        return LlamaChatRole.user;
    }
  }
}

/// 다운로드된(캐시된) 로컬 모델 파일 관리(목록/삭제).
class LocalModelStorage {
  LocalModelStorage() : _manager = DefaultModelDownloadManager();

  final ModelDownloadManager _manager;

  Future<List<ModelCacheEntry>> listCached() => _manager.list();

  Future<void> remove(String cacheKey) => _manager.remove(cacheKey);
}
