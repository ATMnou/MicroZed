import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/export/lorebook_exporter.dart';
import '../data/import/lorebook_parser.dart';
import '../data/repositories/lorebook_repository.dart';
import '../l10n/app_localizations.dart';
import 'lorebook_plot_picker_screen.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 항목 편집 중 상태(제목/키워드/내용 컨트롤러 + 펼침 여부).
class _EntryForm {
  _EntryForm({
    this.id,
    String title = '',
    String keywords = '',
    String content = '',
  }) : titleController = TextEditingController(text: title),
       keywordsController = TextEditingController(text: keywords),
       contentController = TextEditingController(text: content);

  factory _EntryForm.fromEntry(LorebookEntry entry) => _EntryForm(
    id: entry.id,
    title: entry.title,
    keywords: entry.keywords,
    content: entry.content,
  );

  final int? id;
  final TextEditingController titleController;
  final TextEditingController keywordsController;
  final TextEditingController contentController;
  bool expanded = true;

  void dispose() {
    titleController.dispose();
    keywordsController.dispose();
    contentController.dispose();
  }
}

/// 제작 탭의 '제작하기'(로어북 탭) 또는 로어북의 '...' 메뉴 > '수정'에서 나오는 편집 화면.
/// 탭: 로어 정보 / 플롯 연결 ('설정' 탭은 빼고, 글자수/개수 제한도 두지 않는다).
class LorebookEditScreen extends StatefulWidget {
  const LorebookEditScreen({super.key, this.lorebookId});

  final int? lorebookId;

  @override
  State<LorebookEditScreen> createState() => _LorebookEditScreenState();
}

