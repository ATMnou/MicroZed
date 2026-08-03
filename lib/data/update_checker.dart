import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// GitHub Releases 기준 최신 버전 확인 결과.
///
/// 원스토어(앱 ID 1007910)는 공식적으로 공개된 버전 조회 API가 없어서(상품 페이지를
/// 긁는 방식은 페이지 구조가 바뀌면 예고 없이 깨진다) 여기서는 다루지 않는다. 원스토어
/// 업데이트 확인이 꼭 필요하면 원스토어 개발자 콘솔에서 공식적으로 제공하는 방법이
/// 생겼을 때 별도로 추가하는 게 안전하다.
class UpdateCheckResult {
  const UpdateCheckResult({
    required this.currentVersion,
    this.latestVersion,
    this.releaseUrl,
    this.updateAvailable = false,
    this.checkFailed = false,
  });

  final String currentVersion;
  final String? latestVersion;
  final String? releaseUrl;
  final bool updateAvailable;
  final bool checkFailed;
}

class UpdateChecker {
  UpdateChecker({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  static const _githubReleasesUrl =
      'https://api.github.com/repos/ATMnou/MicroZed/releases/latest';

  Future<UpdateCheckResult> check() async {
    final info = await PackageInfo.fromPlatform();
    final current = info.version;
    try {
      final response = await _client
          .get(
            Uri.parse(_githubReleasesUrl),
            headers: const {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        return UpdateCheckResult(currentVersion: current, checkFailed: true);
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final tag = (json['tag_name'] as String?) ?? '';
      final latest = tag.startsWith('v') ? tag.substring(1) : tag;
      if (latest.isEmpty) {
        return UpdateCheckResult(currentVersion: current, checkFailed: true);
      }
      return UpdateCheckResult(
        currentVersion: current,
        latestVersion: latest,
        releaseUrl: json['html_url'] as String?,
        updateAvailable: _isNewer(latest, current),
      );
    } catch (_) {
      return UpdateCheckResult(currentVersion: current, checkFailed: true);
    }
  }

  /// 세미버전 문자열(major.minor.patch) 비교. [a]가 [b]보다 최신이면 true.
  /// 형식을 못 읽으면(숫자가 아닌 부분은 0 취급) 보수적으로 false를 준다.
  bool _isNewer(String a, String b) {
    List<int> parts(String v) =>
        v.split('+').first.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final pa = parts(a);
    final pb = parts(b);
    for (var i = 0; i < 3; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va != vb) return va > vb;
    }
    return false;
  }
}
