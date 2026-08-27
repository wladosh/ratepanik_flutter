import 'package:flutter/material.dart';

import '../../l10n/rp_strings.dart';
import '../../services/game_service.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_hero_background.dart';

class PickCorrectScreen extends StatelessWidget {
  const PickCorrectScreen({super.key, required this.game});
  final GameService game;

  @override
  Widget build(BuildContext context) {
    final state = game.state;
    final prompt = state.currentPrompt;
    final cards =
        (prompt?.payload['cards'] as List<dynamic>?)?.cast<String>() ?? [];
    final turns = state.blockTurns;
    final tappedIndices = turns.map((t) => t.cardIndex).toSet();
    final correctIndices = (prompt?.payload['correct_indices']
                as List<dynamic>?)
            ?.map((e) => e as int)
            .toSet() ??
        {};

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '🃏 ${RpStrings.pickCorrectTitle}',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (prompt != null)
            Text(
              prompt.prompt,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: RpColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          const SizedBox(height: 4),
          Text(
            '${state.correctTurnsCount}/4 gefunden',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: RpColors.purple,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: cards.asMap().entries.map((e) {
                final index = e.key;
                final text = e.value;
                final tapped = tappedIndices.contains(index);
                final isCorrect =
                    tapped && correctIndices.contains(index);
                final isWrong =
                    tapped && !correctIndices.contains(index);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: tapped
                        ? null
                        : () => game.tapCard(index),
                    borderRadius: BorderRadius.circular(RpRadii.lg),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? RpColors.success.withValues(alpha: 0.15)
                            : isWrong
                                ? RpColors.danger.withValues(alpha: 0.15)
                                : RpColors.bgElevated,
                        borderRadius: BorderRadius.circular(RpRadii.lg),
                        border: Border.all(
                          color: isCorrect
                              ? RpColors.success
                              : isWrong
                                  ? RpColors.danger
                                  : RpColors.border,
                          width: 2,
                        ),
                        boxShadow: tapped
                            ? null
                            : const [
                                BoxShadow(
                                  color: RpColors.cardShadow,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isCorrect)
                                const Icon(Icons.check_circle_rounded,
                                    color: RpColors.success, size: 20),
                              if (isWrong)
                                const Icon(Icons.cancel_rounded,
                                    color: RpColors.danger, size: 20),
                              if (tapped) const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: tapped
                                            ? RpColors.textSecondary
                                            : RpColors.text,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
