import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/rp_strings.dart';
import '../../services/game_service.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';

class NumberGuessScreen extends StatefulWidget {
  const NumberGuessScreen({super.key, required this.game});
  final GameService game;

  @override
  State<NumberGuessScreen> createState() => _NumberGuessScreenState();
}

class _NumberGuessScreenState extends State<NumberGuessScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.replaceAll(',', '.').trim();
    final guess = double.tryParse(text);
    if (guess == null) return;
    setState(() => _submitting = true);
    await widget.game.submitNumberGuess(guess);
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.game.state.currentPrompt;
    final unit = prompt?.payload['unit'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          Text(
            '🔢 ${RpStrings.guessTitle}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          RpCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  prompt?.prompt ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    unit,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RpColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: TextField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[\d.,\-]')),
              ],
              decoration: InputDecoration(
                hintText: RpStrings.guessPlaceholder,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: RpColors.textSecondary,
                    ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(height: 16),
          RpPrimaryButton(
            label: _submitting ? RpStrings.loading : RpStrings.guessSubmit,
            enabled: !_submitting && _controller.text.isNotEmpty,
            onPressed: _submit,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
