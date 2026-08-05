import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:llamadart/llamadart.dart' show ModelCacheEntry;

import '../data/ai/local_llm/local_llm_engine.dart';
import '../data/ai/local_llm/local_model_catalog.dart';
import '../data/db/database.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../l10n/app_localizations.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 마이페이지 > '로컬 LLM'에서 진입하는 화면.
/// 추천 모델 다운로드, 커스텀 GGUF 파일 가져오기, 로드/언로드, 저장된 로컬 프리셋
/// 관리, 다운로드 캐시 정리를 한곳에서 다룬다.
class LocalLlmScreen extends StatefulWidget {
  const LocalLlmScreen({super.key});

  @override
  State<LocalLlmScreen> createState() => _LocalLlmScreenState();
}

class _LocalLlmScreenState extends State<LocalLlmScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _cardBg => _p.surface;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _textFaint => _p.textFaint;
  Color get _textGhost => _p.textGhost;
  Color get _mutedText => _p.textMuted;
  Color get _danger => _p.danger;
  Color get _borderGrey => _p.border;
  Color get _textSecondary => _p.textSecondary;

  late final AiPresetRepository _presetRepo;
  late final LocalModelStorage _storage;

  String? _busyKey; // 지금 다운로드/로딩 중인 catalog id 또는 preset id
  double? _busyFraction;
  List<ModelCacheEntry>? _cachedEntries;

  @override
  void initState() {
    super.initState();
    _presetRepo = AiPresetRepository(AppDatabase.instance);
    _storage = LocalModelStorage();
    _refreshCache();
  }

  Future<void> _refreshCache() async {
    final entries = await _storage.listCached();
    if (mounted) setState(() => _cachedEntries = entries);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.localLlmScreenTitle,
          style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Text(l10n.localLlmScreenDescription, style: TextStyle(color: _textFaint, fontSize: 12)),
            const SizedBox(height: 16),
            _buildStatusCard(l10n),
            const SizedBox(height: 20),
            Text(l10n.localLlmRecommendedSectionTitle, style: _sectionTitleStyle),
            const SizedBox(height: 8),
            ...kLocalModelCatalog.map((e) => _buildCatalogCard(l10n, e)),
            const SizedBox(height: 20),
            Text(l10n.localLlmImportSectionTitle, style: _sectionTitleStyle),
            const SizedBox(height: 8),
            _buildImportCard(l10n),
            const SizedBox(height: 20),
            Text(l10n.localLlmSavedPresetsSectionTitle, style: _sectionTitleStyle),
            const SizedBox(height: 8),
            _buildSavedPresetsList(l10n),
            const SizedBox(height: 20),
            Text(l10n.localLlmCacheSectionTitle, style: _sectionTitleStyle),
            const SizedBox(height: 8),
            _buildCacheSection(l10n),
          ],
        ),
      ),
    );
  }

  TextStyle get _sectionTitleStyle => TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600);

  Widget _buildStatusCard(AppLocalizations l10n) {
    final current = LocalLlmEngine.instance.current;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.memory, color: current != null ? _purple : _textGhost, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.localLlmCurrentStatusLabel, style: TextStyle(color: _mutedText, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  current?.label ?? l10n.localLlmNoModelLoaded,
                  style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (current != null)
            TextButton(
              onPressed: () async {
                await LocalLlmEngine.instance.unload();
                if (mounted) setState(() {});
              },
              child: Text(l10n.localLlmUnloadButton, style: TextStyle(color: _danger, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  /// 카탈로그 엔트리의 설명 문구는 언어별로 달라야 하므로 id 기준으로 l10n에서 조회한다.
  String _modelDescription(AppLocalizations l10n, String id) {
    switch (id) {
      case 'huihui-qwen3.5-08b':
        return l10n.localLlmModelDescHuihuiQwen3508b;
      case 'huihui-qwen35-4b':
        return l10n.localLlmModelDescHuihuiQwen354b;
      case 'huihui-gemma4-e2b':
        return l10n.localLlmModelDescHuihuiGemma4E2b;
      case 'huihui-gemma4-e4b':
        return l10n.localLlmModelDescHuihuiGemma4E4b;
      default:
        return '';
    }
  }

  Widget _buildCatalogCard(AppLocalizations l10n, LocalModelCatalogEntry entry) {
    final isCurrent = LocalLlmEngine.instance.current?.source == entry.source;
    final isBusy = _busyKey == entry.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.label, style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_modelDescription(l10n, entry.id), style: TextStyle(color: _mutedText, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('~${entry.approxSizeMb} MB', style: TextStyle(color: _textGhost, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                label: isCurrent ? l10n.localLlmInUseLabel : l10n.localLlmUseButton,
                enabled: !isCurrent && _busyKey == null,
                busy: isBusy,
                onPressed: () => _useCatalogEntry(l10n, entry),
              ),
            ],
          ),
          if (isBusy) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _busyFraction,
              backgroundColor: _textGhost,
              color: _purple,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool enabled,
    required bool busy,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: _textPrimary,
        disabledForegroundColor: _textGhost,
        side: BorderSide(color: enabled ? _purple : _borderGrey),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: busy
          ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: _textSecondary))
          : Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Future<void> _useCatalogEntry(AppLocalizations l10n, LocalModelCatalogEntry entry) async {
    setState(() {
      _busyKey = entry.id;
      _busyFraction = null;
    });
    try {
      await LocalLlmEngine.instance.load(
        source: entry.source,
        label: entry.label,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() => _busyFraction = progress.fraction);
        },
      );
      final existing = await _presetRepo.getByLocalModelSource(entry.source);
      await _presetRepo.upsert(
        id: existing?.id,
        name: entry.label,
        description: l10n.localLlmPresetDescription,
        baseUrl: 'local',
        modelName: entry.label,
        isLocal: true,
        localModelSource: entry.source,
      );
      await _refreshCache();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.localLlmLoadSuccessMessage(entry.label))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.localLlmLoadFailureMessage(e))));
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Widget _buildImportCard(AppLocalizations l10n) {
    final isBusy = _busyKey == '_import';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Text(l10n.localLlmImportDescription, style: TextStyle(color: _mutedText, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: l10n.localLlmImportButton,
            enabled: _busyKey == null,
            busy: isBusy,
            onPressed: _importCustomModel,
          ),
        ],
      ),
    );
  }

  Future<void> _importCustomModel() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['gguf']);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    final fileName = result.files.single.name;
    final label = fileName.toLowerCase().endsWith('.gguf') ? fileName.substring(0, fileName.length - 5) : fileName;

    if (!mounted) return;
    setState(() {
      _busyKey = '_import';
      _busyFraction = null;
    });
    try {
      await LocalLlmEngine.instance.load(source: path, label: label);
      final existing = await _presetRepo.getByLocalModelSource(path);
      await _presetRepo.upsert(
        id: existing?.id,
        name: label,
        description: l10n.localLlmPresetDescription,
        baseUrl: 'local',
        modelName: label,
        isLocal: true,
        localModelSource: path,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.localLlmLoadSuccessMessage(label))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.localLlmLoadFailureMessage(e))));
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Widget _buildSavedPresetsList(AppLocalizations l10n) {
    return StreamBuilder<List<AiPreset>>(
      stream: _presetRepo.watchAll(),
      builder: (context, snapshot) {
        final presets = (snapshot.data ?? const []).where((p) => p.isLocal).toList();
        if (presets.isEmpty) {
          return Text(l10n.localLlmNoSavedPresets, style: TextStyle(color: _textFaint, fontSize: 12));
        }
        return Column(
          children: presets.map((preset) {
            final isCurrent = LocalLlmEngine.instance.current?.source == preset.localModelSource;
            final isBusy = _busyKey == 'preset-${preset.id}';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(preset.name, style: TextStyle(color: _textPrimary, fontSize: 13)),
                  ),
                  _buildActionButton(
                    label: isCurrent ? l10n.localLlmInUseLabel : l10n.localLlmLoadButton,
                    enabled: !isCurrent && _busyKey == null,
                    busy: isBusy,
                    onPressed: () => _loadSavedPreset(l10n, preset),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: _mutedText, size: 18),
                    onPressed: () => _presetRepo.delete(preset.id),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _loadSavedPreset(AppLocalizations l10n, AiPreset preset) async {
    final source = preset.localModelSource;
    if (source == null) return;
    setState(() {
      _busyKey = 'preset-${preset.id}';
      _busyFraction = null;
    });
    try {
      await LocalLlmEngine.instance.load(
        source: source,
        label: preset.modelName,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() => _busyFraction = progress.fraction);
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.localLlmLoadSuccessMessage(preset.modelName))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.localLlmLoadFailureMessage(e))));
    } finally {
      if (mounted) setState(() => _busyKey = null);
    }
  }

  Widget _buildCacheSection(AppLocalizations l10n) {
    final entries = _cachedEntries;
    if (entries == null) {
      return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (entries.isEmpty) {
      return Text(l10n.localLlmNoCachedModels, style: TextStyle(color: _textFaint, fontSize: 12));
    }
    return Column(
      children: entries.map((entry) {
        final sizeLabel = entry.bytes != null ? '${(entry.bytes! / (1024 * 1024)).toStringAsFixed(0)} MB' : '';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.fileName, style: TextStyle(color: _textPrimary, fontSize: 13), overflow: TextOverflow.ellipsis),
                    if (sizeLabel.isNotEmpty)
                      Text(sizeLabel, style: TextStyle(color: _textGhost, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: _mutedText, size: 18),
                onPressed: () async {
                  await _storage.remove(entry.cacheKey);
                  await _refreshCache();
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
