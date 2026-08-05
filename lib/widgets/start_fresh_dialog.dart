import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../data/theme/color_palette.dart';
import '../data/theme/palette_scope.dart';

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
  ColorPalette get _p => PaletteScope.of(context);
  Color get _purple => _p.primary;
  Color get _cardBg => _p.surface;
  Color get _textPrimary => _p.textPrimary;
  Color get _mutedText => _p.textMuted;
  Color get _textSecondary => _p.textSecondary;
  Color get _borderGrey => _p.border;
  bool _saveCurrent = true;


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: _cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.startFreshDialogTitle,
              style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.startFreshDialogDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: _mutedText, fontSize: 13, height: 1.4),
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
                  Text(l10n.startFreshDialogSaveCheckbox, style: TextStyle(color: _textSecondary, fontSize: 13)),
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
                      foregroundColor: _textSecondary,
                      side: BorderSide(color: _borderGrey),
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
                      foregroundColor: _textPrimary,
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
