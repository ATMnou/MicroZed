import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../db/database.dart';
import 'plot_data_importer.dart';

/// [PlotPackageImporter.importFromBytes]의 결과. 패키지 안의 플롯마다 하나씩 담긴다.
class PlotPackageImportResult {
  const PlotPackageImportResult({required this.plotResults});

  final List<PlotDataImportResult> plotResults;

  int get plotCount => plotResults.length;
}

/// [PlotPackageExporter]가 만든 `.mzpack`(여러 플롯 묶음)을 읽어 플롯마다 새로운 플롯으로
/// 가져온다. `plots/plot_<i>/` 접두어로 묶인 파일들을 플롯 단위 서브 아카이브로 다시 잘라서,
/// 기존 [PlotDataImporter.importArchive]를 그대로 재사용한다.
class PlotPackageImporter {
  PlotPackageImporter(AppDatabase db) : _plotDataImporter = PlotDataImporter(db);

  final PlotDataImporter _plotDataImporter;

  static final _prefixPattern = RegExp(r'^plots/plot_(\d+)/(.+)$');

  Future<PlotPackageImportResult> importFromBytes(Uint8List zipBytes) async {
    final Archive outer;
    try {
      outer = ZipDecoder().decodeBytes(zipBytes);
    } catch (_) {
      throw PlotDataImportException('zip 파일을 읽지 못했어요. 손상되었거나 올바른 파일이 아니에요.');
    }

    final manifestFile = outer.findFile('manifest.json');
    if (manifestFile == null) {
      throw PlotDataImportException('올바른 MicroZed 플롯 패키지 파일이 아니에요.');
    }
    late final Map<String, dynamic> manifest;
    try {
      manifest = jsonDecode(utf8.decode(manifestFile.content)) as Map<String, dynamic>;
    } catch (_) {
      throw PlotDataImportException('파일 내용을 읽지 못했어요.');
    }
    if (manifest['app'] != 'microzed' || manifest['kind'] != 'pack') {
      throw PlotDataImportException('올바른 MicroZed 플롯 패키지 파일이 아니에요.');
    }

    final byIndex = <int, List<ArchiveFile>>{};
    for (final file in outer) {
      if (!file.isFile) continue;
      final match = _prefixPattern.firstMatch(file.name);
      if (match == null) continue;
      final index = int.parse(match.group(1)!);
      final innerName = match.group(2)!;
      (byIndex[index] ??= []).add(ArchiveFile(innerName, file.content.length, file.content));
    }
    if (byIndex.isEmpty) {
      throw PlotDataImportException('패키지 안에 플롯이 없어요.');
    }

    final results = <PlotDataImportResult>[];
    for (final index in byIndex.keys.toList()..sort()) {
      final subArchive = Archive();
      for (final file in byIndex[index]!) {
        subArchive.addFile(file);
      }
      results.add(await _plotDataImporter.importArchive(subArchive));
    }

    return PlotPackageImportResult(plotResults: results);
  }
}
