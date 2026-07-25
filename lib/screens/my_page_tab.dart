import 'package:flutter/material.dart';

import '../data/db/database.dart';
import '../data/repositories/token_usage_repository.dart';
import 'ai_preset_screen.dart';
import 'profile_list_screen.dart';
import 'token_usage_history_screen.dart';

/// '마이페이지' 탭 화면.
/// 유저 프로필 카드, 제타패스 배너, 스캐터랩 정보 등 불필요한 항목은 제거하고
/// 대화 프로필 편집 버튼과 소모된 토큰 표시만 남겼다.
class MyPageTab extends StatefulWidget {
  const MyPageTab({super.key});

  @override
  State<MyPageTab> createState() => _MyPageTabState();
}

class _MyPageTabState extends State<MyPageTab> {
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
        _buildTopBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildProfileEditButton(context),
                  _buildPresetSettingButton(context),
                ],
              ),
              const SizedBox(height: 16),
              _buildTokenSection(context),
              const SizedBox(height: 32),
              _buildSourceLink(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const Text(
            '마이페이지',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Icon(Icons.menu, color: Colors.white, size: 22),
        ],
      ),
    );
  }

  Widget _buildProfileEditButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileListScreen()),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF3A3A3A)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text('대화 프로필 편집', style: TextStyle(fontSize: 13)),
    );
  }

  Widget _buildPresetSettingButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AiPresetScreen()),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF3A3A3A)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text('AI 프리셋 설정', style: TextStyle(fontSize: 13)),
    );
  }

  Widget _buildTokenSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Color(0xFF7A6FF0), size: 20),
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
                  const Text('소모된 토큰', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    formatted,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Color(0xFF3A3A3A)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('내역', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceLink() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '소스 링크 (준비 중)',
        style: TextStyle(color: Colors.white24, fontSize: 12),
      ),
    );
  }
}
