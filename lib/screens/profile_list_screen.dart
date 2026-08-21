import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/import/conversation_profile_importer.dart';
import '../data/repositories/conversation_profile_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/local_avatar.dart';
import 'conversation_profile_edit_screen.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 마이페이지 > '대화 프로필 편집'에서 진입하는 프로필 목록 화면.
class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({super.key});

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _textPrimary => _p.textPrimary;
  late final ConversationProfileRepository _repository;
  PlotType? _scopeFilter;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _repository = ConversationProfileRepository(AppDatabase.instance);
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context)!;
    if (_importing) return;
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['mzprofile']);
    if (result == null || result.files.isEmpty) return; // 취소됨
    setState(() => _importing = true);
    try {
      final bytes = await result.files.single.readAsBytes();
      await ConversationProfileImporter(AppDatabase.instance).importFromBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileImportSuccessMessage)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileImportFailureMessage(e))));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: _textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.myPageEditProfileButton,
          style: TextStyle(
            color: _textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: _importing
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _textPrimary))
                : Icon(Icons.file_download_outlined, color: _textPrimary, size: 22),
            tooltip: AppLocalizations.of(context)!.profileImportButton,
            onPressed: _importing ? null : _import,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<List<ConversationProfile>>(
          stream: _repository.watchAll(scope: _scopeFilter),
          builder: (context, snapshot) {
            final profiles = snapshot.data ?? const [];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildScopeFilterRow(context),
                const SizedBox(height: 12),
                _AddProfileTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ConversationProfileEditScreen(
                          profileId: null,
                          initialScope: _scopeFilter,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ...profiles.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProfileTile(
                      name: p.name,
                      imagePath: p.imagePath,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ConversationProfileEditScreen(profileId: p.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScopeFilterRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = _p;
    final options = <(String, PlotType?)>[
      (l10n.createTabPlotTypeFilterAll, null),
      (l10n.createTabPlotTypeFilterStoryChat, PlotType.storyChat),
      (l10n.createTabPlotTypeFilterVisualNovel, PlotType.visualNovel),
    ];
    return Row(
      children: [
        for (final option in options) ...[
          GestureDetector(
            onTap: () => setState(() => _scopeFilter = option.$2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _scopeFilter == option.$2 ? p.primary : p.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                option.$1,
                style: TextStyle(
                  color: _scopeFilter == option.$2 ? p.onPrimary : p.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  const _AddProfileTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: PaletteScope.of(context).surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: PaletteScope.of(context).surfaceAlt,
              child: Icon(Icons.add, color: PaletteScope.of(context).textSecondary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.chatProfileSheetAddButton,
              style: TextStyle(color: PaletteScope.of(context).textPrimary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.name,
    required this.imagePath,
    required this.onTap,
  });

  final String name;
  final String? imagePath;
  final VoidCallback onTap;

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
          LocalAvatar(imagePath: imagePath, radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: PaletteScope.of(context).textPrimary, fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: PaletteScope.of(context).textMuted,
              size: 18,
            ),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
