import 'dart:io';

import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/conversation_profile_repository.dart';
import '../data/repositories/plot_conversation_profile_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/local_avatar.dart';
import 'plot_conversation_profile_edit_screen.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

/// 이 플롯으로 새 채팅을 시작할 때 어떤 대화 프로필을 쓸지 고르는 화면.
/// 플롯 전용 프로필이 있으면 스와이프 가능한 카드 뷰로 먼저 보여주고, 목록 보기로 전환하면
/// 플롯 전용 + 전역 프로필을 모두 한 리스트로 보여준다.
///
/// [Navigator.pop]으로 선택 결과를 돌려준다: 취소면 null, 골랐으면 둘 중 하나만 값이 있는
/// 레코드(`globalProfileId`는 전역 프로필, `plotProfileId`는 이 플롯 전용 프로필).
class PlotProfilePickerScreen extends StatefulWidget {
  const PlotProfilePickerScreen({super.key, required this.plotId});

  final int plotId;

  @override
  State<PlotProfilePickerScreen> createState() => _PlotProfilePickerScreenState();
}

typedef _ProfileChoice = ({int? globalProfileId, int? plotProfileId});

class _PlotProfilePickerScreenState extends State<PlotProfilePickerScreen> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _background => _p.background;
  Color get _cardBg => _p.surface;
  Color get _purple => _p.primary;
  Color get _textPrimary => _p.textPrimary;
  Color get _textSecondary => _p.textSecondary;
  Color get _textFaint => _p.textFaint;
  Color get _textGhost => _p.textGhost;
  late final PlotConversationProfileRepository _plotProfileRepo;
  late final ConversationProfileRepository _globalProfileRepo;
  final _pageController = PageController();

  bool _listMode = false;
  bool _loading = true;
  List<PlotConversationProfile> _plotProfiles = const [];


  @override
  void initState() {
    super.initState();
    _plotProfileRepo = PlotConversationProfileRepository(AppDatabase.instance);
    _globalProfileRepo = ConversationProfileRepository(AppDatabase.instance);
    _load();
  }

  Future<void> _load() async {
    final profiles = await _plotProfileRepo.getByPlot(widget.plotId);
    if (!mounted) return;
    setState(() {
      _plotProfiles = profiles;
      _listMode = profiles.isEmpty;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPlotProfile(int id) => Navigator.of(context).pop<_ProfileChoice>((globalProfileId: null, plotProfileId: id));

  void _selectGlobalProfile(int id) => Navigator.of(context).pop<_ProfileChoice>((globalProfileId: id, plotProfileId: null));

  Future<void> _openEditor({int? profileId}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlotConversationProfileEditScreen(plotId: widget.plotId, profileId: profileId),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: _purple))
            : Column(
                children: [
                  _buildTopBar(l10n),
                  Expanded(child: _listMode ? _buildListView(l10n) : _buildCardView(l10n)),
                ],
              ),
      ),
    );
  }

  Widget _buildTopBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: _textPrimary, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              l10n.plotProfilePickerTitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (!_listMode)
            IconButton(
              icon: Icon(Icons.view_list, color: _textSecondary, size: 22),
              onPressed: () => setState(() => _listMode = true),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildCardView(AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _plotProfiles.length,
            itemBuilder: (context, index) => _buildProfileCard(l10n, _plotProfiles[index]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: _textSecondary, size: 28),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                ),
              ),
              Text(
                l10n.plotProfilePickerSwipeHint,
                style: TextStyle(color: _textFaint, fontSize: 12),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: _textSecondary, size: 28),
                onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(AppLocalizations l10n, PlotConversationProfile profile) {
    final imagePath = profile.imagePath;
    final hasImage = imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.file(File(imagePath), fit: BoxFit.cover)
            else
              Container(color: _cardBg, child: Icon(Icons.person, color: _textGhost, size: 96)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: _RoundIconButton(
                icon: Icons.edit,
                onTap: () => _openEditor(profileId: profile.id),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 84,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: _plotProfileRepo.resolveDisplayName(profile),
                    builder: (context, snapshot) => Text(
                      snapshot.data ?? profile.name,
                      style: TextStyle(color: _textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.shortIntro,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () => _selectPlotProfile(profile.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor: _textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    l10n.plotProfilePickerSelectButton,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Text(
          l10n.plotProfilePickerListTitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _openEditor(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.add, color: _textSecondary, size: 20),
                const SizedBox(width: 12),
                Text(l10n.plotProfileAddButton, style: TextStyle(color: _textPrimary, fontSize: 14)),
              ],
            ),
          ),
        ),
        for (final profile in _plotProfiles)
          _ListRow(
            imagePath: profile.imagePath,
            nameBuilder: () => _plotProfileRepo.resolveDisplayName(profile),
            subtitle: profile.shortIntro,
            onTap: () => _selectPlotProfile(profile.id),
          ),
        StreamBuilder<List<ConversationProfile>>(
          stream: _globalProfileRepo.watchAll(),
          builder: (context, snapshot) {
            final profiles = snapshot.data ?? const [];
            return Column(
              children: [
                for (final profile in profiles)
                  _ListRow(
                    imagePath: profile.imagePath,
                    nameBuilder: () async => profile.name,
                    subtitle: profile.description,
                    onTap: () => _selectGlobalProfile(profile.id),
                  ),
              ],
            );
          },
        ),
      ],
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
        child: Icon(icon, color: PaletteScope.of(context).textPrimary, size: 18),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.imagePath,
    required this.nameBuilder,
    required this.subtitle,
    required this.onTap,
  });

  final String? imagePath;
  final Future<String> Function() nameBuilder;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: PaletteScope.of(context).surface, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            LocalAvatar(imagePath: imagePath, radius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: nameBuilder(),
                    builder: (context, snapshot) => Text(
                      snapshot.data ?? '',
                      style: TextStyle(color: PaletteScope.of(context).textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: PaletteScope.of(context).textMuted, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
