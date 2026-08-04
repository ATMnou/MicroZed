import 'dart:convert';
import 'dart:typed_data';

import '../db/database.dart';

/// [LorebookEntry] 목록을 SillyTavern World Info JSON으로 직렬화한다.
/// `keywords`는 이 앱에서 콤마로 join해 저장하므로, 내보낼 때는 다시 배열로 나눈다.
class LorebookExporter {
  static Uint8List toWorldInfoJson(List<LorebookEntry> entries) {
    final entriesMap = <String, dynamic>{};
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final keys = entry.keywords.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
      entriesMap['$i'] = {
        'key': keys,
        'keysecondary': <String>[],
        'comment': entry.title,
        'content': entry.content,
        'constant': false,
        'selective': true,
        'order': entry.sortOrder,
        'position': 0,
        'disable': false,
      };
    }
    final json = {'entries': entriesMap};
    return Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(json)));
  }
}
