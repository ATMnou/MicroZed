import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// 유저 말풍선 메뉴의 '여기서부터 새로하기'를 눌렀을 때 뜨는 확인 다이얼로그.
/// 결과: true면 확인, null이면 취소. 기존 대화는 항상 그대로 보관되고 '이어하기'에 남는다.
class StartFreshFromHereDialog extends StatelessWidget {
  const StartFreshFromHereDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(context: context, builder: (_) => const StartFreshFromHereDialog());
  }

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
              l10n.startFreshFromHereDialogTitle,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.startFreshFromHereDialogDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
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
                    onPressed: () => Navigator.of(context).pop(true),
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
