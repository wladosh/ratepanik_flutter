import 'package:flutter/material.dart';

import '../../l10n/rp_strings.dart';
import '../../services/game_service.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';

class FindLieScreen extends StatelessWidget {
  const FindLieScreen({super.key, required this.game});
  final GameService game;

  @override
  Widget build(BuildContext context) {
    final prompt = game.state.currentPrompt;
    final statements =
        (prompt?.payload['statements'] as List<dynamic>?)?.cast<String>() ??
            [];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          Text(
            '🤥 ${RpStrings.findLieTitle}',
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
                  ),
            ),
          const SizedBox(height: 24),
          ...statements.asMap().entries.map((e) {
            final index = e.key;
            final text = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => game.submitFindLie(index),
                  borderRadius: BorderRadius.circular(RpRadii.lg),
                  child: Ink(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: RpColors.bgElevated,
                      borderRadius: BorderRadius.circular(RpRadii.lg),
                      boxShadow: const [
                        BoxShadow(
                          color: RpColors.cardShadow,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        text,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
