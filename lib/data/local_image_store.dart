import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 캐릭터/커버/대화 프로필 이미지를 앱 전용 저장 공간에 복사해서 보관한다.
/// 원본 파일이 임시 경로(모바일 갤러리 캐시 등)에 있어도 앱 재실행 후 깨지지 않도록
/// 고른 이미지를 항상 로컬로 복사한 뒤 그 경로를 반환한다.
class LocalImageStore {
  static const _imageTypeGroup = XTypeGroup(
    label: 'images',
    extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
  );

  /// 이미지를 선택해서 앱 저장 공간에 복사하고 새 경로를 반환한다. 취소하면 null.
  Future<String?> pickAndSave(String prefix) async {
    final picked = await openFile(acceptedTypeGroups: [_imageTypeGroup]);
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final dir = await getApplicationSupportDirectory();
    final imagesDir = Directory(p.join(dir.path, 'images'));
    await imagesDir.create(recursive: true);

    final ext = p.extension(picked.name).isEmpty ? '.png' : p.extension(picked.name);
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final savedFile = File(p.join(imagesDir.path, fileName));
    await savedFile.writeAsBytes(bytes);
    return savedFile.path;
  }
}
