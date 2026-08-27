import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/supabase_config.dart';
import '../../l10n/rp_strings.dart';
import '../../routing/app_router.dart';
import '../../services/game_service.dart';
import '../../theme/rp_colors.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';
import '../../widgets/rp_room_code_field.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _codeController = TextEditingController();
  String? _codeError;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() => _codeError = null));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = supabase.auth.currentUser;
      if (user != null && !user.isAnonymous) {
        context.go(RpRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _onJoinAsGuest() async {
    final code = sanitizeRoomCode(_codeController.text);
    if (code.length != 6) {
      setState(() => _codeError = RpStrings.landingCodeError);
      return;
    }
    final game = RatepanikApp.gameOf(context);
    setState(() => _joining = true);
    try {
      var user = supabase.auth.currentUser;
      if (user == null) {
        await supabase.auth.signInAnonymously();
        user = supabase.auth.currentUser;
      }
      if (user == null) return;

      final name = generateGuestName();
      final err = await game.joinRoom(code, name);
      if (err == null && mounted) {
        context.go(RpRoutes.lobby);
      } else if (err != null) {
        setState(() => _codeError = err);
      }
    } catch (e) {
      setState(() => _codeError = 'Beitritt fehlgeschlagen.');
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canJoin = _codeController.text.length == 6;

    return RpHeroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                children: [
                  const _LandingHero(),
                  const SizedBox(height: 8),
                  RpCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFE0D6),
                                    Color(0xFFFFD0D0),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.groups_rounded,
                                color: RpColors.peach,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    RpStrings.landingGuestTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    RpStrings.landingGuestSubtitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: RpColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        RpRoomCodeField(
                          controller: _codeController,
                          errorText: _codeError,
                          onSubmitted: (_) => _onJoinAsGuest(),
                        ),
                        const SizedBox(height: 16),
                        RpPrimaryButton(
                          label: _joining
                              ? RpStrings.loading
                              : RpStrings.landingJoin,
                          enabled: canJoin && !_joining,
                          onPressed: _onJoinAsGuest,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(
                          child: Divider(color: RpColors.border)),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          RpStrings.or,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: RpColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const Expanded(
                          child: Divider(color: RpColors.border)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: RpSoftButton(
                          label: RpStrings.landingRegister,
                          icon: Icons.person_add_alt_1_rounded,
                          onPressed: () => context.push(RpRoutes.register),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RpOutlineButton(
                          label: RpStrings.landingLogin,
                          icon: Icons.login_rounded,
                          onPressed: () => context.push(RpRoutes.login),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: RpColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          RpStrings.landingFooter,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: RpColors.textSecondary),
                        ),
                      ),
                    ],
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

class _LandingHero extends StatelessWidget {
  const _LandingHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: RpColors.wordmarkGradient,
            boxShadow: const [
              BoxShadow(
                color: RpColors.cardShadow,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.emoji_events_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: 20),
        const RpWordmark(),
        const SizedBox(height: 8),
        Text(
          RpStrings.landingTagline,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: RpColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
