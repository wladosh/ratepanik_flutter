import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/rp_strings.dart';
import '../../routing/app_router.dart';
import '../../services/game_service.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';

class FinalScreen extends StatelessWidget {
  const FinalScreen({super.key, required this.game});
  final GameService game;

  @override
  Widget build(BuildContext context) {
    final state = game.state;
    final ranked = List.of(state.players)
      ..sort((a, b) => b.score.compareTo(a.score));
    final isHost = state.isHost;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text('🏆', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            RpStrings.matchFinal,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: ranked.length,
              itemBuilder: (context, index) {
                final p = ranked[index];
                final isMe = p.id == state.myPlayerId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isMe
                        ? RpColors.purpleSoft.withValues(alpha: 0.3)
                        : RpColors.bgElevated,
                    borderRadius: BorderRadius.circular(RpRadii.lg),
                    border: isMe
                        ? Border.all(color: RpColors.purple, width: 2)
                        : null,
                    boxShadow: index == 0
                        ? const [
                            BoxShadow(
                              color: RpColors.cardShadow,
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      _PlacementIcon(rank: index + 1),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          p.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${p.score} Pkt.',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: index == 0
                                      ? RpColors.hirncoin
                                      : RpColors.text,
                                ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (isHost)
            RpPrimaryButton(
              label: RpStrings.matchPlayAgain,
              onPressed: () async {
                await game.resetGame();
              },
            ),
          const SizedBox(height: 12),
          RpOutlineButton(
            label: RpStrings.matchBackHome,
            onPressed: () {
              game.goHome();
              context.go(RpRoutes.home);
            },
          ),
        ],
      ),
    );
  }
}

class _PlacementIcon extends StatelessWidget {
  const _PlacementIcon({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    if (rank <= 3) {
      final emoji = ['🥇', '🥈', '🥉'][rank - 1];
      return Text(emoji, style: const TextStyle(fontSize: 28));
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: RpColors.bgMuted,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: RpColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
