import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../data/theme/palette_scope.dart';

/// 유저 말풍선 메뉴의 '여기서부터 새로하기'를 눌렀을 때 뜨는 확인 다이얼로그.
/// 결과: true면 확인, null이면 취소. 기존 대화는 항상 그대로 보관되고 '이어하기'에 남는다.
class StartFreshFromHereDialog extends StatelessWidget {
  const StartFreshFromHereDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(context: context, builder: (_) => const StartFreshFromHereDialog());
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: PaletteScope.of(context).surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.startFreshFromHereDialogTitle,
              style: TextStyle(color: PaletteScope.of(context).textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.startFreshFromHereDialogDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: PaletteScope.of(context).textMuted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PaletteScope.of(context).textSecondary,
                      side: BorderSide(color: PaletteScope.of(context).border),
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
                      backgroundColor: PaletteScope.of(context).primary,
                      foregroundColor: PaletteScope.of(context).textPrimary,
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
