import 'dart:io';

import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/lorebook_repository.dart';
import '../data/repositories/plot_repository.dart';
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
          child: _buildCreateButton(),
        ),
      ],
    );
  }

  Widget _buildPlotList() {
    return StreamBuilder<List<PlotSummary>>(
      stream: _plotRepository.watchAll(),
      builder: (context, snapshot) {
        final allPlots = snapshot.data ?? const [];
        final plots = _filterPlots(allPlots);
        return Column(
          children: [
            _buildSummaryRow(count: allPlots.length, total: '대화량 ${_totalConversations(allPlots)}'),
            Expanded(
              child: plots.isEmpty
                  ? Center(
                      child: Text(
                        _query.trim().isEmpty ? '아직 만든 플롯이 없어요' : '검색 결과가 없어요',
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
        final allLorebooks = snapshot.data ?? const [];
        final lorebooks = _filterLorebooks(allLorebooks);
        final totalConversations = allLorebooks.fold<int>(0, (sum, l) => sum + l.conversationCount);
        return Column(
          children: [
            _buildSummaryRow(count: allLorebooks.length, total: '대화량 $totalConversations'),
            Expanded(
              child: lorebooks.isEmpty
                  ? Center(
                      child: Text(
                        _query.trim().isEmpty ? '아직 만든 로어북이 없어요' : '검색 결과가 없어요',
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
                            children: const [
                              Text(
                                '• 대화량은 해당 로어북이 연결된 플롯에서 생긴 대화의 총합이에요.',
                                style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '• 로어북을 수정하거나 삭제하면 연결된 모든 플롯에 즉시 반영돼요. 변경하실 때 꼭 한 번 더 확인해주세요.',
                                style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
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
                      hintText: _activeTab == 0 ? '플롯 제목, 소개, 해시태그 검색' : '로어북 제목 검색',
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
                  child: const Text('취소', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ],
            )
          : Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _activeTab = 0),
                  child: Text(
                    '플롯',
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
                    '로어북',
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('총 $count개', style: const TextStyle(color: Colors.white70, fontSize: 13)),
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

  Widget _buildCreateButton() {
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
      label: const Text('제작하기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }
}

class _PlotTile extends StatelessWidget {
  const _PlotTile({required this.data});

  final PlotSummary data;

  void _showOptionsMenu(BuildContext context) {
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
                title: const Text('플롯 수정', style: TextStyle(color: Colors.white)),
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
                title: const Text('삭제', style: TextStyle(color: Colors.white)),
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
                    '대화량 ${data.conversationCount}',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: Colors.white54, size: 18),
            const SizedBox(width: 16),
            const Icon(Icons.bar_chart, color: Colors.white54, size: 18),
            const SizedBox(width: 16),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
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
                    '대화량 ${data.conversationCount} · 연결 플롯 ${data.linkedPlotCount}',
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
