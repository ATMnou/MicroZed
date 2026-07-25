import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/lorebook_repository.dart';
import 'lorebook_edit_screen.dart';
import 'lorebook_plot_picker_screen.dart';

/// 제작 탭에서 로어북 행을 그냥 누르면(수정/삭제 아님) 나오는 보기 전용 화면.
class LorebookDetailScreen extends StatefulWidget {
  const LorebookDetailScreen({super.key, required this.lorebookId});

  final int lorebookId;

  @override
  State<LorebookDetailScreen> createState() => _LorebookDetailScreenState();
}

class _LorebookDetailScreenState extends State<LorebookDetailScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final LorebookRepository _repository;

  static const _background = Color(0xFF141414);
  static const _cardBg = Color(0xFF1E1E1E);
  static const _purple = Color(0xFF7A6FF0);

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: const Text('로어북을 삭제할까요?', style: TextStyle(color: Colors.white)),
        content: const Text('연결된 모든 플롯에 즉시 반영돼요.', style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
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
              return const Center(child: CircularProgressIndicator(color: _purple));
            }
            if (lorebook == null) {
              return const Center(
                child: Text('삭제된 로어북이에요', style: TextStyle(color: Colors.white38, fontSize: 13)),
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
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                            '대화량 $conversationCount · 연결 플롯 $linkedPlotCount',
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white38,
                  labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  tabs: const [Tab(text: '로어 정보'), Tab(text: '연결 플롯')],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => LorebookPlotPickerScreen(lorebookId: widget.lorebookId)),
              );
            },
            child: const Text('플롯 연결', style: TextStyle(color: _purple, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
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
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('로어북 수정', style: TextStyle(color: Colors.white))),
              PopupMenuItem(value: 'delete', child: Text('삭제', style: TextStyle(color: Colors.redAccent))),
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
          return const Center(
            child: Text('작성된 항목이 없어요', style: TextStyle(color: Colors.white38, fontSize: 13)),
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
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                              color: const Color(0xFF262626),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(keyword, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                Text(entry.content, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
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
          return const Center(
            child: Text('연결된 플롯이 없어요', style: TextStyle(color: Colors.white38, fontSize: 13)),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: plots.length,
          separatorBuilder: (_, _) => const Divider(color: Color(0xFF2A2A2A), height: 1),
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(plots[index].title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        );
      },
    );
  }
}
