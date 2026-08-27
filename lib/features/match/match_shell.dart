import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../l10n/rp_strings.dart';
import '../../routing/app_router.dart';
import '../../services/game_service.dart';
import '../../theme/rp_colors.dart';
import '../../widgets/rp_hero_background.dart';
import 'theme_pick_screen.dart';
import 'number_guess_screen.dart';
import 'find_lie_screen.dart';
import 'order_it_screen.dart';
import 'pick_correct_screen.dart';
import 'block_scoreboard_screen.dart';
import 'final_screen.dart';
import 'waiting_screen.dart';
import 'reveal_screen.dart';

class MatchShell extends StatelessWidget {
  const MatchShell({super.key});

  @override
  Widget build(BuildContext context) {
    final game = RatepanikApp.gameOf(context);

    return ListenableBuilder(
      listenable: game,
      builder: (context, _) {
        final state = game.state;

        // If we returned to home, navigate away
        if (state.phase == GamePhase.home) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(RpRoutes.home);
          });
          return const SizedBox.shrink();
        }
        if (state.phase == GamePhase.lobby) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(RpRoutes.lobby);
          });
          return const SizedBox.shrink();
        }

        // Stamp question clock when host sees prompt
        if (state.isHost &&
            state.currentBlock != null &&
            state.currentPrompt != null &&
            state.currentBlock!.startedAt == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            game.stampQuestionClock();
          });
        }

        Widget body;
        switch (state.phase) {
          case GamePhase.themePick:
            body = ThemePickScreen(game: game);
          case GamePhase.numberGuess:
            body = NumberGuessScreen(game: game);
          case GamePhase.numberGuessWaiting:
            body = const WaitingScreen();
          case GamePhase.numberGuessReveal:
            body = RevealScreen(game: game, mode: 'number_guess');
          case GamePhase.findLie:
            body = FindLieScreen(game: game);
          case GamePhase.findLieWaiting:
            body = const WaitingScreen();
          case GamePhase.findLieReveal:
            body = RevealScreen(game: game, mode: 'find_lie');
          case GamePhase.orderIt:
            body = OrderItScreen(game: game);
          case GamePhase.orderItWaiting:
            body = const WaitingScreen();
          case GamePhase.orderItReveal:
            body = RevealScreen(game: game, mode: 'order_it');
          case GamePhase.pickCorrect:
            body = PickCorrectScreen(game: game);
          case GamePhase.blockScoreboard:
            body = BlockScoreboardScreen(game: game);
          case GamePhase.final_:
            body = FinalScreen(game: game);
          default:
            body = _LoadingBody(state: state);
        }

        return RpHeroBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  _MatchHeader(state: state),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        state.error!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: RpColors.danger),
                      ),
                    ),
                  Expanded(child: body),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MatchHeader extends StatelessWidget {
  const _MatchHeader({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final block = state.currentBlock;
    final room = state.room;
    if (room == null) return const SizedBox.shrink();

    final blockLabel = block != null
        ? '${RpStrings.matchBlock} ${block.blockIndex + 1}/${room.totalBlocks}'
        : '';
    final roundLabel = block != null
        ? '${RpStrings.matchRound} ${block.currentRound + 1}/${block.roundsTotal}'
        : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              blockLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: RpColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          if (block != null && !block.isComplete)
            _TimerPill(state: state),
          Expanded(
            child: Text(
              roundLabel,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: RpColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerPill extends StatefulWidget {
  const _TimerPill({required this.state});
  final GameState state;

  @override
  State<_TimerPill> createState() => _TimerPillState();
}

class _TimerPillState extends State<_TimerPill> {
  @override
  void initState() {
    super.initState();
    _startTick();
  }

  void _startTick() {
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {});
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final block = widget.state.currentBlock;
    if (block == null || block.startedAt == null) return const SizedBox.shrink();
    final timerMs = widget.state.questionTimerMs ?? 30000;
    final endMs =
        DateTime.parse(block.startedAt!).millisecondsSinceEpoch + timerMs;
    final remaining =
        ((endMs - DateTime.now().millisecondsSinceEpoch) / 1000).ceil();
    final secs = remaining.clamp(0, 999);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: secs <= 5 ? RpColors.danger : RpColors.purple,
        borderRadius: BorderRadius.circular(RpRadii.pill),
      ),
      child: Text(
        '${secs}s',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: RpColors.purple),
          const SizedBox(height: 16),
          Text(
            RpStrings.loading,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: RpColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
