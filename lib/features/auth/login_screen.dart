import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/rp_strings.dart';
import '../../routing/app_router.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_coming_soon.dart';
import '../../widgets/rp_hero_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RpHeroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                children: [
                  const RpWordmark(),
                  const SizedBox(height: 6),
                  Text(
                    RpStrings.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: RpColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  RpCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          RpStrings.loginEmailLabel,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            hintText: RpStrings.loginEmail,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            hintText: RpStrings.loginPassword,
                            suffixIcon: TextButton(
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              child: Text(
                                _obscurePassword
                                    ? RpStrings.loginShowPassword
                                    : RpStrings.loginHidePassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        RpPrimaryButton(
                          label: RpStrings.loginSubmit,
                          onPressed: () => context.go(RpRoutes.home),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => showComingSoon(context),
                          child: Text(
                            RpStrings.loginNoAccount,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: RpColors.purple,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: RpColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          RpStrings.loginMoreOptions,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: RpColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const Expanded(child: Divider(color: RpColors.border)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => showComingSoon(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: RpColors.text,
                      side: const BorderSide(
                        color: RpColors.border,
                        width: 1.5,
                      ),
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RpRadii.md),
                      ),
                      textStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _GoogleMark(),
                        SizedBox(width: 12),
                        Text(RpStrings.loginGoogle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  RpOutlineButton(
                    label: RpStrings.loginGuest,
                    color: RpColors.textSecondary,
                    height: 46,
                    onPressed: () => showComingSoon(context),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(RpRoutes.landing),
                    child: Text(
                      RpStrings.loginBackHome,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: RpColors.textSecondary,
                        fontWeight: FontWeight.w500,
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

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: Text(
            'G',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4285F4),
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