class _LorebookEditScreenState extends State<LorebookEditScreen>
    with SingleTickerProviderStateMixin {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _cardBg => _p.surface;
  Color get _borderGrey => _p.border;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _mutedText => _p.textMuted;
  Color get _textFaint => _p.textFaint;
  late final TabController _tabController;
  late final LorebookRepository _repository;

  final _titleController = TextEditingController();
  final _shortIntroController = TextEditingController();
  List<_EntryForm> _entryForms = [];
  bool _loading = true;
  bool _saving = false;
  bool _importing = false;
  bool _exporting = false;


  bool get _isEditing => widget.lorebookId != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repository = LorebookRepository(AppDatabase.instance);
    _load();
  }

  Future<void> _load() async {
    if (widget.lorebookId != null) {
      final lorebook = await _repository.getById(widget.lorebookId!);
      final entries = await _repository.getEntries(widget.lorebookId!);
      _titleController.text = lorebook?.title ?? '';
      _shortIntroController.text = lorebook?.shortIntro ?? '';
      _entryForms = entries.map((e) => _EntryForm.fromEntry(e)).toList();
    }
    if (_entryForms.isEmpty) {
      _entryForms = [_EntryForm()];
    }
    if (mounted) setState(() => _loading = false);
  }

  void _addEntry() {
    setState(() {
      for (final form in _entryForms) {
        form.expanded = false;
      }
      _entryForms.add(_EntryForm());
    });
  }

  Future<void> _removeEntry(int index) async {
    final form = _entryForms[index];
    if (form.id != null) {
      await _repository.deleteEntry(form.id!);
    }
    form.dispose();
    if (mounted) setState(() => _entryForms.removeAt(index));
  }

  /// SillyTavern World Info JSON 또는 JanitorAI 스타일 배열(.json)을 읽어서 파싱된 항목을
  /// 폼 목록 맨 뒤에 미저장 상태로 추가한다. 새 로어북을 만드는 중이면 "새 로어북으로",
  /// 기존 로어북을 열어서 가져오면 "이 로어북에 추가"가 되는 셈이라 별도 대상 선택 없이도
  /// 지금 열려 있는 화면이 곧 가져오기 대상이다. 실제 DB 반영은 평소처럼 저장을 눌러야 한다.
  Future<void> _importFromFile() async {
    final l10n = AppLocalizations.of(context)!;
    if (_importing) return;
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['json']);
    if (result == null || result.files.isEmpty) return;
    setState(() => _importing = true);
    try {
      final bytes = await result.files.single.readAsBytes();
      final json = jsonDecode(utf8.decode(bytes));
      final parsed = LorebookParser.parseJson(json);
      setState(() {
        for (final form in _entryForms) {
          form.expanded = false;
        }
        for (final entry in parsed) {
          _entryForms.add(_EntryForm(
            title: entry.title ?? '',
            keywords: entry.keywords.join(','),
            content: entry.content,
          ));
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lorebookImportSuccessMessage(parsed.length))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lorebookImportFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _exportToFile() async {
    final l10n = AppLocalizations.of(context)!;
    if (_exporting || widget.lorebookId == null) return;
    setState(() => _exporting = true);
    try {
      final entries = await _repository.getEntries(widget.lorebookId!);
      final bytes = LorebookExporter.toWorldInfoJson(entries);
      final safeTitle = _titleController.text.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final path = await FilePicker.saveFile(
        fileName: '${safeTitle.isEmpty ? 'lorebook' : safeTitle}.json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
        bytes: bytes,
      );
      if (path == null) return; // 취소됨
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lorebookExportSuccessMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lorebookExportFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final lorebookId = await _repository.upsert(
      id: widget.lorebookId,
      title: _titleController.text.trim(),
      shortIntro: _shortIntroController.text.trim(),
    );
    for (final form in _entryForms) {
      final title = form.titleController.text.trim();
      final keywords = form.keywordsController.text.trim();
      final content = form.contentController.text.trim();
      if (title.isEmpty && keywords.isEmpty && content.isEmpty) continue;
      if (form.id == null) {
        final newId = await _repository.addEntry(lorebookId);
        await _repository.updateEntry(
          id: newId,
          title: title,
          keywords: keywords,
          content: content,
        );
      } else {
        await _repository.updateEntry(
          id: form.id!,
          title: title,
          keywords: keywords,
          content: content,
        );
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _shortIntroController.dispose();
    for (final form in _entryForms) {
      form.dispose();
    }
    super.dispose();
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
          icon: Icon(Icons.close, color: _textPrimary, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Text(
          l10n.lorebookEditAppBarTitle,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: _importing
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _mutedText),
                  )
                : Icon(Icons.file_download_outlined, color: _textPrimary, size: 20),
            tooltip: l10n.lorebookImportButtonTooltip,
            onPressed: _importing ? null : _importFromFile,
          ),
          if (widget.lorebookId != null)
            IconButton(
              icon: _exporting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _mutedText),
                    )
                  : Icon(Icons.file_upload_outlined, color: _textPrimary, size: 20),
              tooltip: l10n.lorebookExportButtonTooltip,
              onPressed: _exporting ? null : _exportToFile,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _loading || _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: _textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                _isEditing
                    ? l10n.plotEditSaveButtonEdit
                    : l10n.lorebookEditSaveButtonCreate,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _textPrimary,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: _textPrimary,
          unselectedLabelColor: _textFaint,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: l10n.lorebookInfoTabLabel),
            Tab(text: l10n.lorebookPlotConnectTabLabel),
          ],
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _purple))
          : SafeArea(
              top: false,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoreInfoTab(),
                  widget.lorebookId == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              l10n.lorebookEditSaveFirstMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _textFaint,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : _PlotConnectTab(
                          lorebookId: widget.lorebookId!,
                          repository: _repository,
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildLoreInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.plotEditAboutSectionTitle,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.lorebookEditIntroDescription,
          style: TextStyle(color: _textFaint, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _plainField(
                label: l10n.lorebookEditTitleFieldLabel,
                controller: _titleController,
                required: true,
              ),
              const SizedBox(height: 16),
              _plainField(
                label: l10n.plotEditShortIntroLabel,
                controller: _shortIntroController,
                maxLines: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.lorebookEditEntriesSectionTitle,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _entryForms.length; i++) ...[
          _buildEntryCard(i),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: _addEntry,
          style: OutlinedButton.styleFrom(
            foregroundColor: _textPrimary,
            side: BorderSide(color: _borderGrey),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.add, size: 16),
          label: Text(
            l10n.lorebookEditAddEntryButton,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(int index) {
    final l10n = AppLocalizations.of(context)!;
    final form = _entryForms[index];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => form.expanded = !form.expanded),
            child: Row(
              children: [
                Icon(
                  form.expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: _mutedText,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.lorebookEditEntryCardTitle(index + 1),
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _removeEntry(index),
                  child: Icon(
                    Icons.delete_outline,
                    color: _mutedText,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          if (form.expanded) ...[
            const SizedBox(height: 12),
            _plainField(
              label: l10n.plotEditTitleFieldLabel,
              controller: form.titleController,
              hint: l10n.lorebookEditEntryTitleHint,
            ),
            const SizedBox(height: 16),
            _plainField(
              label: l10n.lorebookEditKeywordsLabel,
              controller: form.keywordsController,
              required: true,
              maxLines: 2,
              hint: l10n.lorebookEditKeywordsHint,
            ),
            const SizedBox(height: 16),
            _plainField(
              label: l10n.lorebookEditContentLabel,
              controller: form.contentController,
              required: true,
              maxLines: 5,
              hint: l10n.lorebookEditContentHint,
            ),
          ],
        ],
      ),
    );
  }

  Widget _plainField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (required)
              Text(
                '*',
                style: TextStyle(
                  color: _purple,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: _textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textFaint, fontSize: 12),
            filled: true,
            fillColor: _background,
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _purple),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlotConnectTab extends StatelessWidget {
  const _PlotConnectTab({required this.lorebookId, required this.repository});

  final int lorebookId;
  final LorebookRepository repository;


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lorebookEditConnectPlotsTitle,
            style: TextStyle(
              color: PaletteScope.of(context).textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.lorebookEditConnectPlotsDescription,
            style: TextStyle(color: PaletteScope.of(context).textFaint, fontSize: 12),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Plot>>(
            stream: repository.watchLinkedPlots(lorebookId),
            builder: (context, snapshot) {
              final linked = snapshot.data ?? const [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              LorebookPlotPickerScreen(lorebookId: lorebookId),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PaletteScope.of(context).textPrimary,
                      side: BorderSide(color: PaletteScope.of(context).border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      l10n.lorebookConnectButtonWithCount(linked.length),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (linked.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    for (final plot in linked)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          plot.title,
                          style: TextStyle(
                            color: PaletteScope.of(context).textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
