import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/ai/plot_ai_generator_service.dart';
import '../data/db/database.dart';
import '../data/export/plot_card_exporter.dart';
import '../data/export/plot_data_exporter.dart';
import '../data/local_image_store.dart';
import '../data/repositories/ai_preset_repository.dart';
import '../data/repositories/character_repository.dart';
import '../data/repositories/intro_entry_repository.dart';
import '../data/repositories/lorebook_repository.dart';
import '../data/repositories/plot_conversation_profile_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/dashed_box.dart';
import '../widgets/local_avatar.dart';
import 'lorebook_connect_screen.dart';
import 'plot_conversation_profile_edit_screen.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 'AI로 캐릭터 생성' 다이얼로그가 돌려주는 선택 결과.
class _AiCharacterRequest {
  const _AiCharacterRequest({required this.preset, required this.prompt});
  final AiPreset preset;
  final String prompt;
}

/// 'AI로 인트로 생성' 다이얼로그가 돌려주는 선택 결과.
class _AiIntroRequest {
  const _AiIntroRequest({required this.preset, required this.prompt});
  final AiPreset preset;
  final String prompt;
}

/// 프롬프트 탭에서 편집 중인 캐릭터 1명 분의 폼 상태.
class _CharacterForm {
  _CharacterForm({
    this.id,
    String name = '',
    String description = '',
    this.imagePath,
    String aboutText = '',
  }) : nameController = TextEditingController(text: name),
       descController = TextEditingController(text: description),
       aboutController = TextEditingController(text: aboutText);

  factory _CharacterForm.fromCharacter(Character character) => _CharacterForm(
    id: character.id,
    name: character.name,
    description: character.description,
    imagePath: character.imagePath,
    aboutText: character.aboutText,
  );

  final int? id;
  final TextEditingController nameController;
  final TextEditingController descController;

  /// 상세 페이지에 표시할 캐릭터별 소개 마크다운(AI에게는 전달되지 않음).
  final TextEditingController aboutController;
  String? imagePath;

  void dispose() {
    nameController.dispose();
    descController.dispose();
    aboutController.dispose();
  }
}

/// 제작 탭의 '제작하기' 버튼 또는 플롯의 '...' 메뉴 > '플롯 수정'을 눌렀을 때 나오는
/// 플롯 생성/편집 화면을 클론 코딩했다. 스타일/설정 탭은 제거했고, 로어북 탭은 빈 상태로 둔다.
/// 프롬프트/인트로/소개(짧은 소개·해시태그·커버/캐릭터 이미지) 탭이 실제 DB에 저장된다.
/// '나만의 소개글 꾸미기' 마크다운은 아직 UI 셸이다.
class PlotEditScreen extends StatefulWidget {
  const PlotEditScreen({super.key, this.plotId});

  /// null이면 신규 제작, 값이 있으면 기존 플롯 수정.
  final int? plotId;

  @override
  State<PlotEditScreen> createState() => _PlotEditScreenState();
}

