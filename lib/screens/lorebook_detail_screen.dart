import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/lorebook_repository.dart';
import '../l10n/app_localizations.dart';
import 'lorebook_edit_screen.dart';
import 'lorebook_plot_picker_screen.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 제작 탭에서 로어북 행을 그냥 누르면(수정/삭제 아님) 나오는 보기 전용 화면.
class LorebookDetailScreen extends StatefulWidget {
  const LorebookDetailScreen({super.key, required this.lorebookId});

  final int lorebookId;

  @override
  State<LorebookDetailScreen> createState() => _LorebookDetailScreenState();
}

class _LorebookDetailScreenState extends State<LorebookDetailScreen> with SingleTickerProviderStateMixin {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _cardBg => _p.surface;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _mutedText => _p.textMuted;
  Color get _danger => _p.danger;
  Color get _textFaint => _p.textFaint;
  Color get _pillGrey => _p.surfaceAlt;
  Color get _textSecondary => _p.textSecondary;
  late final TabController _tabController;
  late final LorebookRepository _repository;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repository = LorebookRepository(AppDatabase.instance);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(l10n.createTabDeleteLorebookConfirmTitle, style: TextStyle(color: _textPrimary)),
        content: Text(l10n.createTabDeleteLorebookConfirmContent, style: TextStyle(color: _mutedText)),
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
    if (confirmed == true) {
      await _repository.delete(widget.lorebookId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: FutureBuilder<Lorebook?>(
          future: _repository.getById(widget.lorebookId),
          builder: (context, snapshot) {
            final lorebook = snapshot.data;
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(color: _purple));
            }
            if (lorebook == null) {
              return Center(
                child: Text(AppLocalizations.of(context)!.lorebookDetailDeletedMessage, style: TextStyle(color: _textFaint, fontSize: 13)),
              );
            }
            return Column(
              children: [
                _buildAppBar(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lorebook.title,
                        style: TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      StreamBuilder<List<LorebookSummary>>(
                        stream: _repository.watchAll(),
                        builder: (context, summarySnapshot) {
                          final summary = (summarySnapshot.data ?? const [])
                              .where((s) => s.lorebook.id == widget.lorebookId);
                          final conversationCount = summary.isEmpty ? 0 : summary.first.conversationCount;
                          final linkedPlotCount = summary.isEmpty ? 0 : summary.first.linkedPlotCount;
                          return Text(
                            AppLocalizations.of(context)!.lorebookTileStats(conversationCount, linkedPlotCount),
                            style: TextStyle(color: _textFaint, fontSize: 12),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: _textPrimary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: _textPrimary,
                  unselectedLabelColor: _textFaint,
                  labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.lorebookInfoTabLabel),
                    Tab(text: AppLocalizations.of(context)!.lorebookLinkedPlotsTabLabel),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoreInfoTab(),
                      _buildLinkedPlotsTab(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => LorebookPlotPickerScreen(lorebookId: widget.lorebookId)),
              );
            },
            child: Text(l10n.lorebookPlotConnectTabLabel, style: TextStyle(color: _purple, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: _textPrimary, size: 22),
            color: _cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => LorebookEditScreen(lorebookId: widget.lorebookId)),
                );
              } else if (value == 'delete') {
                _confirmDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text(l10n.lorebookDetailEditMenuItem, style: TextStyle(color: _textPrimary))),
              PopupMenuItem(value: 'delete', child: Text(l10n.commonDelete, style: TextStyle(color: _danger))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoreInfoTab() {
    return StreamBuilder<List<LorebookEntry>>(
      stream: _repository.watchEntries(widget.lorebookId),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const [];
        if (entries.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.lorebookDetailNoEntriesMessage, style: TextStyle(color: _textFaint, fontSize: 13)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final keywords = entry.keywords.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.title.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      entry.title,
                      style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (keywords.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final keyword in keywords)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _pillGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(keyword, style: TextStyle(color: _textSecondary, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                Text(entry.content, style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.5)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLinkedPlotsTab() {
    return StreamBuilder<List<Plot>>(
      stream: _repository.watchLinkedPlots(widget.lorebookId),
      builder: (context, snapshot) {
        final plots = snapshot.data ?? const [];
        if (plots.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.lorebookDetailNoLinkedPlotsMessage, style: TextStyle(color: _textFaint, fontSize: 13)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: plots.length,
          separatorBuilder: (_, _) => Divider(color: _pillGrey, height: 1),
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(plots[index].title, style: TextStyle(color: _textPrimary, fontSize: 14)),
          ),
        );
      },
    );
  }
}
