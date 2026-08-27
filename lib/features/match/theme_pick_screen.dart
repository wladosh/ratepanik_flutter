import 'package:flutter/material.dart';

import '../../l10n/rp_strings.dart';
import '../../models/game_scoring.dart';
import '../../services/game_service.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_hero_background.dart';

const _themeIcons = <String, String>{
  'gaming': 'assets/rp/rp_theme_gaming_256.png',
  'geschichte': 'assets/rp/rp_theme_geschichte_256.png',
  'wissenschaft-natur': 'assets/rp/rp_theme_wissenschaft_natur_256.png',
  'sport': 'assets/rp/rp_theme_sport_256.png',
  'musik': 'assets/rp/rp_theme_musik_256.png',
  'film-serie': 'assets/rp/rp_theme_film_serie_256.png',
  'reise-orte': 'assets/rp/rp_theme_reise_orte_256.png',
};

class ThemePickScreen extends StatelessWidget {
  const ThemePickScreen({super.key, required this.game});
  final GameService game;

  @override
  Widget build(BuildContext context) {
    final state = game.state;
    final themes = state.themeOptions;
    final isMyPick = state.isThemePicker;
    final block = state.currentBlock;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            RpStrings.themePickTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          if (block != null)
            Text(
              '${modeEmoji(block.mode)} ${modeLabelDe(block.mode)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: RpColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          const SizedBox(height: 8),
          if (!isMyPick)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${_pickerName(state)} ${RpStrings.themePickWaiting}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: RpColors.textSecondary,
                    ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: themes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final theme = themes[index];
                final assetPath = _themeIcons[theme.slug];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isMyPick
                        ? () => game.selectTheme(theme.id)
                        : null,
                    borderRadius: BorderRadius.circular(RpRadii.lg),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: RpColors.bgElevated,
                        borderRadius: BorderRadius.circular(RpRadii.lg),
                        boxShadow: const [
                          BoxShadow(
                            color: RpColors.cardShadow,
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            if (assetPath != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  assetPath,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(width: 56, height: 56),
                                ),
                              )
                            else
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: RpColors.bgMuted,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.quiz_rounded,
                                    color: RpColors.purple),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                theme.nameDe,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (isMyPick)
                              const Icon(Icons.chevron_right_rounded,
                                  color: RpColors.purple),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _pickerName(GameState state) {
    final pickerId = state.themePickerPlayerId;
    if (pickerId == null) return '';
    final player =
        state.players.where((p) => p.id == pickerId).firstOrNull;
    return player?.displayName ?? '';
  }
}
