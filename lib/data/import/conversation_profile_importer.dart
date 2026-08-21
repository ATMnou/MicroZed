import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../db/database.dart';
import '../local_image_store.dart';
import '../repositories/conversation_profile_repository.dart';

class ConversationProfileImportException implements Exception {
  ConversationProfileImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// [ConversationProfileExporter]가 만든 `.mzprofile` zip을 읽어 완전히 새로운 전역 대화
/// 프로필로 저장한다. [PlotDataImporter]와 마찬가지로 원본 id는 쓰지 않고 항상 새로 만든다.
class ConversationProfileImporter {
  ConversationProfileImporter(AppDatabase db)
      : _profileRepository = ConversationProfileRepository(db),
        _imageStore = LocalImageStore();

  final ConversationProfileRepository _profileRepository;
  final LocalImageStore _imageStore;

  Future<int> importFromBytes(Uint8List zipBytes) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } catch (_) {
      throw ConversationProfileImportException('zip 파일을 읽지 못했어요. 손상되었거나 올바른 파일이 아니에요.');
    }

    final manifestFile = archive.findFile('manifest.json');
    final dataFile = archive.findFile('data.json');
    if (manifestFile == null || dataFile == null) {
      throw ConversationProfileImportException('올바른 MicroZed 대화 프로필 파일이 아니에요.');
    }

    late final Map<String, dynamic> manifest;
    late final Map<String, dynamic> data;
    try {
      manifest = jsonDecode(utf8.decode(manifestFile.content)) as Map<String, dynamic>;
      data = jsonDecode(utf8.decode(dataFile.content)) as Map<String, dynamic>;
    } catch (_) {
      throw ConversationProfileImportException('파일 내용을 읽지 못했어요.');
    }
    if (manifest['app'] != 'microzed' || manifest['kind'] != 'conversation_profile') {
      throw ConversationProfileImportException('올바른 MicroZed 대화 프로필 파일이 아니에요.');
    }

    final imagePathByOriginalName = <String, String>{};
    var imageIndex = 0;
    for (final file in archive) {
      if (!file.isFile || !file.name.startsWith('images/')) continue;
      final originalName = file.name.substring('images/'.length);
      if (originalName.isEmpty) continue;
      final ext = p.extension(originalName);
      final savedPath = await _imageStore.saveBytes(
        'profileimport_${imageIndex++}',
        file.content,
        ext: ext.isEmpty ? '.png' : ext,
      );
      imagePathByOriginalName[originalName] = savedPath;
    }
    String? remapImage(String? originalPath) {
      if (originalPath == null || originalPath.isEmpty) return originalPath;
      return imagePathByOriginalName[p.basename(originalPath)] ?? originalPath;
    }

    final profileJson = data['profile'] as Map<String, dynamic>?;
    if (profileJson == null) {
      throw ConversationProfileImportException('대화 프로필 데이터가 없어요.');
    }

    return _profileRepository.upsert(
      name: profileJson['name'] as String? ?? '',
      description: profileJson['description'] as String? ?? '',
      imagePath: remapImage(profileJson['imagePath'] as String?),
      vnStandingImagePath: remapImage(profileJson['vnStandingImagePath'] as String?),
    );
  }
}
