import 'dart:math';

import '../../db/database.dart';
import '../game_llm_choice.dart';
import 'uno_models.dart';

enum UnoPlayer { user, opponent }

/// 1:1 우노. 표준 108장 덱을 쓰되, 2인전이라 리버스는 스킵과 동일하게(낸 사람이 한 번 더)
/// 처리한다.
class UnoEngine {
  UnoEngine() {
    _buildDeck();
    _deal();
  }

  final _random = Random();
  final List<UnoCard> drawPile = [];
  final List<UnoCard> discardPile = [];
  final List<UnoCard> userHand = [];
  final List<UnoCard> opponentHand = [];

  UnoPlayer turn = UnoPlayer.user;
  UnoColor currentColor = UnoColor.red;
  bool gameOver = false;
  UnoPlayer? winner;

  /// 마지막으로 상대가 뽑은 카드 개수(+2/+4 적용 결과) 등 화면에 알려줄 최근 이벤트 요약.
  String? lastEventKo;

  void _buildDeck() {
    for (final color in [UnoColor.red, UnoColor.yellow, UnoColor.green, UnoColor.blue]) {
      drawPile.add(UnoCard(color: color, value: UnoValue.n0));
      for (final v in [
        UnoValue.n1, UnoValue.n2, UnoValue.n3, UnoValue.n4, UnoValue.n5,
        UnoValue.n6, UnoValue.n7, UnoValue.n8, UnoValue.n9,
        UnoValue.skip, UnoValue.reverse, UnoValue.drawTwo,
      ]) {
        drawPile.add(UnoCard(color: color, value: v));
        drawPile.add(UnoCard(color: color, value: v));
      }
    }
    for (var i = 0; i < 4; i++) {
      drawPile.add(const UnoCard(color: UnoColor.wild, value: UnoValue.wild));
      drawPile.add(const UnoCard(color: UnoColor.wild, value: UnoValue.wildDrawFour));
    }
    drawPile.shuffle(_random);
  }

  void _deal() {
    for (var i = 0; i < 7; i++) {
      userHand.add(drawPile.removeLast());
      opponentHand.add(drawPile.removeLast());
    }
    // 시작 패는 진행이 꼬이지 않도록 액션/와일드가 아닌 카드가 나올 때까지 다시 뽑는다.
    UnoCard first;
    do {
      if (drawPile.isEmpty) _reshuffleFromDiscard();
      first = drawPile.removeLast();
      discardPile.add(first);
    } while (unoValueIsWild(first.value) || first.value == UnoValue.skip || first.value == UnoValue.reverse || first.value == UnoValue.drawTwo);
    currentColor = first.color;
  }

  UnoCard get topCard => discardPile.last;

  List<UnoCard> handOf(UnoPlayer player) => player == UnoPlayer.user ? userHand : opponentHand;

  bool isPlayable(UnoCard card) {
    if (unoValueIsWild(card.value)) return true;
    if (card.color == currentColor) return true;
    if (card.value == topCard.value) return true;
    return false;
  }

  void _reshuffleFromDiscard() {
    if (discardPile.length <= 1) return;
    final top = discardPile.removeLast();
    drawPile.addAll(discardPile);
    discardPile
      ..clear()
      ..add(top);
    drawPile.shuffle(_random);
  }

  /// 뽑기. 뽑은 카드를 그대로 돌려준다(호출부가 즉시 낼 수 있는지 판단할 수 있도록).
  UnoCard drawCard(UnoPlayer player) {
    if (drawPile.isEmpty) _reshuffleFromDiscard();
    if (drawPile.isEmpty) {
      // 덱과 버림더미를 합쳐도 카드가 없는 극단적인 경우 - 발생하지 않지만 방어적으로 처리.
      return handOf(player).isNotEmpty ? handOf(player).first : const UnoCard(color: UnoColor.red, value: UnoValue.n0);
    }
    final card = drawPile.removeLast();
    handOf(player).add(card);
    return card;
  }

  /// [chosenColor]는 와일드 카드를 낼 때만 의미가 있다.
  void playCard(UnoPlayer player, UnoCard card, {UnoColor? chosenColor}) {
    if (gameOver) return;
    final hand = handOf(player);
    hand.remove(card);
    discardPile.add(card);
    currentColor = unoValueIsWild(card.value) ? (chosenColor ?? UnoColor.red) : card.color;

    if (hand.isEmpty) {
      gameOver = true;
      winner = player;
      return;
    }

    final other = player == UnoPlayer.user ? UnoPlayer.opponent : UnoPlayer.user;
    switch (card.value) {
      case UnoValue.skip:
      case UnoValue.reverse:
        // 2인전에서는 리버스도 스킵과 동일: 낸 사람이 한 번 더 둔다.
        turn = player;
        lastEventKo = null;
        break;
      case UnoValue.drawTwo:
        for (var i = 0; i < 2; i++) {
          drawCard(other);
        }
        turn = player;
        break;
      case UnoValue.wildDrawFour:
        for (var i = 0; i < 4; i++) {
          drawCard(other);
        }
        turn = player;
        break;
      default:
        turn = other;
    }
  }

