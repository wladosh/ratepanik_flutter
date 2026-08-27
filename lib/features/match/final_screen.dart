import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/rp_strings.dart';
import '../../routing/app_router.dart';
import '../../services/game_service.dart';
import '../../services/profile_service.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';

class FinalScreen extends StatefulWidget {
  const FinalScreen({super.key, required this.game});
  final GameService game;

  @override
  State<FinalScreen> createState() => _FinalScreenState();
}

class _FinalScreenState extends State<FinalScreen> {
  final _profileService = ProfileService();
  MatchReward? _reward;
  int? _streak;

  @override
  void initState() {
    super.initState();
    _claimRewards();
  }

  Future<void> _claimRewards() async {
    final roomId = widget.game.state.room?.id;
    if (roomId == null) return;

    final reward = await _profileService.grantMatchRewards(roomId);
    final streak = await _profileService.recordDailyPlay();

    if (mounted) {
      setState(() {
        _reward = reward;
        _streak = streak;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.game.state;
    final ranked = List.of(state.players)
      ..sort((a, b) => b.score.compareTo(a.score));
    final isHost = state.isHost;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text('🏆', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            RpStrings.matchFinal,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),

          // Rewards banner
          if (_reward != null) _RewardsBanner(reward: _reward!, streak: _streak),
          if (_reward != null) const SizedBox(height: 12),

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
                await widget.game.resetGame();
              },
            ),
          const SizedBox(height: 12),
          RpOutlineButton(
            label: RpStrings.matchBackHome,
            onPressed: () {
              widget.game.goHome();
              context.go(RpRoutes.home);
            },
          ),
        ],
      ),
    );
  }
}

class _RewardsBanner extends StatelessWidget {
  const _RewardsBanner({required this.reward, this.streak});
  final MatchReward reward;
  final int? streak;

  @override
  Widget build(BuildContext context) {
    return RpCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            RpStrings.matchRewardsTitle,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RewardChip(
                icon: Icons.trending_up_rounded,
                color: RpColors.success,
                label: '+${reward.xpAwarded} XP',
              ),
              _RewardChip(
                icon: Icons.monetization_on_rounded,
                color: RpColors.hirncoin,
                label: '+${reward.hirncoinsAwarded}',
              ),
              if (streak != null && streak! > 0)
                _RewardChip(
                  icon: Icons.local_fire_department_rounded,
                  color: RpColors.danger,
                  label: '$streak🔥',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Platz ${reward.placement}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: RpColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RpRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
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
      decoration: const BoxDecoration(
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
