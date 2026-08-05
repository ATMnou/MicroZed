import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/export/plot_package_exporter.dart';
import '../data/import/character_card_parser.dart';
import '../data/import/character_card_source.dart';
import '../data/import/plot_data_importer.dart';
import '../data/import/plot_import_service.dart';
import '../data/import/plot_package_importer.dart';
import '../data/repositories/lorebook_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../l10n/app_localizations.dart';
import 'lorebook_detail_screen.dart';
import 'lorebook_edit_screen.dart';
import 'plot_ai_generate_screen.dart';
import 'plot_edit_screen.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// '제작' 탭 화면.
/// 플롯/로어북 탭 모두 실제 DB(Drift)에서 스트리밍한다.
class CreateTab extends StatefulWidget {
  const CreateTab({super.key});

  @override
  State<CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _textFaint => _p.textFaint;
  Color get _textPrimary => _p.textPrimary;
  Color get _textSecondary => _p.textSecondary;
  Color get _textGhost => _p.textGhost;
  Color get _danger => _p.danger;
  Color get _cardBg => _p.surface;
  Color get _borderGrey => _p.border;
  Color get _mutedText => _p.textMuted;
  Color get _purple => _p.primary;
  Color get _pillGrey => _p.surfaceAlt;
  late final PlotRepository _plotRepository;
  late final LorebookRepository _lorebookRepository;
  final _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';
  int _activeTab = 0;
  bool _importing = false;

  /// 톱니바퀴로 진입하는 다중 선택(체크박스) 모드. 플롯 탭에서만 쓴다.
  bool _selecting = false;
  final Set<int> _selectedPlotIds = {};
  bool _exportingPackage = false;

