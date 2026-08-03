import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/db/database.dart';
import 'package:microzed/data/export/plot_package_exporter.dart';
import 'package:microzed/data/import/plot_package_importer.dart';
import 'package:microzed/data/repositories/character_repository.dart';
import 'package:microzed/data/repositories/plot_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('여러 플롯을 .mzpack으로 내보낸 뒤 다시 가져오면 각 플롯이 이미지 포함 그대로 복제된다', () async {
    final tempDir = Directory.systemTemp.createTempSync('microzed_plotpack_test_');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final plotRepo = PlotRepository(db);
    final characterRepo = CharacterRepository(db);

    final coverBytesA = Uint8List.fromList([1, 2, 3]);
    final coverPathA = await _writeFakeImage(tempDir.path, 'a.png', coverBytesA);
    final plotIdA = await plotRepo.upsertPlot(
      title: '플롯 A',
      description: '설명 A',
      coverImagePath: coverPathA,
    );
    await characterRepo.add(plotId: plotIdA, name: '캐릭터 A', isRepresentative: true);

    final plotIdB = await plotRepo.upsertPlot(title: '플롯 B', description: '설명 B');
    await characterRepo.add(plotId: plotIdB, name: '캐릭터 B', isRepresentative: true);

    final packBytes = await PlotPackageExporter(db).exportPlots([plotIdA, plotIdB]);

    final result = await PlotPackageImporter(db).importFromBytes(packBytes);
    expect(result.plotCount, 2);

    final importedTitles = <String>{};
    for (final plotResult in result.plotResults) {
      final plot = await plotRepo.getById(plotResult.plotId);
      expect(plot, isNotNull);
      importedTitles.add(plot!.title);
      expect(plotResult.characterCount, 1);
    }
    expect(importedTitles, {'플롯 A', '플롯 B'});

    // 이미지가 있던 플롯 A는 이미지도 같이 복제되어야 한다.
    final aPlot = (await Future.wait(result.plotResults.map((r) => plotRepo.getById(r.plotId))))
        .whereType<Plot>()
        .firstWhere((p) => p.title == '플롯 A');
    expect(aPlot.coverImagePath, isNotNull);
    expect(aPlot.coverImagePath, isNot(coverPathA));
    expect(await File(aPlot.coverImagePath!).readAsBytes(), coverBytesA);

    // 원본 플롯들은 그대로 남아 있어야 한다(병합이지 교체가 아님).
    expect(await plotRepo.getById(plotIdA), isNotNull);
    expect(await plotRepo.getById(plotIdB), isNotNull);
  });

  test('app/kind가 올바르지 않은 zip은 거부한다', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await expectLater(
      PlotPackageImporter(db).importFromBytes(Uint8List.fromList([0, 1, 2])),
      throwsA(anything),
    );
  });
}
