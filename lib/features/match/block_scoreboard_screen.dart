import 'package:flutter/material.dart';

import '../../l10n/rp_strings.dart';
import '../../services/game_service.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_buttons.dart';

class BlockScoreboardScreen extends StatelessWidget {
  const BlockScoreboardScreen({super.key, required this.game});
  final GameService game;

  @override
  Widget build(BuildContext context) {
    final state = game.state;
    final room = state.room;
    final isHost = state.isHost;
    final isLastBlock =
        room != null && room.currentBlockIndex >= room.totalBlocks - 1;

    final ranked = List.of(state.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            RpStrings.matchScoreboard,
            style: Theme.of(context)
                .textTheme
                .titleLarge
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
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? RpColors.purpleSoft.withValues(alpha: 0.3)
                        : RpColors.bgElevated,
                    borderRadius: BorderRadius.circular(RpRadii.md),
                    border: isMe
                        ? Border.all(color: RpColors.purple, width: 2)
                        : null,
                  ),
                  child: Row(
                    children: [
                      _RankBadge(rank: index + 1),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          p.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        '${p.score} Pkt.',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
          if (isHost)
            RpPrimaryButton(
              label: isLastBlock
                  ? RpStrings.matchFinish
                  : RpStrings.matchNext,
              onPressed: () => game.advanceFromBlockScore(),
            ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    final color = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => RpColors.textSecondary,
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
