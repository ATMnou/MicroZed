import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/export/plot_card_exporter.dart';
import '../data/local_image_store.dart';
import '../data/repositories/character_repository.dart';
import '../data/repositories/intro_entry_repository.dart';
import '../data/repositories/lorebook_repository.dart';
import '../data/repositories/plot_repository.dart';
import '../widgets/dashed_box.dart';
import '../widgets/local_avatar.dart';
import 'lorebook_connect_screen.dart';

/// 프롬프트 탭에서 편집 중인 캐릭터 1명 분의 폼 상태.
class _CharacterForm {
  _CharacterForm({
    this.id,
    String name = '',
    String description = '',
    this.imagePath,
    String aboutText = '',
  })  : nameController = TextEditingController(text: name),
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

class _PlotEditScreenState extends State<PlotEditScreen> with SingleTickerProviderStateMixin {
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

  static const _background = Color(0xFF141414);
  static const _cardBg = Color(0xFF1E1E1E);
  static const _borderGrey = Color(0xFF3A3A3A);
  static const _purple = Color(0xFF7A6FF0);

  static const _tabs = ['프롬프트', '로어북', '인트로', '소개'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _plotRepository = PlotRepository(AppDatabase.instance);
    _characterRepository = CharacterRepository(AppDatabase.instance);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.plotId != null) {
      final plot = await _plotRepository.getById(widget.plotId!);
      final characters = await _characterRepository.getByPlot(widget.plotId!);
      _titleController.text = plot?.title ?? '';
      _descController.text = plot?.description ?? '';
      _shortIntroController.text = plot?.shortIntro ?? '';
      _hashtags = (plot?.hashtags ?? '').split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
      _coverImagePath = plot?.coverImagePath;
      _characterForms = characters.isEmpty
          ? [_CharacterForm(name: '캐릭터 1')]
          : characters.map((c) => _CharacterForm.fromCharacter(c)).toList();
    } else {
      _characterForms = [_CharacterForm(name: '캐릭터 1')];
    }
    if (mounted) setState(() => _loading = false);
  }

