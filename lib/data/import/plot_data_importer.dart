import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../db/database.dart';
import '../local_image_store.dart';
import '../repositories/character_repository.dart';
import '../repositories/intro_entry_repository.dart';
import '../repositories/lorebook_repository.dart';
import '../repositories/plot_conversation_profile_repository.dart';
import '../repositories/plot_repository.dart';

class PlotDataImportException implements Exception {
  PlotDataImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// [PlotDataImporter.importFromBytes]의 결과.
class PlotDataImportResult {
  const PlotDataImportResult({
    required this.plotId,
    required this.characterCount,
    required this.lorebookCount,
  });

  final int plotId;
  final int characterCount;
  final int lorebookCount;
}

/// [PlotDataExporter]가 만든 `.mzplot` zip을 읽어 완전히 새로운 플롯으로 저장한다.
///
/// 기존 데이터를 지우는 전체 백업 복원과 달리, 이미 데이터가 있는 DB에 "병합"하는 것이라
/// 원본 id를 그대로 쓰지 않는다 - 모든 레코드를 리포지토리의 생성 메서드로 새로 만들고,
/// 참조 관계(캐릭터/인트로 버전/로어북 id)는 가져오는 동안 새로 발급된 id로 다시 연결한다.
/// 이미지도 파일명 충돌을 피하기 위해 전부 새 이름으로 저장한다.
class PlotDataImporter {
  PlotDataImporter(AppDatabase db)
      : _plotRepository = PlotRepository(db),
        _characterRepository = CharacterRepository(db),
        _introRepository = IntroEntryRepository(db),
        _profileRepository = PlotConversationProfileRepository(db),
        _lorebookRepository = LorebookRepository(db),
        _imageStore = LocalImageStore();

  final PlotRepository _plotRepository;
  final CharacterRepository _characterRepository;
  final IntroEntryRepository _introRepository;
  final PlotConversationProfileRepository _profileRepository;
  final LorebookRepository _lorebookRepository;
  final LocalImageStore _imageStore;

