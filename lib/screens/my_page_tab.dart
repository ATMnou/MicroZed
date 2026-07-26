import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../data/backup/backup_service.dart';
import '../data/db/database.dart';
import '../data/repositories/token_usage_repository.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'ai_preset_screen.dart';
import 'profile_list_screen.dart';
import 'system_prompt_edit_screen.dart';
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
        _buildTopBar(context),
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
                  _buildSystemPromptButton(context),
                ],
              ),
              const SizedBox(height: 16),
              _buildTokenSection(context),
              const SizedBox(height: 16),
              _buildLanguageSection(context),
              const SizedBox(height: 32),
              _buildBackupSection(context),
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
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Icon(Icons.menu, color: Colors.white, size: 22),
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
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF3A3A3A)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(l10n.myPageEditProfileButton, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildPresetSettingButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
      child: Text(l10n.myPageAiPresetButton, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildSystemPromptButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SystemPromptEditScreen()),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF3A3A3A)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(l10n.systemPromptButtonLabel, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildTokenSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  Text(l10n.myPageTokensUsedLabel, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
            child: Text(l10n.myPageHistoryButton, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.language, color: Colors.white70),
        title: Text(l10n.settingsLanguage, style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: ValueListenableBuilder<Locale?>(
          valueListenable: localeController,
          builder: (context, locale, _) {
            return Text(
              _labelForLocale(l10n, locale),
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            );
          },
        ),
        onTap: () => _showLanguagePicker(context),
      ),
    );
  }

  String _labelForLocale(AppLocalizations l10n, Locale? locale) {
    switch (locale?.languageCode) {
      case 'ko':
        return l10n.languageKorean;
      case 'en':
        return l10n.languageEnglish;
      case 'ja':
        return l10n.languageJapanese;
      default:
        return l10n.languageSystemDefault;
    }
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final current = localeController.value;
    final options = <Locale?>[null, const Locale('ko'), const Locale('en'), const Locale('ja')];

    final selected = await showDialog<Locale?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(l10n.settingsLanguageDialogTitle, style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: options.map((locale) {
              return RadioListTile<Locale?>(
                value: locale,
                groupValue: current,
                activeColor: const Color(0xFF7A6FF0),
                title: Text(_labelForLocale(l10n, locale), style: const TextStyle(color: Colors.white)),
                onChanged: (value) => Navigator.of(dialogContext).pop(value),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (!context.mounted) return;
    if (selected != current || (selected == null && current == null)) {
      await localeController.setLocale(selected);
    }
  }

  Widget _buildBackupSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.myPageBackupSectionTitle, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            l10n.myPageBackupSectionDescription,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
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
                label: Text(l10n.myPageExportAllButton, style: const TextStyle(fontSize: 13)),
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
                label: Text(l10n.myPageImportAllButton, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup() async {
    final l10n = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(l10n.myPageExportSuccessMessage)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.myPageExportFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
  }

  Future<void> _importBackup() async {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(l10n.myPageImportDialogTitle, style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n.myPageImportDialogContent,
          style: const TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.myPageImportRestoreButton, style: const TextStyle(color: Colors.redAccent)),
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
            l10n.myPageImportSuccessMessage(summary.plotCount, summary.chatMessageCount, summary.lorebookCount),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.myPageImportFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Widget _buildSourceLink(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        l10n.myPageSourceLinkComingSoon,
        style: const TextStyle(color: Colors.white24, fontSize: 12),
      ),
    );
  }
}
