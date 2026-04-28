import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/ai_cubit.dart';

/// Reusable card that shows AI insight state.
/// `onGenerate` is invoked when the user taps the action button (idle/failure).
class AiInsightCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String generateLabel;
  final VoidCallback onGenerate;

  const AiInsightCard({
    super.key,
    required this.title,
    required this.icon,
    required this.generateLabel,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AiCubit, AiState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
                theme.colorScheme.tertiaryContainer.withValues(alpha: 0.30),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              if (state.status == AiStatus.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.status == AiStatus.success &&
                  state.insight != null)
                SelectableText(
                  state.insight!.content,
                  style: theme.textTheme.bodyMedium,
                )
              else if (state.status == AiStatus.failure)
                Text(
                  state.errorMessage ?? 'Something went wrong.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: state.status == AiStatus.loading ? null : onGenerate,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(state.insight == null
                      ? generateLabel
                      : 'Regenerate'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
