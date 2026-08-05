import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/local_image_store.dart';
import '../data/repositories/conversation_profile_repository.dart';
import '../data/repositories/plot_conversation_profile_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/local_avatar.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 플롯 편집 > 프롬프트 탭의 '플롯 전용 대화 프로필' 추가/수정 화면.
/// 마이페이지의 전역 프로필 편집 화면과 구조는 비슷하지만, 짧은 소개(표시 전용)가 추가되고
/// 설명은 캐릭터 소개처럼 AI에게 그대로 전달된다.
class PlotConversationProfileEditScreen extends StatefulWidget {
  const PlotConversationProfileEditScreen({
    super.key,
    required this.plotId,
    this.profileId,
  });

  final int plotId;

  /// null이면 신규 추가, 값이 있으면 기존 프로필 수정.
  final int? profileId;

  @override
  State<PlotConversationProfileEditScreen> createState() => _PlotConversationProfileEditScreenState();
}

class _PlotConversationProfileEditScreenState extends State<PlotConversationProfileEditScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _borderGrey => _p.border;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _cardBg => _p.surface;
  Color get _textFaint => _p.textFaint;
  Color get _textSecondary => _p.textSecondary;
  Color get _textGhost => _p.textGhost;
  late final PlotConversationProfileRepository _repository;
  late final ConversationProfileRepository _globalProfileRepository;
  final _imageStore = LocalImageStore();
  final _nameController = TextEditingController();
  final _shortIntroController = TextEditingController();
  final _descController = TextEditingController();
  bool _useGlobalName = false;
  String? _globalDefaultName;
  String? _imagePath;
  bool _loading = true;
  bool _saving = false;


  bool get _isEditing => widget.profileId != null;

  @override
  void initState() {
    super.initState();
    _repository = PlotConversationProfileRepository(AppDatabase.instance);
    _globalProfileRepository = ConversationProfileRepository(AppDatabase.instance);
    _load();
  }

  Future<void> _load() async {
    final globalDefault = await _globalProfileRepository.getDefault();
    _globalDefaultName = globalDefault?.name;
    if (widget.profileId != null) {
      final profile = await _repository.getById(widget.profileId!);
      _nameController.text = profile?.name ?? '';
      _shortIntroController.text = profile?.shortIntro ?? '';
      _descController.text = profile?.description ?? '';
      _useGlobalName = profile?.useGlobalName ?? false;
      _imagePath = profile?.imagePath;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final path = await _imageStore.pickAndSave('plot_profile');
    if (path != null && mounted) setState(() => _imagePath = path);
  }

  Future<void> _save() async {
    if (!_useGlobalName && _nameController.text.trim().isEmpty) return;
    if (_shortIntroController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await _repository.upsert(
      id: widget.profileId,
      plotId: widget.plotId,
      name: _useGlobalName ? (_globalDefaultName ?? '') : _nameController.text.trim(),
      useGlobalName: _useGlobalName,
      shortIntro: _shortIntroController.text.trim(),
      description: _descController.text.trim(),
      imagePath: _imagePath,
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    if (widget.profileId == null) return;
    await _repository.delete(widget.profileId!);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortIntroController.dispose();
    _descController.dispose();
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
          icon: Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.myPageEditProfileButton,
          style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: _textPrimary, size: 22),
              onPressed: _delete,
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _purple))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        LocalAvatar(imagePath: _imagePath, radius: 36),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(color: _purple, shape: BoxShape.circle),
                            child: Icon(Icons.edit, color: _textPrimary, size: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.plotEditNameFieldLabel,
                  style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  enabled: !_useGlobalName,
                  maxLength: 20,
                  style: TextStyle(color: _textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _cardBg,
                    contentPadding: const EdgeInsets.all(12),
                    counterStyle: TextStyle(color: _textFaint, fontSize: 11),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _purple),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _borderGrey),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _useGlobalName,
                  onChanged: (v) => setState(() => _useGlobalName = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: _purple,
                  dense: true,
                  title: Text(
                    l10n.plotProfileUseGlobalNameLabel,
                    style: TextStyle(color: _textSecondary, fontSize: 13),
                  ),
                  subtitle: _globalDefaultName == null
                      ? null
                      : Text(
                          l10n.plotProfileUseGlobalNameDescription(_globalDefaultName!),
                          style: TextStyle(color: _textFaint, fontSize: 12),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.plotProfileShortIntroLabel,
                  style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.plotProfileShortIntroDescription,
                  style: TextStyle(color: _textFaint, fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _shortIntroController,
                  maxLines: 3,
                  maxLength: 50,
                  style: TextStyle(color: _textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _cardBg,
                    contentPadding: const EdgeInsets.all(12),
                    counterStyle: TextStyle(color: _textFaint, fontSize: 11),
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
                const SizedBox(height: 24),
                Text(
                  l10n.plotProfileDescriptionLabel,
                  style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  maxLines: 6,
                  style: TextStyle(color: _textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.plotProfileDescriptionHint,
                    hintStyle: TextStyle(color: _textGhost, fontSize: 13, height: 1.4),
                    filled: true,
                    fillColor: _cardBg,
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading || _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: _textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                l10n.aiPresetSaveButton,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
