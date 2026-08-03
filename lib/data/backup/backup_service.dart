import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/database.dart';

class BackupException implements Exception {
  BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 복원 후 화면에 보여줄 간단한 요약.
class BackupRestoreSummary {
  const BackupRestoreSummary({
    required this.plotCount,
    required this.chatMessageCount,
    required this.lorebookCount,
  });

  final int plotCount;
  final int chatMessageCount;
  final int lorebookCount;
}

/// 앱의 모든 데이터를 하나의 zip 파일로 저장/복원한다.
///
/// 실제 sqlite 파일을 통째로 복사하는 대신, 모든 테이블을 JSON으로 직렬화해서 담는다
/// (드리프트가 각 테이블 데이터 클래스에 만들어주는 toJson/fromJson을 그대로 쓴다).
/// 이렇게 하면 살아있는 DB 커넥션이 파일 잠금을 잡고 있어도 안전하고, 복원도 앱을 새로
/// 켤 필요 없이 같은 커넥션으로 바로 반영된다(Drift의 watch 스트림이 자동으로 갱신됨).
///
/// zip 안에는 다음이 들어간다:
/// - manifest.json: 포맷/스키마 버전, 내보낸 시각, 내보낼 당시의 로컬 이미지 폴더 경로
/// - data.json: 모든 테이블의 모든 행
/// - images/*: 캐릭터/커버/대화 프로필 이미지 원본 파일
/// - secure/*: BYOK API 키가 암호화되어 있는 로컬 보안 저장소 파일(같은 Windows 계정의
///   같은 기기에서 복원할 때만 그대로 복호화된다. 다른 기기/계정이면 키는 무시되고 새로
///   등록하면 된다 - 앱이 알아서 무시하고 크래시하지 않는다)
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  static const _formatVersion = 1;

  Future<Uint8List> exportAll() async {
    final tables = <String, List<Map<String, dynamic>>>{
      'plots': (await _db.select(_db.plots).get()).map((r) => r.toJson()).toList(),
      'characters': (await _db.select(_db.characters).get()).map((r) => r.toJson()).toList(),
      'introVersions': (await _db.select(_db.introVersions).get()).map((r) => r.toJson()).toList(),
      'introEntries': (await _db.select(_db.introEntries).get()).map((r) => r.toJson()).toList(),
      'conversationProfiles': (await _db.select(_db.conversationProfiles).get()).map((r) => r.toJson()).toList(),
      'plotConversationProfiles':
          (await _db.select(_db.plotConversationProfiles).get()).map((r) => r.toJson()).toList(),
      'aiPresets': (await _db.select(_db.aiPresets).get()).map((r) => r.toJson()).toList(),
      'chatSessions': (await _db.select(_db.chatSessions).get()).map((r) => r.toJson()).toList(),
      'chatTurns': (await _db.select(_db.chatTurns).get()).map((r) => r.toJson()).toList(),
      'chatMessages': (await _db.select(_db.chatMessages).get()).map((r) => r.toJson()).toList(),
      'chatMemorySummaries': (await _db.select(_db.chatMemorySummaries).get()).map((r) => r.toJson()).toList(),
      'talkSessions': (await _db.select(_db.talkSessions).get()).map((r) => r.toJson()).toList(),
      'talkMessages': (await _db.select(_db.talkMessages).get()).map((r) => r.toJson()).toList(),
      'tokenUsageLogs': (await _db.select(_db.tokenUsageLogs).get()).map((r) => r.toJson()).toList(),
      'lorebooks': (await _db.select(_db.lorebooks).get()).map((r) => r.toJson()).toList(),
      'lorebookEntries': (await _db.select(_db.lorebookEntries).get()).map((r) => r.toJson()).toList(),
      'lorebookPlotLinks': (await _db.select(_db.lorebookPlotLinks).get()).map((r) => r.toJson()).toList(),
    };

    final appSupportDir = await getApplicationSupportDirectory();
    final imagesDir = Directory(p.join(appSupportDir.path, 'images'));

    final manifest = {
      'app': 'microzed',
      'formatVersion': _formatVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'imagesDir': imagesDir.path,
    };

    final archive = Archive();
    archive.addFile(ArchiveFile.string('manifest.json', jsonEncode(manifest)));
    archive.addFile(ArchiveFile.string('data.json', jsonEncode(tables)));

    if (await imagesDir.exists()) {
      await for (final entity in imagesDir.list()) {
        if (entity is File) {
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile('images/${p.basename(entity.path)}', bytes.length, bytes));
        }
      }
    }

