import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// 채팅 화면 드로어의 '새로하기'를 눌렀을 때 뜨는 확인 다이얼로그.
/// 결과: null이면 취소, true/false면 확인 + '현재 대화 저장하기' 체크 여부.
class StartFreshDialog extends StatefulWidget {
  const StartFreshDialog({super.key});

  @override
  State<StartFreshDialog> createState() => _StartFreshDialogState();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(context: context, builder: (_) => const StartFreshDialog());
  }
}

class _StartFreshDialogState extends State<StartFreshDialog> {
  bool _saveCurrent = true;

  static const _purple = Color(0xFF7A6FF0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.startFreshDialogTitle,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.startFreshDialogDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => setState(() => _saveCurrent = !_saveCurrent),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _saveCurrent,
                    activeColor: _purple,
                    onChanged: (v) => setState(() => _saveCurrent = v ?? true),
                  ),
                  Text(l10n.startFreshDialogSaveCheckbox, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Color(0xFF3A3A3A)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_saveCurrent),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(l10n.commonConfirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
