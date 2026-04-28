import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/trading_strategy.dart';
import '../cubit/strategy_cubit.dart';
import 'strategy_form_page.dart';

class StrategyListPage extends StatelessWidget {
  const StrategyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trading Strategies')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StrategyFormPage()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New strategy'),
      ),
      body: BlocBuilder<StrategyCubit, StrategyState>(
        builder: (context, state) {
          if (!state.ready) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.strategies.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: state.strategies.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final s = state.strategies[i];
              final isActive = state.active?.id == s.id;
              return _StrategyTile(
                strategy: s,
                isActive: isActive,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => StrategyFormPage(existing: s)),
                ),
                onSetActive: () =>
                    context.read<StrategyCubit>().setActive(isActive ? null : s.id),
                onDelete: () => _confirmDelete(context, s),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TradingStrategy s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete strategy?'),
        content: Text(
            "'${s.name}' will be permanently removed. This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton.tonal(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<StrategyCubit>().delete(s.id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_outlined,
                size: 56,
                color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No trading strategy yet',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Define your strategy (style, allocation, stop-loss, buy/sell rules) and the AI will evaluate coins against it.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StrategyTile extends StatelessWidget {
  final TradingStrategy strategy;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onSetActive;
  final VoidCallback onDelete;

  const _StrategyTile({
    required this.strategy,
    required this.isActive,
    required this.onTap,
    required this.onSetActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(strategy.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _Tag(strategy.style.label),
                  _Tag(strategy.horizon.label),
                  _Tag('Max ${strategy.maxAllocationPerCoinPct.toStringAsFixed(0)}%'),
                  if (strategy.stopLossPct != null)
                    _Tag('SL ${strategy.stopLossPct!.toStringAsFixed(0)}%'),
                  if (strategy.takeProfitPct != null)
                    _Tag('TP ${strategy.takeProfitPct!.toStringAsFixed(0)}%'),
                ],
              ),
              if (strategy.buyConditions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'BUY: ${strategy.buyConditions}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (strategy.sellConditions.isNotEmpty)
                Text(
                  'SELL: ${strategy.sellConditions}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onSetActive,
                    icon: Icon(isActive
                        ? Icons.toggle_on_rounded
                        : Icons.toggle_off_rounded),
                    label:
                        Text(isActive ? 'Deactivate' : 'Set as active'),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: theme.textTheme.labelSmall),
    );
  }
}
