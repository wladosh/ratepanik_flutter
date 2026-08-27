import 'package:flutter/material.dart';

import '../../l10n/rp_strings.dart';
import '../../models/db_models.dart';
import '../../models/game_scoring.dart';
import '../../services/game_service.dart';
import '../../theme/rp_colors.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';

class RevealScreen extends StatelessWidget {
  const RevealScreen({super.key, required this.game, required this.mode});
  final GameService game;
  final String mode;

  @override
  Widget build(BuildContext context) {
    final state = game.state;
    final prompt = state.currentPrompt;
    final answers = state.roundAnswers;
    final isHost = state.isHost;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '${modeEmoji(mode)} ${_revealTitle()}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (prompt != null) _buildPromptCard(context, prompt),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: answers.length,
              itemBuilder: (context, index) {
                final a = answers[index];
                final player = state.players
                    .where((p) => p.id == a.playerId)
                    .firstOrNull;
                final name = player?.displayName ?? '?';
                String answerText;
                if (mode == 'number_guess') {
                  answerText = '${a.numericAnswer ?? '—'}';
                } else if (mode == 'find_lie') {
                  answerText = 'Wahl: ${(a.numericAnswer?.toInt() ?? 0) + 1}';
                } else {
                  answerText = 'Eingereicht';
                }
                return ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: RpColors.purple,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(name),
                  subtitle: Text(answerText),
                  trailing: Text(
                    '+${a.pointsAwarded}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: a.pointsAwarded > 0
                              ? RpColors.success
                              : RpColors.textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                );
              },
            ),
          ),
          if (isHost)
            RpPrimaryButton(
              label: RpStrings.matchNext,
              onPressed: () => game.advanceFromReveal(),
            ),
        ],
      ),
    );
  }

  String _revealTitle() {
    switch (mode) {
      case 'number_guess':
        return RpStrings.guessRevealTitle;
      case 'find_lie':
        return RpStrings.findLieRevealTitle;
      case 'order_it':
        return RpStrings.orderItRevealTitle;
      default:
        return RpStrings.guessRevealTitle;
    }
  }

  Widget _buildPromptCard(BuildContext context, Prompt prompt) {
    return RpCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            prompt.prompt,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (mode == 'number_guess') ...[
            const SizedBox(height: 8),
            Text(
              '${RpStrings.guessCorrectAnswer}: ${prompt.payload['answer']}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: RpColors.success,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
          if (mode == 'find_lie') ..._buildFindLieReveal(context, prompt),
          if (mode == 'order_it') ..._buildOrderItReveal(context, prompt),
        ],
      ),
    );
  }

  List<Widget> _buildFindLieReveal(BuildContext context, Prompt prompt) {
    final statements =
        (prompt.payload['statements'] as List<dynamic>?)?.cast<String>() ??
            [];
    final lieIndex = prompt.payload['lie_index'] as int? ?? 0;
    if (lieIndex >= statements.length) return [];
    return [
      const SizedBox(height: 8),
      Text(
        'Die Lüge: ${statements[lieIndex]}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: RpColors.danger,
              fontWeight: FontWeight.w700,
            ),
      ),
    ];
  }

  List<Widget> _buildOrderItReveal(BuildContext context, Prompt prompt) {
    final items =
        (prompt.payload['items'] as List<dynamic>?)?.cast<String>() ?? [];
    final correct =
        (prompt.payload['correct_order'] as List<dynamic>?)?.cast<int>() ??
            [];
    return [
      const SizedBox(height: 8),
      ...correct.asMap().entries.map((e) {
        final idx = e.value;
        final text = idx < items.length ? items[idx] : '?';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: RpColors.success,
                child: Text(
                  '${e.key + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(text)),
            ],
          ),
        );
      }),
    ];
  }
}
