import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../ai/presentation/cubit/ai_cubit.dart';
import '../../../ai/presentation/widgets/ai_insight_card.dart';
import '../../domain/entities/coin_sort.dart';
import '../bloc/coin_detail_bloc.dart';
import 'price_line_chart.dart';

class CoinDetailSheet extends StatelessWidget {
  final String uuid;
  const CoinDetailSheet({super.key, required this.uuid});

  static Future<void> show(BuildContext context, String uuid) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => CoinDetailSheet(uuid: uuid),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CoinDetailBloc(
            getCoinDetail: sl(),
            getCoinHistory: sl(),
          )..add(CoinDetailOpened(uuid)),
        ),
        BlocProvider(create: (_) => sl<AiCubit>()),
      ],
      child: const _CoinDetailSheetView(),
    );
  }
}

class _CoinDetailSheetView extends StatelessWidget {
  const _CoinDetailSheetView();

  static String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length != 6) return null;
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return BlocBuilder<CoinDetailBloc, CoinDetailState>(
          builder: (context, state) {
            if (state.status == CoinDetailStatus.loading ||
                state.status == CoinDetailStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == CoinDetailStatus.failure &&
                state.detail == null) {
              return ErrorView(
                message: state.errorMessage ?? 'Failed to load coin.',
                onRetry: () => context
                    .read<CoinDetailBloc>()
                    .add(CoinDetailOpened(state.uuid ?? '')),
              );
            }
            final detail = state.detail!;
            final coin = detail.coin;
            final theme = Theme.of(context);
            final l = AppLocalizations.of(context);
            final changePositive = (coin.change ?? 0) >= 0;
            final changeColor = changePositive
                ? const Color(0xFF16A34A)
                : const Color(0xFFDC2626);

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  children: [
                    _Icon(
                      url: coin.iconUrl,
                      symbol: coin.symbol,
                      heroTag: 'coin-icon-${coin.uuid}',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coin.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                coin.symbol,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (coin.rank != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l.rank(coin.rank!),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  Formatters.price(coin.price),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.percent(coin.change),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _PeriodSelector(
                  selected: state.period,
                  onChanged: (p) => context
                      .read<CoinDetailBloc>()
                      .add(CoinDetailPeriodChanged(p)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: state.historyLoading
                      ? const Center(child: CircularProgressIndicator())
                      : PriceLineChart(
                          history: state.history,
                          color: _parseColor(coin.color) ??
                              theme.colorScheme.primary,
                        ),
                ),
                const SizedBox(height: 24),
                _StatsGrid(
                  high: state.highest,
                  low: state.lowest,
                  marketCap: coin.marketCap,
                  volume: coin.volume24h,
                ),
                const SizedBox(height: 16),
                Builder(builder: (ctx) {
                  final lang = Localizations.localeOf(ctx).languageCode;
                  return AiInsightCard(
                    title: lang == 'tr' ? 'AI Analiz' : 'AI Insight',
                    icon: Icons.auto_awesome_rounded,
                    generateLabel:
                        lang == 'tr' ? 'Analiz et' : 'Analyze',
                    onGenerate: () => ctx.read<AiCubit>().analyzeCoin(
                          coin: detail,
                          history: state.history,
                          languageCode: lang,
                        ),
                  );
                }),
                if (detail.allTimeHigh != null) ...[
                  const SizedBox(height: 12),
                  _StatTile(
                    label: l.allTimeHigh,
                    value: Formatters.price(detail.allTimeHigh),
                  ),
                ],
                if (detail.websiteUrl != null &&
                    detail.websiteUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _WebsiteRow(url: detail.websiteUrl!),
                ],
                if (detail.description != null &&
                    detail.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    l.description,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _stripHtml(detail.description!),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _Icon extends StatelessWidget {
  final String? url;
  final String symbol;
  final String heroTag;
  const _Icon({
    required this.url,
    required this.symbol,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: 22,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        symbol.isEmpty ? '?' : symbol[0],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    Widget child;
    if (url == null || url!.isEmpty || url!.endsWith('.svg')) {
      child = fallback;
    } else {
      child = ClipOval(
        child: CachedNetworkImage(
          imageUrl: url!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          placeholder: (_, __) => fallback,
          errorWidget: (_, __, ___) => fallback,
        ),
      );
    }
    return Hero(
      tag: heroTag,
      flightShuttleBuilder: (_, __, ___, ____, _____) => Material(
        type: MaterialType.transparency,
        child: child,
      ),
      child: child,
    );
  }
}

class _WebsiteRow extends StatelessWidget {
  final String url;
  const _WebsiteRow({required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: url));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$url copied')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(Icons.link_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                url,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l.website,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.copy_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final CoinHistoryPeriod selected;
  final ValueChanged<CoinHistoryPeriod> onChanged;
  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: CoinHistoryPeriod.values.map((p) {
          final isSelected = p == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(p.label),
              selected: isSelected,
              onSelected: (_) => onChanged(p),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final double? high;
  final double? low;
  final double? marketCap;
  final double? volume;

  const _StatsGrid({
    required this.high,
    required this.low,
    required this.marketCap,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _StatTile(label: l.high, value: Formatters.price(high)),
        _StatTile(label: l.low, value: Formatters.price(low)),
        _StatTile(label: l.marketCap, value: Formatters.compactPrice(marketCap)),
        _StatTile(label: l.volume24h, value: Formatters.compactPrice(volume)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
