import 'package:flutter/material.dart';

import '../../l10n/rp_strings.dart';
import '../../services/game_service.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_buttons.dart';

class OrderItScreen extends StatefulWidget {
  const OrderItScreen({super.key, required this.game});
  final GameService game;

  @override
  State<OrderItScreen> createState() => _OrderItScreenState();
}

class _OrderItScreenState extends State<OrderItScreen> {
  late List<int> _order;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final items =
        (widget.game.state.currentPrompt?.payload['items'] as List<dynamic>?)
                ?.length ??
            4;
    _order = List.generate(items, (i) => i)..shuffle();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await widget.game.submitOrderIt(_order);
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.game.state.currentPrompt;
    final items =
        (prompt?.payload['items'] as List<dynamic>?)?.cast<String>() ?? [];
    final axis = prompt?.payload['order_axis'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '↕️ ${RpStrings.orderItTitle}',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          if (prompt != null)
            Text(
              prompt.prompt,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: RpColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          if (axis.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              axis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: RpColors.purple,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _order.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _order.removeAt(oldIndex);
                  _order.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final itemIndex = _order[index];
                final text =
                    itemIndex < items.length ? items[itemIndex] : '?';
                return Container(
                  key: ValueKey(itemIndex),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: RpColors.bgElevated,
                    borderRadius: BorderRadius.circular(RpRadii.md),
                    boxShadow: const [
                      BoxShadow(
                        color: RpColors.cardShadow,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: RpColors.purple,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      text,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(
                      Icons.drag_handle_rounded,
                      color: RpColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          RpPrimaryButton(
            label:
                _submitting ? RpStrings.loading : RpStrings.orderItSubmit,
            enabled: !_submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
