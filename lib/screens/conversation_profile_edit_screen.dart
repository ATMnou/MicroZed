import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/local_image_store.dart';
import '../data/repositories/conversation_profile_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/local_avatar.dart';

/// 프로필 목록에서 대화 프로필을 누르면 나오는 상세 편집 화면.
/// 설명(선택) 항목은 글자 수 제한(카운터)을 두지 않는다.
class ConversationProfileEditScreen extends StatefulWidget {
  const ConversationProfileEditScreen({super.key, required this.profileId});

  /// null이면 신규 추가, 값이 있으면 기존 프로필 수정.
  final int? profileId;

  @override
  State<ConversationProfileEditScreen> createState() =>
      _ConversationProfileEditScreenState();
}

class _ConversationProfileEditScreenState
    extends State<ConversationProfileEditScreen> {
  late final ConversationProfileRepository _repository;
  final _imageStore = LocalImageStore();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _applyAsDefault = true;
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
    _repository = ConversationProfileRepository(AppDatabase.instance);
    _load();
  }

  Future<void> _load() async {
    if (widget.profileId != null) {
      final profile = await _repository.getById(widget.profileId!);
      _nameController.text = profile?.name ?? '';
      _descController.text = profile?.description ?? '';
      _applyAsDefault = profile?.isDefault ?? false;
      _imagePath = profile?.imagePath;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final path = await _imageStore.pickAndSave('profile');
    if (path != null && mounted) setState(() => _imagePath = path);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await _repository.upsert(
      id: widget.profileId,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      applyAsDefault: _applyAsDefault,
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.myPageEditProfileButton,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 22,
              ),
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
                            decoration: const BoxDecoration(
                              color: _purple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      l10n.plotEditNameFieldLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.profileEditNameDescription,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
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
                const SizedBox(height: 24),
                Text(
                  l10n.profileEditDescriptionLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
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
                const SizedBox(height: 24),
                Text(
                  l10n.profileEditDefaultSectionTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.profileEditApplyDefaultTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.profileEditApplyDefaultDescription,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _applyAsDefault,
                        activeThumbColor: Colors.white,
                        activeTrackColor: _purple,
                        onChanged: (v) => setState(() => _applyAsDefault = v),
                      ),
                    ],
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.aiPresetSaveButton,
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
