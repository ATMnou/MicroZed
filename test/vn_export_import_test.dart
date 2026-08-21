import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/backup/backup_service.dart';
import 'package:microzed/data/db/database.dart';
import 'package:microzed/data/export/plot_data_exporter.dart';
import 'package:microzed/data/import/plot_data_importer.dart';
import 'package:microzed/data/repositories/character_repository.dart';
import 'package:microzed/data/repositories/intro_entry_repository.dart';
import 'package:microzed/data/repositories/plot_repository.dart';
import 'package:microzed/data/repositories/vn_background_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// `getApplicationSupportDirectory()`가 실제 OS 채널 없이도 동작하도록, 테스트별 임시
/// 폴더를 돌려주는 가짜 path_provider 구현.
class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._path);

  final String _path;

  @override
  Future<String?> getApplicationSupportPath() async => _path;
}

Future<String> _writeFakeImage(String appSupportPath, String fileName, List<int> bytes) async {
  final imagesDir = Directory(p.join(appSupportPath, 'images'));
  await imagesDir.create(recursive: true);
  final file = File(p.join(imagesDir.path, fileName));
  await file.writeAsBytes(bytes);
  return file.path;
}

/// 배경/캐릭터 표정/선택지/플레이어블 캐릭터/씬 연출 정보를 모두 가진 비주얼 노벨 플롯을
/// 하나 만들어서 돌려준다.
Future<({int plotId, int backgroundId, int characterId})> _seedVnPlot(
  AppDatabase db,
  String appSupportPath,
) async {
  final plotRepo = PlotRepository(db);
  final characterRepo = CharacterRepository(db);
  final introRepo = IntroEntryRepository(db);
  final backgroundRepo = VnBackgroundRepository(db);

  final plotId = await plotRepo.upsertPlot(
    title: 'VN 플롯',
    description: 'VN 설명',
    plotType: PlotType.visualNovel,
  );
  await plotRepo.updateVnPlaySettings(
    plotId: plotId,
    vnInputMode: VnInputMode.freeText,
    vnAiInputAssist: true,
    vnDiceEnabled: false,
  );

  final bgPath = await _writeFakeImage(appSupportPath, 'bg.png', Uint8List.fromList([1, 1, 1]));
  final backgroundId = await backgroundRepo.add(plotId: plotId, title: '교실', imagePath: bgPath);

  final characterId = await characterRepo.add(
    plotId: plotId,
    name: '주인공',
    isPlayable: true,
    spriteScale: 1.25,
    spriteOffsetX: 0.1,
    spriteOffsetY: -0.2,
  );
  final expressionPath = await _writeFakeImage(appSupportPath, 'joy.png', Uint8List.fromList([2, 2, 2]));
  await characterRepo.setExpressionImage(characterId: characterId, emotion: VnEmotion.joy, imagePath: expressionPath);

  final versionId = await introRepo.ensureDefaultVersion(plotId);
  await introRepo.add(
    plotId: plotId,
    introVersionId: versionId,
    characterId: characterId,
    type: IntroEntryType.character,
    content: '교실에서의 첫 만남',
    vnBackgroundId: backgroundId,
    vnExpression: VnEmotion.joy,
    vnSceneType: VnSceneType.dialogue,
  );
  await introRepo.addChoice(
    introVersionId: versionId,
    content: '말을 건다',
    useDice: true,
    difficulty: VnDiceDifficulty.hard,
  );

  return (plotId: plotId, backgroundId: backgroundId, characterId: characterId);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('.mzplot으로 내보낸 비주얼 노벨 플롯을 가져오면 VN 전용 데이터가 그대로 복제된다', () async {
    final tempDir = Directory.systemTemp.createTempSync('microzed_vn_mzplot_test_');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final seed = await _seedVnPlot(db, tempDir.path);

    final zipBytes = await PlotDataExporter(db).exportPlot(seed.plotId);
    final result = await PlotDataImporter(db).importFromBytes(zipBytes);
    expect(result.plotId, isNot(seed.plotId));

    final plotRepo = PlotRepository(db);
    final newPlot = await plotRepo.getById(result.plotId);
    expect(newPlot, isNotNull);
    expect(newPlot!.plotType, PlotType.visualNovel); // 가장 흔했던 회귀: storyChat으로 바뀌던 문제
    expect(newPlot.vnInputMode, VnInputMode.freeText);
    expect(newPlot.vnAiInputAssist, isTrue);
    expect(newPlot.vnDiceEnabled, isFalse);

    final characterRepo = CharacterRepository(db);
    final newCharacters = await characterRepo.getByPlot(result.plotId);
    expect(newCharacters, hasLength(1));
    final newCharacter = newCharacters.single;
    expect(newCharacter.isPlayable, isTrue);
    expect(newCharacter.spriteScale, 1.25);
    expect(newCharacter.spriteOffsetX, 0.1);
    expect(newCharacter.spriteOffsetY, -0.2);

    final newExpressions = await characterRepo.getExpressions(newCharacter.id);
    expect(newExpressions, hasLength(1));
    expect(newExpressions.single.emotion, VnEmotion.joy);
    expect(await File(newExpressions.single.imagePath).readAsBytes(), [2, 2, 2]);

    final backgroundRepo = VnBackgroundRepository(db);
    final newBackgrounds = await backgroundRepo.getByPlot(result.plotId);
    expect(newBackgrounds, hasLength(1));
    expect(newBackgrounds.single.title, '교실');
    expect(await File(newBackgrounds.single.imagePath).readAsBytes(), [1, 1, 1]);

    final introRepo = IntroEntryRepository(db);
    final newVersions = await introRepo.getVersions(result.plotId);
    expect(newVersions, hasLength(1));
    final newEntries = await introRepo.getByVersion(newVersions.single.id);
    // 플레이어블 캐릭터가 복원되었으므로 characterPick 마커가 자동으로 하나 붙고,
    // 원본의 대사 엔트리가 뒤따라야 한다 - 중복 마커가 생기면 안 된다.
    expect(newEntries.where((e) => e.type == IntroEntryType.characterPick), hasLength(1));
    final dialogueEntry = newEntries.singleWhere((e) => e.type == IntroEntryType.character);
    expect(dialogueEntry.content, '교실에서의 첫 만남');
    expect(dialogueEntry.vnBackgroundId, newBackgrounds.single.id);
    expect(dialogueEntry.vnExpression, VnEmotion.joy);
    expect(dialogueEntry.vnSceneType, VnSceneType.dialogue);

    final newChoices = await introRepo.getChoices(newVersions.single.id);
    expect(newChoices, hasLength(1));
    expect(newChoices.single.content, '말을 건다');
    expect(newChoices.single.useDice, isTrue);
    expect(newChoices.single.difficulty, VnDiceDifficulty.hard);
  });

  test('전체 백업을 내보낸 뒤 복원하면 비주얼 노벨 전용 데이터가 함께 재현된다', () async {
    final tempDirA = Directory.systemTemp.createTempSync('microzed_vn_backup_a_');
    final tempDirB = Directory.systemTemp.createTempSync('microzed_vn_backup_b_');
    addTearDown(() {
      tempDirA.deleteSync(recursive: true);
      tempDirB.deleteSync(recursive: true);
    });

    final sourceDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(sourceDb.close);
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDirA.path);
    final seed = await _seedVnPlot(sourceDb, tempDirA.path);

    final zipBytes = await BackupService(sourceDb).exportAll();

    final targetDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(targetDb.close);
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDirB.path);
    await BackupService(targetDb).restoreFromBytes(zipBytes);

    final restoredPlot = await PlotRepository(targetDb).getById(seed.plotId);
    expect(restoredPlot, isNotNull);
    expect(restoredPlot!.plotType, PlotType.visualNovel);
    expect(restoredPlot.vnInputMode, VnInputMode.freeText);

    final characterRepo = CharacterRepository(targetDb);
    final restoredCharacters = await characterRepo.getByPlot(seed.plotId);
    expect(restoredCharacters, hasLength(1));
    expect(restoredCharacters.single.isPlayable, isTrue);

    final restoredExpressions = await characterRepo.getExpressions(seed.characterId);
    expect(restoredExpressions, hasLength(1));
    expect(restoredExpressions.single.emotion, VnEmotion.joy);
    expect(await File(restoredExpressions.single.imagePath).readAsBytes(), [2, 2, 2]);

    final backgroundRepo = VnBackgroundRepository(targetDb);
    final restoredBackgrounds = await backgroundRepo.getByPlot(seed.plotId);
    expect(restoredBackgrounds, hasLength(1));
    expect(restoredBackgrounds.single.id, seed.backgroundId);
    expect(await File(restoredBackgrounds.single.imagePath).readAsBytes(), [1, 1, 1]);

    final introRepo = IntroEntryRepository(targetDb);
    final versions = await introRepo.getVersions(seed.plotId);
    final choices = await introRepo.getChoices(versions.single.id);
    expect(choices, hasLength(1));
    expect(choices.single.content, '말을 건다');
    expect(choices.single.difficulty, VnDiceDifficulty.hard);
  });
}