    await for (final entity in appSupportDir.list()) {
      if (entity is File && p.basename(entity.path).startsWith('secure_')) {
        final bytes = await entity.readAsBytes();
        archive.addFile(ArchiveFile('secure/${p.basename(entity.path)}', bytes.length, bytes));
      }
    }

    return ZipEncoder().encodeBytes(archive);
  }

  /// 백업 zip을 읽어 현재 앱의 모든 데이터를 완전히 대체한다. 되돌릴 수 없으니 호출부에서
  /// 반드시 사용자에게 명확히 경고하고 확인을 받은 뒤에 불러야 한다.
  Future<BackupRestoreSummary> restoreFromBytes(Uint8List zipBytes) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } catch (_) {
      throw BackupException('zip 파일을 읽지 못했어요. 손상되었거나 올바른 백업 파일이 아니에요.');
    }

    final manifestFile = archive.findFile('manifest.json');
    final dataFile = archive.findFile('data.json');
    if (manifestFile == null || dataFile == null) {
      throw BackupException('올바른 MicroZed 백업 파일이 아니에요.');
    }

    late final Map<String, dynamic> manifest;
    late final Map<String, dynamic> data;
    try {
      manifest = jsonDecode(utf8.decode(manifestFile.content)) as Map<String, dynamic>;
      data = jsonDecode(utf8.decode(dataFile.content)) as Map<String, dynamic>;
    } catch (_) {
      throw BackupException('백업 파일 내용을 읽지 못했어요.');
    }

    final backupSchemaVersion = manifest['schemaVersion'] as int? ?? 0;
    if (backupSchemaVersion > _db.schemaVersion) {
      throw BackupException('이 백업은 더 최신 버전의 앱에서 만들어져서 지금 버전으로는 불러올 수 없어요. 앱을 업데이트한 뒤 다시 시도해주세요.');
    }

    List<Map<String, dynamic>> rowsFor(String key) => (data[key] as List? ?? const []).cast<Map<String, dynamic>>();

    final plotsJson = rowsFor('plots');
    final charactersJson = rowsFor('characters');
    final introVersionsJson = rowsFor('introVersions');
    final introEntriesJson = rowsFor('introEntries');
    final conversationProfilesJson = rowsFor('conversationProfiles');
    final plotConversationProfilesJson = rowsFor('plotConversationProfiles');
    final aiPresetsJson = rowsFor('aiPresets');
    final chatSessionsJson = rowsFor('chatSessions');
    final chatTurnsJson = rowsFor('chatTurns');
    final chatMessagesJson = rowsFor('chatMessages');
    final chatMemorySummariesJson = rowsFor('chatMemorySummaries');
    final talkSessionsJson = rowsFor('talkSessions');
    final talkMessagesJson = rowsFor('talkMessages');
    final tokenUsageLogsJson = rowsFor('tokenUsageLogs');
    final lorebooksJson = rowsFor('lorebooks');
    final lorebookEntriesJson = rowsFor('lorebookEntries');
    final lorebookPlotLinksJson = rowsFor('lorebookPlotLinks');

    final oldImagesDir = manifest['imagesDir'] as String? ?? '';
    final appSupportDir = await getApplicationSupportDirectory();
    final newImagesDir = p.join(appSupportDir.path, 'images');

    final imagesDirEntity = Directory(newImagesDir);
    if (await imagesDirEntity.exists()) {
      await imagesDirEntity.delete(recursive: true);
    }
    await imagesDirEntity.create(recursive: true);

    for (final file in archive) {
      if (!file.isFile) continue;
      if (file.name.startsWith('images/')) {
        final fileName = file.name.substring('images/'.length);
        if (fileName.isEmpty) continue;
        await File(p.join(newImagesDir, fileName)).writeAsBytes(file.content);
      } else if (file.name.startsWith('secure/')) {
        final fileName = file.name.substring('secure/'.length);
        if (fileName.isEmpty) continue;
        await File(p.join(appSupportDir.path, fileName)).writeAsBytes(file.content);
      }
    }

    String? remapPath(String? path) {
      if (path == null || oldImagesDir.isEmpty || !path.startsWith(oldImagesDir)) return path;
      return newImagesDir + path.substring(oldImagesDir.length);
    }

    await _db.transaction(() async {
      // 자식 -> 부모 순서로 기존 데이터를 모두 비운다.
      await _db.delete(_db.chatMessages).go();
      await _db.delete(_db.chatTurns).go();
      await _db.delete(_db.chatMemorySummaries).go();
      await _db.delete(_db.tokenUsageLogs).go();
      await _db.delete(_db.chatSessions).go();
      await _db.delete(_db.talkMessages).go();
      await _db.delete(_db.talkSessions).go();
      await _db.delete(_db.introEntries).go();
      await _db.delete(_db.introVersions).go();
      await _db.delete(_db.lorebookPlotLinks).go();
      await _db.delete(_db.lorebookEntries).go();
      await _db.delete(_db.lorebooks).go();
      await _db.delete(_db.characters).go();
      await _db.delete(_db.plotConversationProfiles).go();
      await _db.delete(_db.plots).go();
      await _db.delete(_db.conversationProfiles).go();
      await _db.delete(_db.aiPresets).go();

      // 부모 -> 자식 순서로 백업 당시의 id를 그대로 유지하며 복원한다.
      for (final json in plotsJson) {
        final row = Plot.fromJson(json);
        final remapped = row.copyWith(coverImagePath: Value(remapPath(row.coverImagePath)));
        await _db.into(_db.plots).insert(remapped, mode: InsertMode.insertOrReplace);
      }
      for (final json in charactersJson) {
        final row = Character.fromJson(json);
        final remapped = row.copyWith(imagePath: Value(remapPath(row.imagePath)));
        await _db.into(_db.characters).insert(remapped, mode: InsertMode.insertOrReplace);
      }
      for (final json in plotConversationProfilesJson) {
        final row = PlotConversationProfile.fromJson(json);
        final remapped = row.copyWith(imagePath: Value(remapPath(row.imagePath)));
        await _db.into(_db.plotConversationProfiles).insert(remapped, mode: InsertMode.insertOrReplace);
      }
      for (final json in introVersionsJson) {
        final row = IntroVersion.fromJson(json);
        await _db.into(_db.introVersions).insert(row, mode: InsertMode.insertOrReplace);
      }
      for (final json in introEntriesJson) {
        final row = IntroEntry.fromJson(json);
        final remapped = row.type == IntroEntryType.image
            ? row.copyWith(content: remapPath(row.content) ?? row.content)
            : row;
        await _db.into(_db.introEntries).insert(remapped, mode: InsertMode.insertOrReplace);
      }
      for (final json in conversationProfilesJson) {
        final row = ConversationProfile.fromJson(json);
        final remapped = row.copyWith(imagePath: Value(remapPath(row.imagePath)));
        await _db.into(_db.conversationProfiles).insert(remapped, mode: InsertMode.insertOrReplace);
      }
      for (final json in aiPresetsJson) {
        final row = AiPreset.fromJson(json);
        await _db.into(_db.aiPresets).insert(row, mode: InsertMode.insertOrReplace);
      }
      for (final json in chatSessionsJson) {
        final row = ChatSession.fromJson(json);
        await _db.into(_db.chatSessions).insert(row, mode: InsertMode.insertOrReplace);
      }
      for (final json in chatTurnsJson) {
        final row = ChatTurn.fromJson(json);
        await _db.into(_db.chatTurns).insert(row, mode: InsertMode.insertOrReplace);
      }
      for (final json in chatMessagesJson) {
        final row = ChatMessage.fromJson(json);
        final remapped = row.senderType == MessageSender.image
            ? row.copyWith(content: remapPath(row.content) ?? row.content)
            : row;
        await _db.into(_db.chatMessages).insert(remapped, mode: InsertMode.insertOrReplace);
      }
      for (final json in chatMemorySummariesJson) {
        final row = ChatMemorySummary.fromJson(json);
        await _db.into(_db.chatMemorySummaries).insert(row, mode: InsertMode.insertOrReplace);
      }
      for (final json in talkSessionsJson) {
        final row = TalkSession.fromJson(json);
        await _db.into(_db.talkSessions).insert(row, mode: InsertMode.insertOrReplace);
      }
      for (final json in talkMessagesJson) {
        final row = TalkMessage.fromJson(json);
        final remapped = row.attachmentType == TalkAttachmentType.image
            ? row.copyWith(attachmentPath: Value(remapPath(row.attachmentPath)))
            : row;
        await _db.into(_db.talkMessages).insert(remapped, mode: InsertMode.insertOrReplace);
      }
      for (final json in tokenUsageLogsJson) {
        final row = TokenUsageLog.fromJson(json);
        await _db.into(_db.tokenUsageLogs).insert(row, mode: InsertMode.insertOrReplace);
      }
      for (final json in lorebooksJson) {
        final row = Lorebook.fromJson(json);
        await _db.into(_db.lorebooks).insert(row, mode: InsertMode.insertOrReplace);
      }
      for (final json in lorebookEntriesJson) {
        final row = LorebookEntry.fromJson(json);
        await _db.into(_db.lorebookEntries).insert(row, mode: InsertMode.insertOrReplace);
      }
      for (final json in lorebookPlotLinksJson) {
        final row = LorebookPlotLink.fromJson(json);
        await _db.into(_db.lorebookPlotLinks).insert(row, mode: InsertMode.insertOrReplace);
      }
    });

    return BackupRestoreSummary(
      plotCount: plotsJson.length,
      chatMessageCount: chatMessagesJson.length,
      lorebookCount: lorebooksJson.length,
    );
  }

  /// 마이페이지 > 환경설정 > '전체 초기화'가 호출한다. 모든 테이블을 비우고, 저장해둔
  /// 이미지/보안 저장소 파일까지 지워서 앱을 첫 설치 상태로 되돌린다. 되돌릴 수 없으니
  /// 호출부에서 반드시 사용자에게 명확히 경고하고 확인을 받은 뒤에 불러야 한다.
  /// 다운로드해둔 로컬 LLM 모델 캐시는 용량이 크고 다시 받으려면 시간이 걸려서 지우지 않는다.
  Future<void> resetAll() async {
    await _db.transaction(() async {
      // 자식 -> 부모 순서로 모든 데이터를 비운다(restoreFromBytes와 같은 순서).
      await _db.delete(_db.chatMessages).go();
      await _db.delete(_db.chatTurns).go();
      await _db.delete(_db.tokenUsageLogs).go();
      await _db.delete(_db.chatSessions).go();
      await _db.delete(_db.introEntries).go();
      await _db.delete(_db.introVersions).go();
      await _db.delete(_db.lorebookPlotLinks).go();
      await _db.delete(_db.lorebookEntries).go();
      await _db.delete(_db.lorebooks).go();
      await _db.delete(_db.characters).go();
      await _db.delete(_db.plotConversationProfiles).go();
      await _db.delete(_db.plots).go();
      await _db.delete(_db.conversationProfiles).go();
      await _db.delete(_db.aiPresets).go();
    });

    final appSupportDir = await getApplicationSupportDirectory();
    final imagesDir = Directory(p.join(appSupportDir.path, 'images'));
    if (await imagesDir.exists()) {
      await imagesDir.delete(recursive: true);
    }
    await for (final entity in appSupportDir.list()) {
      if (entity is File && p.basename(entity.path).startsWith('secure_')) {
        await entity.delete();
      }
    }
  }
}
