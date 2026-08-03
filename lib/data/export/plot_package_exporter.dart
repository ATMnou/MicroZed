import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../db/database.dart';
import '../repositories/plot_repository.dart';
import 'plot_data_exporter.dart';

/// 제작 탭 톱니바퀴 > 다중 선택 > 내보내기가 쓰는, 여러 플롯을 한 번에 담는 전용 형식
/// (`.mzpack`). 기존 [PlotDataExporter]가 만드는 플롯 1개짜리 zip을 그대로 재사용해서,
/// `plots/plot_<i>/` 하위 경로에 통째로 다시 담기만 한다(zip 안에 zip을 넣는 게 아니라
/// 파일 경로에 접두어만 붙여서 하나의 zip으로 평탄화한다).
class PlotPackageExporter {
  PlotPackageExporter(AppDatabase db)
      : _plotDataExporter = PlotDataExporter(db),
        _plotRepository = PlotRepository(db);

  final PlotDataExporter _plotDataExporter;
  final PlotRepository _plotRepository;

  static const _formatVersion = 1;

  Future<Uint8List> exportPlots(List<int> plotIds) async {
    if (plotIds.isEmpty) {
      throw PlotDataExportException('내보낼 플롯을 선택해주세요.');
    }

    final outer = Archive();
    final titles = <String>[];
    for (var i = 0; i < plotIds.length; i++) {
      final plotBytes = await _plotDataExporter.exportPlot(plotIds[i]);
      final inner = ZipDecoder().decodeBytes(plotBytes);
      final plot = await _plotRepository.getById(plotIds[i]);
      titles.add(plot?.title ?? '');
      for (final file in inner) {
        if (!file.isFile) continue;
        outer.addFile(ArchiveFile('plots/plot_$i/${file.name}', file.content.length, file.content));
      }
    }

    final manifest = {
      'app': 'microzed',
      'kind': 'pack',
      'formatVersion': _formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'plotCount': plotIds.length,
      'plotTitles': titles,
    };
    outer.addFile(ArchiveFile.string('manifest.json', jsonEncode(manifest)));

    return ZipEncoder().encodeBytes(outer);
  }
}
