import 'dart:math';

import '../../db/database.dart';
import '../game_llm_choice.dart';

enum LiarsBarPlayer { user, opponent }

/// 스팀 원작의 리볼버 대신, 이 앱에서는 생명(하트) 게이지로 탈락을 표현한다.
enum LiarsBarRank { ace, king, queen, joker }

class LiarsBarChallengeResult {
  const LiarsBarChallengeResult({required this.claimWasTrue, required this.cards, required this.loser});
  final bool claimWasTrue;
  final List<LiarsBarRank> cards;
  final LiarsBarPlayer loser;
}

class LiarsBarClaim {
  const LiarsBarClaim({required this.player, required this.cards});
  final LiarsBarPlayer player;
  final List<LiarsBarRank> cards;
}

/// 1:1 라이어스바. 축소 덱(A/K/Q 각 4장 + 조커 2장 = 14장)에서 5장씩 나눠 갖고, 라운드마다
/// 목표 카드(A/K/Q 중 하나, 조커는 항상 와일드로 인정)를 랜덤으로 정한다.
class LiarsBarEngine {
  LiarsBarEngine({this.maxLife = 3}) {
    _roundStarter = LiarsBarPlayer.user;
    startRound();
  }

  final int maxLife;
  final _random = Random();

  List<LiarsBarRank> userHand = [];
  List<LiarsBarRank> opponentHand = [];
  final List<LiarsBarRank> _burned = [];

  LiarsBarRank targetRank = LiarsBarRank.ace;
  LiarsBarPlayer turn = LiarsBarPlayer.user;
  LiarsBarClaim? pendingClaim;
  late LiarsBarPlayer _roundStarter;

  int userLife = 3;
  int opponentLife = 3;
  bool gameOver = false;
  LiarsBarPlayer? matchWinner;

  List<LiarsBarRank> handOf(LiarsBarPlayer p) => p == LiarsBarPlayer.user ? userHand : opponentHand;

  bool matchesTarget(LiarsBarRank rank) => rank == targetRank || rank == LiarsBarRank.joker;

  void startRound() {
    final deck = <LiarsBarRank>[
      for (var i = 0; i < 4; i++) LiarsBarRank.ace,
      for (var i = 0; i < 4; i++) LiarsBarRank.king,
      for (var i = 0; i < 4; i++) LiarsBarRank.queen,
      LiarsBarRank.joker,
      LiarsBarRank.joker,
    ]..shuffle(_random);
    userHand = deck.sublist(0, 5);
    opponentHand = deck.sublist(5, 10);
    targetRank = [LiarsBarRank.ace, LiarsBarRank.king, LiarsBarRank.queen][_random.nextInt(3)];
    _burned.clear();
    pendingClaim = null;
    turn = _roundStarter;
  }

  /// 낼 카드 1~3장을 목표 카드라고 주장하며 뒷면으로 낸다. 카드 자체는 손패에서 바로 빠진다.
  void playClaim(LiarsBarPlayer player, List<LiarsBarRank> cards) {
    if (gameOver || cards.isEmpty || cards.length > 3) return;
    final hand = handOf(player);
    for (final c in cards) {
      hand.remove(c);
    }
    pendingClaim = LiarsBarClaim(player: player, cards: cards);
    turn = player == LiarsBarPlayer.user ? LiarsBarPlayer.opponent : LiarsBarPlayer.user;
  }

  /// 믿는다: 낸 카드는 판에서 완전히 빠지고, 낸 사람 손패가 비었으면 그 사람이 라운드를
  /// 이겨서 상대가 생명을 잃는다. 아니면 믿어준 사람 차례로 넘어간다.
  LiarsBarPlayer? believe() {
    final claim = pendingClaim;
    if (claim == null) return null;
    _burned.addAll(claim.cards);
    pendingClaim = null;
    if (handOf(claim.player).isEmpty) {
      final loser = claim.player == LiarsBarPlayer.user ? LiarsBarPlayer.opponent : LiarsBarPlayer.user;
      _loseLife(loser);
      return loser;
    }
    turn = claim.player == LiarsBarPlayer.user ? LiarsBarPlayer.opponent : LiarsBarPlayer.user;
    return null;
  }

  /// 의심한다: 공개해서 진실이면 의심한 사람이, 거짓(블러핑)이면 낸 사람이 생명을 잃는다.
  LiarsBarChallengeResult challenge(LiarsBarPlayer challenger) {
    final claim = pendingClaim!;
    final allTrue = claim.cards.every(matchesTarget);
    final loser = allTrue ? challenger : claim.player;
    _burned.addAll(claim.cards);
    pendingClaim = null;
    _loseLife(loser);
    return LiarsBarChallengeResult(claimWasTrue: allTrue, cards: claim.cards, loser: loser);
  }

  void _loseLife(LiarsBarPlayer player) {
    if (player == LiarsBarPlayer.user) {
      userLife = (userLife - 1).clamp(0, maxLife);
    } else {
      opponentLife = (opponentLife - 1).clamp(0, maxLife);
    }
    if (userLife <= 0 || opponentLife <= 0) {
      gameOver = true;
      matchWinner = userLife <= 0 ? LiarsBarPlayer.opponent : LiarsBarPlayer.user;
      return;
    }
    _roundStarter = player == LiarsBarPlayer.user ? LiarsBarPlayer.opponent : LiarsBarPlayer.user;
    startRound();
  }

