import 'dart:io';

import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/import/character_card_parser.dart';
import '../data/import/character_card_source.dart';
import '../data/import/plot_import_service.dart';
import '../data/repositories/lorebook_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../l10n/app_localizations.dart';
import 'lorebook_detail_screen.dart';
import 'lorebook_edit_screen.dart';
import 'plot_edit_screen.dart';

/// '제작' 탭 화면.
/// 플롯/로어북 탭 모두 실제 DB(Drift)에서 스트리밍한다.
class CreateTab extends StatefulWidget {
  const CreateTab({super.key});

  @override
  State<CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  late final PlotRepository _plotRepository;
  late final LorebookRepository _lorebookRepository;
  final _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';
  int _activeTab = 0;
  bool _importing = false;

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
    return lorebooks.where((l) => l.lorebook.title.toLowerCase().contains(q)).toList();
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
            _buildSummaryRow(count: allPlots.length, total: l10n.conversationCountLabel(_totalConversations(allPlots))),
            Expanded(
              child: plots.isEmpty
                  ? Center(
                      child: Text(
                        _query.trim().isEmpty ? l10n.homeNoPlotsYet : l10n.commonNoSearchResults,
                        style: const TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    )
                  : ListView(children: plots.map((p) => _PlotTile(data: p)).toList()),
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
        final totalConversations = allLorebooks.fold<int>(0, (sum, l) => sum + l.conversationCount);
        return Column(
          children: [
            _buildSummaryRow(count: allLorebooks.length, total: l10n.conversationCountLabel(totalConversations)),
            Expanded(
              child: lorebooks.isEmpty
                  ? Center(
                      child: Text(
                        _query.trim().isEmpty ? l10n.createTabNoLorebooksYet : l10n.commonNoSearchResults,
                        style: const TextStyle(color: Colors.white38, fontSize: 13),
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
                                style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.createTabLorebookNote2,
                                style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
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
      child: _searching
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: _activeTab == 0 ? l10n.searchHintPlot : l10n.searchHintLorebook,
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
                      color: _activeTab == 0 ? Colors.white : Colors.white38,
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
                      color: _activeTab == 1 ? Colors.white : Colors.white38,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _searching = true),
                  child: const Icon(Icons.manage_search, color: Colors.white, size: 24),
                ),
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
          Text(l10n.totalCountLabel(count), style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(width: 12),
          Text(total, style: const TextStyle(color: Colors.white70, fontSize: 13)),
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

  Widget _buildImportButton() {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      onPressed: _importing ? null : _showImportSheet,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1E1E1E),
        side: const BorderSide(color: Color(0xFF3A3A3A)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      icon: _importing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
            )
          : const Icon(Icons.file_download_outlined, size: 18),
      label: Text(l10n.createTabImportButton, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _showImportSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
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
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder_open_outlined, color: Colors.white),
                title: Text(l10n.createTabImportFromFileTitle, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  l10n.createTabImportFromFileSubtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                onTap: () => Navigator.of(sheetContext).pop('file'),
              ),
              ListTile(
                leading: const Icon(Icons.link, color: Colors.white),
                title: Text(l10n.createTabImportFromUrlTitle, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  l10n.createTabImportFromUrlSubtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                onTap: () => Navigator.of(sheetContext).pop('url'),
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
    }
  }

  Future<String?> _askForUrl() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(l10n.createTabImportUrlDialogTitle, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'https://...',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF3A3A3A))),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7A6FF0))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(l10n.createTabImportConfirmButton, style: const TextStyle(color: Color(0xFF7A6FF0))),
          ),
        ],
      ),
    );
  }

  Future<void> _runImport(Future<ParsedCharacterCard?> Function() loader) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _importing = true);
    try {
      final card = await loader();
      if (card == null) return; // 취소됨
      final result = await PlotImportService(AppDatabase.instance).importAsNewPlot(card);
      if (!mounted) return;
      if (!result.hadIntro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.createTabNoIntroWarning),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlotEditScreen(plotId: result.plotId)));
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
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlotEditScreen()));
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LorebookEditScreen()));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7A6FF0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      icon: const Icon(Icons.add, size: 18),
      label: Text(l10n.createTabCreateButton, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }
}

class _PlotTile extends StatelessWidget {
  const _PlotTile({required this.data});

  final PlotSummary data;

  void _showOptionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.white),
                title: Text(l10n.createTabEditPlotMenuItem, style: const TextStyle(color: Colors.white)),
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
                leading: const Icon(Icons.delete_outline, color: Colors.white),
                title: Text(l10n.commonDelete, style: const TextStyle(color: Colors.white)),
                onTap: () async {
                  await PlotRepository(AppDatabase.instance).deletePlot(data.plot.id);
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PlotEditScreen(plotId: data.plot.id)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: data.plot.coverImagePath != null
                  ? Image.file(
                      File(data.plot.coverImagePath!),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    )
                  : Container(width: 44, height: 44, color: const Color(0xFF3A3A3A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.plot.title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.conversationCountLabel(data.conversationCount),
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showOptionsMenu(context),
              child: const Icon(Icons.more_vert, color: Colors.white54, size: 18),
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
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(l10n.createTabDeleteLorebookConfirmTitle, style: const TextStyle(color: Colors.white)),
        content: Text(l10n.createTabDeleteLorebookConfirmContent, style: const TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDelete, style: const TextStyle(color: Colors.redAccent)),
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
          MaterialPageRoute(builder: (_) => LorebookDetailScreen(lorebookId: data.lorebook.id)),
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
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.lorebookTileStats(data.conversationCount, data.linkedPlotCount),
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => LorebookEditScreen(lorebookId: data.lorebook.id)),
                );
              },
              child: const Icon(Icons.edit_outlined, color: Colors.white54, size: 18),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => _confirmDelete(context),
              child: const Icon(Icons.delete_outline, color: Colors.white54, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
