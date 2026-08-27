import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/rp_strings.dart';
import '../../routing/app_router.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_coming_soon.dart';
import '../../widgets/rp_hero_background.dart';
import '../../widgets/rp_room_code_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _codeController = TextEditingController();
  String? _joinError;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() => _joinError = null));
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onJoin() {
    final code = sanitizeRoomCode(_codeController.text);
    if (code.length != 6) {
      setState(() => _joinError = RpStrings.homeJoinCodeLength);
      return;
    }
    showComingSoon(context);
  }

  @override
  Widget build(BuildContext context) {
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
                  const _HomeHeader(),
                  const SizedBox(height: 16),
                  const _StreakCard(),
                  const SizedBox(height: 12),
                  const _CreateRoomCard(),
                  const SizedBox(height: 12),
                  RpCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          RpStrings.homeJoinKicker,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: RpColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          RpStrings.homeJoinTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),
                        RpRoomCodeField(
                          controller: _codeController,
                          errorText: _joinError,
                          onSubmitted: (_) => _onJoin(),
                        ),
                        const SizedBox(height: 12),
                        RpPrimaryButton(
                          label: RpStrings.homeJoinButton,
                          enabled: _codeController.text.length == 6,
                          onPressed: _onJoin,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    RpStrings.homePreviewHint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: RpColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(RpRoutes.landing),
                    child: Text(
                      RpStrings.loginBackHome,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: RpColors.textSecondary,
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
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

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
                RpStrings.player,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                RpStrings.partyPlayer,
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
                RpStrings.soon,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  RpStrings.homeStreakNull,
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
                RpStrings.soon,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
  const _CreateRoomCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showComingSoon(context),
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
                        RpStrings.homeCreateKicker,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: RpColors.purple,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        RpStrings.homeCreateTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        RpStrings.homeCreateBody,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RpColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: RpColors.purple,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
