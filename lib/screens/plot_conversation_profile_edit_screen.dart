import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/local_image_store.dart';
import '../data/repositories/conversation_profile_repository.dart';
import '../data/repositories/plot_conversation_profile_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/local_avatar.dart';

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

  static const _background = Color(0xFF141414);
  static const _borderGrey = Color(0xFF3A3A3A);
  static const _purple = Color(0xFF7A6FF0);

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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.myPageEditProfileButton,
          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
              onPressed: _delete,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
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
                            decoration: const BoxDecoration(color: _purple, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, color: Colors.white, size: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.plotEditNameFieldLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  enabled: !_useGlobalName,
                  maxLength: 20,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.all(12),
                    counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _purple),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _borderGrey),
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
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  subtitle: _globalDefaultName == null
                      ? null
                      : Text(
                          l10n.plotProfileUseGlobalNameDescription(_globalDefaultName!),
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.plotProfileShortIntroLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.plotProfileShortIntroDescription,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _shortIntroController,
                  maxLines: 3,
                  maxLength: 50,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.all(12),
                    counterStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _purple),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.plotProfileDescriptionLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  maxLines: 6,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.plotProfileDescriptionHint,
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13, height: 1.4),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.all(12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _purple),
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
                foregroundColor: Colors.white,
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
