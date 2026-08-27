import 'package:flutter/material.dart';

import '../../l10n/rp_strings.dart';
import '../../theme/rp_colors.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.hourglass_top_rounded,
            size: 48,
            color: RpColors.purple,
          ),
          const SizedBox(height: 16),
          Text(
            RpStrings.matchWaiting,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: RpColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
