import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/db/database.dart';
import '../data/repositories/token_usage_repository.dart';
import '../l10n/app_localizations.dart';
import 'preferences_screen.dart';
import 'profile_list_screen.dart';
import 'token_usage_history_screen.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

const _repoUrl = 'https://github.com/ATMnou/MicroZed';

/// '마이페이지' 탭 화면.
/// 유저 프로필 카드, 제타패스 배너, 스캐터랩 정보 등 불필요한 항목은 제거하고
/// 대화 프로필 편집 버튼과 소모된 토큰 표시만 남겼다. AI 프리셋/로컬 LLM/시스템 프롬프트/
/// 스냅샷/언어/백업처럼 자주 안 건드리는 설정류는 환경설정(PreferencesScreen)으로 옮겼다.
class MyPageTab extends StatefulWidget {
  const MyPageTab({super.key});

  @override
  State<MyPageTab> createState() => _MyPageTabState();
}

class _MyPageTabState extends State<MyPageTab> {
  ColorPalette get _p => PaletteScope.of(context);
  Color get _textPrimary => _p.textPrimary;
  Color get _borderGrey => _p.border;
  Color get _cardBg => _p.surface;
  Color get _purple => _p.primary;
  Color get _textSecondary => _p.textSecondary;
  Color get _textFaint => _p.textFaint;
  Color get _mutedText => _p.textMuted;
  late final TokenUsageRepository _tokenUsageRepository;

  @override
  void initState() {
    super.initState();
    _tokenUsageRepository = TokenUsageRepository(AppDatabase.instance);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileEditButton(context),
              const SizedBox(height: 16),
              _buildTokenSection(context),
              const SizedBox(height: 32),
              _buildSourceLink(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Text(
            l10n.myPageTitle,
            style: TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PreferencesScreen()),
              );
            },
            child: Icon(Icons.settings_outlined, color: _textPrimary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileEditButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileListScreen()),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: _textPrimary,
        side: BorderSide(color: _borderGrey),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(l10n.myPageEditProfileButton, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildTokenSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt, color: _purple, size: 20),
          const SizedBox(width: 8),
          StreamBuilder<TokenUsageTotals>(
            stream: _tokenUsageRepository.watchTotals(),
            builder: (context, snapshot) {
              final totalTokens = snapshot.data?.totalTokens ?? 0;
              final formatted = totalTokens.toString().replaceAllMapped(
                    RegExp(r'\B(?=(\d{3})+(?!\d))'),
                    (m) => ',',
                  );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.myPageTokensUsedLabel, style: TextStyle(color: _textSecondary, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    formatted,
                    style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TokenUsageHistoryScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _textSecondary,
              side: BorderSide(color: _borderGrey),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(l10n.myPageHistoryButton, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceLink(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => showLicensePage(
            context: context,
            applicationName: l10n.appTitle,
          ),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.description_outlined, color: _textFaint, size: 16),
                const SizedBox(width: 8),
                Text(l10n.myPageLicensesButton, style: TextStyle(color: _mutedText, fontSize: 13)),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () => launchUrl(Uri.parse(_repoUrl), mode: LaunchMode.externalApplication),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.code, color: _textFaint, size: 16),
                const SizedBox(width: 8),
                Text(l10n.myPageSourceCodeButton, style: TextStyle(color: _mutedText, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
