import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../db/database.dart';
import '../repositories/character_repository.dart';
import '../repositories/intro_entry_repository.dart';
import '../repositories/lorebook_repository.dart';
import '../repositories/plot_repository.dart';
import 'png_card_writer.dart';

class PlotExportException implements Exception {
  PlotExportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 이 앱의 플롯을 SillyTavern 호환 캐릭터 카드(chara_card_v2, PNG)로 내보낸다.
/// [PlotImportService]가 만든 매핑의 역방향에 해당한다.
class PlotCardExporter {
  PlotCardExporter(AppDatabase db)
      : _plotRepository = PlotRepository(db),
        _characterRepository = CharacterRepository(db),
        _introRepository = IntroEntryRepository(db),
        _lorebookRepository = LorebookRepository(db);

  final PlotRepository _plotRepository;
  final CharacterRepository _characterRepository;
  final IntroEntryRepository _introRepository;
  final LorebookRepository _lorebookRepository;

  Future<Uint8List> exportPlot(int plotId) async {
    final plot = await _plotRepository.getById(plotId);
    if (plot == null) {
      throw PlotExportException('플롯을 찾을 수 없어요.');
    }
    final characters = await _characterRepository.getByPlot(plotId);
    final representative = characters.isEmpty
        ? null
        : characters.firstWhere((c) => c.isRepresentative, orElse: () => characters.first);

    final versions = await _introRepository.getVersions(plotId);
    final greetings = <String>[];
    for (final version in versions) {
      final entries = await _introRepository.getByVersion(version.id);
      final text = entries
          .where((e) => e.type != IntroEntryType.image)
          .map((e) => e.content.trim())
          .where((c) => c.isNotEmpty)
          .join('\n\n');
      if (text.isNotEmpty) greetings.add(text);
    }

    final loreEntries = <Map<String, dynamic>>[];
    final lorebookIds = await _lorebookRepository.linkedLorebookIds(plotId);
    final lorebookTitles = <String>[];
    for (final lorebookId in lorebookIds) {
      final lorebook = await _lorebookRepository.getById(lorebookId);
      if (lorebook != null) lorebookTitles.add(lorebook.title);
      final entries = await _lorebookRepository.getEntries(lorebookId);
      for (final entry in entries) {
        if (entry.content.trim().isEmpty) continue;
        loreEntries.add({
          'keys': entry.keywords.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList(),
          'content': entry.content,
          'name': entry.title,
          'enabled': true,
        });
      }
    }

    final tags = plot.hashtags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final cardName = representative?.name ?? plot.title;
    final bookName = lorebookTitles.isEmpty ? '$cardName 세계관' : lorebookTitles.join(', ');

    final data = <String, dynamic>{
      'name': cardName,
      'description': representative?.description ?? '',
      'personality': '',
      'scenario': plot.description,
      'first_mes': greetings.isEmpty ? '' : greetings.first,
      'mes_example': '',
      'creator_notes': plot.shortIntro ?? '',
      'system_prompt': '',
      'post_history_instructions': '',
      'alternate_greetings': greetings.length > 1 ? greetings.sublist(1) : <String>[],
      'tags': tags,
      'creator': 'MicroZed',
      'character_version': '1.0',
      'extensions': <String, dynamic>{},
      if (loreEntries.isNotEmpty) 'character_book': {'name': bookName, 'entries': loreEntries},
    };

    final cardJson = {
      'spec': 'chara_card_v2',
      'spec_version': '2.0',
      'data': data,
    };
    final base64Json = base64.encode(utf8.encode(jsonEncode(cardJson)));

    final basePng = await _loadBasePng(representative?.imagePath ?? plot.coverImagePath);
    return PngCardWriter.embedTextChunk(basePng, 'chara', base64Json);
  }

  Future<Uint8List> _loadBasePng(String? imagePath) async {
    if (imagePath != null) {
      final file = File(imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (PngCardWriter.isPng(bytes)) return bytes;
      }
    }
    return PngCardWriter.generatePlaceholder();
  }
}
