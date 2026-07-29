import 'package:flutter/material.dart';

import '../data/ai/local_llm/local_llm_engine.dart';
import '../data/backup/backup_service.dart';
import '../data/chat_image_preferences.dart';
import '../data/db/database.dart';
import '../data/db/seed.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

/// 마이페이지 > '환경설정'. 채팅에 붙는 인트로/스냅샷 이미지를 정사각형으로 보여줄지,
/// 가로를 꽉 채워서 보여줄지 고르고, 맨 아래 위험 구역에서 전체 초기화도 할 수 있다.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  static const _background = Color(0xFF141414);
  static const _cardBg = Color(0xFF1E1E1E);
  static const _borderGrey = Color(0xFF3A3A3A);
  static const _purple = Color(0xFF7A6FF0);

  bool _resetting = false;

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
            const SizedBox(height: 32),
            _buildDangerZone(context),
          ],
        ),
      ),
    );
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
