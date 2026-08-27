import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/rp_strings.dart';
import '../../theme/rp_colors.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RpHeroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        RpStrings.shopTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Lootbox cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _LootboxCard(
                      title: 'Gewöhnlich',
                      price: 50,
                      assetPath: 'assets/rp/rp_loot_box_common_256.png',
                      color: const Color(0xFFE8F4FF),
                    ),
                    const SizedBox(height: 12),
                    _LootboxCard(
                      title: 'Ungewöhnlich',
                      price: 100,
                      assetPath: 'assets/rp/rp_loot_box_uncommon_256.png',
                      color: const Color(0xFFE8FFE8),
                    ),
                    const SizedBox(height: 12),
                    _LootboxCard(
                      title: 'Selten',
                      price: 200,
                      assetPath: 'assets/rp/rp_loot_box_rare_256.png',
                      color: const Color(0xFFF0EAFF),
                    ),
                    const SizedBox(height: 12),
                    _LootboxCard(
                      title: 'Episch',
                      price: 400,
                      assetPath: 'assets/rp/rp_loot_box_epic_256.png',
                      color: const Color(0xFFFFE8F3),
                    ),
                    const SizedBox(height: 12),
                    _LootboxCard(
                      title: 'Legendär',
                      price: 800,
                      assetPath: 'assets/rp/rp_loot_box_legendary_256.png',
                      color: const Color(0xFFFFF3D6),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LootboxCard extends StatelessWidget {
  const _LootboxCard({
    required this.title,
    required this.price,
    required this.assetPath,
    required this.color,
  });

  final String title;
  final int price;
  final String assetPath;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RpCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.card_giftcard_rounded,
                  color: RpColors.purple,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      size: 16,
                      color: RpColors.hirncoin,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$price',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: RpColors.hirncoin,
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          RpPrimaryButton(
            label: RpStrings.shopBuy,
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text(RpStrings.soon)),
                );
            },
          ),
        ],
      ),
    );
  }
}
