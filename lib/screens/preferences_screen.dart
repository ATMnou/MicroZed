import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/ai/local_llm/local_llm_engine.dart';
import '../data/app_theme_preferences.dart';
import '../data/backup/backup_service.dart';
import '../data/chat_image_preferences.dart';
import '../data/db/database.dart';
import '../data/db/seed.dart';
import '../data/update_checker.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'ai_preset_screen.dart';
import 'lan_sync_screen.dart';
import 'local_llm_screen.dart';
import 'snapshot_settings_screen.dart';
import 'summary_settings_screen.dart';
import 'system_prompt_edit_screen.dart';

/// 마이페이지 > '환경설정'. 채팅에 붙는 인트로/스냅샷 이미지를 정사각형으로 보여줄지,
/// 가로를 꽉 채워서 보여줄지 고르고, 맨 아래 위험 구역에서 전체 초기화도 할 수 있다.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  static const _cardBg = Color(0xFF1E1E1E);
  static const _borderGrey = Color(0xFF3A3A3A);
  static const _purple = Color(0xFF7A6FF0);

  bool _resetting = false;
  bool _backingUp = false;
  bool _restoring = false;
  late final BackupService _backupService;
  final _updateChecker = UpdateChecker();
  bool _checkingUpdate = false;
  UpdateCheckResult? _updateResult;
  String? _currentVersion;

  @override
  void initState() {
    super.initState();
    _backupService = BackupService(AppDatabase.instance);
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _currentVersion = info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          l10n.preferencesTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAiSection(context),
            const SizedBox(height: 24),
            _buildLanguageSection(context),
            const SizedBox(height: 24),
            _buildThemeSection(context),
            const SizedBox(height: 24),
            Text(
              l10n.preferencesImageDisplayModeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.preferencesImageDisplayModeDescription,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<ChatImageDisplayMode>(
              valueListenable: chatImagePreferences,
              builder: (context, mode, _) {
                return Column(
                  children: ChatImageDisplayMode.values.map((option) {
                    final selected = option == mode;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => chatImagePreferences.setMode(option),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? _purple : _borderGrey,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option == ChatImageDisplayMode.square
                                      ? l10n.preferencesImageDisplaySquareOption
                                      : l10n.preferencesImageDisplayFullWidthOption,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check,
                                  color: _purple,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildBackupSection(context),
            const SizedBox(height: 24),
            _buildVersionSection(context),
            const SizedBox(height: 32),
            _buildDangerZone(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAiSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.preferencesAiSectionTitle,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildNavButton(
              label: l10n.myPageAiPresetButton,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiPresetScreen()),
              ),
            ),
            _buildNavButton(
              label: l10n.myPageLocalLlmButton,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LocalLlmScreen()),
              ),
            ),
            _buildNavButton(
              label: l10n.systemPromptButtonLabel,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SystemPromptEditScreen()),
              ),
            ),
            _buildNavButton(
              label: l10n.myPageSnapshotSettingsButton,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SnapshotSettingsScreen()),
              ),
            ),
            _buildNavButton(
              label: l10n.myPageSummarySettingsButton,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SummarySettingsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton({required String label, required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: _borderGrey),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  String _themeOptionLabel(AppLocalizations l10n, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return l10n.preferencesThemeDarkOption;
      case AppThemeMode.light:
        return l10n.preferencesThemeLightOption;
      case AppThemeMode.amoled:
        return l10n.preferencesThemeAmoledOption;
      case AppThemeMode.system:
        return l10n.preferencesThemeSystemOption;
    }
  }

  Widget _buildThemeSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.preferencesThemeSectionTitle,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<AppThemeMode>(
          valueListenable: appThemePreferences,
          builder: (context, mode, _) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppThemeMode.values.map((option) {
                final selected = option == mode;
                return ChoiceChip(
                  label: Text(_themeOptionLabel(l10n, option)),
                  selected: selected,
                  onSelected: (_) => appThemePreferences.setMode(option),
                  backgroundColor: _cardBg,
                  selectedColor: _purple.withValues(alpha: 0.25),
                  labelStyle: TextStyle(
                    color: selected ? _purple : Colors.white70,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(color: selected ? _purple : _borderGrey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: _cardBg,
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
        backgroundColor: _cardBg,
        title: Text(l10n.settingsLanguageDialogTitle, style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: options.map((locale) {
              return RadioListTile<Locale?>(
                value: locale,
                groupValue: current,
                activeColor: _purple,
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
        color: _cardBg,
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
                  side: const BorderSide(color: _borderGrey),
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
                  side: const BorderSide(color: _borderGrey),
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
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LanSyncScreen()),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: _borderGrey),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.wifi_tethering, size: 16),
                label: Text(l10n.lanSyncSectionTitle, style: const TextStyle(fontSize: 13)),
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
      final path = await FilePicker.saveFile(
        fileName: 'microzed_backup_$timestamp.mzbackup',
        type: FileType.custom,
        allowedExtensions: const ['mzbackup'],
        bytes: bytes,
      );
      if (path == null) return; // 취소됨
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
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mzbackup'],
    );
    if (result == null || result.files.isEmpty) return; // 취소됨
    final picked = result.files.single;
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
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

  Widget _buildVersionSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = _updateResult;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.preferencesVersionSectionTitle,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.preferencesCurrentVersionLabel(_currentVersion ?? '...'),
            style: const TextStyle(color: Colors.white54, fontSize: 12.5),
          ),
          if (result != null) ...[
            const SizedBox(height: 6),
            Text(
              result.checkFailed
                  ? l10n.preferencesUpdateCheckFailedMessage
                  : result.updateAvailable
                      ? l10n.preferencesUpdateAvailableMessage(result.latestVersion ?? '')
                      : l10n.preferencesUpToDateMessage,
              style: TextStyle(
                color: result.updateAvailable ? _purple : Colors.white38,
                fontSize: 12.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _checkingUpdate ? null : _checkForUpdate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: _borderGrey),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: _checkingUpdate
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                      )
                    : const Icon(Icons.refresh, size: 16),
                label: Text(l10n.preferencesCheckUpdateButton, style: const TextStyle(fontSize: 13)),
              ),
              if (result?.updateAvailable == true && result?.releaseUrl != null)
                OutlinedButton.icon(
                  onPressed: () => launchUrl(Uri.parse(result!.releaseUrl!), mode: LaunchMode.externalApplication),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _purple,
                    side: const BorderSide(color: _purple),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(l10n.preferencesViewReleaseButton, style: const TextStyle(fontSize: 13)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdate() async {
    setState(() => _checkingUpdate = true);
    final result = await _updateChecker.check();
    if (!mounted) return;
    setState(() {
      _updateResult = result;
      _checkingUpdate = false;
    });
  }

  Widget _buildDangerZone(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.preferencesDangerZoneTitle,
            style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.preferencesResetAllDescription,
            style: const TextStyle(color: Colors.white38, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _resetting ? null : () => _confirmReset(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            icon: _resetting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                  )
                : const Icon(Icons.delete_forever_outlined, size: 16),
            label: Text(l10n.preferencesResetAllButton),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text(l10n.preferencesResetAllButton, style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n.preferencesResetConfirmContent,
          style: const TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonConfirm, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;

    final confirmWord = l10n.preferencesResetConfirmWord;
    final controller = TextEditingController();
    final typedOk = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final matches = controller.text.trim() == confirmWord;
          return AlertDialog(
            backgroundColor: _cardBg,
            title: Text(l10n.preferencesResetAllButton, style: const TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.preferencesResetTypeToConfirm(confirmWord),
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  onChanged: (_) => setDialogState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: confirmWord,
                    hintStyle: const TextStyle(color: Colors.white24),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: _borderGrey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: matches ? () => Navigator.of(dialogContext).pop(true) : null,
                child: Text(l10n.preferencesResetAllButton, style: const TextStyle(color: Colors.redAccent)),
              ),
            ],
          );
        },
      ),
    );
    controller.dispose();
    if (typedOk != true || !context.mounted) return;
    await _performReset(context);
  }

  Future<void> _performReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _resetting = true);
    try {
      await LocalLlmEngine.instance.unload();
      await BackupService(AppDatabase.instance).resetAll();
      await seedIfEmpty(AppDatabase.instance);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.preferencesResetSuccessMessage)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.preferencesResetFailureMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
  }
}
