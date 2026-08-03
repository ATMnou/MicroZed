import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'backup/backup_service.dart';
import 'db/database.dart';

/// [LanSyncHost.start]가 돌려주는, 화면에 보여줄 접속 정보.
class LanSyncHostInfo {
  const LanSyncHostInfo({required this.addresses, required this.port, required this.pin});

  /// 같은 공유기에 물린 다른 기기에서 보이는 이 기기의 후보 IPv4 주소들(대개 1개).
  final List<String> addresses;
  final int port;
  final String pin;
}

/// LAN 동기화(내보내기 쪽). 임시 로컬 HTTP 서버를 열어서 [BackupService.exportAll] 결과를
/// PIN으로 보호된 `/export` 엔드포인트 하나로만 서빙한다. 1회 성공적으로 전송하거나
/// [stop]이 호출되면 서버를 닫는다 - 계속 켜두지 않아서 노출 시간을 최소화한다.
class LanSyncHost {
  LanSyncHost(this._db);

  final AppDatabase _db;
  HttpServer? _server;

  bool get isRunning => _server != null;

  Future<LanSyncHostInfo> start({void Function()? onExported, void Function(Object error)? onError}) async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _server = server;
    final pin = (100000 + Random.secure().nextInt(900000)).toString();

    server.listen((request) async {
      try {
        if (request.method != 'GET' || request.uri.path != '/export') {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          return;
        }
        // 응답마다 커넥션을 닫도록 강제한다. keep-alive로 소켓이 계속 열려 있으면 아래
        // stop()의 close(force: false)가 "아직 활성 연결이 있다"고 보고 영영 끝나지 않는다
        // (같은 요청 핸들러 안에서 자기 자신의 연결이 끝나기를 기다리는 셈이라 데드락과 같음).
        request.response.headers.set(HttpHeaders.connectionHeader, 'close');
        if (request.uri.queryParameters['pin'] != pin) {
          request.response.statusCode = HttpStatus.forbidden;
          await request.response.close();
          return;
        }
        final bytes = await BackupService(_db).exportAll();
        request.response.headers.contentType = ContentType('application', 'octet-stream');
        request.response.add(bytes);
        await request.response.close();
        onExported?.call();
      } catch (e) {
        onError?.call(e);
      } finally {
        // await하지 않는다: close(force: false)는 "지금 활성 연결이 모두 끝날 때까지" 기다리는데,
        // 지금 이 요청 핸들러 자신이 바로 그 활성 연결이라서 여기서 await하면 자기 자신을
        // 기다리는 데드락이 된다. 핸들러가 먼저 반환되게 두고 stop()은 그 뒤에 따로 진행시킨다.
        unawaited(stop());
      }
    });

    final addresses = await _localIPv4Addresses();
    return LanSyncHostInfo(addresses: addresses, port: server.port, pin: pin);
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    // force: false만 켜서 새 연결만 막는다. force: true는 지금 응답을 다 쓰기 전에 소켓을
    // 강제로 끊어버려서, 방금 보낸 export 응답이 클라이언트에 온전히 도착하기 전에
    // 커넥션이 끊기는 레이스 컨디션이 있었다(스모크 테스트로 확인됨).
    await server?.close(force: false);
  }

  Future<List<String>> _localIPv4Addresses() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    return interfaces.expand((i) => i.addresses).map((a) => a.address).toList();
  }
}

/// LAN 동기화(가져오기 쪽). 다른 기기가 [LanSyncHost]로 열어둔 주소/PIN을 입력받아
/// 전체 백업 바이트를 받아온다. 실제 DB 반영(전체 교체)은 호출부가 기존
/// [BackupService.restoreFromBytes]로 따로 처리한다.
class LanSyncClient {
  LanSyncClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  Future<Uint8List> fetch({required String host, required int port, required String pin}) async {
    final uri = Uri.http('$host:$port', '/export', {'pin': pin});
    final response = await _client.get(uri).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('LAN 동기화 요청이 실패했어요 (${response.statusCode}).');
    }
    return response.bodyBytes;
  }
}