  /// 아직 상대(또는 나) 손에 있을 수 있는, 목표와 일치하는 카드 최대 개수(내 손패 + 이미
  /// 소모된 카드는 제외). 의심 여부 판단 휴리스틱에 쓴다.
  int remainingMatchingOutside(List<LiarsBarRank> knownHand) {
    // A/K/Q 각각 4장 + 조커 2장(항상 와일드) = 목표와 일치할 수 있는 카드 총 6장.
    const totalMatching = 6;
    final knownMatching = knownHand.where(matchesTarget).length;
    final burnedMatching = _burned.where(matchesTarget).length;
    return (totalMatching - knownMatching - burnedMatching).clamp(0, totalMatching);
  }
}

/// 난이도 설정이 없는 고정 휴리스틱 AI(블러핑 비율/의심 판단).
class LiarsBarAi {
  final _random = Random();

  List<LiarsBarRank> chooseClaim(LiarsBarEngine engine) {
    final hand = engine.opponentHand;
    final honest = hand.where(engine.matchesTarget).toList();
    final bluffPool = hand.where((r) => !engine.matchesTarget(r)).toList();

    if (honest.isEmpty) {
      final count = min(1 + _random.nextInt(2), bluffPool.length);
      bluffPool.shuffle(_random);
      return bluffPool.take(count.clamp(1, bluffPool.length)).toList();
    }
    final wantBluffMix = _random.nextDouble() < 0.2 && bluffPool.isNotEmpty;
    honest.shuffle(_random);
    final honestCount = min(3, honest.length);
    final playHonest = honest.take(honestCount).toList();
    if (wantBluffMix && playHonest.length < 3) {
      bluffPool.shuffle(_random);
      playHonest.add(bluffPool.first);
    }
    return playHonest.take(3).toList();
  }

  bool decideChallenge(LiarsBarEngine engine) {
    final claim = engine.pendingClaim!;
    final claimedCount = claim.cards.length;
    final possibleOutside = engine.remainingMatchingOutside(engine.opponentHand);
    if (claimedCount > possibleOutside) return true; // 상대 손에 그만큼 있을 수 없으니 확실한 블러핑
    final baseSuspicion = 0.12 + 0.22 * (claimedCount - 1);
    return _random.nextDouble() < baseSuspicion;
  }
}

/// 두 판단 지점 모두 "기존 [LiarsBarAi] 휴리스틱이 만든 후보 중 선택" 방식이라, LLM이 무슨
/// 답을 하든 항상 이미 유효한(손패 범위 안의) 카드 조합/이진 선택만 나온다.
class LiarsBarLlmAi {
  final _fallback = LiarsBarAi();

  Future<List<LiarsBarRank>> chooseClaim({
    required LiarsBarEngine engine,
    required GameLlmChoice llmChoice,
    required AiPreset? preset,
    required Character character,
  }) async {
    final candidates = <String, List<LiarsBarRank>>{};
    for (var i = 0; i < 3; i++) {
      final claim = _fallback.chooseClaim(engine);
      candidates[claim.map((r) => r.name).join(',')] = claim;
    }
    final options = candidates.values.toList();
    final index = await llmChoice.chooseIndex(
      preset: preset,
      character: character,
      gameNameKo: '라이어스바',
      stateKo: _claimStateText(engine),
      options: [for (final c in options) '${_describeCards(c)} 냄 (${c.length}장)'],
    );
    return index != null ? options[index] : _fallback.chooseClaim(engine);
  }

  Future<bool> decideChallenge({
    required LiarsBarEngine engine,
    required GameLlmChoice llmChoice,
    required AiPreset? preset,
    required Character character,
  }) async {
    final index = await llmChoice.chooseIndex(
      preset: preset,
      character: character,
      gameNameKo: '라이어스바',
      stateKo: _challengeStateText(engine),
      options: const ['믿는다(그대로 넘어간다)', '의심한다(공개시켜서 확인한다)'],
    );
    if (index != null) return index == 1;
    return _fallback.decideChallenge(engine);
  }

  String _rankKo(LiarsBarRank rank) => switch (rank) {
        LiarsBarRank.ace => 'A',
        LiarsBarRank.king => 'K',
        LiarsBarRank.queen => 'Q',
        LiarsBarRank.joker => '조커',
      };

  String _describeCards(List<LiarsBarRank> cards) => cards.map(_rankKo).join(', ');

  String _claimStateText(LiarsBarEngine engine) {
    final targetKo = _rankKo(engine.targetRank);
    return '목표 카드: $targetKo (조커는 항상 목표로 인정됨). 내 손패: ${_describeCards(engine.opponentHand)}. '
        '몇 장을, 어떤 카드로 낼지(정직하게 낼지 블러핑할지 포함) 아래 후보 중에서 고르세요.';
  }

  String _challengeStateText(LiarsBarEngine engine) {
    final claim = engine.pendingClaim!;
    final targetKo = _rankKo(engine.targetRank);
    return '목표 카드: $targetKo. 상대가 ${claim.cards.length}장을 목표 카드라고 주장하며 냈다(뒷면이라 실제 카드는 모름). '
        '내 손패: ${_describeCards(engine.opponentHand)}. 이 주장을 믿을지 의심할지 고르세요.';
  }
}
