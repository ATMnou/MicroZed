import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/ai/ai_chat_service.dart';
import '../../../data/db/database.dart';
import '../../../data/games/game_flavor_dialogue.dart';
import '../../../data/games/game_llm_choice.dart';
import '../../../data/games/liars_bar/liars_bar_engine.dart';
import '../../../data/repositories/ai_preset_repository.dart';
import '../../../data/repositories/game_result_repository.dart';
import '../../../data/theme/color_palette.dart';
import '../../../data/theme/palette_scope.dart';
import '../../../l10n/app_localizations.dart';
import '../game_widgets.dart';

class LiarsBarGameScreen extends StatefulWidget {
  const LiarsBarGameScreen({super.key, required this.opponent, this.useLlmMoves = false, this.speakEveryMove = false});

  final Character opponent;
  final bool useLlmMoves;
  final bool speakEveryMove;

  @override
  State<LiarsBarGameScreen> createState() => _LiarsBarGameScreenState();
}

class _LiarsBarGameScreenState extends State<LiarsBarGameScreen> {
  late LiarsBarEngine _engine;
  final _ai = LiarsBarAi();
  final _llmAi = LiarsBarLlmAi();
  late final GameResultRepository _resultRepo;
  late final GameFlavorDialogue _flavor;
  late final GameLlmChoice _llmChoice;
  late final AiPresetRepository _presetRepo;
  bool _aiThinking = false;
  String? _opponentLine;
  bool _resultRecorded = false;
  final Set<int> _selectedIndexes = {};
  List<LiarsBarRank>? _revealCards;
  bool? _revealWasTrue;

