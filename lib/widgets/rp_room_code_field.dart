import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/rp_strings.dart';
import '../theme/rp_colors.dart';

class RpRoomCodeField extends StatelessWidget {
  const RpRoomCodeField({
    super.key,
    required this.controller,
    this.errorText,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      textCapitalization: TextCapitalization.characters,
      maxLength: 6,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 4,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          return newValue.copyWith(text: newValue.text.toUpperCase());
        }),
      ],
      decoration: InputDecoration(
        hintText: RpStrings.landingJoinHint,
        counterText: '',
        suffixText: '${controller.text.length}/6',
        suffixStyle: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: RpColors.textSecondary),
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RpColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: errorText != null ? RpColors.danger : RpColors.border,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RpColors.focusRing, width: 2),
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}

String sanitizeRoomCode(String raw) {
  return raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
}
