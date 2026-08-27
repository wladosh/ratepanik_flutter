import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_config.dart';
import '../../l10n/rp_strings.dart';
import '../../routing/app_router.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_buttons.dart';
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
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (email.isEmpty || password.isEmpty) {
        setState(() => _error = 'E-Mail und Passwort eingeben.');
        return;
      }
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (mounted) context.go(RpRoutes.home);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = RpStrings.loginError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginAsGuest() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await supabase.auth.signInAnonymously();
      if (mounted) context.go(RpRoutes.home);
    } catch (e) {
      setState(() => _error = RpStrings.loginError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: RpColors.danger),
                      ),
                    ),
                  RpCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          RpStrings.loginEmailLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
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
                                  () =>
                                      _obscurePassword = !_obscurePassword,
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
                          label: _loading
                              ? RpStrings.loading
                              : RpStrings.loginSubmit,
                          enabled: !_loading,
                          onPressed: _loginWithEmail,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.go(RpRoutes.register),
                          child: Text(
                            RpStrings.loginNoAccount,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
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
                      const Expanded(
                          child: Divider(color: RpColors.border)),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          RpStrings.loginMoreOptions,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
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
                  const SizedBox(height: 16),
                  RpOutlineButton(
                    label: RpStrings.loginGuest,
                    color: RpColors.textSecondary,
                    height: 46,
                    onPressed: _loginAsGuest,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(RpRoutes.landing),
                    child: Text(
                      RpStrings.loginBackHome,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
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
