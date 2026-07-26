import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/backup/backup_service.dart';
import 'package:microzed/data/db/database.dart';
import 'package:microzed/data/export/plot_card_exporter.dart';
import 'package:microzed/data/import/character_card_parser.dart';
import 'package:microzed/data/repositories/character_repository.dart';
import 'package:microzed/data/repositories/intro_entry_repository.dart';
import 'package:microzed/data/repositories/lorebook_repository.dart';
import 'package:microzed/data/repositories/plot_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// `getApplicationSupportDirectory()`가 실제 OS 채널 없이도 동작하도록, 테스트별 임시
/// 폴더를 돌려주는 가짜 path_provider 구현.
class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._path);

  final String _path;

  @override
  Future<String?> getApplicationSupportPath() async => _path;
}

Future<int> _seedSamplePlot(AppDatabase db) async {
  final plotRepository = PlotRepository(db);
  final characterRepository = CharacterRepository(db);
  final introRepository = IntroEntryRepository(db);
  final lorebookRepository = LorebookRepository(db);

  final plotId = await plotRepository.upsertPlot(
    title: '테스트 플롯',
    description: '테스트 시나리오',
    shortIntro: '짧은 소개',
    hashtags: ['테스트', '판타지'],
  );
  final characterId = await characterRepository.add(
    plotId: plotId,
    name: '테스트 캐릭터',
    description: '캐릭터 설명',
    isRepresentative: true,
    aboutText: '상세 소개',
  );
  final versionId = await introRepository.ensureDefaultVersion(plotId);
  await introRepository.add(
    plotId: plotId,
    introVersionId: versionId,
    characterId: characterId,
    type: IntroEntryType.character,
    content: '안녕, {{user}}!',
  );
  final altVersionId = await introRepository.addVersion(plotId);
  await introRepository.add(
    plotId: plotId,
    introVersionId: altVersionId,
    characterId: characterId,
    type: IntroEntryType.character,
    content: '다른 인사말이에요.',
  );

  final lorebookId = await lorebookRepository.upsert(title: '세계관북');
  final entryId = await lorebookRepository.addEntry(lorebookId);
  await lorebookRepository.updateEntry(id: entryId, title: '설정', keywords: '마을,광장', content: '마을 광장 설명.');
  await lorebookRepository.setLorebookLinksForPlot(plotId, {lorebookId});

  return plotId;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('플롯을 SillyTavern 카드로 내보내면 다시 파싱해도 내용이 일치한다', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final plotId = await _seedSamplePlot(db);
    final pngBytes = await PlotCardExporter(db).exportPlot(plotId);

    final parsed = CharacterCardParser.parsePng(pngBytes);
    expect(parsed.name, '테스트 캐릭터');
    expect(parsed.description, '캐릭터 설명');
    expect(parsed.scenario, '테스트 시나리오');
    expect(parsed.firstMessage, '안녕, {{user}}!');
    expect(parsed.alternateGreetings, ['다른 인사말이에요.']);
    expect(parsed.tags, ['테스트', '판타지']);
    expect(parsed.creatorNotes, '짧은 소개');
    expect(parsed.loreEntries, hasLength(1));
    expect(parsed.loreEntries.first.keys, ['마을', '광장']);
    expect(parsed.loreEntries.first.content, '마을 광장 설명.');
  });

  test('전체 백업을 내보낸 뒤 다른 DB/기기로 복원하면 데이터가 그대로 재현된다', () async {
    final tempDirA = Directory.systemTemp.createTempSync('microzed_test_a_');
    final tempDirB = Directory.systemTemp.createTempSync('microzed_test_b_');
    addTearDown(() {
      tempDirA.deleteSync(recursive: true);
      tempDirB.deleteSync(recursive: true);
    });

    final sourceDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(sourceDb.close);
    final plotId = await _seedSamplePlot(sourceDb);

    // 내보낼 때는 '기기 A'의 앱 지원 폴더를 가리키게 한다.
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDirA.path);
    final zipBytes = await BackupService(sourceDb).exportAll();

    final targetDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(targetDb.close);
    // 복원 전 대상 DB에 이미 있던 데이터는 전부 대체되어야 한다.
    await PlotRepository(targetDb).upsertPlot(title: '지워질 플롯', description: '지워짐');

    // 복원은 '기기 B'(다른 경로)에서 일어난다고 가정해, 경로 리매핑도 함께 검증한다.
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDirB.path);
    final summary = await BackupService(targetDb).restoreFromBytes(zipBytes);
    expect(summary.plotCount, 1);
    expect(summary.lorebookCount, 1);

    final restoredPlot = await PlotRepository(targetDb).getById(plotId);
    expect(restoredPlot, isNotNull);
    expect(restoredPlot!.title, '테스트 플롯');
    expect(restoredPlot.hashtags, '테스트,판타지');

    final restoredCharacters = await CharacterRepository(targetDb).getByPlot(plotId);
    expect(restoredCharacters, hasLength(1));
    expect(restoredCharacters.first.name, '테스트 캐릭터');
    expect(restoredCharacters.first.aboutText, '상세 소개');

    final allPlots = await targetDb.select(targetDb.plots).get();
    expect(allPlots, hasLength(1)); // 기존 '지워질 플롯'은 사라졌어야 한다

    final lorebooks = await LorebookRepository(targetDb).getById(
      (await targetDb.select(targetDb.lorebooks).get()).first.id,
    );
    expect(lorebooks?.title, '세계관북');
  });
}
