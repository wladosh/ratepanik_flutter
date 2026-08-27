import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_config.dart';
import '../../l10n/rp_strings.dart';
import '../../theme/rp_colors.dart';
import '../../widgets/rp_hero_background.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Map<String, dynamic>> _achievements = [];
  Set<String> _unlockedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = supabase.auth.currentUser?.id;
    try {
      final all = await supabase
          .from('achievements')
          .select()
          .eq('active', true)
          .order('title');
      if (userId != null) {
        final unlocked = await supabase
            .from('user_achievements')
            .select('achievement_id')
            .eq('user_id', userId);
        _unlockedIds = (unlocked as List<dynamic>)
            .map((e) => e['achievement_id'] as String)
            .toSet();
      }
      setState(() {
        _achievements =
            (all as List<dynamic>).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RpHeroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        RpStrings.achievementsTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_loading)
                const CircularProgressIndicator(color: RpColors.purple)
              else if (_achievements.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      RpStrings.achievementsEmpty,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: RpColors.textSecondary),
                    ),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: _achievements.length,
                    itemBuilder: (context, index) {
                      final a = _achievements[index];
                      final unlocked =
                          _unlockedIds.contains(a['id'] as String);
                      final iconKey = a['icon_key'] as String? ?? '';
                      return Opacity(
                        opacity: unlocked ? 1.0 : 0.4,
                        child: RpCard(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _badgeIcon(iconKey),
                              const SizedBox(height: 6),
                              Text(
                                a['title'] as String? ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badgeIcon(String iconKey) {
    final assetMap = {
      'first_game': 'assets/rp/rp_badge_first_game_128.png',
      'first_room': 'assets/rp/rp_badge_first_room_128.png',
      'first_win': 'assets/rp/rp_badge_first_win_128.png',
      'exact_hit': 'assets/rp/rp_badge_exact_hit_128.png',
      'perfect_pick': 'assets/rp/rp_badge_perfect_pick_128.png',
      'clutch': 'assets/rp/rp_badge_clutch_128.png',
      'panic_pick': 'assets/rp/rp_badge_panic_pick_128.png',
      'party_host': 'assets/rp/rp_badge_party_host_128.png',
      'streak_3': 'assets/rp/rp_badge_streak_3_128.png',
    };
    final path = assetMap[iconKey];
    if (path != null) {
      return Image.asset(
        path,
        width: 40,
        height: 40,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.emoji_events_rounded, color: RpColors.yellow),
      );
    }
    return const Icon(Icons.emoji_events_rounded,
        color: RpColors.yellow, size: 36);
  }
}
