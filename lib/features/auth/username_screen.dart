import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/rp_strings.dart';
import '../../routing/app_router.dart';
import '../../services/profile_service.dart';
import '../../theme/rp_colors.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final _ctrl = TextEditingController();
  final _service = ProfileService();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _claim() async {
    final name = _ctrl.text.trim();
    if (name.length < 3 || name.length > 20) {
      setState(() => _error = RpStrings.usernameInvalid);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _service.claimUsername(name);
    if (mounted) {
      if (result.ok) {
        context.go(RpRoutes.home);
      } else {
        setState(() {
          _error = result.error == 'already_taken'
              ? RpStrings.usernameTaken
              : result.error;
          _loading = false;
        });
      }
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const RpWordmark(fontSize: 32),
                    const SizedBox(height: 24),
                    Text(
                      RpStrings.usernameTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 24),
                    RpCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _ctrl,
                            autofocus: true,
                            maxLength: 20,
                            decoration: InputDecoration(
                              hintText: RpStrings.usernameHint,
                              counterText: '',
                              errorText: _error,
                            ),
                            onSubmitted: (_) => _claim(),
                          ),
                          const SizedBox(height: 16),
                          RpPrimaryButton(
                            label: _loading
                                ? RpStrings.loading
                                : RpStrings.usernameSubmit,
                            enabled: !_loading,
                            onPressed: _claim,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go(RpRoutes.home),
                      child: Text(
                        'Überspringen',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
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
      ),
    );
  }
}