class _PlotEditScreenState extends State<PlotEditScreen>
    with SingleTickerProviderStateMixin {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _cardBg => _p.surface;
  Color get _borderGrey => _p.border;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _textFaint => _p.textFaint;
  Color get _mutedText => _p.textMuted;
  Color get _textSecondary => _p.textSecondary;
  late final TabController _tabController;
  late final PlotRepository _plotRepository;
  late final CharacterRepository _characterRepository;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _shortIntroController = TextEditingController();

  final _imageStore = LocalImageStore();

  List<_CharacterForm> _characterForms = [];
  List<String> _hashtags = [];
  String? _coverImagePath;
  bool _loading = true;
  bool _saving = false;
  bool _exporting = false;
  bool _aiGeneratingCharacter = false;


  static const _tabCount = 4;

  List<String> _tabLabels(AppLocalizations l10n) => [
    l10n.plotEditTabPrompt,
    l10n.plotEditTabLorebook,
    l10n.characterDetailIntroSectionTitle,
    l10n.plotEditTabAbout,
  ];

  bool _initialLoadStarted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _plotRepository = PlotRepository(AppDatabase.instance);
    _characterRepository = CharacterRepository(AppDatabase.instance);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoadStarted) {
      _initialLoadStarted = true;
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    if (widget.plotId != null) {
      final plot = await _plotRepository.getById(widget.plotId!);
      final characters = await _characterRepository.getByPlot(widget.plotId!);
      if (!mounted) return;
      _titleController.text = plot?.title ?? '';
      _descController.text = plot?.description ?? '';
      _shortIntroController.text = plot?.shortIntro ?? '';
      _hashtags = (plot?.hashtags ?? '')
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      _coverImagePath = plot?.coverImagePath;
      final l10n = AppLocalizations.of(context)!;
      _characterForms = characters.isEmpty
          ? [_CharacterForm(name: l10n.plotEditDefaultCharacterName(1))]
          : characters.map((c) => _CharacterForm.fromCharacter(c)).toList();
    } else {
      _characterForms = [
        _CharacterForm(
          name: AppLocalizations.of(context)!.plotEditDefaultCharacterName(1),
        ),
      ];
    }
    if (mounted) setState(() => _loading = false);
  }

  void _addCharacter() {
    setState(() {
      _characterForms.add(
        _CharacterForm(
          name: AppLocalizations.of(
            context,
          )!.plotEditDefaultCharacterName(_characterForms.length + 1),
        ),
      );
    });
  }

  /// 프롬프트 탭의 'AI로 생성' 버튼. 프리셋을 고르고(선택) 짧은 지시를 준 뒤, 지금 입력된
  /// 플롯 제목/설명을 맥락으로 캐릭터 1명을 만들어 캐릭터 목록에 추가한다.
  Future<void> _aiGenerateCharacter() async {
    final l10n = AppLocalizations.of(context)!;
    final presets = await AiPresetRepository(AppDatabase.instance).watchAll().first;
    if (!mounted) return;
    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.plotAiGeneratePresetEmptyHint)),
      );
      return;
    }
    final request = await _showAiCharacterDialog(presets);
    if (request == null) return;

    setState(() => _aiGeneratingCharacter = true);
    try {
      final draft = await PlotAiGeneratorService(AppDatabase.instance).generateCharacter(
        preset: request.preset,
        plotTitle: _titleController.text.trim(),
        plotDescription: _descController.text.trim(),
        userPrompt: request.prompt,
      );
      if (!mounted) return;
      if (draft.name.isEmpty) throw StateError('AI가 올바른 형식으로 응답하지 않았어요.');
      setState(() {
        _characterForms.add(
          _CharacterForm(name: draft.name, description: draft.description),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.plotAiGenerateFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _aiGeneratingCharacter = false);
    }
  }

  Future<_AiCharacterRequest?> _showAiCharacterDialog(List<AiPreset> presets) {
    final l10n = AppLocalizations.of(context)!;
    var selected = presets.first;
    final promptController = TextEditingController();
    return showDialog<_AiCharacterRequest>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: _cardBg,
            title: Text(l10n.plotEditAddCharacterButton, style: TextStyle(color: _textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _borderGrey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AiPreset>(
                      value: selected,
                      isExpanded: true,
                      dropdownColor: _background,
                      style: TextStyle(color: _textPrimary, fontSize: 14),
                      items: presets.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                      onChanged: (preset) {
                        if (preset != null) setDialogState(() => selected = preset);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: promptController,
                  maxLines: 3,
                  minLines: 2,
                  style: TextStyle(color: _textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.plotAiGeneratePromptHint,
                    hintStyle: TextStyle(color: _textFaint, fontSize: 13),
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.commonCancel, style: TextStyle(color: _mutedText)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(
                  _AiCharacterRequest(preset: selected, prompt: promptController.text),
                ),
                child: Text(l10n.plotAiGenerateSubmitButton, style: TextStyle(color: _purple)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _removeCharacter(int index) async {
    if (index == 0) return;
    final form = _characterForms[index];
    if (form.id != null) {
      await _characterRepository.delete(form.id!);
    }
    form.dispose();
    if (mounted) setState(() => _characterForms.removeAt(index));
  }

  Future<void> _pickCharacterImage(int index) async {
    final path = await _imageStore.pickAndSave('character');
    if (path != null && mounted)
      setState(() => _characterForms[index].imagePath = path);
  }

  void _removeCharacterImage(int index) {
    setState(() => _characterForms[index].imagePath = null);
  }

  Future<void> _pickCoverImage() async {
    final path = await _imageStore.pickAndSave('cover');
    if (path != null && mounted) setState(() => _coverImagePath = path);
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty ||
        _characterForms.isEmpty ||
        _characterForms.first.nameController.text.trim().isEmpty) {
      return;
    }
    setState(() => _saving = true);
    final plotId = await _plotRepository.upsertPlot(
      plotId: widget.plotId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      shortIntro: _shortIntroController.text.trim(),
      hashtags: _hashtags,
      coverImagePath: _coverImagePath,
    );
    for (var i = 0; i < _characterForms.length; i++) {
      final form = _characterForms[i];
      final name = form.nameController.text.trim();
      if (name.isEmpty) continue;
      if (form.id == null) {
        await _characterRepository.add(
          plotId: plotId,
          name: name,
          description: form.descController.text.trim(),
          imagePath: form.imagePath,
          isRepresentative: i == 0,
          sortOrder: i,
          aboutText: form.aboutController.text.trim(),
        );
      } else {
        await _characterRepository.update(
          id: form.id!,
          name: name,
          description: form.descController.text.trim(),
          imagePath: form.imagePath,
          sortOrder: i,
          aboutText: form.aboutController.text.trim(),
        );
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _exportAsSillyTavernCard() async {
    final l10n = AppLocalizations.of(context)!;
    final plotId = widget.plotId;
    if (plotId == null || _exporting) return;
    setState(() => _exporting = true);
    try {
      final bytes = await PlotCardExporter(
        AppDatabase.instance,
      ).exportPlot(plotId);
      final safeTitle = _titleController.text.trim().replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '_',
      );
      final path = await FilePicker.saveFile(
        fileName: '${safeTitle.isEmpty ? 'plot' : safeTitle}.png',
        type: FileType.custom,
        allowedExtensions: const ['png'],
        bytes: bytes,
      );
      if (path == null) return; // 취소됨
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.plotEditExportSuccessMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.plotEditExportFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// SillyTavern 카드와 달리 대표 캐릭터 하나로 손실 압축하지 않고, 이 플롯의 모든
  /// 캐릭터/인트로/플롯 전용 프로필/연결된 로어북과 이미지를 전용 zip 형식으로 내보낸다.
  Future<void> _exportAsPlotDataPackage() async {
    final l10n = AppLocalizations.of(context)!;
    final plotId = widget.plotId;
    if (plotId == null || _exporting) return;
    setState(() => _exporting = true);
    try {
      final bytes = await PlotDataExporter(AppDatabase.instance).exportPlot(plotId);
      final safeTitle = _titleController.text.trim().replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '_',
      );
      final path = await FilePicker.saveFile(
        fileName: '${safeTitle.isEmpty ? 'plot' : safeTitle}.mzplot',
        type: FileType.custom,
        allowedExtensions: const ['mzplot'],
        bytes: bytes,
      );
      if (path == null) return; // 취소됨
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.plotEditExportDataSuccessMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.plotEditExportFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _shortIntroController.dispose();
    for (final form in _characterForms) {
      form.dispose();
    }
    super.dispose();
  }

  bool get _isEditing => widget.plotId != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(context),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _purple))
          : SafeArea(
              top: false,
              child: Column(
                children: [
                  _buildTabBar(context),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _PromptTab(
                          plotId: widget.plotId,
                          titleController: _titleController,
                          descController: _descController,
                          characterForms: _characterForms,
                          onPickCharacterImage: _pickCharacterImage,
                          onRemoveCharacterImage: _removeCharacterImage,
                          onAddCharacter: _addCharacter,
                          onRemoveCharacter: _removeCharacter,
                          onAiGenerateCharacter: _aiGenerateCharacter,
                          aiGeneratingCharacter: _aiGeneratingCharacter,
                        ),
                        _LorebookTab(plotId: widget.plotId),
                        _IntroTab(plotId: widget.plotId),
                        _AboutTab(
                          shortIntroController: _shortIntroController,
                          hashtags: _hashtags,
                          onHashtagsChanged: (tags) =>
                              setState(() => _hashtags = tags),
                          coverImagePath: _coverImagePath,
                          onPickCoverImage: _pickCoverImage,
                          characterForms: _characterForms,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: _background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: _textPrimary, size: 22),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Text(
        l10n.plotEditAppBarTitle,
        style: TextStyle(
          color: _textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: _exporting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _textSecondary,
                  ),
                )
              : Icon(Icons.more_horiz, color: _textPrimary, size: 22),
          color: _cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabled: widget.plotId != null && !_exporting,
          onSelected: (value) {
            if (value == 'export_card') _exportAsSillyTavernCard();
            if (value == 'export_data') _exportAsPlotDataPackage();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export_card',
              child: Text(
                l10n.plotEditExportCardMenuItem,
                style: TextStyle(color: _textPrimary),
              ),
            ),
            PopupMenuItem(
              value: 'export_data',
              child: Text(
                l10n.plotEditExportDataMenuItem,
                style: TextStyle(color: _textPrimary),
              ),
            ),
          ],
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
                  : l10n.plotEditSaveButtonCreate,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: _textPrimary,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: _textPrimary,
      unselectedLabelColor: _textFaint,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      tabs: _tabLabels(
        AppLocalizations.of(context)!,
      ).map((t) => Tab(text: t)).toList(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (required)
          Text(
            '*',
            style: TextStyle(
              color: PaletteScope.of(context).primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          text,
          style: TextStyle(
            color: PaletteScope.of(context).textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.showCharCount = false,
    this.maxLines = 1,
    this.required = false,
    this.expandable = false,
  });

  final String label;
  final TextEditingController controller;
  final bool showCharCount;
  final int maxLines;
  final bool required;

  /// true면 라벨 옆에 작은 확장 버튼을 붙여서, 전체 화면 편집기로 옮겨가 더 편하게
  /// 긴 글을 쓸 수 있게 한다(플롯 프롬프트 관련 입력창처럼 내용이 길어질 수 있는 곳용).
  final bool expandable;

  Future<void> _openFullscreenEditor(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _FullscreenTextEditScreen(title: label, initialText: controller.text),
      ),
    );
    if (result != null) controller.text = result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (expandable)
          Row(
            children: [
              Expanded(child: _SectionLabel(label, required: required)),
              InkWell(
                onTap: () => _openFullscreenEditor(context),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.open_in_full, size: 15, color: PaletteScope.of(context).textFaint),
                ),
              ),
            ],
          )
        else
          _SectionLabel(label, required: required),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: PaletteScope.of(context).textPrimary, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: PaletteScope.of(context).background,
            contentPadding: const EdgeInsets.all(12),
            counter: showCharCount
                ? AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        l10n.plotEditCharCountLabel(controller.text.length),
                        style: TextStyle(
                          color: PaletteScope.of(context).textFaint,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: PaletteScope.of(context).border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: PaletteScope.of(context).primary),
            ),
          ),
        ),
      ],
    );
  }
}

/// [_LabeledField]의 확장 버튼으로 진입하는 전체 화면 텍스트 편집기.
/// 저장을 누르면 편집한 텍스트를 [Navigator.pop]으로 돌려주고, 뒤로가기(취소)면 null을 돌려준다.
class _FullscreenTextEditScreen extends StatefulWidget {
  const _FullscreenTextEditScreen({required this.title, required this.initialText});

  final String title;
  final String initialText;

  @override
  State<_FullscreenTextEditScreen> createState() => _FullscreenTextEditScreenState();
}

class _FullscreenTextEditScreenState extends State<_FullscreenTextEditScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _textPrimary => _p.textPrimary;
  Color get _purple => _p.primary;
  late final TextEditingController _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: PaletteScope.of(context).background,
      appBar: AppBar(
        backgroundColor: PaletteScope.of(context).background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: _textPrimary, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_controller.text),
            child: Text(
              l10n.commonSave,
              style: TextStyle(color: _purple, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(color: _textPrimary, fontSize: 15, height: 1.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: PaletteScope.of(context).surface,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptTab extends StatelessWidget {
  const _PromptTab({
    required this.plotId,
    required this.titleController,
    required this.descController,
    required this.characterForms,
    required this.onPickCharacterImage,
    required this.onRemoveCharacterImage,
    required this.onAddCharacter,
    required this.onRemoveCharacter,
    required this.onAiGenerateCharacter,
    required this.aiGeneratingCharacter,
  });

  final int? plotId;
  final TextEditingController titleController;
  final TextEditingController descController;
  final List<_CharacterForm> characterForms;
  final ValueChanged<int> onPickCharacterImage;
  final ValueChanged<int> onRemoveCharacterImage;
  final VoidCallback onAddCharacter;
  final ValueChanged<int> onRemoveCharacter;
  final VoidCallback onAiGenerateCharacter;
  final bool aiGeneratingCharacter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.plotEditBasicSettingsTitle,
          style: TextStyle(
            color: PaletteScope.of(context).textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: PaletteScope.of(context).surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LabeledField(
                label: l10n.plotEditTitleFieldLabel,
                controller: titleController,
                showCharCount: true,
                required: true,
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: l10n.plotEditDescriptionFieldLabel,
                controller: descController,
                maxLines: 4,
                required: true,
                expandable: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < characterForms.length; i++) ...[
          _buildCharacterCard(context, i),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAddCharacter,
                style: OutlinedButton.styleFrom(
                  foregroundColor: PaletteScope.of(context).textPrimary,
                  side: BorderSide(color: PaletteScope.of(context).border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  l10n.plotEditAddCharacterButton,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: aiGeneratingCharacter ? null : onAiGenerateCharacter,
                style: OutlinedButton.styleFrom(
                  foregroundColor: PaletteScope.of(context).textPrimary,
                  side: BorderSide(color: PaletteScope.of(context).border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: aiGeneratingCharacter
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: PaletteScope.of(context).textSecondary),
                      )
                    : const Icon(Icons.auto_awesome, size: 16),
                label: Text(
                  l10n.createTabAiGenerateButton,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _PlotProfilesSection(plotId: plotId),
      ],
    );
  }

  Widget _buildCharacterCard(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    final form = characterForms[index];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PaletteScope.of(context).surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.plotEditDefaultCharacterName(index + 1),
                style: TextStyle(
                  color: PaletteScope.of(context).textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (index > 0)
                GestureDetector(
                  onTap: () => onRemoveCharacter(index),
                  child: Icon(
                    Icons.delete_outline,
                    color: PaletteScope.of(context).textMuted,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: form.imagePath != null
                ? GestureDetector(
                    onTap: () => onPickCharacterImage(index),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(form.imagePath!),
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (index == 0)
                          Positioned(
                            left: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: PaletteScope.of(context).primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.plotEditRepresentativeBadge,
                                style: TextStyle(
                                  color: PaletteScope.of(context).textPrimary,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => onRemoveCharacterImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: PaletteScope.of(context).textSecondary,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () => onPickCharacterImage(index),
                    child: DashedBox(
                      width: 96,
                      height: 96,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            color: PaletteScope.of(context).primary,
                            size: 20,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.plotEditCharacterImagePlaceholder,
                            style: TextStyle(
                              color: PaletteScope.of(context).textFaint,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          _LabeledField(
            label: l10n.plotEditNameFieldLabel,
            controller: form.nameController,
            showCharCount: true,
            required: true,
          ),
          const SizedBox(height: 16),
          _LabeledField(
            label: l10n.plotEditDescriptionFieldLabel,
            controller: form.descController,
            maxLines: 3,
            expandable: true,
          ),
        ],
      ),
    );
  }
}

/// 플롯 편집 > 프롬프트 탭 맨 아래의 '플롯 전용 대화 프로필' 섹션. 이 플롯으로 새 채팅을
/// 시작할 때 고를 수 있는 유저 프로필을 여기서 만든다(개수 제한 없음).
class _PlotProfilesSection extends StatefulWidget {
  const _PlotProfilesSection({required this.plotId});

  final int? plotId;

  @override
  State<_PlotProfilesSection> createState() => _PlotProfilesSectionState();
}

class _PlotProfilesSectionState extends State<_PlotProfilesSection> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _textFaint => _p.textFaint;
  Color get _textPrimary => _p.textPrimary;
  late final PlotConversationProfileRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = PlotConversationProfileRepository(AppDatabase.instance);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final plotId = widget.plotId;
    if (plotId == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          l10n.plotProfileSavePlotFirst,
          style: TextStyle(color: _textFaint, fontSize: 13),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.plotProfileSectionTitle,
          style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.plotProfileSectionDescription,
          style: TextStyle(color: _textFaint, fontSize: 12),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<PlotConversationProfile>>(
          stream: _repository.watchByPlot(plotId),
          builder: (context, snapshot) {
            final profiles = snapshot.data ?? const [];
            return Column(
              children: [
                for (final profile in profiles) ...[
                  _PlotProfileCard(
                    profile: profile,
                    repository: _repository,
                    onEdit: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlotConversationProfileEditScreen(
                          plotId: plotId,
                          profileId: profile.id,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlotConversationProfileEditScreen(plotId: plotId),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _textPrimary,
                    side: BorderSide(color: PaletteScope.of(context).border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    l10n.plotProfileAddButton,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PlotProfileCard extends StatelessWidget {
  const _PlotProfileCard({
    required this.profile,
    required this.repository,
    required this.onEdit,
  });

  final PlotConversationProfile profile;
  final PlotConversationProfileRepository repository;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PaletteScope.of(context).surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          LocalAvatar(imagePath: profile.imagePath, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String>(
                  future: repository.resolveDisplayName(profile),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? profile.name,
                      style: TextStyle(color: PaletteScope.of(context).textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  profile.shortIntro,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: PaletteScope.of(context).textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: PaletteScope.of(context).textMuted, size: 18),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

class _LorebookTab extends StatefulWidget {
  const _LorebookTab({required this.plotId});

  final int? plotId;

  @override
  State<_LorebookTab> createState() => _LorebookTabState();
}

class _LorebookTabState extends State<_LorebookTab> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _textFaint => _p.textFaint;
  Color get _textPrimary => _p.textPrimary;
  late final LorebookRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = LorebookRepository(AppDatabase.instance);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.plotId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.plotEditLorebookSavePlotFirst,
            textAlign: TextAlign.center,
            style: TextStyle(color: _textFaint, fontSize: 13),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.plotEditLorebookConnectTitle,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.help_outline, color: _textFaint, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.plotEditLorebookConnectDescription,
            style: TextStyle(color: _textFaint, fontSize: 12),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Lorebook>>(
            stream: _repository.watchLinkedLorebooks(widget.plotId!),
            builder: (context, snapshot) {
              final linked = snapshot.data ?? const [];
              return OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          LorebookConnectScreen(plotId: widget.plotId!),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textPrimary,
                  side: BorderSide(
                    color: PaletteScope.of(context).border,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  l10n.plotEditLorebookConnectButton(linked.length),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IntroTab extends StatefulWidget {
  const _IntroTab({required this.plotId});

  final int? plotId;

  @override
  State<_IntroTab> createState() => _IntroTabState();
}

enum _ComposerMode { narrator, user, character }

class _IntroTabState extends State<_IntroTab> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _cardBg => _p.surface;
  Color get _textPrimary => _p.textPrimary;
  Color get _borderGrey => _p.border;
  Color get _purple => _p.primary;
  Color get _mutedText => _p.textMuted;
  Color get _textFaint => _p.textFaint;
  Color get _textGhost => _p.textGhost;
  Color get _textSecondary => _p.textSecondary;
  Color get _pillGrey => _p.surfaceAlt;
  _ComposerMode _composerMode = _ComposerMode.narrator;
  int? _selectedCharacterId;
  late final TextEditingController _composerController;
  late final IntroEntryRepository _repository;
  late final CharacterRepository _characterRepository;
  late final LocalImageStore _imageStore;
  int _selectedVersionIndex = 0;

  @override
  void initState() {
    super.initState();
    _composerController = TextEditingController();
    _repository = IntroEntryRepository(AppDatabase.instance);
    _characterRepository = CharacterRepository(AppDatabase.instance);
    _imageStore = LocalImageStore();
    if (widget.plotId != null) {
      _repository.ensureDefaultVersion(widget.plotId!);
    }
  }

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  String _composerHint(BuildContext context, List<Character> characters) {
    final l10n = AppLocalizations.of(context)!;
    switch (_composerMode) {
      case _ComposerMode.narrator:
        return l10n.plotEditIntroHintNarrator;
      case _ComposerMode.user:
        return l10n.plotEditIntroHintUser;
      case _ComposerMode.character:
        final match = characters.where((c) => c.id == _selectedCharacterId);
        final name = match.isEmpty
            ? l10n.chatDefaultCharacterName
            : match.first.name;
        return l10n.plotEditIntroHintCharacter(name);
    }
  }

  Future<void> _pickAndAddImage(int introVersionId) async {
    final plotId = widget.plotId;
    if (plotId == null) return;
    final path = await _imageStore.pickAndSave('intro');
    if (path == null) return;
    await _repository.add(
      plotId: plotId,
      introVersionId: introVersionId,
      type: IntroEntryType.image,
      content: path,
    );
  }

  Future<void> _send(int introVersionId) async {
    final plotId = widget.plotId;
    final text = _composerController.text.trim();
    if (plotId == null || text.isEmpty) return;
    final type = switch (_composerMode) {
      _ComposerMode.narrator => IntroEntryType.narrator,
      _ComposerMode.user => IntroEntryType.user,
      _ComposerMode.character => IntroEntryType.character,
    };
    await _repository.add(
      plotId: plotId,
      introVersionId: introVersionId,
      characterId: type == IntroEntryType.character
          ? _selectedCharacterId
          : null,
      type: type,
      content: text,
    );
    _composerController.clear();
  }

  bool _aiGeneratingIntro = false;

  /// 인트로 탭의 'AI로 생성' 버튼. 프리셋을 고르고(선택) 짧은 지시를 준 뒤, 지금 플롯의
  /// 제목/설명/등록된 캐릭터를 맥락으로 첫 상황(나레이션+캐릭터 대사)을 몇 줄 만들어서
  /// 지금 보고 있는 인트로 버전 끝에 이어붙인다.
  Future<void> _aiGenerateIntro(int introVersionId, List<Character> characters) async {
    final l10n = AppLocalizations.of(context)!;
    final plotId = widget.plotId;
    if (plotId == null) return;
    final presets = await AiPresetRepository(AppDatabase.instance).watchAll().first;
    if (!mounted) return;
    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.plotAiGeneratePresetEmptyHint)),
      );
      return;
    }
    final request = await _showAiIntroDialog(presets);
    if (request == null) return;

    setState(() => _aiGeneratingIntro = true);
    try {
      final plot = await PlotRepository(AppDatabase.instance).getById(plotId);
      final lines = await PlotAiGeneratorService(AppDatabase.instance).generateIntro(
        preset: request.preset,
        plotTitle: plot?.title ?? '',
        plotDescription: plot?.description ?? '',
        characterNames: characters.map((c) => c.name).toList(),
        userPrompt: request.prompt,
      );
      if (lines.isEmpty) throw StateError('AI가 올바른 형식으로 응답하지 않았어요.');
      final characterIdByName = {for (final c in characters) c.name: c.id};
      for (final line in lines) {
        final characterId = line.isCharacterLine ? characterIdByName[line.characterName] : null;
        await _repository.add(
          plotId: plotId,
          introVersionId: introVersionId,
          characterId: characterId,
          type: line.isCharacterLine && characterId != null ? IntroEntryType.character : IntroEntryType.narrator,
          content: line.content,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.plotAiGenerateFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _aiGeneratingIntro = false);
    }
  }

  Future<_AiIntroRequest?> _showAiIntroDialog(List<AiPreset> presets) {
    final l10n = AppLocalizations.of(context)!;
    var selected = presets.first;
    final promptController = TextEditingController();
    return showDialog<_AiIntroRequest>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: _cardBg,
            title: Text(l10n.plotEditIntroAiGenerateButton, style: TextStyle(color: _textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _p.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _borderGrey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AiPreset>(
                      value: selected,
                      isExpanded: true,
                      dropdownColor: _p.background,
                      style: TextStyle(color: _textPrimary, fontSize: 14),
                      items: presets.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                      onChanged: (preset) {
                        if (preset != null) setDialogState(() => selected = preset);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: promptController,
                  maxLines: 3,
                  minLines: 2,
                  style: TextStyle(color: _textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.plotAiGeneratePromptHint,
                    hintStyle: TextStyle(color: _textFaint, fontSize: 13),
                    filled: true,
                    fillColor: _p.background,
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.commonCancel, style: TextStyle(color: _mutedText)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(
                  _AiIntroRequest(preset: selected, prompt: promptController.text),
                ),
                child: Text(l10n.plotAiGenerateSubmitButton, style: TextStyle(color: _purple)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _reorder(
    List<IntroEntry> entries,
    int oldIndex,
    int newIndex,
  ) async {
    final reordered = List<IntroEntry>.from(entries);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    await _repository.reorder(reordered.map((e) => e.id).toList());
  }

  Future<void> _editEntry(IntroEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: entry.content);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          l10n.plotEditEditContentDialogTitle,
          style: TextStyle(color: _textPrimary),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          style: TextStyle(color: _textPrimary),
          decoration: InputDecoration(
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
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(
              l10n.commonSave,
              style: TextStyle(color: _purple),
            ),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _repository.updateContent(entry.id, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plotId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppLocalizations.of(context)!.plotEditIntroSavePlotFirst,
            textAlign: TextAlign.center,
            style: TextStyle(color: _textFaint, fontSize: 13),
          ),
        ),
      );
    }
    return StreamBuilder<List<Character>>(
      stream: _characterRepository.watchByPlot(widget.plotId!),
      builder: (context, characterSnapshot) {
        final characters = characterSnapshot.data ?? const [];
        return StreamBuilder<List<IntroVersion>>(
          stream: _repository.watchVersions(widget.plotId!),
          builder: (context, versionSnapshot) {
            final versions = versionSnapshot.data ?? const [];
            if (versions.isEmpty) {
              return Center(
                child: CircularProgressIndicator(color: _purple),
              );
            }
            final currentIndex = _selectedVersionIndex.clamp(
              0,
              versions.length - 1,
            );
            final currentVersion = versions[currentIndex];
            return Column(
              children: [
                _buildVersionSwitcher(context, versions, currentIndex),
                Expanded(
                  child: StreamBuilder<List<IntroEntry>>(
                    stream: _repository.watchByVersion(currentVersion.id),
                    builder: (context, snapshot) {
                      final entries = snapshot.data ?? const [];
                      final l10n = AppLocalizations.of(context)!;
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.plotEditIntroFirstSceneTitle,
                                  style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _aiGeneratingIntro
                                    ? null
                                    : () => _aiGenerateIntro(currentVersion.id, characters),
                                style: TextButton.styleFrom(
                                  foregroundColor: _purple,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: _aiGeneratingIntro
                                    ? SizedBox(
                                        width: 13,
                                        height: 13,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: _purple),
                                      )
                                    : const Icon(Icons.auto_awesome, size: 15),
                                label: Text(l10n.plotEditIntroAiGenerateButton, style: const TextStyle(fontSize: 12.5)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (entries.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  l10n.plotEditIntroEmptyMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _textFaint,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          if (entries.isNotEmpty)
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              buildDefaultDragHandles: false,
                              itemCount: entries.length,
                              onReorderItem: (oldIndex, newIndex) =>
                                  _reorder(entries, oldIndex, newIndex),
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                return Padding(
                                  key: ValueKey(entry.id),
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: 8,
                                            right: 4,
                                          ),
                                          child: Icon(
                                            Icons.drag_indicator,
                                            color: _textGhost,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildEntryLine(
                                          entry,
                                          characters,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          if (entries.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            _buildProfileMarker(),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                _buildComposer(currentVersion.id, characters),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVersionSwitcher(
    BuildContext context,
    List<IntroVersion> versions,
    int currentIndex,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.characterDetailIntroSectionTitle,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _RoundIconButton(
            icon: Icons.chevron_left,
            onTap: currentIndex > 0
                ? () => setState(() => _selectedVersionIndex = currentIndex - 1)
                : () {},
          ),
          const SizedBox(width: 8),
          Text(
            '${currentIndex + 1}/${versions.length}',
            style: TextStyle(color: _textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 8),
          _RoundIconButton(
            icon: Icons.chevron_right,
            onTap: currentIndex < versions.length - 1
                ? () => setState(() => _selectedVersionIndex = currentIndex + 1)
                : () {},
          ),
          const SizedBox(width: 8),
          _RoundIconButton(
            icon: Icons.add,
            onTap: () async {
              final newId = await _repository.addVersion(widget.plotId!);
              final newVersions = await _repository.getVersions(widget.plotId!);
              final newIndex = newVersions.indexWhere((v) => v.id == newId);
              if (mounted)
                setState(
                  () => _selectedVersionIndex = newIndex < 0 ? 0 : newIndex,
                );
            },
          ),
          if (versions.length > 1) ...[
            const SizedBox(width: 8),
            _RoundIconButton(
              icon: Icons.delete_outline,
              onTap: () async {
                await _repository.deleteVersion(versions[currentIndex].id);
                if (mounted) setState(() => _selectedVersionIndex = 0);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEntryLine(IntroEntry entry, List<Character> characters) {
    switch (entry.type) {
      case IntroEntryType.character:
        return _buildCharacterLine(entry, characters);
      case IntroEntryType.narrator:
        return _buildNarratorLine(entry);
      case IntroEntryType.user:
        return _buildUserLine(entry);
      case IntroEntryType.image:
        return _buildImageLine(entry);
      case IntroEntryType.characterPick:
        // 비주얼 노벨 전용 마커라 스토리챗 플롯의 인트로 탭에는 나타나지 않는다.
        return const SizedBox.shrink();
    }
  }

  Widget _buildEditDeleteButtons(IntroEntry entry) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundIconButton(
          icon: Icons.edit_outlined,
          onTap: () => _editEntry(entry),
        ),
        const SizedBox(width: 8),
        _RoundIconButton(
          icon: Icons.delete_outline,
          onTap: () => _repository.delete(entry.id),
        ),
      ],
    );
  }

  Widget _buildCharacterLine(IntroEntry entry, List<Character> characters) {
    final match = characters.where((c) => c.id == entry.characterId);
    final character = match.isEmpty ? null : match.first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocalAvatar(
          imagePath: character?.imagePath,
          radius: 14,
          icon: Icons.pets,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                character?.name ??
                    AppLocalizations.of(context)!.chatDefaultCharacterName,
                style: TextStyle(color: _purple, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: PaletteScope.of(context).surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        entry.content,
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildEditDeleteButtons(entry),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarratorLine(IntroEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Row(
        children: [
          Icon(Icons.reorder, color: _mutedText, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              entry.content,
              style: TextStyle(color: _mutedText, fontSize: 14),
            ),
          ),
          _buildEditDeleteButtons(entry),
        ],
      ),
    );
  }

  Widget _buildUserLine(IntroEntry entry) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildEditDeleteButtons(entry),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: PaletteScope.of(context).primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              entry.content,
              style: TextStyle(color: _textPrimary, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageLine(IntroEntry entry) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(entry.content),
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        _RoundIconButton(
          icon: Icons.delete_outline,
          onTap: () => _repository.delete(entry.id),
        ),
      ],
    );
  }

  Widget _buildProfileMarker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _pillGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_indicator, color: _textFaint, size: 16),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!.plotEditProfileMarkerLabel,
            style: TextStyle(color: _mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(int introVersionId, List<Character> characters) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: _pillGrey)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    color: _textSecondary,
                    size: 20,
                  ),
                  onPressed: () => _pickAndAddImage(introVersionId),
                  tooltip: l10n.plotEditAddImageTooltip,
                ),
                const SizedBox(width: 8),
                _ComposerTab(
                  icon: Icons.reorder,
                  label: l10n.plotEditComposerNarrator,
                  selected: _composerMode == _ComposerMode.narrator,
                  onTap: () =>
                      setState(() => _composerMode = _ComposerMode.narrator),
                ),
                const SizedBox(width: 16),
                _ComposerTab(
                  icon: Icons.visibility_outlined,
                  label: l10n.chatDefaultUserName,
                  selected: _composerMode == _ComposerMode.user,
                  onTap: () =>
                      setState(() => _composerMode = _ComposerMode.user),
                ),
                if (characters.length == 1) ...[
                  const SizedBox(width: 16),
                  _ComposerTab(
                    icon: Icons.pets,
                    label: characters.first.name,
                    selected: _composerMode == _ComposerMode.character,
                    onTap: () => setState(() {
                      _composerMode = _ComposerMode.character;
                      _selectedCharacterId = characters.first.id;
                    }),
                  ),
                ] else if (characters.length > 1) ...[
                  const SizedBox(width: 16),
                  _CharacterDropdownTab(
                    characters: characters,
                    selectedCharacterId: _selectedCharacterId,
                    selected: _composerMode == _ComposerMode.character,
                    onSelected: (id) => setState(() {
                      _composerMode = _ComposerMode.character;
                      _selectedCharacterId = id;
                    }),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _composerController,
                  style: TextStyle(color: _textPrimary, fontSize: 14),
                  onSubmitted: (_) => _send(introVersionId),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: _composerHint(context, characters),
                    hintStyle: TextStyle(
                      color: _textFaint,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _pillGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '{{user}}',
                  style: TextStyle(color: _textSecondary, fontSize: 12),
                ),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: _borderGrey,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.arrow_upward,
                    color: _mutedText,
                    size: 16,
                  ),
                  onPressed: () => _send(introVersionId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: PaletteScope.of(context).surfaceAlt,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: PaletteScope.of(context).textSecondary, size: 14),
      ),
    );
  }
}

/// 캐릭터가 여러 명일 때 쓰는 컴포저 탭. 화면이 좁아 모든 캐릭터를 가로로 나열하면
/// 일부가 화면 밖으로 밀려나 선택할 수 없게 되는 문제를 피하려고, 탭 하나를 눌러
/// 팝업 메뉴에서 캐릭터를 고르는 방식으로 바꿨다.
class _CharacterDropdownTab extends StatelessWidget {
  const _CharacterDropdownTab({
    required this.characters,
    required this.selectedCharacterId,
    required this.selected,
    required this.onSelected,
  });

  final List<Character> characters;
  final int? selectedCharacterId;
  final bool selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final match = characters.where((c) => c.id == selectedCharacterId);
    final label = match.isEmpty
        ? AppLocalizations.of(context)!.chatDefaultCharacterName
        : match.first.name;
    final color = selected ? PaletteScope.of(context).textPrimary : PaletteScope.of(context).textFaint;
    return PopupMenuButton<int>(
      color: PaletteScope.of(context).surfaceAlt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final character in characters)
          PopupMenuItem(
            value: character.id,
            child: Text(
              character.name,
              style: TextStyle(color: PaletteScope.of(context).textPrimary),
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets, color: color, size: 14),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.arrow_drop_down, color: color, size: 16),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 4),
              Container(width: 24, height: 2, color: PaletteScope.of(context).textPrimary),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComposerTab extends StatelessWidget {
  const _ComposerTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? PaletteScope.of(context).textPrimary : PaletteScope.of(context).textFaint;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 4),
              Container(width: 24, height: 2, color: PaletteScope.of(context).textPrimary),
            ],
          ],
        ),
      ),
    );
  }
}

class _AboutTab extends StatefulWidget {
  const _AboutTab({
    required this.shortIntroController,
    required this.hashtags,
    required this.onHashtagsChanged,
    required this.coverImagePath,
    required this.onPickCoverImage,
    required this.characterForms,
  });

  final TextEditingController shortIntroController;
  final List<String> hashtags;
  final ValueChanged<List<String>> onHashtagsChanged;
  final String? coverImagePath;
  final VoidCallback onPickCoverImage;
  final List<_CharacterForm> characterForms;

  @override
  State<_AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<_AboutTab> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _cardBg => _p.surface;
  Color get _textPrimary => _p.textPrimary;
  Color get _textFaint => _p.textFaint;
  Color get _borderGrey => _p.border;
  Color get _purple => _p.primary;
  Color get _mutedText => _p.textMuted;
  Color get _pillGrey => _p.surfaceAlt;
  Color get _textSecondary => _p.textSecondary;
  /// 캐릭터별 소개 섹션의 펼침 상태. 인덱스 0(첫 캐릭터)만 기본으로 펼쳐둔다.
  final Set<int> _expandedCharacters = {0};
  final _imageStore = LocalImageStore();

  /// 캐릭터 소개 마크다운에 이미지를 첨부한다. 커서 위치에 마크다운 이미지 태그를 끼워 넣는다.
  Future<void> _addAboutImage(int index) async {
    final path = await _imageStore.pickAndSave('character_about');
    if (path == null || !mounted) return;
    final controller = widget.characterForms[index].aboutController;
    final text = controller.text;
    final selection = controller.selection;
    final insertAt = selection.isValid ? selection.start : text.length;
    final removeEnd = selection.isValid ? selection.end : text.length;
    final insertion = '![]($path)\n';
    final newText = text.replaceRange(insertAt, removeEnd, insertion);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: insertAt + insertion.length),
    );
  }

  Future<void> _addHashtag() async {
    if (widget.hashtags.length >= 10) return;
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(
          l10n.plotEditAddHashtagDialogTitle,
          style: TextStyle(color: _textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: _textPrimary),
          decoration: InputDecoration(
            hintText: l10n.plotEditHashtagHint,
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
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(
              l10n.commonAdd,
              style: TextStyle(color: _purple),
            ),
          ),
        ],
      ),
    );
    if (result != null &&
        result.isNotEmpty &&
        !widget.hashtags.contains(result)) {
      widget.onHashtagsChanged([...widget.hashtags, result]);
    }
  }

  void _removeHashtag(String tag) {
    widget.onHashtagsChanged(widget.hashtags.where((t) => t != tag).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.plotEditCoverTitle,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: widget.onPickCoverImage,
          child: widget.coverImagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.coverImagePath!),
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                )
              : DashedBox(
                  width: double.infinity,
                  height: 140,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: _purple, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        l10n.plotEditCoverImagePlaceholder,
                        style: TextStyle(
                          color: _textFaint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.plotEditShortIntroLabel,
              style: TextStyle(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.shortIntroController,
              style: TextStyle(color: _textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: l10n.plotEditShortIntroHint,
                hintStyle: TextStyle(color: _textFaint, fontSize: 13),
                filled: true,
                fillColor: PaletteScope.of(context).background,
                contentPadding: const EdgeInsets.all(12),
                counter: AnimatedBuilder(
                  animation: widget.shortIntroController,
                  builder: (context, _) => Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      l10n.plotEditCharCountLabel(
                        widget.shortIntroController.text.length,
                      ),
                      style: TextStyle(
                        color: _textFaint,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: PaletteScope.of(context).border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: PaletteScope.of(context).primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          l10n.plotEditHashtagsLabel,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.hashtags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in widget.hashtags)
                Chip(
                  label: Text('#$tag'),
                  backgroundColor: _pillGrey,
                  labelStyle: TextStyle(
                    color: _textPrimary,
                    fontSize: 12,
                  ),
                  deleteIcon: Icon(
                    Icons.close,
                    size: 14,
                    color: _mutedText,
                  ),
                  onDeleted: () => _removeHashtag(tag),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide.none,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: widget.hashtags.length >= 10 ? null : _addHashtag,
          style: OutlinedButton.styleFrom(
            foregroundColor: _textSecondary,
            side: BorderSide(color: PaletteScope.of(context).border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.add, size: 14),
          label: Text(
            l10n.plotEditHashtagAddButton(widget.hashtags.length),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 28),
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
          l10n.plotEditAboutSectionDescription,
          style: TextStyle(color: _textFaint, fontSize: 12),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < widget.characterForms.length; i++) ...[
          _buildCharacterAboutSection(context, i),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildCharacterAboutSection(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context)!;
    final form = widget.characterForms[index];
    final expanded = _expandedCharacters.contains(index);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() {
            if (expanded) {
              _expandedCharacters.remove(index);
            } else {
              _expandedCharacters.add(index);
            }
          }),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: form.nameController,
                  builder: (context, _) {
                    final name = form.nameController.text.trim();
                    return Text(
                      '## ${name.isEmpty ? l10n.plotEditDefaultCharacterName(index + 1) : name}',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () => _addAboutImage(index),
                tooltip: l10n.plotEditAddImageTooltip,
                icon: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: _mutedText,
                  size: 20,
                ),
              ),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: _mutedText,
              ),
            ],
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 8),
          TextField(
            controller: form.aboutController,
            maxLines: 6,
            minLines: 3,
            style: TextStyle(color: _textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: l10n.plotEditAboutFieldHint,
              hintStyle: TextStyle(color: _textFaint, fontSize: 13),
              filled: true,
              fillColor: PaletteScope.of(context).background,
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: PaletteScope.of(context).border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: PaletteScope.of(context).primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
