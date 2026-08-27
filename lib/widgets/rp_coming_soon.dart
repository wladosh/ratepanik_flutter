import 'package:flutter/material.dart';

import '../l10n/rp_strings.dart';

void showComingSoon(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(const SnackBar(content: Text(RpStrings.soon)));
}
