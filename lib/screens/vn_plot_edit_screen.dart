import 'dart:io';

import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/local_image_store.dart';
import '../data/repositories/character_repository.dart';
import '../data/repositories/intro_entry_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../data/repositories/vn_background_repository.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';
import '../l10n/app_localizations.dart';
import '../widgets/dashed_box.dart';
import '../widgets/local_avatar.dart';

/// 비주얼 노벨 플롯의 제작/편집 화면. Zeta의 '비주얼 노벨' 플롯 편집 플로우를 클론 코딩했다.
///
/// [PlotEditScreen](StoryChat 플롯 편집 화면)과 같은 시각적 언어(패딩, 카드 모양, 팔레트 색)를
/// 따르지만, 콘텐츠 구성이 달라서 별도 화면으로 분리했다:
/// - 콘텐츠(세계관/등장인물/플레이어블 캐릭터/배경)
/// - 인트로(대화형·연출형 턴 + 선택지)
/// - 소개(짧은 소개 + 커버)
/// - 플레이 설정(입력 방식/AI 어시스트/주사위)
///
/// StoryChat 편집 화면은 저장 버튼을 누르면 화면을 닫지만(그 뒤 다시 열어야 로어북/인트로를
/// 편집할 수 있음), 이 화면은 콘텐츠 탭 안에 배치/저장이 즉시 반영되는 섹션(등장인물, 배경)과
/// 상단 저장 버튼으로 한 번에 저장되는 필드(제목, 세계관, 해시태그)가 한 탭에 섞여 있어서,
/// 저장 버튼이 화면을 닫지 않고 대신 plotId를 확보해서 화면에 머무른 채 계속 편집할 수 있게
/// 했다. 신규 생성 시 plotId가 생기기 전까지는 등장인물/배경/인트로/플레이 설정 섹션이
/// '먼저 저장해주세요' 안내로 비활성화된다(StoryChat 편집 화면의 로어북/인트로 탭이 plotId
/// 없을 때 보여주는 안내와 같은 패턴).
class VnPlotEditScreen extends StatefulWidget {
  const VnPlotEditScreen({super.key, this.plotId});

  /// null이면 신규 제작, 값이 있으면 기존 비주얼 노벨 플롯 수정.
  final int? plotId;

  @override
  State<VnPlotEditScreen> createState() => _VnPlotEditScreenState();
}

class _VnPlotEditScreenState extends State<VnPlotEditScreen>
    with SingleTickerProviderStateMixin {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;

  late final TabController _tabController;
  late final PlotRepository _plotRepository;

  final _titleController = TextEditingController();
  final _worldviewController = TextEditingController();
  final _shortIntroController = TextEditingController();
  final _imageStore = LocalImageStore();

  List<String> _hashtags = [];
  String? _coverImagePath;

  /// widget.plotId로 시작하지만, 신규 생성 중 상단 저장을 처음 누르면 새로 생긴 id로
  /// 갱신된다(화면은 닫히지 않고 계속 편집 가능해진다).
  int? _plotId;

  bool _loading = true;
  bool _saving = false;
  bool _initialLoadStarted = false;

  static const _tabCount = 4;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _plotRepository = PlotRepository(AppDatabase.instance);
    _plotId = widget.plotId;
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
    if (_plotId != null) {
      final plot = await _plotRepository.getById(_plotId!);
      if (!mounted) return;
      _titleController.text = plot?.title ?? '';
      _worldviewController.text = plot?.description ?? '';
      _shortIntroController.text = plot?.shortIntro ?? '';
      _hashtags = (plot?.hashtags ?? '')
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      _coverImagePath = plot?.coverImagePath;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickCoverImage() async {
    final path = await _imageStore.pickAndSave('vn_cover');
    if (path != null && mounted) setState(() => _coverImagePath = path);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.vnEditTitleRequiredMessage)),
      );
      return;
    }
    setState(() => _saving = true);
    final id = await _plotRepository.upsertPlot(
      plotId: _plotId,
      title: _titleController.text.trim(),
      description: _worldviewController.text.trim(),
      shortIntro: _shortIntroController.text.trim(),
      hashtags: _hashtags,
      coverImagePath: _coverImagePath,
      plotType: PlotType.visualNovel,
    );
    if (!mounted) return;
    setState(() {
      _plotId = id;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.vnEditSavedMessage)),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _worldviewController.dispose();
    _shortIntroController.dispose();
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
                        _VnContentsTab(
                          plotId: _plotId,
                          titleController: _titleController,
                          worldviewController: _worldviewController,
                          hashtags: _hashtags,
                          onHashtagsChanged: (tags) =>
                              setState(() => _hashtags = tags),
                        ),
                        _VnIntroTab(plotId: _plotId),
                        _VnInfoTab(
                          shortIntroController: _shortIntroController,
                          coverImagePath: _coverImagePath,
                          onPickCoverImage: _pickCoverImage,
                        ),
                        _VnPlaySettingsTab(plotId: _plotId),
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
        _isEditing ? l10n.vnEditAppBarTitleEdit : l10n.vnEditAppBarTitleCreate,
        style: TextStyle(
          color: _textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
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
                  ? l10n.vnEditSaveButtonEdit
                  : l10n.vnEditSaveButtonCreate,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.vnEditTabContents,
      l10n.characterDetailIntroSectionTitle,
      l10n.vnEditTabInfo,
      l10n.vnEditTabPlaySettings,
    ];
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: _textPrimary,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: _textPrimary,
      unselectedLabelColor: PaletteScope.of(context).textFaint,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      tabs: labels.map((t) => Tab(text: t)).toList(),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// 공용 소형 위젯
// ────────────────────────────────────────────────────────────────────────

class _VnSectionHeader extends StatelessWidget {
  const _VnSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: PaletteScope.of(context).textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// plotId가 아직 없어서 (또는 다른 이유로) 비활성화된 섹션에 보여주는 안내 문구.
class _VnPlaceholderMessage extends StatelessWidget {
  const _VnPlaceholderMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: PaletteScope.of(context).textFaint,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// 이미지 자리(전신 이미지/배경/커버 등)에 재사용하는 픽커. 이미지가 있으면 미리보기 +
/// 우상단 제거 버튼(옵션)을, 없으면 [DashedBox] 자리표시자를 보여준다.
class _VnImagePicker extends StatelessWidget {
  const _VnImagePicker({
    required this.imagePath,
    required this.onTap,
    this.onRemove,
    this.width = 96,
    this.height = 96,
    this.placeholderText,
    this.borderRadius = 10,
  });

