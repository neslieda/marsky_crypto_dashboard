import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/strategy_signal.dart';
import '../cubit/strategy_signal_cubit.dart';

class StrategySignalCard extends StatelessWidget {
  final String title;
  final String generateLabel;
  final VoidCallback onGenerate;

  const StrategySignalCard({
    super.key,
    required this.title,
    required this.generateLabel,
    required this.onGenerate,
  });

  Color _actionColor(BuildContext context, SignalAction a) {
    return switch (a) {
      SignalAction.buy => const Color(0xFF16A34A),
      SignalAction.sell => const Color(0xFFDC2626),
      SignalAction.hold => Theme.of(context).colorScheme.primary,
      SignalAction.avoid => const Color(0xFF6B7280),
    };
  }

  IconData _actionIcon(SignalAction a) => switch (a) {
        SignalAction.buy => Icons.trending_up_rounded,
        SignalAction.sell => Icons.trending_down_rounded,
        SignalAction.hold => Icons.pause_circle_outline_rounded,
        SignalAction.avoid => Icons.block_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<StrategySignalCubit, SignalState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.status == SignalStatus.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.status == SignalStatus.success &&
                  state.signal != null)
                _SignalBody(
                  signal: state.signal!,
                  color: _actionColor(context, state.signal!.action),
                  icon: _actionIcon(state.signal!.action),
                )
              else if (state.status == SignalStatus.failure)
                Text(
                  state.errorMessage ?? 'Failed to evaluate.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed:
                      state.status == SignalStatus.loading ? null : onGenerate,
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: Text(state.signal == null
                      ? generateLabel
                      : 'Re-evaluate'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SignalBody extends StatelessWidget {
  final StrategySignal signal;
  final Color color;
  final IconData icon;
  const _SignalBody(
      {required this.signal, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    signal.action.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${signal.confidence}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Text('confidence', style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        SelectableText(signal.reasoning, style: theme.textTheme.bodyMedium),
        if (signal.suggestedEntry != null ||
            signal.suggestedExit != null ||
            signal.suggestedAllocationPct != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (signal.suggestedEntry != null)
                _Chip(label: 'Entry', value: signal.suggestedEntry!),
              if (signal.suggestedExit != null)
                _Chip(label: 'Exit', value: signal.suggestedExit!),
              if (signal.suggestedAllocationPct != null)
                _Chip(
                    label: 'Alloc %', value: signal.suggestedAllocationPct!),
            ],
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final double value;
  const _Chip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
