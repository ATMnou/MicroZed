import 'package:flutter/material.dart';

import '../../data/db/database.dart';
import '../../data/theme/palette_scope.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/local_avatar.dart';

/// 게임 화면 상단에 고정으로 얹는 상대 캐릭터 배너. [line]이 있으면 말풍선으로 짧은
/// 대사를 자연스럽게 페이드인/아웃한다.
class OpponentBanner extends StatelessWidget {
  const OpponentBanner({super.key, required this.opponent, this.line, this.turnLabel});

  final Character opponent;
  final String? line;
  final String? turnLabel;

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocalAvatar(imagePath: opponent.imagePath, radius: 22, icon: Icons.pets),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      opponent.name,
                      style: TextStyle(color: p.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    if (turnLabel != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10)),
                        child: Text(turnLabel!, style: TextStyle(color: p.textSecondary, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: (line == null || line!.isEmpty)
                      ? const SizedBox(key: ValueKey('empty'), height: 0)
                      : Container(
                          key: ValueKey(line),
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(10)),
                          child: Text(line!, style: TextStyle(color: p.textSecondary, fontSize: 12)),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 생명/체력 게이지(라이어스바 전용). 리볼버 연출 대신 하트 아이콘으로 표시한다.
class LifeHearts extends StatelessWidget {
  const LifeHearts({super.key, required this.current, required this.max});

  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    final p = PaletteScope.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final filled = i < current;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            filled ? Icons.favorite : Icons.favorite_border,
            key: ValueKey('$i-$filled'),
            color: filled ? p.danger : p.textFaint,
            size: 18,
          ),
        );
      }),
    );
  }
}

enum GameEndOutcome { win, loss, draw }

/// 게임 종료 시 띄우는 결과 시트. '다시하기'를 누르면 [onPlayAgain]을, '게임 목록으로'를
/// 누르면 현재 게임 화면 자체를 pop한다.
Future<void> showGameEndSheet(
  BuildContext context, {
  required GameEndOutcome outcome,
  required VoidCallback onPlayAgain,
}) {
  final l10n = AppLocalizations.of(context)!;
  final p = PaletteScope.of(context);
  final (title, color) = switch (outcome) {
    GameEndOutcome.win => (l10n.gameYouWinTitle, p.primary),
    GameEndOutcome.loss => (l10n.gameYouLoseTitle, p.danger),
    GameEndOutcome.draw => (l10n.gameDrawTitle, p.textSecondary),
  };
  return showModalBottomSheet(
    context: context,
    backgroundColor: p.surface,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    onPlayAgain();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.gamePlayAgainButton, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    // 게임 화면 + 상대 선택 화면을 모두 닫고 게임 홈으로 돌아간다.
                    await Navigator.of(context).maybePop();
                    if (context.mounted) await Navigator.of(context).maybePop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: p.textPrimary,
                    side: BorderSide(color: p.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.gameBackToListButton),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
