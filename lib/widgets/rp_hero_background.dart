import 'package:flutter/material.dart';

import '../theme/rp_colors.dart';

class RpHeroBackground extends StatelessWidget {
  const RpHeroBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: RpColors.heroGradient),
      child: child,
    );
  }
}

class RpWordmark extends StatelessWidget {
  const RpWordmark({super.key, this.fontSize = 40});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          RpColors.wordmarkGradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        'Ratepanik',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          height: 1.05,
          letterSpacing: -0.8,
          color: Colors.white,
        ),
      ),
    );
  }
}

class RpCard extends StatelessWidget {
  const RpCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RpColors.bgElevated,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: RpColors.cardShadow,
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
