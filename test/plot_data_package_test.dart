import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/db/database.dart';
import 'package:microzed/data/export/plot_data_exporter.dart';
import 'package:microzed/data/import/plot_data_importer.dart';
import 'package:microzed/data/repositories/character_repository.dart';
import 'package:microzed/data/repositories/intro_entry_repository.dart';
import 'package:microzed/data/repositories/lorebook_repository.dart';
import 'package:microzed/data/repositories/plot_conversation_profile_repository.dart';
import 'package:microzed/data/repositories/plot_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._path);

  final String _path;

  @override
  Future<String?> getApplicationSupportPath() async => _path;
}

/// 진짜 이미지 파일이 필요한 export 검증을 위해, 앱 지원 폴더의 images/ 아래에
/// 더미 PNG 바이트를 직접 써넣고 그 경로를 돌려준다.
Future<String> _writeFakeImage(String appSupportPath, String fileName, List<int> bytes) async {
  final imagesDir = Directory(p.join(appSupportPath, 'images'));
  await imagesDir.create(recursive: true);
  final file = File(p.join(imagesDir.path, fileName));
  await file.writeAsBytes(bytes);
  return file.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('플롯 전용 형식(.mzplot)으로 내보낸 뒤 다시 가져오면 이미지 포함 전체 데이터가 새 플롯으로 복제된다', () async {
    final tempDir = Directory.systemTemp.createTempSync('microzed_plotdata_test_');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final plotRepo = PlotRepository(db);
    final characterRepo = CharacterRepository(db);
    final introRepo = IntroEntryRepository(db);
    final lorebookRepo = LorebookRepository(db);
    final plotProfileRepo = PlotConversationProfileRepository(db);

    final coverBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    final coverPath = await _writeFakeImage(tempDir.path, 'cover.png', coverBytes);
    final charBytes = Uint8List.fromList([9, 9, 9]);
    final charImagePath = await _writeFakeImage(tempDir.path, 'char.png', charBytes);

    final plotId = await plotRepo.upsertPlot(
      title: '원본 플롯',
      description: '원본 설명',
      shortIntro: '짧은 소개',
      hashtags: ['판타지', '학원물'],
      coverImagePath: coverPath,
    );
    final characterId = await characterRepo.add(
      plotId: plotId,
      name: '원본 캐릭터',
      description: '캐릭터 설명',
      imagePath: charImagePath,
      isRepresentative: true,
      aboutText: '상세 소개',
    );
    final versionId = await introRepo.ensureDefaultVersion(plotId);
    await introRepo.add(
      plotId: plotId,
      introVersionId: versionId,
      characterId: characterId,
      type: IntroEntryType.character,
      content: '첫 인사',
    );
    final altVersionId = await introRepo.addVersion(plotId);
    await introRepo.add(
      plotId: plotId,
      introVersionId: altVersionId,
      characterId: characterId,
      type: IntroEntryType.character,
      content: '대안 인사',
    );

    await plotProfileRepo.upsert(
      plotId: plotId,
      name: '전용 프로필',
      shortIntro: '한 줄 소개',
      description: '페르소나 설명',
    );

    final lorebookId = await lorebookRepo.upsert(title: '세계관북');
    final entryId = await lorebookRepo.addEntry(lorebookId);
    await lorebookRepo.updateEntry(id: entryId, title: '설정', keywords: '마을,광장', content: '마을 광장 설명.');
    await lorebookRepo.setLorebookLinksForPlot(plotId, {lorebookId});

    // 내보내기.
    final zipBytes = await PlotDataExporter(db).exportPlot(plotId);

    // 가져오기: 같은 DB에 '병합'되어야 한다(기존 플롯은 그대로 남고 새 플롯이 추가됨).
    final result = await PlotDataImporter(db).importFromBytes(zipBytes);
    expect(result.plotId, isNot(plotId));
    expect(result.characterCount, 1);
    expect(result.lorebookCount, 1);

    // 원본은 그대로 남아 있어야 한다(병합이지 교체가 아님).
    final originalStillThere = await plotRepo.getById(plotId);
    expect(originalStillThere, isNotNull);
    expect(originalStillThere!.title, '원본 플롯');

    final newPlot = await plotRepo.getById(result.plotId);
    expect(newPlot, isNotNull);
    expect(newPlot!.title, '원본 플롯');
    expect(newPlot.description, '원본 설명');
    expect(newPlot.hashtags, '판타지,학원물');
    expect(newPlot.coverImagePath, isNotNull);
    expect(newPlot.coverImagePath, isNot(coverPath)); // 새 파일로 저장되어 경로가 달라야 함
    expect(await File(newPlot.coverImagePath!).readAsBytes(), coverBytes);

    final newCharacters = await characterRepo.getByPlot(result.plotId);
    expect(newCharacters, hasLength(1));
    expect(newCharacters.first.name, '원본 캐릭터');
    expect(newCharacters.first.imagePath, isNot(charImagePath));
    expect(await File(newCharacters.first.imagePath!).readAsBytes(), charBytes);

    final newVersions = await introRepo.getVersions(result.plotId);
    expect(newVersions, hasLength(2));
    final firstEntries = await introRepo.getByVersion(newVersions[0].id);
    expect(firstEntries.single.content, '첫 인사');
    expect(firstEntries.single.characterId, newCharacters.first.id);
    final secondEntries = await introRepo.getByVersion(newVersions[1].id);
    expect(secondEntries.single.content, '대안 인사');

    final newProfiles = await plotProfileRepo.getByPlot(result.plotId);
    expect(newProfiles, hasLength(1));
    expect(newProfiles.first.name, '전용 프로필');
    expect(newProfiles.first.description, '페르소나 설명');

    final newLorebookIds = await lorebookRepo.linkedLorebookIds(result.plotId);
    expect(newLorebookIds, hasLength(1));
    final newLorebook = await lorebookRepo.getById(newLorebookIds.first);
    expect(newLorebook?.title, '세계관북');
    final newLorebookEntries = await lorebookRepo.getEntries(newLorebookIds.first);
    expect(newLorebookEntries.single.content, '마을 광장 설명.');

    // 원본 로어북 연결은 그대로, 새로 만든 로어북은 별개 레코드여야 한다(복제, 공유 아님).
    final originalLorebookIds = await lorebookRepo.linkedLorebookIds(plotId);
    expect(originalLorebookIds, {lorebookId});
    expect(newLorebookIds.first, isNot(lorebookId));
  });
}