  Future<PlotDataImportResult> importFromBytes(
    Uint8List zipBytes, {
    int? targetPlotId,
    int? mergeLorebookId,
  }) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } catch (_) {
      throw PlotDataImportException('zip 파일을 읽지 못했어요. 손상되었거나 올바른 파일이 아니에요.');
    }
    return importArchive(archive, targetPlotId: targetPlotId, mergeLorebookId: mergeLorebookId);
  }

  /// [importFromBytes]의 핵심 로직. 이미 디코딩된 [Archive]를 받아서 그대로 가져온다 -
  /// `.mzpack`(여러 플롯 묶음)이 하나의 바깥 zip 안에 플롯별 `manifest.json`/`data.json`/
  /// `images/*`를 서브 디렉터리로 담고 있을 때, 플롯 단위로 쪼갠 서브 [Archive]를 만들어
  /// 이 메서드를 여러 번 호출하는 식으로 재사용한다([PlotPackageImporter] 참고).
  ///
  /// [targetPlotId]가 주어지면 새 플롯을 만들지 않고 그 플롯에 캐릭터/인트로/플롯 전용
  /// 프로필을 추가로 얹는다(대표 캐릭터로 지정하지 않음). [mergeLorebookId]가 함께 주어지면
  /// 가져온 로어북 항목들을 새 로어북들로 나누지 않고 그 기존 로어북 하나에 전부 이어 붙인다.
  Future<PlotDataImportResult> importArchive(
    Archive archive, {
    int? targetPlotId,
    int? mergeLorebookId,
  }) async {
    final manifestFile = archive.findFile('manifest.json');
    final dataFile = archive.findFile('data.json');
    if (manifestFile == null || dataFile == null) {
      throw PlotDataImportException('올바른 MicroZed 플롯 파일이 아니에요.');
    }

    late final Map<String, dynamic> manifest;
    late final Map<String, dynamic> data;
    try {
      manifest = jsonDecode(utf8.decode(manifestFile.content)) as Map<String, dynamic>;
      data = jsonDecode(utf8.decode(dataFile.content)) as Map<String, dynamic>;
    } catch (_) {
      throw PlotDataImportException('파일 내용을 읽지 못했어요.');
    }
    if (manifest['app'] != 'microzed' || manifest['kind'] != 'plot') {
      throw PlotDataImportException('올바른 MicroZed 플롯 파일이 아니에요.');
    }

    // zip 안의 이미지를 전부 새 파일로 저장해두고, 원본 파일명 -> 새 경로 맵을 만든다.
    final imagePathByOriginalName = <String, String>{};
    var imageIndex = 0;
    for (final file in archive) {
      if (!file.isFile || !file.name.startsWith('images/')) continue;
      final originalName = file.name.substring('images/'.length);
      if (originalName.isEmpty) continue;
      final ext = p.extension(originalName);
      final savedPath = await _imageStore.saveBytes(
        'plotimport_${imageIndex++}',
        file.content,
        ext: ext.isEmpty ? '.png' : ext,
      );
      imagePathByOriginalName[originalName] = savedPath;
    }
    String? remapImage(String? originalPath) {
      if (originalPath == null || originalPath.isEmpty) return originalPath;
      return imagePathByOriginalName[p.basename(originalPath)] ?? originalPath;
    }

    List<Map<String, dynamic>> rowsFor(String key) => (data[key] as List? ?? const []).cast<Map<String, dynamic>>();

    final plotJson = data['plot'] as Map<String, dynamic>?;
    if (plotJson == null) {
      throw PlotDataImportException('플롯 데이터가 없어요.');
    }
    final hashtags = (plotJson['hashtags'] as String? ?? '')
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final plotId = targetPlotId ??
        await _plotRepository.upsertPlot(
          title: plotJson['title'] as String? ?? '',
          description: plotJson['description'] as String? ?? '',
          shortIntro: plotJson['shortIntro'] as String? ?? '',
          hashtags: hashtags,
          coverImagePath: remapImage(plotJson['coverImagePath'] as String?),
        );

    // 기존 플롯에 병합할 때는 대표 캐릭터를 새로 지정하지 않고(이미 있으니), 정렬 순서도
    // 기존 캐릭터들 뒤로 이어 붙인다.
    final existingCharacterCount =
        targetPlotId == null ? 0 : (await _characterRepository.getByPlot(targetPlotId)).length;
    final characterIdMap = <int, int>{};
    for (final json in rowsFor('characters')) {
      final newId = await _characterRepository.add(
        plotId: plotId,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        imagePath: remapImage(json['imagePath'] as String?),
        isRepresentative: targetPlotId == null ? (json['isRepresentative'] as bool? ?? false) : false,
        sortOrder: existingCharacterCount + ((json['sortOrder'] as num?)?.toInt() ?? 0),
        aboutText: json['aboutText'] as String? ?? '',
      );
      characterIdMap[(json['id'] as num).toInt()] = newId;
    }

    // 원본 버전 순서(sortOrder asc)대로 새 버전을 만들면서 id를 매핑한다. addVersion은
    // 호출할 때마다 그 플롯의 현재 최대 sortOrder+1을 스스로 매기므로, 순서대로 호출하기만
    // 하면 원본과 같은 상대 순서로 재구성된다.
    final introVersionsJson = rowsFor('introVersions')
      ..sort((a, b) => ((a['sortOrder'] as num?) ?? 0).compareTo((b['sortOrder'] as num?) ?? 0));
    final introVersionIdMap = <int, int>{};
    for (final json in introVersionsJson) {
      final newId = await _introRepository.addVersion(plotId);
      introVersionIdMap[(json['id'] as num).toInt()] = newId;
    }

    for (final json in rowsFor('introEntries')) {
      final oldVersionId = (json['introVersionId'] as num?)?.toInt();
      final newVersionId = oldVersionId == null ? null : introVersionIdMap[oldVersionId];
      if (newVersionId == null) continue; // 원본 버전을 못 찾으면(비정상 데이터) 건너뛴다.
      final oldCharacterId = (json['characterId'] as num?)?.toInt();
      final type = IntroEntryType.values[(json['type'] as num).toInt()];
      final rawContent = json['content'] as String? ?? '';
      await _introRepository.add(
        plotId: plotId,
        introVersionId: newVersionId,
        characterId: oldCharacterId == null ? null : characterIdMap[oldCharacterId],
        type: type,
        content: type == IntroEntryType.image ? (remapImage(rawContent) ?? rawContent) : rawContent,
      );
    }

    for (final json in rowsFor('plotConversationProfiles')) {
      await _profileRepository.upsert(
        plotId: plotId,
        name: json['name'] as String? ?? '',
        useGlobalName: json['useGlobalName'] as bool? ?? false,
        shortIntro: json['shortIntro'] as String? ?? '',
        description: json['description'] as String? ?? '',
        imagePath: remapImage(json['imagePath'] as String?),
      );
    }

    // mergeLorebookId가 있으면 원본의 로어북 구분을 무시하고 모든 항목을 그 기존
    // 로어북 하나에 이어 붙인다. 없으면 예전처럼 원본 로어북들을 그대로 새로 만든다.
    final linkedLorebookIds = <int>{};
    if (mergeLorebookId != null) {
      for (final json in rowsFor('lorebookEntries')) {
        final entryId = await _lorebookRepository.addEntry(mergeLorebookId);
        await _lorebookRepository.updateEntry(
          id: entryId,
          title: json['title'] as String? ?? '',
          keywords: json['keywords'] as String? ?? '',
          content: json['content'] as String? ?? '',
        );
      }
      if (rowsFor('lorebookEntries').isNotEmpty) linkedLorebookIds.add(mergeLorebookId);
    } else {
      final lorebookIdMap = <int, int>{};
      for (final json in rowsFor('lorebooks')) {
        final newId = await _lorebookRepository.upsert(
          title: json['title'] as String? ?? '',
          shortIntro: json['shortIntro'] as String? ?? '',
        );
        lorebookIdMap[(json['id'] as num).toInt()] = newId;
      }
      for (final json in rowsFor('lorebookEntries')) {
        final oldLorebookId = (json['lorebookId'] as num?)?.toInt();
        final newLorebookId = oldLorebookId == null ? null : lorebookIdMap[oldLorebookId];
        if (newLorebookId == null) continue;
        final entryId = await _lorebookRepository.addEntry(newLorebookId);
        await _lorebookRepository.updateEntry(
          id: entryId,
          title: json['title'] as String? ?? '',
          keywords: json['keywords'] as String? ?? '',
          content: json['content'] as String? ?? '',
        );
      }
      linkedLorebookIds.addAll(lorebookIdMap.values);
    }
    if (linkedLorebookIds.isNotEmpty) {
      final existingLinks = await _lorebookRepository.linkedLorebookIds(plotId);
      await _lorebookRepository.setLorebookLinksForPlot(plotId, {...existingLinks, ...linkedLorebookIds});
    }

    return PlotDataImportResult(
      plotId: plotId,
      characterCount: characterIdMap.length,
      lorebookCount: linkedLorebookIds.length,
    );
  }
}
