import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/lorebook_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../l10n/app_localizations.dart';

/// 로어북 편집 > '플롯 연결' 탭의 '+ 연결하기'에서 나오는 플롯 선택 화면.
class LorebookPlotPickerScreen extends StatefulWidget {
  const LorebookPlotPickerScreen({super.key, required this.lorebookId});

  final int lorebookId;

  @override
  State<LorebookPlotPickerScreen> createState() =>
      _LorebookPlotPickerScreenState();
}

class _LorebookPlotPickerScreenState extends State<LorebookPlotPickerScreen> {
  late final LorebookRepository _lorebookRepository;
  late final PlotRepository _plotRepository;

  Set<int> _selectedPlotIds = {};
  bool _loading = true;

  static const _background = Color(0xFF141414);
  static const _purple = Color(0xFF7A6FF0);

  @override
  void initState() {
    super.initState();
    _lorebookRepository = LorebookRepository(AppDatabase.instance);
    _plotRepository = PlotRepository(AppDatabase.instance);
    _load();
  }

  Future<void> _load() async {
    final linked = await _lorebookRepository.linkedPlotIds(widget.lorebookId);
    if (mounted) {
      setState(() {
        _selectedPlotIds = linked;
        _loading = false;
      });
    }
  }

  Future<void> _confirm() async {
    await _lorebookRepository.setPlotLinksForLorebook(
      widget.lorebookId,
      _selectedPlotIds,
    );
    if (mounted) Navigator.of(context).pop();
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
        title: Text(
          l10n.lorebookPlotConnectTabLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : StreamBuilder<List<PlotSummary>>(
              stream: _plotRepository.watchAll(),
              builder: (context, snapshot) {
                final plots = snapshot.data ?? const [];
                if (plots.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.homeNoPlotsYet,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: plots.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: Color(0xFF2A2A2A), height: 1),
                  itemBuilder: (context, index) {
                    final plot = plots[index].plot;
                    final selected = _selectedPlotIds.contains(plot.id);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _selectedPlotIds.add(plot.id);
                        } else {
                          _selectedPlotIds.remove(plot.id);
                        }
                      }),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: _purple,
                      title: Text(
                        plot.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.lorebookConnectButtonWithCount(_selectedPlotIds.length),
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
