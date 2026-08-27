import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/supabase_config.dart';
import '../../l10n/rp_strings.dart';
import '../../routing/app_router.dart';
import '../../services/profile_service.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';
import '../../widgets/rp_room_code_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _codeController = TextEditingController();
  final _profileService = ProfileService();
  String? _joinError;
  bool _creating = false;
  bool _joining = false;

  int _hirncoins = 0;
  int _streak = 0;
  int _level = 1;
  String? _username;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() => _joinError = null));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (supabase.auth.currentUser == null) {
        context.go(RpRoutes.landing);
        return;
      }
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final profile = await _profileService.loadProfile();
    if (mounted && profile != null) {
      setState(() {
        _hirncoins = profile['hirncoins'] as int? ?? 0;
        _streak = profile['current_streak'] as int? ?? 0;
        _level = profile['level'] as int? ?? 1;
        _username = profile['username'] as String?;
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final user = supabase.auth.currentUser!;
      final displayName = _username ??
          user.userMetadata?['display_name'] as String? ??
          user.userMetadata?['full_name'] as String? ??
          user.email?.split('@').first ??
          'Host';
      final game = RatepanikApp.gameOf(context);
      final code = await game.createRoom(displayName, user.id);
      if (code != null && mounted) {
        context.go(RpRoutes.lobby);
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _onJoin() async {
    final code = sanitizeRoomCode(_codeController.text);
    if (code.length != 6) {
      setState(() => _joinError = RpStrings.homeJoinCodeLength);
      return;
    }
    setState(() => _joining = true);
    try {
      final user = supabase.auth.currentUser!;
      final displayName = _username ??
          user.userMetadata?['display_name'] as String? ??
          user.userMetadata?['full_name'] as String? ??
          user.email?.split('@').first ??
          'Spieler';
      final game = RatepanikApp.gameOf(context);
      final err = await game.joinRoom(code, displayName);
      if (err == null && mounted) {
        context.go(RpRoutes.lobby);
      } else if (err != null) {
        setState(() => _joinError = err);
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) context.go(RpRoutes.landing);
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final isGuest = user?.isAnonymous ?? true;
    final displayName = _username ??
        user?.userMetadata?['display_name'] as String? ??
        user?.userMetadata?['full_name'] as String? ??
        user?.email?.split('@').first ??
        RpStrings.player;

    return RpHeroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _HomeHeader(
                    displayName: displayName,
                    isGuest: isGuest,
                    hirncoins: _hirncoins,
                    onLogout: _logout,
                  ),
                  const SizedBox(height: 16),

                  if (!isGuest) ...[
                    _CreateRoomCard(
                      creating: _creating,
                      onTap: _createRoom,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Join card
                  RpCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    RpStrings.homeJoinKicker,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: RpColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    RpStrings.homeJoinTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                for (var i = 0; i < 3; i++)
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: [
                                      RpColors.purple,
                                      RpColors.mint,
                                      RpColors.peach,
                                    ][i],
                                    child: Text(
                                      ['😊', '😎', '🤩'][i],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        RpRoomCodeField(
                          controller: _codeController,
                          errorText: _joinError,
                          onSubmitted: (_) => _onJoin(),
                        ),
                        const SizedBox(height: 12),
                        RpPrimaryButton(
                          label: _joining
                              ? RpStrings.loading
                              : RpStrings.homeJoinButton,
                          enabled: _codeController.text.length == 6 && !_joining,
                          onPressed: _onJoin,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2×2: Freunde / Statistik / Erfolge / Shop
                  Row(
                    children: [
                      Expanded(
                        child: _HomeNavCard(
                          title: RpStrings.homeFriends,
                          subtitle: RpStrings.homeFriendsBody,
                          color: const Color(0xFFE5F3FF),
                          assetPath: 'assets/rp/rp_icon_friends_slimes_128.png',
                          fallbackIcon: Icons.people_alt_rounded,
                          iconColor: RpColors.sky,
                          onTap: () => context.push(RpRoutes.friends),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HomeNavCard(
                          title: RpStrings.homeStats,
                          subtitle: 'Level $_level',
                          color: const Color(0xFFF0EAFF),
                          assetPath: 'assets/rp/rp_icon_stats_clipboard_128.png',
                          fallbackIcon: Icons.bar_chart_rounded,
                          iconColor: RpColors.purple,
                          onTap: () => context.push(RpRoutes.profile),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HomeNavCard(
                          title: RpStrings.homeErfolge,
                          subtitle: '',
                          color: const Color(0xFFFFF5E0),
                          assetPath: 'assets/rp/rp_trophy_gold_512.png',
                          fallbackIcon: Icons.emoji_events_rounded,
                          iconColor: RpColors.yellow,
                          onTap: () => context.push(RpRoutes.achievements),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HomeNavCard(
                          title: RpStrings.homeShop,
                          subtitle: RpStrings.homeShopBody,
                          color: const Color(0xFFE0FFF5),
                          assetPath: 'assets/rp/schleimi/lootbox_closed_128.png',
                          fallbackIcon: Icons.shopping_bag_rounded,
                          iconColor: RpColors.mint,
                          onTap: () => context.push(RpRoutes.shop),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _StreakCard(streak: _streak),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.displayName,
    required this.isGuest,
    required this.hirncoins,
    required this.onLogout,
  });

  final String displayName;
  final bool isGuest;
  final int hirncoins;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: RpColors.bgElevated,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: RpColors.cardShadow,
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.sentiment_satisfied_alt_rounded,
                color: RpColors.purple,
              ),
            ),
            Positioned(
              left: -4,
              bottom: -4,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: RpColors.purple,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '—',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                isGuest ? 'Gast' : RpStrings.partyPlayer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: RpColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: RpColors.hirncoinSoft,
            borderRadius: BorderRadius.circular(RpRadii.pill),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                size: 18,
                color: RpColors.hirncoin,
              ),
              const SizedBox(width: 6),
              Text(
                '$hirncoins',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.logout_rounded, size: 20),
          color: RpColors.textSecondary,
          onPressed: onLogout,
          tooltip: RpStrings.homeLogout,
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return RpCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  RpStrings.homeStreakTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  streak > 0
                      ? RpStrings.homeStreakBody(streak)
                      : RpStrings.homeStreakNull,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: RpColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: RpColors.streakWash,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: Text(
                '$streak',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: RpColors.danger,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateRoomCard extends StatelessWidget {
  const _CreateRoomCard({required this.creating, required this.onTap});

  final bool creating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: creating ? null : onTap,
        borderRadius: BorderRadius.circular(RpRadii.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: RpColors.bgElevated,
            borderRadius: BorderRadius.circular(RpRadii.lg),
            boxShadow: const [
              BoxShadow(
                color: RpColors.cardShadow,
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        RpStrings.homeCreateKicker.toUpperCase(),
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: RpColors.purple,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        RpStrings.homeCreateTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        RpStrings.homeCreateBody,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: RpColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/rp/rp_home_create_room_256.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.chevron_right_rounded,
                      color: RpColors.purple,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeNavCard extends StatelessWidget {
  const _HomeNavCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.assetPath,
    required this.fallbackIcon,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final String assetPath;
  final IconData fallbackIcon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RpRadii.lg),
        child: Ink(
          height: 130,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(RpRadii.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: RpColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RpColors.textSecondary,
                        ),
                  ),
                const Spacer(),
                Image.asset(
                  assetPath,
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(fallbackIcon, size: 36, color: iconColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
