import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_config.dart';
import '../../l10n/rp_strings.dart';
import '../../services/profile_service.dart';
import '../../theme/rp_colors.dart';
import '../../widgets/rp_hero_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService();
  Map<String, dynamic>? _profile;
  int _cosmeticsCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final profile = await _service.loadProfile();
    final owned = await _service.loadOwnedCosmetics();
    if (mounted) {
      setState(() {
        _profile = profile;
        _cosmeticsCount = owned.length;
        _loading = false;
      });
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
                        RpStrings.profileTitle,
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
                const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: RpColors.purple)))
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: RpColors.purpleSoft,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: RpColors.purple, width: 3),
                          ),
                          child: const Icon(
                            Icons.sentiment_satisfied_alt_rounded,
                            size: 48,
                            color: RpColors.purple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _profile?['username'] as String? ??
                              supabase.auth.currentUser?.email
                                  ?.split('@')
                                  .first ??
                              RpStrings.player,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _StatRow(
                        label: RpStrings.profileLevel,
                        value: '${_profile?['level'] ?? 1}',
                        icon: Icons.stars_rounded,
                        color: RpColors.purple,
                      ),
                      const SizedBox(height: 12),
                      _StatRow(
                        label: RpStrings.profileXp,
                        value: '${_profile?['xp'] ?? 0}',
                        icon: Icons.trending_up_rounded,
                        color: RpColors.success,
                      ),
                      const SizedBox(height: 12),
                      _StatRow(
                        label: RpStrings.profileHirncoins,
                        value: '${_profile?['hirncoins'] ?? 0}',
                        icon: Icons.monetization_on_rounded,
                        color: RpColors.hirncoin,
                      ),
                      const SizedBox(height: 12),
                      _StatRow(
                        label: RpStrings.profileStreak,
                        value: '${_profile?['current_streak'] ?? 0} 🔥',
                        icon: Icons.local_fire_department_rounded,
                        color: RpColors.danger,
                      ),
                      const SizedBox(height: 12),
                      _StatRow(
                        label: 'Cosmetics',
                        value: '$_cosmeticsCount',
                        icon: Icons.auto_awesome_rounded,
                        color: RpColors.pink,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RpCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