  final String? imagePath;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final double width;
  final double height;
  final String? placeholderText;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path != null && path.isNotEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Image.file(
                File(path),
                width: width,
                height: height,
                fit: BoxFit.cover,
              ),
            ),
            if (onRemove != null)
              Positioned(
                right: 4,
                top: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: PaletteScope.of(context).textSecondary,
                      size: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: DashedBox(
        width: width,
        height: height,
        borderRadius: borderRadius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: PaletteScope.of(context).primary, size: 20),
            if (placeholderText != null) ...[
              const SizedBox(height: 2),
              Text(
                placeholderText!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PaletteScope.of(context).textFaint,
                  fontSize: 9,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 인물/배경 삭제 전에 뜨는 짧은 확인 다이얼로그. 표정 세트나 인트로에서 참조 중일 수 있어서
/// 실수로 지우는 걸 막는다.
Future<bool> _confirmDelete(BuildContext context, String message) async {
  final l10n = AppLocalizations.of(context)!;
  final palette = PaletteScope.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: palette.surface,
      content: Text(message, style: TextStyle(color: palette.textPrimary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel, style: TextStyle(color: palette.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.commonDelete, style: TextStyle(color: palette.danger)),
        ),
      ],
    ),
  );
  return result ?? false;
}

String _emotionLabel(AppLocalizations l10n, VnEmotion emotion) {
  switch (emotion) {
    case VnEmotion.joy:
      return l10n.vnEditExpressionJoy;
    case VnEmotion.sad:
      return l10n.vnEditExpressionSad;
    case VnEmotion.angry:
      return l10n.vnEditExpressionAngry;
    case VnEmotion.worried:
      return l10n.vnEditExpressionWorried;
    case VnEmotion.surprised:
      return l10n.vnEditExpressionSurprised;
    case VnEmotion.confused:
      return l10n.vnEditExpressionConfused;
  }
}

String _difficultyLabel(AppLocalizations l10n, VnDiceDifficulty difficulty) {
  switch (difficulty) {
    case VnDiceDifficulty.easy:
      return l10n.vnEditDifficultyEasy;
    case VnDiceDifficulty.medium:
      return l10n.vnEditDifficultyMedium;
    case VnDiceDifficulty.hard:
      return l10n.vnEditDifficultyHard;
  }
}

// ────────────────────────────────────────────────────────────────────────
// 탭 1: 콘텐츠 (세계관 / 등장인물 / 플레이어블 캐릭터 / 배경)
// ────────────────────────────────────────────────────────────────────────

class _VnContentsTab extends StatefulWidget {
  const _VnContentsTab({
    required this.plotId,
    required this.titleController,
    required this.worldviewController,
    required this.hashtags,
    required this.onHashtagsChanged,
  });

  final int? plotId;
  final TextEditingController titleController;
  final TextEditingController worldviewController;
  final List<String> hashtags;
  final ValueChanged<List<String>> onHashtagsChanged;

  @override
  State<_VnContentsTab> createState() => _VnContentsTabState();
}

class _VnContentsTabState extends State<_VnContentsTab> {
  late final CharacterRepository _characterRepository;
  late final VnBackgroundRepository _backgroundRepository;
  final _imageStore = LocalImageStore();

  @override
  void initState() {
    super.initState();
    _characterRepository = CharacterRepository(AppDatabase.instance);
    _backgroundRepository = VnBackgroundRepository(AppDatabase.instance);
  }

  Future<void> _addHashtag() async {
    if (widget.hashtags.length >= 10) return;
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: palette.surface,
        title: Text(
          l10n.vnEditAddHashtagDialogTitle,
          style: TextStyle(color: palette.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: palette.textPrimary),
          decoration: InputDecoration(
            hintText: l10n.vnEditHashtagHint,
            hintStyle: TextStyle(color: palette.textFaint),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: palette.border)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: palette.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel, style: TextStyle(color: palette.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(l10n.commonAdd, style: TextStyle(color: palette.primary)),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && !widget.hashtags.contains(result)) {
      widget.onHashtagsChanged([...widget.hashtags, result]);
    }
  }

  void _removeHashtag(String tag) {
    widget.onHashtagsChanged(widget.hashtags.where((t) => t != tag).toList());
  }

  Future<void> _addCharacter({required bool isPlayable, required int sortOrder}) async {
    final plotId = widget.plotId;
    if (plotId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VnCharacterFormScreen(
          plotId: plotId,
          isPlayable: isPlayable,
          sortOrder: sortOrder,
        ),
      ),
    );
  }

  void _editCharacter(Character character) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VnCharacterFormScreen(
          plotId: character.plotId,
          characterId: character.id,
          isPlayable: character.isPlayable,
          sortOrder: character.sortOrder,
        ),
      ),
    );
  }

