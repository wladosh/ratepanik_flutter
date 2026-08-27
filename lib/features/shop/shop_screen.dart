import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/rp_strings.dart';
import '../../services/profile_service.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _service = ProfileService();
  int _hirncoins = 0;
  bool _loading = true;
  bool _opening = false;
  LootboxResult? _lastResult;
  List<Map<String, dynamic>> _ownedItems = [];
  List<Map<String, dynamic>> _cosmeticDefs = [];
  List<Map<String, dynamic>> _loadout = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final profile = await _service.loadProfile();
    final owned = await _service.loadOwnedCosmetics();
    final defs = await _service.loadCosmeticItems();
    final loadout = await _service.loadLoadout();
    if (mounted) {
      setState(() {
        _hirncoins = profile?['hirncoins'] as int? ?? 0;
        _ownedItems = owned;
        _cosmeticDefs = defs;
        _loadout = loadout;
        _loading = false;
      });
    }
  }

  Future<void> _buyLootbox() async {
    if (_opening || _hirncoins < 100) return;
    setState(() {
      _opening = true;
      _lastResult = null;
    });
    final requestId = const Uuid().v4();
    final result = await _service.openLootbox('lootbox_basic', requestId);

    final profile = await _service.loadProfile();
    final owned = await _service.loadOwnedCosmetics();
    if (mounted) {
      setState(() {
        _lastResult = result;
        _hirncoins = profile?['hirncoins'] as int? ?? _hirncoins;
        _ownedItems = owned;
        _opening = false;
      });
    }
  }

  Future<void> _equipItem(String slot, String? itemId) async {
    final result = await _service.equipSlot(slot, itemId);
    if (result.ok) {
      final loadout = await _service.loadLoadout();
      if (mounted) setState(() => _loadout = loadout);
    }
  }

  bool _isEquipped(String itemId) {
    return _loadout.any((l) => l['item_id'] == itemId);
  }

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
                    // Balance pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: RpColors.hirncoinSoft,
                        borderRadius: BorderRadius.circular(RpRadii.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on_rounded,
                              size: 16, color: RpColors.hirncoin),
                          const SizedBox(width: 4),
                          Text(
                            '$_hirncoins',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: RpColors.purple)))
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Lootbox hero
                      _LootboxHero(
                        hirncoins: _hirncoins,
                        opening: _opening,
                        onBuy: _buyLootbox,
                      ),

                      // Last result
                      if (_lastResult != null) ...[
                        const SizedBox(height: 16),
                        _LootboxResultCard(result: _lastResult!),
                      ],

                      // Owned items
                      if (_ownedItems.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          RpStrings.shopOwnedItems,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        ..._buildOwnedGrid(context),
                      ],

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

  List<Widget> _buildOwnedGrid(BuildContext context) {
    final ownedIds = _ownedItems.map((o) => o['item_id'] as String).toSet();
    final items = _cosmeticDefs
        .where((d) => ownedIds.contains(d['id'] as String))
        .toList();

    if (items.isEmpty) return [];

    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          final id = item['id'] as String;
          final name = item['name_de'] as String? ?? id;
          final slot = item['slot'] as String? ?? '';
          final rarity = item['rarity'] as String? ?? '';
          final equipped = _isEquipped(id);

          return SizedBox(
            width: (MediaQuery.of(context).size.width - 56) / 2,
            child: RpCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _RarityDot(rarity: rarity),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slot,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: RpColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 28,
                    width: double.infinity,
                    child: equipped
                        ? OutlinedButton(
                            onPressed: () => _equipItem(slot, null),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              side: const BorderSide(
                                  color: RpColors.success, width: 1.5),
                            ),
                            child: const Text(RpStrings.shopEquipped,
                                style: TextStyle(color: RpColors.success)),
                          )
                        : OutlinedButton(
                            onPressed: () => _equipItem(slot, id),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              side: const BorderSide(
                                  color: RpColors.purple, width: 1.5),
                            ),
                            child: const Text(RpStrings.shopEquip,
                                style: TextStyle(color: RpColors.purple)),
                          ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ];
  }
}

class _LootboxHero extends StatelessWidget {
  const _LootboxHero({
    required this.hirncoins,
    required this.opening,
    required this.onBuy,
  });
  final int hirncoins;
  final bool opening;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final canBuy = hirncoins >= 100 && !opening;

    return RpCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/rp/schleimi/lootbox_closed_256.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: RpColors.bgMuted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.card_giftcard_rounded,
                    size: 48, color: RpColors.purple),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            RpStrings.shopTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on_rounded,
                  size: 20, color: RpColors.hirncoin),
              const SizedBox(width: 4),
              Text(
                '100 Hirncoins',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: RpColors.hirncoin,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: RpPrimaryButton(
              label: opening
                  ? RpStrings.shopOpening
                  : canBuy
                      ? RpStrings.shopOpen
                      : RpStrings.shopNotEnough,
              enabled: canBuy,
              onPressed: onBuy,
            ),
          ),
        ],
      ),
    );
  }
}

class _LootboxResultCard extends StatelessWidget {
  const _LootboxResultCard({required this.result});
  final LootboxResult result;

  @override
  Widget build(BuildContext context) {
    final rarityColor = switch (result.rarity) {
      'legendaer' => RpColors.hirncoin,
      'selten' => RpColors.purple,
      _ => RpColors.textSecondary,
    };

    return RpCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            RpStrings.shopRevealTitle,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: rarityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RpRadii.pill),
            ),
            child: Text(
              result.rarity ?? '',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: rarityColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.nameDe ?? result.itemId ?? '?',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (result.slot != null)
            Text(
              result.slot!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: RpColors.textSecondary,
                  ),
            ),
          if (result.duplicate) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on_rounded,
                    size: 16, color: RpColors.hirncoin),
                const SizedBox(width: 4),
                Text(
                  '+${result.consolationHc} ${RpStrings.shopDuplicate}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: RpColors.hirncoin,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RarityDot extends StatelessWidget {
  const _RarityDot({required this.rarity});
  final String rarity;

  @override
  Widget build(BuildContext context) {
    final color = switch (rarity) {
      'legendaer' => RpColors.hirncoin,
      'selten' => RpColors.purple,
      _ => RpColors.textSecondary,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
