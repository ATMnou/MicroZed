import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../db/database.dart';
import '../repositories/conversation_profile_repository.dart';

class ConversationProfileExportException implements Exception {
  ConversationProfileExportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 마이페이지의 전역 대화 프로필 하나를 전용 zip 형식(`.mzprofile`)으로 내보낸다. [PlotDataExporter]와
/// 같은 구조(manifest.json + data.json + images/)를 쓴다. 플롯 전용 프로필은 이미 `.mzplot`에
/// 포함되어 내보내지므로 이 익스포터는 마이페이지의 전역 프로필(`ConversationProfiles`)만 다룬다.
class ConversationProfileExporter {
  ConversationProfileExporter(AppDatabase db) : _profileRepository = ConversationProfileRepository(db);

  final ConversationProfileRepository _profileRepository;

  static const _formatVersion = 1;

  Future<Uint8List> exportProfile(int profileId) async {
    final profile = await _profileRepository.getById(profileId);
    if (profile == null) {
      throw ConversationProfileExportException('대화 프로필을 찾을 수 없어요.');
    }

    final manifest = {
      'app': 'microzed',
      'kind': 'conversation_profile',
      'formatVersion': _formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'profileName': profile.name,
    };

    final archive = Archive();
    archive.addFile(ArchiveFile.string('manifest.json', jsonEncode(manifest)));
    archive.addFile(ArchiveFile.string('data.json', jsonEncode({'profile': profile.toJson()})));

    final imagePaths = <String>{
      if (profile.imagePath != null) profile.imagePath!,
      if (profile.vnStandingImagePath != null) profile.vnStandingImagePath!,
    };
    for (final path in imagePaths) {
      final file = File(path);
      if (!await file.exists()) continue;
      final bytes = await file.readAsBytes();
      archive.addFile(ArchiveFile('images/${p.basename(path)}', bytes.length, bytes));
    }

    return ZipEncoder().encodeBytes(archive);
  }
}
