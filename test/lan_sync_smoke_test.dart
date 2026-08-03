import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:microzed/data/db/database.dart';
import 'package:microzed/data/lan_sync_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// BackupService.exportAll()이 실제 OS 채널 없이도 동작하도록(안 그러면 플랫폼 채널 응답을
/// 영원히 기다리며 행), 테스트별 임시 폴더를 돌려주는 가짜 path_provider 구현.
class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this._path);
  final String _path;
  @override
  Future<String?> getApplicationSupportPath() async => _path;
}

void main() {
  setUpAll(() {
    PathProviderPlatform.instance = _FakePathProviderPlatform(Directory.systemTemp.path);
  });

  test('LAN sync host serves one export then auto-stops, and rejects wrong PIN', () async {
    final tempPath = p.join(
      Directory.systemTemp.path,
      'microzed_lan_sync_smoke_${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    final file = File(tempPath);
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    final db = AppDatabase.forTesting(NativeDatabase(file));
    await db.into(db.plots).insert(
          PlotsCompanion.insert(title: 'Smoke Test Plot', description: 'desc'),
        );

    final host = LanSyncHost(db);
    var exported = false;
    final info = await host.start(onExported: () => exported = true);

    final client = LanSyncClient();
    final bytes = await client.fetch(host: '127.0.0.1', port: info.port, pin: info.pin);
    expect(bytes, isNotEmpty);

    await Future.delayed(const Duration(milliseconds: 100));
    expect(exported, isTrue);
    expect(host.isRunning, isFalse);

    // Server already auto-stopped after the single successful export, so a second
    // request (even with the right PIN) must fail - this proves the "1회성" behavior.
    await expectLater(
      LanSyncClient().fetch(host: '127.0.0.1', port: info.port, pin: info.pin),
      throwsA(anything),
    );

    await db.close();
  });

  test('LAN sync host rejects a wrong PIN with 403 instead of exporting', () async {
    final tempPath = p.join(
      Directory.systemTemp.path,
      'microzed_lan_sync_smoke2_${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    final file = File(tempPath);
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });

    final db = AppDatabase.forTesting(NativeDatabase(file));
    final host = LanSyncHost(db);
    var exported = false;
    final info = await host.start(onExported: () => exported = true);

    await expectLater(
      LanSyncClient().fetch(host: '127.0.0.1', port: info.port, pin: 'wrong-pin'),
      throwsA(anything),
    );
    expect(exported, isFalse);

    await host.stop();
    await db.close();
  });
}
