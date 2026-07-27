import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'snapshot_settings_store.dart';

class ImageGenException implements Exception {
  ImageGenException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 스냅샷 기능이 쓰는 이미지 생성 클라이언트. 마이페이지 > 스냅샷 설정에서 고른
/// 엔드포인트(OpenRouter 또는 AtlasCloud)에 프롬프트를 보내고 생성된 이미지 바이트를 돌려준다.
class ImageGenClient {
  ImageGenClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  Future<Uint8List> generate({required SnapshotSettings settings, required String prompt}) {
    switch (settings.provider) {
      case SnapshotImageProvider.openRouter:
        return _generateOpenRouter(settings, prompt);
      case SnapshotImageProvider.atlasCloud:
        return _generateAtlasCloud(settings, prompt);
    }
  }

  /// OpenRouter 전용 `/api/v1/images` 엔드포인트는 seedream류의 전용 이미지 모델만
  /// 받아주고, 기본값인 Gemini(`google/gemini-2.5-flash-image`) 같은 채팅형 멀티모달
  /// 모델에 쓰면 401 "User not found"를 돌려준다. 그래서 이 모델들이 실제로 쓰이는 방식인
  /// 채팅 완성 엔드포인트 + `modalities: ["image", "text"]`로 요청한다.
  Future<Uint8List> _generateOpenRouter(SnapshotSettings settings, String prompt) async {
    final response = await _client.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${settings.apiKey}',
      },
      body: jsonEncode({
        'model': settings.modelName,
        'modalities': ['image', 'text'],
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ImageGenException('OpenRouter 이미지 생성에 실패했어요 (${response.statusCode}): ${response.body}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>?;
    final message =
        (choices != null && choices.isNotEmpty) ? (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>? : null;
    final images = message?['images'] as List<dynamic>?;
    final first = (images != null && images.isNotEmpty) ? images.first as Map<String, dynamic> : null;
    final dataUrl = (first?['image_url'] as Map<String, dynamic>?)?['url'] as String?;
    if (dataUrl == null || dataUrl.isEmpty) {
      throw ImageGenException('OpenRouter 응답에서 이미지 데이터를 찾을 수 없어요.');
    }
    final commaIndex = dataUrl.indexOf(',');
    final b64 = commaIndex == -1 ? dataUrl : dataUrl.substring(commaIndex + 1);
    return base64.decode(b64);
  }

  Future<Uint8List> _generateAtlasCloud(SnapshotSettings settings, String prompt) async {
    final createResponse = await _client.post(
      Uri.parse('https://api.atlascloud.ai/api/v1/model/generateImage'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${settings.apiKey}',
      },
      body: jsonEncode({'model': settings.modelName, 'prompt': prompt}),
    );
    if (createResponse.statusCode < 200 || createResponse.statusCode >= 300) {
      throw ImageGenException('AtlasCloud 이미지 생성에 실패했어요 (${createResponse.statusCode}): ${createResponse.body}');
    }
    final createJson = jsonDecode(createResponse.body) as Map<String, dynamic>;
    final predictionId = (createJson['data'] as Map<String, dynamic>?)?['id'] as String?;
    if (predictionId == null || predictionId.isEmpty) {
      throw ImageGenException('AtlasCloud가 예측 ID를 반환하지 않았어요.');
    }

    final deadline = DateTime.now().add(const Duration(seconds: 60));
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(seconds: 2));
      final pollResponse = await _client.get(
        Uri.parse('https://api.atlascloud.ai/api/v1/model/prediction/$predictionId'),
        headers: {'Authorization': 'Bearer ${settings.apiKey}'},
      );
      if (pollResponse.statusCode < 200 || pollResponse.statusCode >= 300) continue;
      final pollJson = jsonDecode(pollResponse.body) as Map<String, dynamic>;
      final data = pollJson['data'] as Map<String, dynamic>?;
      final status = data?['status'] as String?;
      if (status == 'completed') {
        final outputs = data?['outputs'] as List<dynamic>?;
        final imageUrl = (outputs != null && outputs.isNotEmpty) ? outputs.first as String : null;
        if (imageUrl == null || imageUrl.isEmpty) {
          throw ImageGenException('AtlasCloud 결과에서 이미지 URL을 찾을 수 없어요.');
        }
        final imageResponse = await _client.get(Uri.parse(imageUrl));
        if (imageResponse.statusCode < 200 || imageResponse.statusCode >= 300) {
          throw ImageGenException('생성된 이미지를 내려받지 못했어요.');
        }
        return imageResponse.bodyBytes;
      }
      if (status == 'failed' || status == 'error') {
        throw ImageGenException('AtlasCloud 이미지 생성이 실패했어요.');
      }
    }
    throw ImageGenException('AtlasCloud 이미지 생성이 시간 초과됐어요.');
  }
}