  void _addCharacter() {
    setState(() {
      _characterForms.add(_CharacterForm(name: '캐릭터 ${_characterForms.length + 1}'));
    });
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
    if (path != null && mounted) setState(() => _characterForms[index].imagePath = path);
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
    final plotId = widget.plotId;
    if (plotId == null || _exporting) return;
    setState(() => _exporting = true);
    try {
      final bytes = await PlotCardExporter(AppDatabase.instance).exportPlot(plotId);
      final safeTitle = _titleController.text.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final location = await getSaveLocation(
        suggestedName: '${safeTitle.isEmpty ? 'plot' : safeTitle}.png',
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PNG character card', extensions: ['png']),
        ],
      );
      if (location == null) return; // 취소됨
      await File(location.path).writeAsBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SillyTavern 카드로 내보냈어요.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내보내기에 실패했어요: $e')),
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
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _PromptTab(
                        titleController: _titleController,
                        descController: _descController,
                        characterForms: _characterForms,
                        onPickCharacterImage: _pickCharacterImage,
                        onRemoveCharacterImage: _removeCharacterImage,
                        onAddCharacter: _addCharacter,
                        onRemoveCharacter: _removeCharacter,
                      ),
                      _LorebookTab(plotId: widget.plotId),
                      _IntroTab(plotId: widget.plotId),
                      _AboutTab(
                        shortIntroController: _shortIntroController,
                        hashtags: _hashtags,
                        onHashtagsChanged: (tags) => setState(() => _hashtags = tags),
                        coverImagePath: _coverImagePath,
                        onPickCoverImage: _pickCoverImage,
                        characterForms: _characterForms,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 22),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: const Text('플롯', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
      actions: [
        PopupMenuButton<String>(
          icon: _exporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                )
              : const Icon(Icons.more_horiz, color: Colors.white, size: 22),
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          enabled: widget.plotId != null && !_exporting,
          onSelected: (value) {
            if (value == 'export_card') _exportAsSillyTavernCard();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'export_card',
              child: Text('SillyTavern 카드로 내보내기', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text('임시저장', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ElevatedButton(
            onPressed: _loading || _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(_isEditing ? '수정' : '제작', style: const TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white38,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      tabs: _tabs.map((t) => Tab(text: t)).toList(),
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
          const Text('*', style: TextStyle(color: Color(0xFF7A6FF0), fontSize: 14, fontWeight: FontWeight.bold)),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.maxLength,
    this.maxLines = 1,
    this.required = false,
  });

  final String label;
  final TextEditingController controller;
  final int? maxLength;
  final int maxLines;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label, required: required),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: _PlotEditScreenState._background,
            counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _PlotEditScreenState._borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _PlotEditScreenState._purple),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromptTab extends StatelessWidget {
  const _PromptTab({
    required this.titleController,
    required this.descController,
    required this.characterForms,
    required this.onPickCharacterImage,
    required this.onRemoveCharacterImage,
    required this.onAddCharacter,
    required this.onRemoveCharacter,
  });

  final TextEditingController titleController;
  final TextEditingController descController;
  final List<_CharacterForm> characterForms;
  final ValueChanged<int> onPickCharacterImage;
  final ValueChanged<int> onRemoveCharacterImage;
  final VoidCallback onAddCharacter;
  final ValueChanged<int> onRemoveCharacter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Align(
          alignment: Alignment.center,
          child: Text('89/2,400자', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ),
        const SizedBox(height: 16),
        const Text('기본 설정', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _PlotEditScreenState._cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LabeledField(label: '제목', controller: titleController, maxLength: 20, required: true),
              const SizedBox(height: 16),
              _LabeledField(label: '설명', controller: descController, maxLines: 4, required: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < characterForms.length; i++) ...[
          _buildCharacterCard(context, i),
          const SizedBox(height: 16),
        ],
        OutlinedButton.icon(
          onPressed: onAddCharacter,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: _PlotEditScreenState._borderGrey),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('캐릭터 추가', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildCharacterCard(BuildContext context, int index) {
    final form = characterForms[index];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _PlotEditScreenState._cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '캐릭터 ${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (index > 0)
                GestureDetector(
                  onTap: () => onRemoveCharacter(index),
                  child: const Icon(Icons.delete_outline, color: Colors.white54, size: 20),
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
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: _PlotEditScreenState._purple,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('대표', style: TextStyle(color: Colors.white, fontSize: 9)),
                            ),
                          ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => onRemoveCharacterImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.delete_outline, color: Colors.white70, size: 16),
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
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Color(0xFF7A6FF0), size: 20),
                          SizedBox(height: 2),
                          Text('캐릭터 이미지', style: TextStyle(color: Colors.white38, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          _LabeledField(label: '이름', controller: form.nameController, maxLength: 10, required: true),
          const SizedBox(height: 16),
          _LabeledField(label: '설명', controller: form.descController, maxLines: 3),
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
  late final LorebookRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = LorebookRepository(AppDatabase.instance);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plotId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '플롯을 먼저 저장하면 로어북을 연결할 수 있어요.\n프롬프트 탭에서 제목/캐릭터를 입력하고 상단의 저장 버튼을 눌러주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13),
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
              const Text(
                '로어북을 연결해 주세요',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.help_outline, color: Colors.white38, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '로어북에 등록한 키워드가 언급될 때마다\n작성한 내용이 AI에게 전달돼요',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Lorebook>>(
            stream: _repository.watchLinkedLorebooks(widget.plotId!),
            builder: (context, snapshot) {
              final linked = snapshot.data ?? const [];
              return OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LorebookConnectScreen(plotId: widget.plotId!)),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: _PlotEditScreenState._borderGrey),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  '로어북 연결 (${linked.length}/${LorebookConnectScreen.maxLinks})',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

  String _composerHint(List<Character> characters) {
    switch (_composerMode) {
      case _ComposerMode.narrator:
        return '*상황을 설명해주세요*';
      case _ComposerMode.user:
        return '유저 메시지를 입력해주세요';
      case _ComposerMode.character:
        final match = characters.where((c) => c.id == _selectedCharacterId);
        final name = match.isEmpty ? '캐릭터' : match.first.name;
        return '$name의 대사를 입력해주세요';
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
      characterId: type == IntroEntryType.character ? _selectedCharacterId : null,
      type: type,
      content: text,
    );
    _composerController.clear();
  }

  Future<void> _reorder(List<IntroEntry> entries, int oldIndex, int newIndex) async {
    final reordered = List<IntroEntry>.from(entries);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    await _repository.reorder(reordered.map((e) => e.id).toList());
  }

  Future<void> _editEntry(IntroEntry entry) async {
    final controller = TextEditingController(text: entry.content);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('내용 수정', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF3A3A3A))),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7A6FF0))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('저장', style: TextStyle(color: Color(0xFF7A6FF0))),
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '플롯을 먼저 저장하면 인트로를 작성할 수 있어요.\n프롬프트 탭에서 제목/캐릭터를 입력하고 상단의 저장 버튼을 눌러주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13),
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
              return const Center(child: CircularProgressIndicator(color: Color(0xFF7A6FF0)));
            }
            final currentIndex = _selectedVersionIndex.clamp(0, versions.length - 1);
            final currentVersion = versions[currentIndex];
            return Column(
              children: [
                _buildVersionSwitcher(versions, currentIndex),
                Expanded(
                  child: StreamBuilder<List<IntroEntry>>(
                    stream: _repository.watchByVersion(currentVersion.id),
                    builder: (context, snapshot) {
                      final entries = snapshot.data ?? const [];
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text('첫 상황을 만들어 주세요', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (entries.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  '아직 작성된 인트로가 없어요. 아래 입력창에서 첫 줄을 추가해보세요.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white38, fontSize: 13),
                                ),
                              ),
                            ),
                          if (entries.isNotEmpty)
                            ReorderableListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              buildDefaultDragHandles: false,
                              itemCount: entries.length,
                              onReorderItem: (oldIndex, newIndex) => _reorder(entries, oldIndex, newIndex),
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
                                        child: const Padding(
                                          padding: EdgeInsets.only(top: 8, right: 4),
                                          child: Icon(Icons.drag_indicator, color: Colors.white24, size: 18),
                                        ),
                                      ),
                                      Expanded(child: _buildEntryLine(entry, characters)),
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

  Widget _buildVersionSwitcher(List<IntroVersion> versions, int currentIndex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Text('인트로', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const Spacer(),
          _RoundIconButton(
            icon: Icons.chevron_left,
            onTap: currentIndex > 0 ? () => setState(() => _selectedVersionIndex = currentIndex - 1) : () {},
          ),
          const SizedBox(width: 8),
          Text('${currentIndex + 1}/${versions.length}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
              if (mounted) setState(() => _selectedVersionIndex = newIndex < 0 ? 0 : newIndex);
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
    }
  }

  Widget _buildEditDeleteButtons(IntroEntry entry) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundIconButton(icon: Icons.edit_outlined, onTap: () => _editEntry(entry)),
        const SizedBox(width: 8),
        _RoundIconButton(icon: Icons.delete_outline, onTap: () => _repository.delete(entry.id)),
      ],
    );
  }

  Widget _buildCharacterLine(IntroEntry entry, List<Character> characters) {
    final match = characters.where((c) => c.id == entry.characterId);
    final character = match.isEmpty ? null : match.first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LocalAvatar(imagePath: character?.imagePath, radius: 14, icon: Icons.pets),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(character?.name ?? '캐릭터', style: const TextStyle(color: Color(0xFF7A6FF0), fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _PlotEditScreenState._cardBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(entry.content, style: const TextStyle(color: Colors.white, fontSize: 14)),
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
          const Icon(Icons.reorder, color: Colors.white54, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(entry.content, style: const TextStyle(color: Colors.white54, fontSize: 14)),
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
              color: _PlotEditScreenState._purple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(entry.content, style: const TextStyle(color: Colors.white, fontSize: 14)),
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
          child: Image.file(File(entry.content), width: 96, height: 96, fit: BoxFit.cover),
        ),
        const SizedBox(width: 8),
        _RoundIconButton(icon: Icons.delete_outline, onTap: () => _repository.delete(entry.id)),
      ],
    );
  }

  Widget _buildProfileMarker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.drag_indicator, color: Colors.white38, size: 16),
          SizedBox(width: 6),
          Text('대화 프로필 선택 시점', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildComposer(int introVersionId, List<Character> characters) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
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
                  icon: const Icon(Icons.image_outlined, color: Colors.white70, size: 20),
                  onPressed: () => _pickAndAddImage(introVersionId),
                  tooltip: '이미지 추가 (AI에게 전달되지 않아요)',
                ),
                const SizedBox(width: 8),
                _ComposerTab(
                  icon: Icons.reorder,
                  label: '내레이터',
                  selected: _composerMode == _ComposerMode.narrator,
                  onTap: () => setState(() => _composerMode = _ComposerMode.narrator),
                ),
                const SizedBox(width: 16),
                _ComposerTab(
                  icon: Icons.visibility_outlined,
                  label: '유저',
                  selected: _composerMode == _ComposerMode.user,
                  onTap: () => setState(() => _composerMode = _ComposerMode.user),
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
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onSubmitted: (_) => _send(introVersionId),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: _composerHint(characters),
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('{{user}}', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF3A3A3A),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_upward, color: Colors.white54, size: 16),
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
        decoration: const BoxDecoration(
          color: Color(0xFF262626),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 14),
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
    final label = match.isEmpty ? '캐릭터' : match.first.name;
    final color = selected ? Colors.white : Colors.white38;
    return PopupMenuButton<int>(
      color: const Color(0xFF262626),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final character in characters)
          PopupMenuItem(
            value: character.id,
            child: Text(character.name, style: const TextStyle(color: Colors.white)),
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
                Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 2),
                Icon(Icons.arrow_drop_down, color: color, size: 16),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 4),
              Container(width: 24, height: 2, color: Colors.white),
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
    final color = selected ? Colors.white : Colors.white38;
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
                Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            if (selected) ...[
              const SizedBox(height: 4),
              Container(width: 24, height: 2, color: Colors.white),
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
  /// 캐릭터별 소개 섹션의 펼침 상태. 인덱스 0(첫 캐릭터)만 기본으로 펼쳐둔다.
  final Set<int> _expandedCharacters = {0};

  Future<void> _addHashtag() async {
    if (widget.hashtags.length >= 10) return;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('해시태그 추가', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '# 없이 입력해주세요',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF3A3A3A))),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7A6FF0))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('추가', style: TextStyle(color: Color(0xFF7A6FF0))),
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('커버', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: _PlotEditScreenState._borderGrey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
              label: const Text('미리보기', style: TextStyle(fontSize: 12)),
            ),
          ],
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
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Color(0xFF7A6FF0), size: 24),
                      SizedBox(height: 4),
                      Text('커버 이미지', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('짧은 소개', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: widget.shortIntroController,
              maxLength: 40,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: '제목과 함께 보일 짧은 소개를 입력해주세요',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: _PlotEditScreenState._background,
                counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _PlotEditScreenState._borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _PlotEditScreenState._purple),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('해시태그', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('해시태그가 있으면 10배 더 많이 노출될 거예요', style: TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 8),
        if (widget.hashtags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in widget.hashtags)
                Chip(
                  label: Text('#$tag'),
                  backgroundColor: const Color(0xFF262626),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white54),
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
            foregroundColor: Colors.white70,
            side: const BorderSide(color: _PlotEditScreenState._borderGrey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.add, size: 14),
          label: Text('추가 ${widget.hashtags.length}/10', style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(height: 28),
        const Text('소개글', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text(
          '상세 페이지에 표시할 내용, 이미지를 추가해 주세요.\n이 내용은 AI에게 전달되지 않아요.',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < widget.characterForms.length; i++) ...[
          _buildCharacterAboutSection(i),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildCharacterAboutSection(int index) {
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
                      '## ${name.isEmpty ? '캐릭터 ${index + 1}' : name}',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white54,
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
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: '상세 페이지에 표시할 내용을 써주세요.\n이 내용은 AI에게 전달되지 않아요.',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              filled: true,
              fillColor: _PlotEditScreenState._background,
              contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _PlotEditScreenState._borderGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _PlotEditScreenState._purple),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