  /// AI가 낼 카드/색상을 고른다. 액션 카드를 우선하고, 와일드는 최후에 아껴 쓴다.
  ({UnoCard card, UnoColor? color})? chooseAiPlay() {
    final hand = opponentHand;
    final playable = hand.where(isPlayable).toList();
    if (playable.isEmpty) return null;
    playable.sort((a, b) => _priority(b.value).compareTo(_priority(a.value)));
    final chosen = playable.first;
    final color = unoValueIsWild(chosen.value) ? pickColorForHand(hand) : null;
    return (card: chosen, color: color);
  }

  /// 와일드를 낼 때 어떤 색을 부를지 고르는 휴리스틱(손패에서 가장 많은 색). [UnoLlmAi]도
  /// 색상 선택만큼은 이 로직을 그대로 재사용한다 - 승패에 큰 영향이 없는 지엽적인 결정이라
  /// LLM 판단 대상에서 제외했다.
  UnoColor pickColorForHand(List<UnoCard> hand) {
    final counts = <UnoColor, int>{};
    for (final c in hand) {
      if (c.color != UnoColor.wild) counts[c.color] = (counts[c.color] ?? 0) + 1;
    }
    return counts.isEmpty
        ? UnoColor.values[_random.nextInt(4)]
        : (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;
  }

  int _priority(UnoValue v) {
    if (unoValueIsWild(v)) return 0;
    if (v == UnoValue.drawTwo) return 3;
    if (v == UnoValue.skip || v == UnoValue.reverse) return 2;
    return 1;
  }
}

/// 낼 카드 선택만 LLM에게 맡기고(손패 중 낼 수 있는 카드만 후보), 와일드 색상은 기존
/// [UnoEngine.pickColorForHand] 휴리스틱을 그대로 쓴다. 낼 수 있는 카드가 아예 없으면(뽑아야
/// 하는 상황) LLM 경로를 타지 않고 null을 돌려준다 - 호출부가 기존 뽑기 로직을 그대로 쓴다.
class UnoLlmAi {
  Future<({UnoCard card, UnoColor? color})?> chooseMove({
    required UnoEngine engine,
    required GameLlmChoice llmChoice,
    required AiPreset? preset,
    required Character character,
  }) async {
    final playable = engine.opponentHand.where(engine.isPlayable).toList();
    if (playable.isEmpty) return null;
    final options = [for (final c in playable) _describeCard(c)];
    final index = await llmChoice.chooseIndex(
      preset: preset,
      character: character,
      gameNameKo: '우노',
      stateKo: _stateText(engine),
      options: options,
    );
    final chosen = index != null ? playable[index] : engine.chooseAiPlay()!.card;
    final color = unoValueIsWild(chosen.value) ? engine.pickColorForHand(engine.opponentHand) : null;
    return (card: chosen, color: color);
  }

  String _describeCard(UnoCard c) {
    if (unoValueIsWild(c.value)) {
      return c.value == UnoValue.wildDrawFour ? '와일드 드로우4' : '와일드';
    }
    final colorKo = switch (c.color) {
      UnoColor.red => '빨강',
      UnoColor.yellow => '노랑',
      UnoColor.green => '초록',
      UnoColor.blue => '파랑',
      UnoColor.wild => '',
    };
    final valueKo = switch (c.value) {
      UnoValue.skip => '스킵',
      UnoValue.reverse => '리버스',
      UnoValue.drawTwo => '드로우2',
      _ => '${unoValueNumber(c.value)}',
    };
    return '$colorKo $valueKo';
  }

  String _stateText(UnoEngine engine) {
    final handText = engine.opponentHand.map(_describeCard).join(', ');
    final colorKo = switch (engine.currentColor) {
      UnoColor.red => '빨강',
      UnoColor.yellow => '노랑',
      UnoColor.green => '초록',
      UnoColor.blue => '파랑',
      UnoColor.wild => '무색',
    };
    return '현재 색: $colorKo, 맨 위 카드: ${_describeCard(engine.topCard)}\n내 손패(낼 수 있는 카드만): $handText';
  }
}
