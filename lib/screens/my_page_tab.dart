import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../data/backup/backup_service.dart';
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
  late final BackupService _backupService;
  bool _backingUp = false;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _tokenUsageRepository = TokenUsageRepository(AppDatabase.instance);
    _backupService = BackupService(AppDatabase.instance);
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
              _buildBackupSection(context),
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

  Widget _buildBackupSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('데이터 백업', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text(
            '플롯/캐릭터/대화/로어북/프리셋 등 모든 데이터를 파일 하나로 저장하거나 불러올 수 있어요.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _backingUp || _restoring ? null : _exportBackup,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF3A3A3A)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: _backingUp
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                      )
                    : const Icon(Icons.save_alt, size: 16),
                label: const Text('전체 저장', style: TextStyle(fontSize: 13)),
              ),
              OutlinedButton.icon(
                onPressed: _backingUp || _restoring ? null : _importBackup,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF3A3A3A)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: _restoring
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                      )
                    : const Icon(Icons.file_upload_outlined, size: 16),
                label: const Text('전체 불러오기', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup() async {
    setState(() => _backingUp = true);
    try {
      final bytes = await _backupService.exportAll();
      final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final location = await getSaveLocation(
        suggestedName: 'microzed_backup_$timestamp.mzbackup',
        acceptedTypeGroups: const [
          XTypeGroup(label: 'MicroZed backup', extensions: ['mzbackup']),
        ],
      );
      if (location == null) return; // 취소됨
      await File(location.path).writeAsBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전체 데이터를 저장했어요.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장에 실패했어요: $e')),
      );
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
  }

  Future<void> _importBackup() async {
    final picked = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'MicroZed backup', extensions: ['mzbackup']),
      ],
    );
    if (picked == null) return; // 취소됨
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('전체 불러오기', style: TextStyle(color: Colors.white)),
        content: const Text(
          '지금 앱에 있는 모든 플롯/캐릭터/대화/로어북/프리셋이 이 백업 내용으로 완전히 대체돼요.\n'
          '이 작업은 되돌릴 수 없어요. 계속할까요?',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('복원', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _restoring = true);
    try {
      final bytes = await picked.readAsBytes();
      final summary = await _backupService.restoreFromBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '복원 완료: 플롯 ${summary.plotCount}개, 대화 메시지 ${summary.chatMessageCount}개, 로어북 ${summary.lorebookCount}개',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('불러오기에 실패했어요: $e')),
      );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
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