  Future<void> _deleteCharacter(Character character) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmDelete(context, l10n.vnEditDeleteCharacterConfirmMessage);
    if (confirmed) await _characterRepository.delete(character.id);
  }

  Future<void> _pickPlayableFromExisting(List<Character> nonPlayable) async {
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.vnEditSelectExistingCharacterDialogTitle,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (nonPlayable.isEmpty)
                  _VnPlaceholderMessage(l10n.vnEditSelectExistingCharacterEmptyMessage)
                else
                  ...nonPlayable.map(
                    (character) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: LocalAvatar(imagePath: character.imagePath, radius: 20),
                      title: Text(character.name, style: TextStyle(color: palette.textPrimary)),
                      onTap: () async {
                        await _characterRepository.setPlayable(character.id, true);
                        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addBackground() async {
    final plotId = widget.plotId;
    if (plotId == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _VnBackgroundFormDialog(
        plotId: plotId,
        repository: _backgroundRepository,
        imageStore: _imageStore,
      ),
    );
  }

  Future<void> _editBackground(VnBackground background) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _VnBackgroundFormDialog(
        plotId: background.plotId,
        repository: _backgroundRepository,
        imageStore: _imageStore,
        background: background,
      ),
    );
  }

  Future<void> _deleteBackground(VnBackground background) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmDelete(context, l10n.vnEditDeleteBackgroundConfirmMessage);
    if (confirmed) await _backgroundRepository.delete(background.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    final plotId = widget.plotId;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _VnSectionHeader(title: l10n.vnEditTitleFieldLabel),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: widget.titleController,
                style: TextStyle(color: palette.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n.vnEditTitleFieldHint,
                  hintStyle: TextStyle(color: palette.textFaint, fontSize: 13),
                  filled: true,
                  fillColor: palette.background,
                  contentPadding: const EdgeInsets.all(12),
                  counter: AnimatedBuilder(
                    animation: widget.titleController,
                    builder: (context, _) => Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        l10n.vnEditCharCountLabel(widget.titleController.text.length),
                        style: TextStyle(color: palette.textFaint, fontSize: 11),
                      ),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: palette.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: palette.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _VnSectionHeader(title: l10n.vnEditWorldviewLabel),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: widget.worldviewController,
            maxLines: 8,
            minLines: 4,
            style: TextStyle(color: palette.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: l10n.vnEditWorldviewHint,
              hintStyle: TextStyle(color: palette.textFaint, fontSize: 13),
              filled: true,
              fillColor: palette.background,
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: palette.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: palette.primary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _VnSectionHeader(title: l10n.vnEditHashtagsLabel),
        const SizedBox(height: 8),
        if (widget.hashtags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in widget.hashtags)
                Chip(
                  label: Text('#$tag'),
                  backgroundColor: palette.surfaceAlt,
                  labelStyle: TextStyle(color: palette.textPrimary, fontSize: 12),
                  deleteIcon: Icon(Icons.close, size: 14, color: palette.textMuted),
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
            foregroundColor: palette.textSecondary,
            side: BorderSide(color: palette.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.add, size: 14),
          label: Text(
            l10n.vnEditHashtagAddButton(widget.hashtags.length),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 28),
        _VnSectionHeader(title: l10n.vnEditCharactersSectionTitle),
        const SizedBox(height: 12),
        if (plotId == null)
          _VnPlaceholderMessage(l10n.vnEditSavePlotFirstMessage)
        else
          StreamBuilder<List<Character>>(
            stream: _characterRepository.watchNonPlayableByPlot(plotId),
            builder: (context, snapshot) {
              final characters = snapshot.data ?? const [];
              return Column(
                children: [
                  if (characters.isEmpty)
                    _VnPlaceholderMessage(l10n.vnEditCharactersEmptyMessage)
                  else
                    for (final character in characters) ...[
                      _VnCharacterRow(
                        character: character,
                        onTap: () => _editCharacter(character),
                        onDelete: () => _deleteCharacter(character),
                      ),
                      const SizedBox(height: 10),
                    ],
                  OutlinedButton.icon(
                    onPressed: () => _addCharacter(isPlayable: false, sortOrder: characters.length),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.textPrimary,
                      side: BorderSide(color: palette.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      l10n.vnEditAddCharacterButton,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            },
          ),
        const SizedBox(height: 28),
        _VnSectionHeader(title: l10n.vnEditPlayableSectionTitle),
        const SizedBox(height: 12),
        if (plotId == null)
          _VnPlaceholderMessage(l10n.vnEditSavePlotFirstMessage)
        else
          StreamBuilder<List<Character>>(
            stream: _characterRepository.watchPlayableByPlot(plotId),
            builder: (context, playableSnapshot) {
              final playable = playableSnapshot.data ?? const [];
              return StreamBuilder<List<Character>>(
                stream: _characterRepository.watchNonPlayableByPlot(plotId),
                builder: (context, nonPlayableSnapshot) {
                  final nonPlayable = nonPlayableSnapshot.data ?? const [];
                  return Column(
                    children: [
                      if (playable.isEmpty)
                        _VnPlaceholderMessage(l10n.vnEditPlayableEmptyMessage)
                      else
                        for (final character in playable) ...[
                          _VnCharacterRow(
                            character: character,
                            onTap: () => _editCharacter(character),
                            onDelete: () => _deleteCharacter(character),
                          ),
                          const SizedBox(height: 10),
                        ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickPlayableFromExisting(nonPlayable),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: palette.textPrimary,
                                side: BorderSide(color: palette.border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.add, size: 16),
                              label: Text(
                                l10n.vnEditSelectExistingCharacterButton,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _addCharacter(isPlayable: true, sortOrder: playable.length),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: palette.textPrimary,
                                side: BorderSide(color: palette.border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.add, size: 16),
                              label: Text(
                                l10n.vnEditAddCharacterButton,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        const SizedBox(height: 28),
        _VnSectionHeader(title: l10n.vnEditBackgroundsSectionTitle),
        const SizedBox(height: 12),
        if (plotId == null)
          _VnPlaceholderMessage(l10n.vnEditSavePlotFirstMessage)
        else
          StreamBuilder<List<VnBackground>>(
            stream: _backgroundRepository.watchByPlot(plotId),
            builder: (context, snapshot) {
              final backgrounds = snapshot.data ?? const [];
              return Column(
                children: [
                  if (backgrounds.isEmpty)
                    _VnPlaceholderMessage(l10n.vnEditBackgroundsEmptyMessage)
                  else
                    for (final background in backgrounds) ...[
                      _VnBackgroundRow(
                        background: background,
                        onTap: () => _editBackground(background),
                        onDelete: () => _deleteBackground(background),
                      ),
                      const SizedBox(height: 10),
                    ],
                  OutlinedButton.icon(
                    onPressed: _addBackground,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.textPrimary,
                      side: BorderSide(color: palette.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(
                      l10n.vnEditAddBackgroundButton,
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

class _VnCharacterRow extends StatelessWidget {
  const _VnCharacterRow({required this.character, required this.onTap, required this.onDelete});

  final Character character;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteScope.of(context);
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              LocalAvatar(imagePath: character.imagePath, radius: 22, icon: Icons.pets),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: TextStyle(color: palette.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    if (character.aboutText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        character.aboutText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: palette.textMuted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: palette.textMuted, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VnBackgroundRow extends StatelessWidget {
  const _VnBackgroundRow({required this.background, required this.onTap, required this.onDelete});

  final VnBackground background;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteScope.of(context);
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(background.imagePath),
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 44,
                    height: 44,
                    color: palette.surfaceAlt,
                    child: Icon(Icons.image_outlined, color: palette.textFaint, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  background.title,
                  style: TextStyle(color: palette.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: palette.textMuted, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// '새 배경 추가'/배경 수정 다이얼로그. 제목 + 이미지만 다루는 단순한 폼이라 별도 화면
/// 대신 다이얼로그로 처리한다.
class _VnBackgroundFormDialog extends StatefulWidget {
  const _VnBackgroundFormDialog({
    required this.plotId,
    required this.repository,
    required this.imageStore,
    this.background,
  });

  final int plotId;
  final VnBackgroundRepository repository;
  final LocalImageStore imageStore;
  final VnBackground? background;

  @override
  State<_VnBackgroundFormDialog> createState() => _VnBackgroundFormDialogState();
}

class _VnBackgroundFormDialogState extends State<_VnBackgroundFormDialog> {
  late final TextEditingController _titleController;
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.background?.title ?? '');
    _imagePath = widget.background?.imagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final path = await widget.imageStore.pickAndSave('vn_bg');
    if (path != null && mounted) setState(() => _imagePath = path);
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final imagePath = _imagePath;
    if (title.isEmpty || imagePath == null) return;
    setState(() => _saving = true);
    if (widget.background == null) {
      await widget.repository.add(plotId: widget.plotId, title: title, imagePath: imagePath);
    } else {
      await widget.repository.update(id: widget.background!.id, title: title, imagePath: imagePath);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    return AlertDialog(
      backgroundColor: palette.surface,
      title: Text(
        widget.background == null ? l10n.vnEditAddBackgroundDialogTitle : l10n.vnEditEditBackgroundDialogTitle,
        style: TextStyle(color: palette.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _VnImagePicker(
              imagePath: _imagePath,
              onTap: _pickImage,
              width: 120,
              height: 80,
              borderRadius: 10,
              placeholderText: l10n.vnEditBackgroundImageLabel,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _titleController,
            autofocus: true,
            style: TextStyle(color: palette.textPrimary),
            decoration: InputDecoration(
              labelText: l10n.vnEditBackgroundTitleLabel,
              hintText: l10n.vnEditBackgroundTitleHint,
              hintStyle: TextStyle(color: palette.textFaint, fontSize: 13),
              labelStyle: TextStyle(color: palette.textFaint),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: palette.border)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: palette.primary)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel, style: TextStyle(color: palette.textMuted)),
        ),
        TextButton(
          onPressed: _saving ? null : _submit,
          child: Text(l10n.commonSave, style: TextStyle(color: palette.primary)),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// 등장인물/플레이어블 캐릭터 생성·수정 화면 (전신 이미지 + 표정 세트)
// ────────────────────────────────────────────────────────────────────────

class _VnCharacterFormScreen extends StatefulWidget {
  const _VnCharacterFormScreen({
    required this.plotId,
    this.characterId,
    required this.isPlayable,
    required this.sortOrder,
  });

  final int plotId;
  final int? characterId;
  final bool isPlayable;
  final int sortOrder;

  @override
  State<_VnCharacterFormScreen> createState() => _VnCharacterFormScreenState();
}

class _VnCharacterFormScreenState extends State<_VnCharacterFormScreen> {
  late final CharacterRepository _characterRepository;
  final _imageStore = LocalImageStore();

  final _nameController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _personaController = TextEditingController();
  String? _imagePath;

  /// 신규 생성 도중(아직 characterId가 없을 때)에는 [_characterId]가 null이다.
  /// 표정 세트는 캐릭터 row가 존재해야 저장할 수 있어서, 최초 저장 전까지는
  /// '먼저 인물을 저장해주세요' 안내로 비활성화한다.
  int? _characterId;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _characterRepository = CharacterRepository(AppDatabase.instance);
    _characterId = widget.characterId;
    _load();
  }

  Future<void> _load() async {
    if (widget.characterId != null) {
      final character = await _characterRepository.getById(widget.characterId!);
      if (!mounted) return;
      _nameController.text = character?.name ?? '';
      _shortDescController.text = character?.aboutText ?? '';
      _personaController.text = character?.description ?? '';
      _imagePath = character?.imagePath;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescController.dispose();
    _personaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final path = await _imageStore.pickAndSave('vn_char');
    if (path != null && mounted) setState(() => _imagePath = path);
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    if (_characterId == null) {
      final newId = await _characterRepository.add(
        plotId: widget.plotId,
        name: name,
        description: _personaController.text.trim(),
        imagePath: _imagePath,
        sortOrder: widget.sortOrder,
        aboutText: _shortDescController.text.trim(),
        isPlayable: widget.isPlayable,
      );
      if (!mounted) return;
      setState(() {
        _characterId = newId;
        _saving = false;
      });
    } else {
      await _characterRepository.update(
        id: _characterId!,
        name: name,
        description: _personaController.text.trim(),
        imagePath: _imagePath,
        aboutText: _shortDescController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final id = _characterId;
    if (id == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirmDelete(context, l10n.vnEditDeleteCharacterConfirmMessage);
    if (confirmed) {
      await _characterRepository.delete(id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textPrimary, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _characterId == null ? l10n.vnEditCharacterFormTitleCreate : l10n.vnEditCharacterFormTitleEdit,
          style: TextStyle(color: palette.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_characterId != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: palette.textMuted),
              onPressed: _delete,
            ),
          TextButton(
            onPressed: _saving ? null : _submit,
            child: Text(
              l10n.commonConfirm,
              style: TextStyle(color: palette.primary, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: palette.primary))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _VnSectionHeader(title: l10n.vnEditCharacterNameLabel),
                  const SizedBox(height: 8),
                  _VnPlainField(controller: _nameController, hintText: l10n.vnEditCharacterNameHint),
                  const SizedBox(height: 20),
                  _VnSectionHeader(title: l10n.vnEditCharacterShortDescLabel),
                  const SizedBox(height: 8),
                  _VnPlainField(
                    controller: _shortDescController,
                    hintText: l10n.vnEditCharacterShortDescHint,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  _VnSectionHeader(title: l10n.vnEditCharacterPersonaLabel),
                  const SizedBox(height: 8),
                  _VnPlainField(
                    controller: _personaController,
                    hintText: l10n.vnEditCharacterPersonaHint,
                    maxLines: 6,
                    minLines: 3,
                  ),
                  const SizedBox(height: 20),
                  _VnSectionHeader(title: l10n.vnEditCharacterImageLabel),
                  const SizedBox(height: 8),
                  _VnImagePicker(
                    imagePath: _imagePath,
                    onTap: _pickImage,
                    onRemove: _imagePath == null ? null : () => setState(() => _imagePath = null),
                    width: double.infinity,
                    height: 180,
                    placeholderText: l10n.vnEditCharacterImagePlaceholder,
                  ),
                  const SizedBox(height: 24),
                  _VnSectionHeader(title: l10n.vnEditExpressionSectionTitle),
                  const SizedBox(height: 8),
                  if (_characterId == null)
                    _VnPlaceholderMessage(l10n.vnEditExpressionSavePlotFirstMessage)
                  else
                    _VnExpressionGrid(
                      characterId: _characterId!,
                      characterRepository: _characterRepository,
                      imageStore: _imageStore,
                    ),
                ],
              ),
            ),
    );
  }
}

class _VnPlainField extends StatelessWidget {
  const _VnPlainField({
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.minLines,
  });

  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteScope.of(context);
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      style: TextStyle(color: palette.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: palette.textFaint, fontSize: 13),
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.all(12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: palette.primary),
        ),
      ),
    );
  }
}

/// 6종 고정 감정(기쁨/슬픔/분노/걱정/놀람/의문)의 표정 이미지 세트. 2열 그리드로 배치한다.
class _VnExpressionGrid extends StatelessWidget {
  const _VnExpressionGrid({
    required this.characterId,
    required this.characterRepository,
    required this.imageStore,
  });

  final int characterId;
  final CharacterRepository characterRepository;
  final LocalImageStore imageStore;

  static const _emotions = [
    VnEmotion.joy,
    VnEmotion.sad,
    VnEmotion.angry,
    VnEmotion.worried,
    VnEmotion.surprised,
    VnEmotion.confused,
  ];

  Future<void> _pickFor(BuildContext context, VnEmotion emotion) async {
    final path = await imageStore.pickAndSave('vn_expr');
    if (path == null) return;
    await characterRepository.setExpressionImage(characterId: characterId, emotion: emotion, imagePath: path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<VnCharacterExpression>>(
      stream: characterRepository.watchExpressions(characterId),
      builder: (context, snapshot) {
        final expressions = {for (final e in snapshot.data ?? const <VnCharacterExpression>[]) e.emotion: e};
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.85,
          children: [
            for (final emotion in _emotions)
              _VnExpressionTile(
                label: _emotionLabel(l10n, emotion),
                expression: expressions[emotion],
                onAdd: () => _pickFor(context, emotion),
                onRemove: expressions[emotion] == null
                    ? null
                    : () => characterRepository.deleteExpression(expressions[emotion]!.id),
              ),
          ],
        );
      },
    );
  }
}

class _VnExpressionTile extends StatelessWidget {
  const _VnExpressionTile({
    required this.label,
    required this.expression,
    required this.onAdd,
    required this.onRemove,
  });

  final String label;
  final VnCharacterExpression? expression;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _VnImagePicker(
            imagePath: expression?.imagePath,
            onTap: onAdd,
            onRemove: onRemove,
            width: double.infinity,
            height: double.infinity,
            placeholderText: l10n.vnEditExpressionAddTile,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: palette.textSecondary, fontSize: 12)),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// 탭 2: 인트로 (대화형/연출형 턴 + 선택지)
// ────────────────────────────────────────────────────────────────────────

class _VnIntroTab extends StatefulWidget {
  const _VnIntroTab({required this.plotId});

  final int? plotId;

  @override
  State<_VnIntroTab> createState() => _VnIntroTabState();
}

class _VnIntroTabState extends State<_VnIntroTab> {
  late final IntroEntryRepository _repository;
  late final CharacterRepository _characterRepository;
  late final VnBackgroundRepository _backgroundRepository;
  Future<int>? _ensureVersionFuture;
  int _selectedVersionIndex = 0;

  @override
  void initState() {
    super.initState();
    _repository = IntroEntryRepository(AppDatabase.instance);
    _characterRepository = CharacterRepository(AppDatabase.instance);
    _backgroundRepository = VnBackgroundRepository(AppDatabase.instance);
    _maybeEnsureVersion();
  }

  @override
  void didUpdateWidget(covariant _VnIntroTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plotId != widget.plotId) _maybeEnsureVersion();
  }

  void _maybeEnsureVersion() {
    final plotId = widget.plotId;
    if (plotId != null) _ensureVersionFuture = _repository.ensureDefaultVersion(plotId);
  }

  Future<void> _reorderEntries(List<IntroEntry> entries, int oldIndex, int newIndex) async {
    final reordered = List<IntroEntry>.from(entries);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    await _repository.reorder(reordered.map((e) => e.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final plotId = widget.plotId;
    if (plotId == null) {
      return _VnPlaceholderMessage(l10n.vnEditSavePlotFirstMessage);
    }
    return FutureBuilder<int>(
      future: _ensureVersionFuture,
      builder: (context, ensureSnapshot) {
        if (!ensureSnapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: PaletteScope.of(context).primary));
        }
        return StreamBuilder<List<Character>>(
          stream: _characterRepository.watchByPlot(plotId),
          builder: (context, characterSnapshot) {
            final characters = characterSnapshot.data ?? const [];
            return StreamBuilder<List<VnBackground>>(
              stream: _backgroundRepository.watchByPlot(plotId),
              builder: (context, backgroundSnapshot) {
                final backgrounds = backgroundSnapshot.data ?? const [];
                return StreamBuilder<List<IntroVersion>>(
                  stream: _repository.watchVersions(plotId),
                  builder: (context, versionSnapshot) {
                    final versions = versionSnapshot.data ?? const [];
                    if (versions.isEmpty) {
                      return Center(child: CircularProgressIndicator(color: PaletteScope.of(context).primary));
                    }
                    final currentIndex = _selectedVersionIndex.clamp(0, versions.length - 1);
                    final currentVersion = versions[currentIndex];
                    return Column(
                      children: [
                        _buildVersionSwitcher(context, versions, currentIndex),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            children: [
                              StreamBuilder<List<IntroEntry>>(
                                stream: _repository.watchByVersion(currentVersion.id),
                                builder: (context, entrySnapshot) {
                                  final entries = entrySnapshot.data ?? const [];
                                  return _buildEntries(context, entries, characters, backgrounds, currentVersion.id);
                                },
                              ),
                              const SizedBox(height: 24),
                              _VnChoicesSection(introVersionId: currentVersion.id, repository: _repository),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEntries(
    BuildContext context,
    List<IntroEntry> entries,
    List<Character> characters,
    List<VnBackground> backgrounds,
    int introVersionId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entries.isEmpty)
          _VnPlaceholderMessage(l10n.vnEditIntroEmptyMessage)
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: entries.length,
            onReorderItem: (oldIndex, newIndex) => _reorderEntries(entries, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Padding(
                key: ValueKey(entry.id),
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14, right: 4),
                        child: Icon(Icons.drag_indicator, color: palette.textGhost, size: 18),
                      ),
                    ),
                    Expanded(
                      child: _VnIntroEntryCard(
                        entry: entry,
                        characters: characters,
                        backgrounds: backgrounds,
                        introVersionId: introVersionId,
                        plotId: widget.plotId!,
                        repository: _repository,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _repository.add(
            plotId: widget.plotId!,
            introVersionId: introVersionId,
            type: IntroEntryType.narrator,
            content: '',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.textPrimary,
            side: BorderSide(color: palette.border),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.add, size: 16),
          label: Text(l10n.vnEditAddTurnButton, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildVersionSwitcher(BuildContext context, List<IntroVersion> versions, int currentIndex) {
    final palette = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.characterDetailIntroSectionTitle,
            style: TextStyle(color: palette.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          _VnRoundIconButton(
            icon: Icons.chevron_left,
            onTap: currentIndex > 0 ? () => setState(() => _selectedVersionIndex = currentIndex - 1) : () {},
          ),
          const SizedBox(width: 8),
          Text('${currentIndex + 1}/${versions.length}', style: TextStyle(color: palette.textSecondary, fontSize: 13)),
          const SizedBox(width: 8),
          _VnRoundIconButton(
            icon: Icons.chevron_right,
            onTap: currentIndex < versions.length - 1
                ? () => setState(() => _selectedVersionIndex = currentIndex + 1)
                : () {},
          ),
          const SizedBox(width: 8),
          _VnRoundIconButton(
            icon: Icons.add,
            onTap: () async {
              final newId = await _repository.addVersion(widget.plotId!);
              final newVersions = await _repository.getVersions(widget.plotId!);
              final newIndex = newVersions.indexWhere((v) => v.id == newId);
              if (mounted) setState(() => _selectedVersionIndex = newIndex < 0 ? 0 : newIndex);
            },
          ),
          if (versions.length > 1) ...[
            const SizedBox(width: 8),
            _VnRoundIconButton(
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
}

class _VnRoundIconButton extends StatelessWidget {
  const _VnRoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteScope.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: palette.surfaceAlt, shape: BoxShape.circle),
        child: Icon(icon, color: palette.textSecondary, size: 14),
      ),
    );
  }
}

/// 인트로 턴 1개 편집 카드. 대화형/연출형 토글, 배경/표정/화자 드롭다운, 본문 텍스트를 다룬다.
///
/// [IntroEntryRepository.updateVnFields]는 `type`(내레이터/캐릭터 대사) 필드를 바꿀 수 없다.
/// 그래서 화자를 내레이터↔캐릭터로 바꾸거나 연출형으로 전환해서 `type`이 바뀌어야 하는
/// 경우에는 기존 항목을 지우고 같은 위치에 새로 만든 뒤 순서를 다시 맞춘다([_applyChange]).
class _VnIntroEntryCard extends StatefulWidget {
  const _VnIntroEntryCard({
    required this.entry,
    required this.characters,
    required this.backgrounds,
    required this.introVersionId,
    required this.plotId,
    required this.repository,
  });

  final IntroEntry entry;
  final List<Character> characters;
  final List<VnBackground> backgrounds;
  final int introVersionId;
  final int plotId;
  final IntroEntryRepository repository;

  @override
  State<_VnIntroEntryCard> createState() => _VnIntroEntryCardState();
}

class _VnIntroEntryCardState extends State<_VnIntroEntryCard> {
  late final TextEditingController _contentController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.entry.content);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _VnIntroEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.entry.content != _contentController.text) {
      _contentController.text = widget.entry.content;
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _contentController.text != widget.entry.content) {
      _applyChange(content: _contentController.text);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _applyChange({
    VnSceneType? sceneType,
    Object? backgroundId = _unset,
    Object? expression = _unset,
    Object? characterId = _unset,
    String? content,
  }) async {
    final entry = widget.entry;
    final resolvedSceneType = sceneType ?? entry.vnSceneType;
    final resolvedCharacterId = characterId == _unset ? entry.characterId : characterId as int?;
    final isDirection = resolvedSceneType == VnSceneType.direction;
    final desiredType = isDirection
        ? IntroEntryType.narrator
        : (resolvedCharacterId != null ? IntroEntryType.character : IntroEntryType.narrator);

    if (desiredType == entry.type) {
      await widget.repository.updateVnFields(
        entry.id,
        content: content,
        vnSceneType: sceneType,
        vnBackgroundId: backgroundId == _unset ? null : backgroundId as int?,
        clearBackground: backgroundId != _unset && backgroundId == null,
        vnExpression: isDirection ? null : (expression == _unset ? null : expression as VnEmotion?),
        clearExpression: isDirection || (expression != _unset && expression == null),
        characterId: isDirection ? null : (characterId == _unset ? null : resolvedCharacterId),
        clearCharacter: isDirection || (characterId != _unset && resolvedCharacterId == null),
      );
      return;
    }

    // 화자 종류(내레이터↔캐릭터)가 바뀌어 `type`을 변경해야 하는 경우: 삭제 후 같은 자리에 재생성.
    final all = await widget.repository.getByVersion(widget.introVersionId);
    final idx = all.indexWhere((e) => e.id == entry.id);
    await widget.repository.delete(entry.id);
    final newId = await widget.repository.add(
      plotId: widget.plotId,
      introVersionId: widget.introVersionId,
      characterId: isDirection ? null : resolvedCharacterId,
      type: desiredType,
      content: content ?? entry.content,
      vnBackgroundId: backgroundId == _unset ? entry.vnBackgroundId : backgroundId as int?,
      vnExpression: isDirection
          ? null
          : (expression == _unset ? entry.vnExpression : expression as VnEmotion?),
      vnSceneType: resolvedSceneType,
    );
    if (idx >= 0) {
      final ids = all.map((e) => e.id).toList();
      ids[idx] = newId;
      await widget.repository.reorder(ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    final entry = widget.entry;
    final isDialogue = entry.vnSceneType == VnSceneType.dialogue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _VnSegmentedToggle<VnSceneType>(
                  value: entry.vnSceneType,
                  options: const [VnSceneType.dialogue, VnSceneType.direction],
                  labelBuilder: (v) =>
                      v == VnSceneType.dialogue ? l10n.vnEditSceneTypeDialogue : l10n.vnEditSceneTypeDirection,
                  onChanged: (v) => _applyChange(sceneType: v),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: palette.textMuted, size: 20),
                onPressed: () => widget.repository.delete(entry.id),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isDialogue) ...[
            Row(
              children: [
                Expanded(
                  child: _VnDropdown<int?>(
                    value: entry.characterId,
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.vnEditSpeakerNarratorLabel)),
                      for (final c in widget.characters) DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: (v) => _applyChange(characterId: v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _VnDropdown<int?>(
                    value: entry.vnBackgroundId,
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.vnEditNoChangeLabel)),
                      for (final b in widget.backgrounds) DropdownMenuItem(value: b.id, child: Text(b.title)),
                    ],
                    onChanged: (v) => _applyChange(backgroundId: v),
                  ),
                ),
                if (entry.characterId != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _VnDropdown<VnEmotion?>(
                      value: entry.vnExpression,
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.vnEditNoChangeLabel)),
                        for (final e in const [
                          VnEmotion.joy,
                          VnEmotion.sad,
                          VnEmotion.angry,
                          VnEmotion.worried,
                          VnEmotion.surprised,
                          VnEmotion.confused,
                        ])
                          DropdownMenuItem(value: e, child: Text(_emotionLabel(l10n, e))),
                      ],
                      onChanged: (v) => _applyChange(expression: v),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              focusNode: _focusNode,
              maxLines: 3,
              minLines: 1,
              style: TextStyle(color: palette.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: l10n.vnEditIntroContentHint,
                hintStyle: TextStyle(color: palette.textFaint, fontSize: 13),
                filled: true,
                fillColor: palette.background,
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: palette.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: palette.primary),
                ),
              ),
            ),
          ] else ...[
            _VnDropdown<int?>(
              value: entry.vnBackgroundId,
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.vnEditNoChangeLabel)),
                for (final b in widget.backgrounds) DropdownMenuItem(value: b.id, child: Text(b.title)),
              ],
              onChanged: (v) => _applyChange(backgroundId: v),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              focusNode: _focusNode,
              maxLines: 2,
              minLines: 1,
              style: TextStyle(color: palette.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: l10n.vnEditDirectionCaptionHint,
                hintStyle: TextStyle(color: palette.textFaint, fontSize: 13),
                filled: true,
                fillColor: palette.background,
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: palette.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: palette.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// [_VnIntroEntryCardState._applyChange]에서 '값을 안 건드림'과 '명시적으로 null로 지움'을
/// 구분하기 위한 sentinel.
const Object _unset = Object();

class _VnSegmentedToggle<T> extends StatelessWidget {
  const _VnSegmentedToggle({
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteScope.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              onTap: () => onChanged(option),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labelBuilder(option),
                    style: TextStyle(
                      color: option == value ? palette.textPrimary : palette.textFaint,
                      fontSize: 13,
                      fontWeight: option == value ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (option == value) ...[
                    const SizedBox(height: 2),
                    Container(width: 18, height: 2, color: palette.textPrimary),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _VnDropdown<T> extends StatelessWidget {
  const _VnDropdown({required this.value, required this.items, required this.onChanged});

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteScope.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          dropdownColor: palette.surfaceAlt,
          style: TextStyle(color: palette.textPrimary, fontSize: 13),
          icon: Icon(Icons.arrow_drop_down, color: palette.textFaint, size: 18),
          items: items,
          onChanged: (v) {
            if (v != null || items.any((i) => i.value == null)) onChanged(v as T);
          },
        ),
      ),
    );
  }
}

/// 인트로 버전에 딸린 선택지(주사위 사용 여부/난이도 포함) 섹션. 최대 4개.
class _VnChoicesSection extends StatelessWidget {
  const _VnChoicesSection({required this.introVersionId, required this.repository});

  final int introVersionId;
  final IntroEntryRepository repository;

  static const _maxChoices = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    return StreamBuilder<List<VnChoice>>(
      stream: repository.watchChoices(introVersionId),
      builder: (context, snapshot) {
        final choices = snapshot.data ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VnSectionHeader(title: l10n.vnEditChoicesSectionTitle(choices.length)),
            const SizedBox(height: 12),
            for (final choice in choices) ...[
              _VnChoiceCard(choice: choice, repository: repository),
              const SizedBox(height: 10),
            ],
            OutlinedButton.icon(
              onPressed: choices.length >= _maxChoices
                  ? null
                  : () => repository.addChoice(introVersionId: introVersionId, content: ''),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.textPrimary,
                side: BorderSide(color: palette.border),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.vnEditAddChoiceButton, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}

class _VnChoiceCard extends StatefulWidget {
  const _VnChoiceCard({required this.choice, required this.repository});

  final VnChoice choice;
  final IntroEntryRepository repository;

  @override
  State<_VnChoiceCard> createState() => _VnChoiceCardState();
}

class _VnChoiceCardState extends State<_VnChoiceCard> {
  late final TextEditingController _contentController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.choice.content);
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _VnChoiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.choice.content != _contentController.text) {
      _contentController.text = widget.choice.content;
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _contentController.text != widget.choice.content) {
      widget.repository.updateChoice(id: widget.choice.id, content: _contentController.text);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _toggleDice(bool value) async {
    await widget.repository.updateChoice(
      id: widget.choice.id,
      useDice: value,
      difficulty: value && widget.choice.difficulty == null ? VnDiceDifficulty.medium : null,
      clearDifficulty: !value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    final choice = widget.choice;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: palette.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _contentController,
                  focusNode: _focusNode,
                  maxLines: 3,
                  minLines: 1,
                  style: TextStyle(color: palette.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.vnEditChoiceContentHint,
                    hintStyle: TextStyle(color: palette.textFaint, fontSize: 13),
                    filled: true,
                    fillColor: palette.background,
                    contentPadding: const EdgeInsets.all(10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: palette.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: palette.primary),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: palette.textMuted, size: 20),
                onPressed: () => widget.repository.deleteChoice(choice.id),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Switch(
                value: choice.useDice,
                activeTrackColor: palette.primary,
                onChanged: _toggleDice,
              ),
              const SizedBox(width: 4),
              Text(l10n.vnEditUseDiceLabel, style: TextStyle(color: palette.textSecondary, fontSize: 13)),
            ],
          ),
          if (choice.useDice) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                for (final difficulty in const [VnDiceDifficulty.easy, VnDiceDifficulty.medium, VnDiceDifficulty.hard])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _VnChoiceDifficultyButton(
                        label: _difficultyLabel(l10n, difficulty),
                        selected: choice.difficulty == difficulty,
                        onTap: () => widget.repository.updateChoice(id: choice.id, difficulty: difficulty),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VnChoiceDifficultyButton extends StatelessWidget {
  const _VnChoiceDifficultyButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteScope.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? palette.primary.withValues(alpha: 0.16) : palette.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? palette.primary : palette.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? palette.primary : palette.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// 탭 3: 소개 (짧은 소개 + 커버)
// ────────────────────────────────────────────────────────────────────────

class _VnInfoTab extends StatelessWidget {
  const _VnInfoTab({
    required this.shortIntroController,
    required this.coverImagePath,
    required this.onPickCoverImage,
  });

  final TextEditingController shortIntroController;
  final String? coverImagePath;
  final VoidCallback onPickCoverImage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _VnSectionHeader(title: l10n.vnEditCoverTitle),
        const SizedBox(height: 12),
        _VnImagePicker(
          imagePath: coverImagePath,
          onTap: onPickCoverImage,
          width: double.infinity,
          height: 140,
          borderRadius: 12,
          placeholderText: l10n.vnEditCoverImagePlaceholder,
        ),
        const SizedBox(height: 20),
        _VnSectionHeader(title: l10n.vnEditShortIntroLabel),
        const SizedBox(height: 8),
        TextField(
          controller: shortIntroController,
          style: TextStyle(color: palette.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: l10n.vnEditShortIntroHint,
            hintStyle: TextStyle(color: palette.textFaint, fontSize: 13),
            filled: true,
            fillColor: palette.surface,
            contentPadding: const EdgeInsets.all(12),
            counter: AnimatedBuilder(
              animation: shortIntroController,
              builder: (context, _) => Align(
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.vnEditCharCountLabel(shortIntroController.text.length),
                  style: TextStyle(color: palette.textFaint, fontSize: 11),
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: palette.primary),
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// 탭 4: 플레이 설정
// ────────────────────────────────────────────────────────────────────────

class _VnPlaySettingsTab extends StatefulWidget {
  const _VnPlaySettingsTab({required this.plotId});

  final int? plotId;

  @override
  State<_VnPlaySettingsTab> createState() => _VnPlaySettingsTabState();
}

class _VnPlaySettingsTabState extends State<_VnPlaySettingsTab> {
  late final PlotRepository _repository;
  VnInputMode _inputMode = VnInputMode.choice;
  bool _aiAssist = false;
  bool _diceEnabled = false;
  int? _loadedForPlotId;

  @override
  void initState() {
    super.initState();
    _repository = PlotRepository(AppDatabase.instance);
    _maybeLoad();
  }

  @override
  void didUpdateWidget(covariant _VnPlaySettingsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plotId != widget.plotId) _maybeLoad();
  }

  Future<void> _maybeLoad() async {
    final id = widget.plotId;
    if (id == null) return;
    final plot = await _repository.getById(id);
    if (!mounted || plot == null) return;
    setState(() {
      _inputMode = plot.vnInputMode;
      _aiAssist = plot.vnAiInputAssist;
      _diceEnabled = plot.vnDiceEnabled;
      _loadedForPlotId = id;
    });
  }

  Future<void> _persist() async {
    final id = widget.plotId;
    if (id == null) return;
    await _repository.updateVnPlaySettings(
      plotId: id,
      vnInputMode: _inputMode,
      vnAiInputAssist: _aiAssist,
      vnDiceEnabled: _diceEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = PaletteScope.of(context);
    final plotId = widget.plotId;
    if (plotId == null) {
      return _VnPlaceholderMessage(l10n.vnEditSavePlotFirstMessage);
    }
    if (_loadedForPlotId != plotId) {
      return Center(child: CircularProgressIndicator(color: palette.primary));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _VnSectionHeader(title: l10n.vnEditPlaySettingsSectionTitle),
        const SizedBox(height: 16),
        Text(
          l10n.vnEditInputModeLabel,
          style: TextStyle(color: palette.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _VnChoiceDifficultyButton(
                label: l10n.vnEditInputModeChoice,
                selected: _inputMode == VnInputMode.choice,
                onTap: () {
                  setState(() => _inputMode = VnInputMode.choice);
                  _persist();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _VnChoiceDifficultyButton(
                label: l10n.vnEditInputModeFreeText,
                selected: _inputMode == VnInputMode.freeText,
                onTap: () {
                  setState(() => _inputMode = VnInputMode.freeText);
                  _persist();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _inputMode == VnInputMode.choice
              ? l10n.vnEditInputModeChoiceDescription
              : l10n.vnEditInputModeFreeTextDescription,
          style: TextStyle(color: palette.textFaint, fontSize: 12),
        ),
        const SizedBox(height: 24),
        _VnToggleRow(
          title: l10n.vnEditAiAssistLabel,
          description: l10n.vnEditAiAssistDescription,
          value: _aiAssist,
          onChanged: (v) {
            setState(() => _aiAssist = v);
            _persist();
          },
        ),
        const SizedBox(height: 20),
        _VnToggleRow(
          title: l10n.vnEditDiceEventLabel,
          description: l10n.vnEditDiceEventDescription,
          value: _diceEnabled,
          onChanged: (v) {
            setState(() => _diceEnabled = v);
            _persist();
          },
        ),
      ],
    );
  }
}

class _VnToggleRow extends StatelessWidget {
  const _VnToggleRow({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = PaletteScope.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: palette.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: palette.textFaint, fontSize: 12)),
            ],
          ),
        ),
        Switch(value: value, activeTrackColor: palette.primary, onChanged: onChanged),
      ],
    );
  }
}