  @override
  void initState() {
    super.initState();
    _plotRepository = PlotRepository(AppDatabase.instance);
    _lorebookRepository = LorebookRepository(AppDatabase.instance);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlotSummary> _filterPlots(List<PlotSummary> plots) {
    if (_query.trim().isEmpty) return plots;
    final q = _query.trim().toLowerCase();
    return plots.where((p) {
      return p.plot.title.toLowerCase().contains(q) ||
          p.plot.description.toLowerCase().contains(q) ||
          p.plot.hashtags.toLowerCase().contains(q);
    }).toList();
  }

  List<LorebookSummary> _filterLorebooks(List<LorebookSummary> lorebooks) {
    if (_query.trim().isEmpty) return lorebooks;
    final q = _query.trim().toLowerCase();
    return lorebooks
        .where((l) => l.lorebook.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _buildTopTabs(),
            Expanded(
              child: _activeTab == 0 ? _buildPlotList() : _buildLorebookList(),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_activeTab == 0) ...[
                _buildAiGenerateButton(),
                const SizedBox(height: 12),
                _buildImportButton(),
                const SizedBox(height: 12),
              ],
              _buildCreateButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlotList() {
    return StreamBuilder<List<PlotSummary>>(
      stream: _plotRepository.watchAll(),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        final allPlots = snapshot.data ?? const [];
        final plots = _filterPlots(allPlots);
        return Column(
          children: [
            _buildSummaryRow(
              count: allPlots.length,
              total: l10n.conversationCountLabel(_totalConversations(allPlots)),
            ),
            Expanded(
              child: plots.isEmpty
                  ? Center(
                      child: Text(
                        _query.trim().isEmpty
                            ? l10n.homeNoPlotsYet
                            : l10n.commonNoSearchResults,
                        style: TextStyle(
                          color: _textFaint,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView(
                      children: plots
                          .map((p) => _PlotTile(
                                data: p,
                                selecting: _selecting,
                                selected: _selectedPlotIds.contains(p.plot.id),
                                onToggleSelected: () => setState(() {
                                  if (!_selectedPlotIds.add(p.plot.id)) {
                                    _selectedPlotIds.remove(p.plot.id);
                                  }
                                }),
                              ))
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLorebookList() {
    return StreamBuilder<List<LorebookSummary>>(
      stream: _lorebookRepository.watchAll(),
      builder: (context, snapshot) {
        final l10n = AppLocalizations.of(context)!;
        final allLorebooks = snapshot.data ?? const [];
        final lorebooks = _filterLorebooks(allLorebooks);
        final totalConversations = allLorebooks.fold<int>(
          0,
          (sum, l) => sum + l.conversationCount,
        );
        return Column(
          children: [
            _buildSummaryRow(
              count: allLorebooks.length,
              total: l10n.conversationCountLabel(totalConversations),
            ),
            Expanded(
              child: lorebooks.isEmpty
                  ? Center(
                      child: Text(
                        _query.trim().isEmpty
                            ? l10n.createTabNoLorebooksYet
                            : l10n.commonNoSearchResults,
                        style: TextStyle(
                          color: _textFaint,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        ...lorebooks.map((l) => _LorebookTile(data: l)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.createTabLorebookNote1,
                                style: TextStyle(
                                  color: _textFaint,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.createTabLorebookNote2,
                                style: TextStyle(
                                  color: _textFaint,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopTabs() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: _selecting
          ? Row(
              children: [
                Text(
                  l10n.createTabSelectedCount(_selectedPlotIds.length),
                  style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _selectedPlotIds.isEmpty || _exportingPackage ? null : _exportSelectedAsPackage,
                  icon: _exportingPackage
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: _textSecondary),
                        )
                      : Icon(
                          Icons.ios_share,
                          color: _selectedPlotIds.isEmpty ? _textGhost : _textPrimary,
                          size: 20,
                        ),
                ),
                IconButton(
                  onPressed: _selectedPlotIds.isEmpty ? null : _confirmDeleteSelectedPlots,
                  icon: Icon(
                    Icons.delete_outline,
                    color: _selectedPlotIds.isEmpty ? _textGhost : _danger,
                    size: 22,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _selecting = false;
                    _selectedPlotIds.clear();
                  }),
                  icon: Icon(Icons.close, color: _textPrimary, size: 22),
                ),
              ],
            )
          : _searching
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: _textPrimary, fontSize: 14),
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: _activeTab == 0
                          ? l10n.searchHintPlot
                          : l10n.searchHintLorebook,
                      hintStyle: TextStyle(
                        color: _textFaint,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: _cardBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() {
                    _searching = false;
                    _query = '';
                    _searchController.clear();
                  }),
                  child: Text(
                    l10n.commonCancel,
                    style: TextStyle(color: _textSecondary, fontSize: 14),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _activeTab = 0),
                  child: Text(
                    l10n.createTabPlotLabel,
                    style: TextStyle(
                      color: _activeTab == 0 ? _textPrimary : _textFaint,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => setState(() => _activeTab = 1),
                  child: Text(
                    l10n.createTabLorebookLabel,
                    style: TextStyle(
                      color: _activeTab == 1 ? _textPrimary : _textFaint,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _searching = true),
                  child: Icon(
                    Icons.manage_search,
                    color: _textPrimary,
                    size: 24,
                  ),
                ),
                if (_activeTab == 0) ...[
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => setState(() => _selecting = true),
                    child: Icon(
                      Icons.settings_outlined,
                      color: _textPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildSummaryRow({required int count, required String total}) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.totalCountLabel(count),
            style: TextStyle(color: _textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 12),
          Text(
            total,
            style: TextStyle(color: _textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _totalConversations(List<PlotSummary> plots) {
    final total = plots.fold<int>(0, (sum, p) => sum + p.conversationCount);
    return total.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
  }

  Widget _buildAiGenerateButton() {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PlotAiGenerateScreen()),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: _textPrimary,
        backgroundColor: _cardBg,
        side: BorderSide(color: _borderGrey),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      icon: const Icon(Icons.auto_awesome, size: 18),
      label: Text(
        l10n.createTabAiGenerateButton,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildImportButton() {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      onPressed: _importing ? null : _showImportSheet,
      style: OutlinedButton.styleFrom(
        foregroundColor: _textPrimary,
        backgroundColor: _cardBg,
        side: BorderSide(color: _borderGrey),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      icon: _importing
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _textSecondary,
              ),
            )
          : const Icon(Icons.file_download_outlined, size: 18),
      label: Text(
        l10n.createTabImportButton,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _showImportSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.createTabImportSheetTitle,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.folder_open_outlined,
                  color: _textPrimary,
                ),
                title: Text(
                  l10n.createTabImportFromFileTitle,
                  style: TextStyle(color: _textPrimary),
                ),
                subtitle: Text(
                  l10n.createTabImportFromFileSubtitle,
                  style: TextStyle(color: _textFaint, fontSize: 12),
                ),
                onTap: () => Navigator.of(sheetContext).pop('file'),
              ),
              ListTile(
                leading: Icon(Icons.link, color: _textPrimary),
                title: Text(
                  l10n.createTabImportFromUrlTitle,
                  style: TextStyle(color: _textPrimary),
                ),
                subtitle: Text(
                  l10n.createTabImportFromUrlSubtitle,
                  style: TextStyle(color: _textFaint, fontSize: 12),
                ),
                onTap: () => Navigator.of(sheetContext).pop('url'),
              ),
              ListTile(
                leading: Icon(Icons.archive_outlined, color: _textPrimary),
                title: Text(
                  l10n.createTabImportFromPlotDataTitle,
                  style: TextStyle(color: _textPrimary),
                ),
                subtitle: Text(
                  l10n.createTabImportFromPlotDataSubtitle,
                  style: TextStyle(color: _textFaint, fontSize: 12),
                ),
                onTap: () => Navigator.of(sheetContext).pop('plot_data'),
              ),
              ListTile(
                leading: Icon(Icons.inventory_2_outlined, color: _textPrimary),
                title: Text(
                  l10n.createTabImportFromPackageTitle,
                  style: TextStyle(color: _textPrimary),
                ),
                subtitle: Text(
                  l10n.createTabImportFromPackageSubtitle,
                  style: TextStyle(color: _textFaint, fontSize: 12),
                ),
                onTap: () => Navigator.of(sheetContext).pop('plot_pack'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (choice == 'file') {
      await _runImport(() => CharacterCardSource.pickFromFile());
    } else if (choice == 'url') {
      final url = await _askForUrl();
      if (url != null && url.trim().isNotEmpty) {
        await _runImport(() => CharacterCardSource.fetchFromUrl(url.trim()));
      }
    } else if (choice == 'plot_data') {
      await _runPlotDataImport();
    } else if (choice == 'plot_pack') {
      await _runPlotPackageImport();
    }
  }

  /// SillyTavern 카드가 아니라, 이 앱 전용 형식(.mzplot)으로 내보낸 플롯 전체(채팅 제외)를
  /// 가져온다.
  Future<void> _runPlotDataImport() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mzplot'],
    );
    if (result == null || result.files.isEmpty) return; // 취소됨
    final target = await _pickImportTargetPlot();
    if (target.cancelled) return;
    int? mergeLorebookId;
    if (target.plotId != null) {
      if (!mounted) return;
      mergeLorebookId = await _pickLorebookMergeTarget(target.plotId!);
    }
    setState(() => _importing = true);
    try {
      final bytes = await result.files.single.readAsBytes();
      final importResult = await PlotDataImporter(AppDatabase.instance).importFromBytes(
        bytes,
        targetPlotId: target.plotId,
        mergeLorebookId: mergeLorebookId,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlotEditScreen(plotId: importResult.plotId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createTabImportFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  /// 여러 플롯을 한 번에 담은 전용 패키지(.mzpack)를 가져온다. 성공하면 편집 화면으로
  /// 넘어가지 않고(플롯이 여러 개일 수 있어서) 목록에 몇 개가 추가됐는지만 알려준다.
  Future<void> _runPlotPackageImport() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mzpack'],
    );
    if (result == null || result.files.isEmpty) return; // 취소됨
    setState(() => _importing = true);
    try {
      final bytes = await result.files.single.readAsBytes();
      final importResult = await PlotPackageImporter(AppDatabase.instance).importFromBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createTabImportPackageSuccessMessage(importResult.plotCount))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createTabImportFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _confirmDeleteSelectedPlots() async {
    if (_selectedPlotIds.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          l10n.createTabDeleteSelectedConfirmTitle,
          style: TextStyle(color: _textPrimary),
        ),
        content: Text(
          l10n.createTabDeleteSelectedConfirmContent,
          style: TextStyle(color: _mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel, style: TextStyle(color: _mutedText)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDelete, style: TextStyle(color: _danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    for (final plotId in _selectedPlotIds) {
      await _plotRepository.deletePlot(plotId);
    }
    if (!mounted) return;
    setState(() {
      _selecting = false;
      _selectedPlotIds.clear();
    });
  }

  Future<void> _exportSelectedAsPackage() async {
    if (_selectedPlotIds.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _exportingPackage = true);
    try {
      final bytes = await PlotPackageExporter(AppDatabase.instance).exportPlots(_selectedPlotIds.toList());
      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final path = await FilePicker.saveFile(
        fileName: 'microzed_plots_$timestamp.mzpack',
        type: FileType.custom,
        allowedExtensions: const ['mzpack'],
        bytes: bytes,
      );
      if (path == null) return; // 취소됨
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createTabExportPackageSuccessMessage(_selectedPlotIds.length))),
      );
      setState(() {
        _selecting = false;
        _selectedPlotIds.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createTabExportPackageFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _exportingPackage = false);
    }
  }

  Future<String?> _askForUrl() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          l10n.createTabImportUrlDialogTitle,
          style: TextStyle(color: _textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: _textPrimary),
          decoration: InputDecoration(
            hintText: 'https://...',
            hintStyle: TextStyle(color: _textFaint),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _purple),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(color: _mutedText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(
              l10n.createTabImportConfirmButton,
              style: TextStyle(color: _purple),
            ),
          ),
        ],
      ),
    );
  }

  /// 새 플롯으로 만들지, 기존 플롯에 병합할지 고르는 시트. 취소하면 null, 새로 만들기면
  /// `plotId: null`, 기존 플롯을 골랐으면 그 plotId.
  Future<({bool cancelled, int? plotId})> _pickImportTargetPlot() async {
    final l10n = AppLocalizations.of(context)!;
    final plots = await _plotRepository.watchAll().first;
    if (!mounted) return (cancelled: true, plotId: null);
    final choice = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.createTabImportTargetSheetTitle,
                      style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.add_circle_outline, color: _textPrimary),
                  title: Text(l10n.createTabImportTargetNewPlot, style: TextStyle(color: _textPrimary)),
                  onTap: () => Navigator.of(sheetContext).pop(-1),
                ),
                Divider(color: _pillGrey, height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: plots.length,
                    itemBuilder: (context, index) {
                      final plot = plots[index].plot;
                      return ListTile(
                        title: Text(plot.title, style: TextStyle(color: _textPrimary)),
                        onTap: () => Navigator.of(sheetContext).pop(plot.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
    if (choice == null) return (cancelled: true, plotId: null);
    return (cancelled: false, plotId: choice == -1 ? null : choice);
  }

  /// 병합 대상 플롯에 이미 연결된 로어북이 있을 때만 부른다. 새로 만들기를 고르거나
  /// 시트를 그냥 닫으면 null(=새 로어북 생성)을 돌려준다.
  Future<int?> _pickLorebookMergeTarget(int plotId) async {
    final l10n = AppLocalizations.of(context)!;
    final linked = await _lorebookRepository.watchLinkedLorebooks(plotId).first;
    if (linked.isEmpty) return null;
    if (!mounted) return null;
    return showModalBottomSheet<int?>(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.createTabImportLorebookTargetSheetTitle,
                    style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.add_circle_outline, color: _textPrimary),
                title: Text(l10n.createTabImportLorebookTargetNew, style: TextStyle(color: _textPrimary)),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
              Divider(color: _pillGrey, height: 1),
              for (final lorebook in linked)
                ListTile(
                  title: Text(lorebook.title, style: TextStyle(color: _textPrimary)),
                  onTap: () => Navigator.of(sheetContext).pop(lorebook.id),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _runImport(
    Future<ParsedCharacterCard?> Function() loader,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _importing = true);
    try {
      final card = await loader();
      if (card == null) return; // 취소됨
      if (!mounted) return;
      final target = await _pickImportTargetPlot();
      if (target.cancelled) return;

      final PlotImportResult result;
      if (target.plotId == null) {
        result = await PlotImportService(AppDatabase.instance).importAsNewPlot(card);
      } else {
        int? mergeLorebookId;
        if (card.loreEntries.isNotEmpty) {
          if (!mounted) return;
          mergeLorebookId = await _pickLorebookMergeTarget(target.plotId!);
        }
        result = await PlotImportService(AppDatabase.instance).mergeIntoPlot(
          target.plotId!,
          card,
          mergeLorebookId: mergeLorebookId,
        );
      }
      if (!mounted) return;
      if (!result.hadIntro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.createTabNoIntroWarning),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlotEditScreen(plotId: result.plotId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.createTabImportFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Widget _buildCreateButton() {
    final l10n = AppLocalizations.of(context)!;
    return ElevatedButton.icon(
      onPressed: () {
        if (_activeTab == 0) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PlotEditScreen()));
        } else {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LorebookEditScreen()));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _purple,
        foregroundColor: _textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      icon: const Icon(Icons.add, size: 18),
      label: Text(
        l10n.createTabCreateButton,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PlotTile extends StatelessWidget {
  const _PlotTile({
    required this.data,
    this.selecting = false,
    this.selected = false,
    this.onToggleSelected,
  });

  final PlotSummary data;
  final bool selecting;
  final bool selected;
  final VoidCallback? onToggleSelected;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: PaletteScope.of(context).surface,
        title: Text(
          l10n.createTabDeletePlotConfirmTitle,
          style: TextStyle(color: PaletteScope.of(context).textPrimary),
        ),
        content: Text(
          l10n.createTabDeletePlotConfirmContent,
          style: TextStyle(color: PaletteScope.of(context).textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(color: PaletteScope.of(context).textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.commonDelete,
              style: TextStyle(color: PaletteScope.of(context).danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await PlotRepository(AppDatabase.instance).deletePlot(data.plot.id);
    }
  }

  void _showOptionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: PaletteScope.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit_outlined, color: PaletteScope.of(context).textPrimary),
                title: Text(
                  l10n.createTabEditPlotMenuItem,
                  style: TextStyle(color: PaletteScope.of(context).textPrimary),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlotEditScreen(plotId: data.plot.id),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: PaletteScope.of(context).textPrimary),
                title: Text(
                  l10n.commonDelete,
                  style: TextStyle(color: PaletteScope.of(context).textPrimary),
                ),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _confirmDelete(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selecting
          ? onToggleSelected
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlotEditScreen(plotId: data.plot.id),
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (selecting) ...[
              Checkbox(
                value: selected,
                onChanged: (_) => onToggleSelected?.call(),
                activeColor: PaletteScope.of(context).primary,
              ),
              const SizedBox(width: 4),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: data.plot.coverImagePath != null
                  ? Image.file(
                      File(data.plot.coverImagePath!),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 44,
                      height: 44,
                      color: PaletteScope.of(context).border,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.plot.title,
                    style: TextStyle(
                      color: PaletteScope.of(context).textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.conversationCountLabel(data.conversationCount),
                    style: TextStyle(color: PaletteScope.of(context).textFaint, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (!selecting)
              GestureDetector(
                onTap: () => _showOptionsMenu(context),
                child: Icon(
                  Icons.more_vert,
                  color: PaletteScope.of(context).textMuted,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LorebookTile extends StatelessWidget {
  const _LorebookTile({required this.data});

  final LorebookSummary data;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: PaletteScope.of(context).surface,
        title: Text(
          l10n.createTabDeleteLorebookConfirmTitle,
          style: TextStyle(color: PaletteScope.of(context).textPrimary),
        ),
        content: Text(
          l10n.createTabDeleteLorebookConfirmContent,
          style: TextStyle(color: PaletteScope.of(context).textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(color: PaletteScope.of(context).textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.commonDelete,
              style: TextStyle(color: PaletteScope.of(context).danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await LorebookRepository(AppDatabase.instance).delete(data.lorebook.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LorebookDetailScreen(lorebookId: data.lorebook.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.lorebook.title,
                    style: TextStyle(
                      color: PaletteScope.of(context).textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.lorebookTileStats(
                      data.conversationCount,
                      data.linkedPlotCount,
                    ),
                    style: TextStyle(color: PaletteScope.of(context).textFaint, fontSize: 13),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        LorebookEditScreen(lorebookId: data.lorebook.id),
                  ),
                );
              },
              child: Icon(
                Icons.edit_outlined,
                color: PaletteScope.of(context).textMuted,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => _confirmDelete(context),
              child: Icon(
                Icons.delete_outline,
                color: PaletteScope.of(context).textMuted,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