  @override
  void initState() {
    super.initState();
    _resultRepo = GameResultRepository(AppDatabase.instance);
    _presetRepo = AiPresetRepository(AppDatabase.instance);
    final aiChatService = AiChatService(db: AppDatabase.instance);
    _flavor = GameFlavorDialogue(aiChatService: aiChatService);
    _llmChoice = GameLlmChoice(aiChatService: aiChatService);
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _engine = LiarsBarEngine();
      _aiThinking = false;
      _opponentLine = null;
      _resultRecorded = false;
      _selectedIndexes.clear();
      _revealCards = null;
    });
    unawaited(_maybeAiTurn());
  }

  Future<void> _maybeSpeak(String situationKo) async {
    final preset = await _presetRepo.getDefault();
    final line = await _flavor.requestLine(preset: preset, character: widget.opponent, situationKo: situationKo);
    if (!mounted || line == null) return;
    setState(() => _opponentLine = line);
  }

  Future<void> _submitClaim() async {
    if (_engine.gameOver || _engine.turn != LiarsBarPlayer.user || _engine.pendingClaim != null) return;
    if (_selectedIndexes.isEmpty || _selectedIndexes.length > 3) return;
    final cards = _selectedIndexes.map((i) => _engine.userHand[i]).toList();
    setState(() {
      _engine.playClaim(LiarsBarPlayer.user, cards);
      _selectedIndexes.clear();
    });
    await _maybeAiTurn();
  }

  Future<void> _respondBelieve() async {
    if (_engine.gameOver || _engine.turn != LiarsBarPlayer.user || _engine.pendingClaim == null) return;
    setState(() => _engine.believe());
    if (_engine.gameOver) {
      _onMatchOver();
      return;
    }
    await _maybeAiTurn();
  }

  Future<void> _respondChallenge() async {
    if (_engine.gameOver || _engine.turn != LiarsBarPlayer.user || _engine.pendingClaim == null) return;
    final result = _engine.challenge(LiarsBarPlayer.user);
    await _showReveal(result.cards, result.claimWasTrue);
    if (!mounted) return;
    if (_engine.gameOver) {
      _onMatchOver();
      return;
    }
    await _maybeAiTurn();
  }

  Future<void> _showReveal(List<LiarsBarRank> cards, bool wasTrue) async {
    setState(() {
      _revealCards = cards;
      _revealWasTrue = wasTrue;
    });
    unawaited(_maybeSpeak(wasTrue ? '내가 낸 카드가 진짜였다는 게 밝혀졌다' : '블러핑이 들통났다'));
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() {
      _revealCards = null;
      _revealWasTrue = null;
    });
  }

  Future<List<LiarsBarRank>> _chooseClaim() async {
    if (!widget.useLlmMoves) return _ai.chooseClaim(_engine);
    final preset = await _presetRepo.getDefault();
    return _llmAi.chooseClaim(engine: _engine, llmChoice: _llmChoice, preset: preset, character: widget.opponent);
  }

  Future<bool> _decideChallenge() async {
    if (!widget.useLlmMoves) return _ai.decideChallenge(_engine);
    final preset = await _presetRepo.getDefault();
    return _llmAi.decideChallenge(engine: _engine, llmChoice: _llmChoice, preset: preset, character: widget.opponent);
  }

  Future<void> _maybeAiTurn() async {
    if (_engine.gameOver || _engine.turn != LiarsBarPlayer.opponent) return;
    setState(() => _aiThinking = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    if (_engine.pendingClaim == null) {
      final cards = await _chooseClaim();
      if (!mounted) return;
      setState(() {
        _engine.playClaim(LiarsBarPlayer.opponent, cards);
        _aiThinking = false;
      });
      if (widget.speakEveryMove) {
        unawaited(_maybeSpeak('방금 카드 ${cards.length}장을 냈다'));
      }
      return;
    }
    final willChallenge = await _decideChallenge();
    if (!mounted) return;
    if (willChallenge) {
      final result = _engine.challenge(LiarsBarPlayer.opponent);
      setState(() => _aiThinking = false);
      await _showReveal(result.cards, result.claimWasTrue);
    } else {
      setState(() {
        _engine.believe();
        _aiThinking = false;
      });
      if (widget.speakEveryMove) {
        unawaited(_maybeSpeak('상대의 주장을 믿기로 했다'));
      }
    }
    if (!mounted) return;
    if (_engine.gameOver) {
      _onMatchOver();
      return;
    }
    await _maybeAiTurn();
  }

  void _onMatchOver() {
    final outcome = _engine.matchWinner == LiarsBarPlayer.user ? GameEndOutcome.win : GameEndOutcome.loss;
    _recordResult(outcome);
    unawaited(_maybeSpeak(outcome == GameEndOutcome.win ? '내가 졌다' : '내가 이겼다'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGameEndSheet(context, outcome: outcome, onPlayAgain: _resetGame);
    });
  }

  Future<void> _recordResult(GameEndOutcome outcome) async {
    if (_resultRecorded) return;
    _resultRecorded = true;
    await _resultRepo.record(
      gameType: GameType.liarsBar,
      opponentCharacterId: widget.opponent.id,
      outcome: switch (outcome) {
        GameEndOutcome.win => GameOutcome.win,
        GameEndOutcome.loss => GameOutcome.loss,
        GameEndOutcome.draw => GameOutcome.draw,
      },
    );
  }

  Future<void> _confirmResign() async {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: p.surface,
        content: Text(l10n.gameResignConfirmMessage, style: TextStyle(color: p.textPrimary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.gameResignButton, style: TextStyle(color: p.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() {
        _engine.gameOver = true;
        _engine.matchWinner = LiarsBarPlayer.opponent;
      });
      _onMatchOver();
    }
  }

  String _rankLabel(LiarsBarRank rank) => switch (rank) {
        LiarsBarRank.ace => 'A',
        LiarsBarRank.king => 'K',
        LiarsBarRank.queen => 'Q',
        LiarsBarRank.joker => '🃏',
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = PaletteScope.of(context);
    final waitingForUserResponse =
        _engine.turn == LiarsBarPlayer.user && _engine.pendingClaim != null && !_engine.gameOver;
    final userMakingClaim = _engine.turn == LiarsBarPlayer.user && _engine.pendingClaim == null && !_engine.gameOver;

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: p.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l10n.gamesHomeLiarsBarTitle, style: TextStyle(color: p.textPrimary, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.flag_outlined, color: p.textSecondary, size: 20),
            tooltip: l10n.gameResignButton,
            onPressed: _confirmResign,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
        children: [
          OpponentBanner(
            opponent: widget.opponent,
            line: _opponentLine,
            turnLabel: _engine.turn == LiarsBarPlayer.user
                ? l10n.gameYourTurnLabel
                : (_aiThinking ? '${l10n.gameOpponentTurnLabel}...' : l10n.gameOpponentTurnLabel),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Text('${l10n.liarsBarLifeLabel}(${widget.opponent.name}) ', style: TextStyle(color: p.textFaint, fontSize: 11)),
                  LifeHearts(current: _engine.opponentLife, max: _engine.maxLife),
                ]),
                Row(children: [
                  LifeHearts(current: _engine.userLife, max: _engine.maxLife),
                  Text(' ${l10n.liarsBarLifeLabel}(${l10n.gameYouLabel})', style: TextStyle(color: p.textFaint, fontSize: 11)),
                ]),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _revealCards != null
                    ? _buildReveal(l10n, p)
                    : Column(
                        key: const ValueKey('table'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.liarsBarTargetCardLabel, style: TextStyle(color: p.textSecondary, fontSize: 13)),
                          const SizedBox(height: 8),
                          Container(
                            width: 64,
                            height: 88,
                            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(10)),
                            alignment: Alignment.center,
                            child: Text(_rankLabel(_engine.targetRank),
                                style: TextStyle(color: p.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                          ),
                          if (_engine.pendingClaim != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              l10n.liarsBarOpponentClaimLabel(_engine.pendingClaim!.cards.length),
                              style: TextStyle(color: p.textSecondary, fontSize: 13),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
          if (waitingForUserResponse) _buildResponseButtons(l10n, p),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(l10n.liarsBarYourHandLabel, style: TextStyle(color: p.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          if (userMakingClaim)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(l10n.liarsBarSelectHint, style: TextStyle(color: p.textFaint, fontSize: 11)),
            ),
          SizedBox(
            height: 100,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              scrollDirection: Axis.horizontal,
              itemCount: _engine.userHand.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = _selectedIndexes.contains(index);
                return GestureDetector(
                  onTap: !userMakingClaim
                      ? null
                      : () => setState(() {
                            if (selected) {
                              _selectedIndexes.remove(index);
                            } else if (_selectedIndexes.length < 3) {
                              _selectedIndexes.add(index);
                            }
                          }),
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 150),
                    offset: selected ? const Offset(0, -0.12) : Offset.zero,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 60,
                      height: 84,
                      decoration: BoxDecoration(
                        color: selected ? p.primary : p.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selected ? p.primary : p.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _rankLabel(_engine.userHand[index]),
                        style: TextStyle(
                          color: selected ? p.onPrimary : p.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (userMakingClaim)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIndexes.isEmpty ? null : _submitClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.liarsBarPlayButton, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            )
          else
            const SizedBox(height: 16),
        ],
        ),
      ),
    );
  }

  Widget _buildReveal(AppLocalizations l10n, ColorPalette p) {
    return Column(
      key: const ValueKey('reveal'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in _revealCards!) ...[
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) => Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY((1 - value) * 3.14159 / 2),
                  child: child,
                ),
                child: Container(
                  width: 56,
                  height: 78,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text(_rankLabel(c), style: TextStyle(color: p.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _revealWasTrue == true ? l10n.liarsBarRevealTrueMessage : l10n.liarsBarRevealBluffMessage,
          style: TextStyle(
            color: _revealWasTrue == true ? p.primary : p.danger,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildResponseButtons(AppLocalizations l10n, ColorPalette p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _respondBelieve,
              style: OutlinedButton.styleFrom(
                foregroundColor: p.textPrimary,
                side: BorderSide(color: p.border),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(l10n.liarsBarBelieveButton),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _respondChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: p.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(l10n.liarsBarChallengeButton),
            ),
          ),
        ],
      ),
    );
  }
}
