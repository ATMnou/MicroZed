import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/lorebook_repository.dart';
import '../l10n/app_localizations.dart';

/// 플롯 편집 > '로어북' 탭의 '+ 로어북 연결'에서 나오는 로어북 선택 화면.
/// 둘러보기/최근 플레이/내 로어북 같은 탭 구분과 썸네일 이미지는 빼고,
/// 만들어둔 로어북을 한 목록에서 고르는 형태로 단순화했다. 플롯 하나당 최대 5개.
class LorebookConnectScreen extends StatefulWidget {
  const LorebookConnectScreen({super.key, required this.plotId});

  final int plotId;

  static const maxLinks = 5;

  @override
  State<LorebookConnectScreen> createState() => _LorebookConnectScreenState();
}

class _LorebookConnectScreenState extends State<LorebookConnectScreen> {
  late final LorebookRepository _repository;

  Set<int> _selectedLorebookIds = {};
  bool _loading = true;
  bool _searching = false;
  String _query = '';
  final _searchController = TextEditingController();

  static const _background = Color(0xFF141414);
  static const _purple = Color(0xFF7A6FF0);

  @override
  void initState() {
    super.initState();
    _repository = LorebookRepository(AppDatabase.instance);
    _load();
  }

  Future<void> _load() async {
    final linked = await _repository.linkedLorebookIds(widget.plotId);
    if (mounted) {
      setState(() {
        _selectedLorebookIds = linked;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    await _repository.setLorebookLinksForPlot(
      widget.plotId,
      _selectedLorebookIds,
    );
    if (mounted) Navigator.of(context).pop();
  }

  List<LorebookSummary> _filter(List<LorebookSummary> summaries) {
    if (_query.trim().isEmpty) return summaries;
    final q = _query.trim().toLowerCase();
    return summaries
        .where((s) => s.lorebook.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: l10n.searchHintLorebook,
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                ),
              )
            : Text(
                l10n.lorebookConnectTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
        centerTitle: !_searching,
        actions: [
          IconButton(
            icon: Icon(
              _searching ? Icons.close : Icons.search,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) {
                _query = '';
                _searchController.clear();
              }
            }),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : StreamBuilder<List<LorebookSummary>>(
              stream: _repository.watchAll(),
              builder: (context, snapshot) {
                final summaries = _filter(snapshot.data ?? const []);
                if (summaries.isEmpty) {
                  return Center(
                    child: Text(
                      _query.trim().isEmpty
                          ? l10n.createTabNoLorebooksYet
                          : l10n.commonNoSearchResults,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: summaries.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: Color(0xFF2A2A2A), height: 1),
                  itemBuilder: (context, index) {
                    final summary = summaries[index];
                    final selected = _selectedLorebookIds.contains(
                      summary.lorebook.id,
                    );
                    final atCap =
                        !selected &&
                        _selectedLorebookIds.length >=
                            LorebookConnectScreen.maxLinks;
                    return CheckboxListTile(
                      value: selected,
                      onChanged: atCap
                          ? null
                          : (v) => setState(() {
                              if (v == true) {
                                _selectedLorebookIds.add(summary.lorebook.id);
                              } else {
                                _selectedLorebookIds.remove(
                                  summary.lorebook.id,
                                );
                              }
                            }),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: _purple,
                      title: Text(
                        summary.lorebook.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        l10n.lorebookTileStats(
                          summary.conversationCount,
                          summary.linkedPlotCount,
                        ),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedLorebookIds.isEmpty
                    ? const Color(0xFF3A3A3A)
                    : _purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selectedLorebookIds.isEmpty
                    ? l10n.lorebookConnectNoneButton(
                        LorebookConnectScreen.maxLinks,
                      )
                    : l10n.lorebookConnectConfirmButton(
                        _selectedLorebookIds.length,
                        LorebookConnectScreen.maxLinks,
                      ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
