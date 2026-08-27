import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_config.dart';
import '../../l10n/rp_strings.dart';
import '../../routing/app_router.dart';
import '../../theme/rp_colors.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;
      if (email.isEmpty || password.isEmpty) {
        setState(() => _error = 'E-Mail und Passwort eingeben.');
        return;
      }
      await supabase.auth.signUp(email: email, password: password);
      setState(() => _success = RpStrings.registerSuccess);
    } catch (e) {
      setState(() => _error = RpStrings.registerError);
    } finally {
      setState(() => _loading = false);
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
                    RpStrings.registerSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: RpColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  if (_success != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _success!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: RpColors.success),
                      ),
                    ),
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
                          RpStrings.registerTitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            hintText: RpStrings.loginEmail,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            hintText: RpStrings.loginPassword,
                            suffixIcon: TextButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              child: Text(
                                _obscure
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
                              : RpStrings.registerSubmit,
                          enabled: !_loading,
                          onPressed: _register,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(RpRoutes.login),
                    child: Text(
                      RpStrings.registerHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: RpColors.purple,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
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
