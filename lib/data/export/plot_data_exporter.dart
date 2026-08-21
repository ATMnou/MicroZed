import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../db/database.dart';
import '../repositories/character_repository.dart';
import '../repositories/intro_entry_repository.dart';
import '../repositories/lorebook_repository.dart';
import '../repositories/plot_conversation_profile_repository.dart';
import '../repositories/plot_repository.dart';
import '../repositories/vn_background_repository.dart';

class PlotDataExportException implements Exception {
  PlotDataExportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 플롯 하나의 모든 데이터(대화 기록 제외)를 전용 zip 형식(`.mzplot`)으로 내보낸다.
///
/// SillyTavern 카드 내보내기([PlotCardExporter])와 달리 대표 캐릭터 한 명/이미지 한 장으로
/// 손실 압축하지 않고, 이 플롯에 속한 모든 캐릭터/인트로 버전/플롯 전용 대화 프로필/연결된
/// 로어북과 그 안의 모든 이미지를 원본 그대로 zip에 담는다. 대화 세션/메시지는 제외한다.
///
/// zip 구조는 [BackupService]와 비슷하다:
/// - manifest.json: {app, kind: "plot", formatVersion, schemaVersion, exportedAt, plotTitle}
/// - data.json: plot/characters/introVersions/introEntries/plotConversationProfiles/
///   lorebooks/lorebookEntries/vnBackgrounds/vnCharacterExpressions/vnChoices
/// - images/*: 이 플롯이 실제로 참조하는 이미지 파일만(원본 파일명 그대로, VN 배경/캐릭터
///   표정 이미지 포함)
class PlotDataExporter {
  PlotDataExporter(AppDatabase db)
      : _plotRepository = PlotRepository(db),
        _characterRepository = CharacterRepository(db),
        _introRepository = IntroEntryRepository(db),
        _profileRepository = PlotConversationProfileRepository(db),
        _lorebookRepository = LorebookRepository(db),
        _vnBackgroundRepository = VnBackgroundRepository(db);

  final PlotRepository _plotRepository;
  final CharacterRepository _characterRepository;
  final IntroEntryRepository _introRepository;
  final PlotConversationProfileRepository _profileRepository;
  final LorebookRepository _lorebookRepository;
  final VnBackgroundRepository _vnBackgroundRepository;

  // v2: 비주얼 노벨 전용 데이터(배경/캐릭터 표정/선택지)를 data.json에 포함하도록 확장.
  static const _formatVersion = 2;

  Future<Uint8List> exportPlot(int plotId) async {
    final plot = await _plotRepository.getById(plotId);
    if (plot == null) {
      throw PlotDataExportException('플롯을 찾을 수 없어요.');
    }

    final characters = await _characterRepository.getByPlot(plotId);
    final introVersions = await _introRepository.getVersions(plotId);
    final introEntries = <IntroEntry>[];
    for (final version in introVersions) {
      introEntries.addAll(await _introRepository.getByVersion(version.id));
    }
    final profiles = await _profileRepository.getByPlot(plotId);

    // 비주얼 노벨 전용 데이터. plotType이 storyChat이면 셋 다 비어있다.
    final vnBackgrounds = await _vnBackgroundRepository.getByPlot(plotId);
    final vnCharacterExpressions = <VnCharacterExpression>[];
    for (final character in characters) {
      vnCharacterExpressions.addAll(await _characterRepository.getExpressions(character.id));
    }
    final vnChoices = <VnChoice>[];
    for (final version in introVersions) {
      vnChoices.addAll(await _introRepository.getChoices(version.id));
    }

    final lorebookIds = await _lorebookRepository.linkedLorebookIds(plotId);
    final lorebooks = <Lorebook>[];
    final lorebookEntries = <LorebookEntry>[];
    for (final lorebookId in lorebookIds) {
      final lorebook = await _lorebookRepository.getById(lorebookId);
      if (lorebook == null) continue;
      lorebooks.add(lorebook);
      lorebookEntries.addAll(await _lorebookRepository.getEntries(lorebookId));
    }

    final data = {
      'plot': plot.toJson(),
      'characters': characters.map((c) => c.toJson()).toList(),
      'introVersions': introVersions.map((v) => v.toJson()).toList(),
      'introEntries': introEntries.map((e) => e.toJson()).toList(),
      'plotConversationProfiles': profiles.map((p) => p.toJson()).toList(),
      'lorebooks': lorebooks.map((l) => l.toJson()).toList(),
      'lorebookEntries': lorebookEntries.map((e) => e.toJson()).toList(),
      'vnBackgrounds': vnBackgrounds.map((b) => b.toJson()).toList(),
      'vnCharacterExpressions': vnCharacterExpressions.map((e) => e.toJson()).toList(),
      'vnChoices': vnChoices.map((c) => c.toJson()).toList(),
    };

    final manifest = {
      'app': 'microzed',
      'kind': 'plot',
      'formatVersion': _formatVersion,
      'schemaVersion': 0, // 필드 이름만 읽어서 임포트하므로 스키마 버전 호환 검사는 하지 않는다.
      'exportedAt': DateTime.now().toIso8601String(),
      'plotTitle': plot.title,
    };

    final archive = Archive();
    archive.addFile(ArchiveFile.string('manifest.json', jsonEncode(manifest)));
    archive.addFile(ArchiveFile.string('data.json', jsonEncode(data)));

    // 이 플롯이 실제로 참조하는 이미지 파일만 모은다(앱 전체 이미지 폴더를 통째로 담지 않는다).
    final imagePaths = <String>{
      if (plot.coverImagePath != null) plot.coverImagePath!,
      for (final c in characters)
        if (c.imagePath != null) c.imagePath!,
      for (final p in profiles)
        if (p.imagePath != null) p.imagePath!,
      for (final e in introEntries)
        if (e.type == IntroEntryType.image) e.content,
      for (final b in vnBackgrounds) b.imagePath,
      for (final e in vnCharacterExpressions) e.imagePath,
    };
    for (final path in imagePaths) {
      final file = File(path);
      if (!await file.exists()) continue;
      final bytes = await file.readAsBytes();
      archive.addFile(ArchiveFile('images/${p.basename(path)}', bytes.length, bytes));
    }

    return ZipEncoder().encodeBytes(archive);
  }
}
