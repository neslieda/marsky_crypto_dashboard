import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/coin.dart';
import '../bloc/coins_list_bloc.dart';
import '../bloc/coin_detail_bloc.dart';
import '../widgets/price_line_chart.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  Coin? _left;
  Coin? _right;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.compare)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: _Slot(
                  coin: _left,
                  label: 'A',
                  onPick: (c) => setState(() => _left = c),
                )),
                const SizedBox(width: 12),
                const Icon(Icons.compare_arrows_rounded),
                const SizedBox(width: 12),
                Expanded(
                    child: _Slot(
                  coin: _right,
                  label: 'B',
                  onPick: (c) => setState(() => _right = c),
                )),
              ],
            ),
            const SizedBox(height: 16),
            if (_left != null && _right != null)
              Expanded(
                child: _CompareDetails(left: _left!, right: _right!),
              )
            else
              Expanded(
                child: Center(
                  child: Text(l.compareHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  final Coin? coin;
  final String label;
  final ValueChanged<Coin> onPick;
  const _Slot({required this.coin, required this.label, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showModalBottomSheet<Coin>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => const _CoinPickerSheet(),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            if (coin == null)
              const Icon(Icons.add_circle_outline, size: 32)
            else ...[
              _Icon(url: coin!.iconUrl, symbol: coin!.symbol),
              const SizedBox(height: 6),
              Text(coin!.symbol,
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompareDetails extends StatelessWidget {
  final Coin left;
  final Coin right;
  const _CompareDetails({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      children: [
        _Row(label: l.price, a: Formatters.price(left.price), b: Formatters.price(right.price)),
        _Row(
            label: l.change24h,
            a: Formatters.percent(left.change),
            b: Formatters.percent(right.change)),
        _Row(
            label: l.marketCap,
            a: Formatters.compactPrice(left.marketCap),
            b: Formatters.compactPrice(right.marketCap)),
        _Row(
            label: l.volume24h,
            a: Formatters.compactPrice(left.volume24h),
            b: Formatters.compactPrice(right.volume24h)),
        _Row(
            label: '#',
            a: left.rank?.toString() ?? '-',
            b: right.rank?.toString() ?? '-'),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: _ComparisonChart(left: left, right: right),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String a;
  final String b;
  const _Row({required this.label, required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(a,
                  textAlign: TextAlign.left,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700))),
          Expanded(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ))),
          Expanded(
              child: Text(b,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _ComparisonChart extends StatelessWidget {
  final Coin left;
  final Coin right;
  const _ComparisonChart({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MiniHistory(uuid: left.uuid)),
        const SizedBox(width: 8),
        Expanded(child: _MiniHistory(uuid: right.uuid)),
      ],
    );
  }
}

class _MiniHistory extends StatelessWidget {
  final String uuid;
  const _MiniHistory({required this.uuid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoinDetailBloc(
        getCoinDetail: sl(),
        getCoinHistory: sl(),
      )..add(CoinDetailOpened(uuid)),
      child: BlocBuilder<CoinDetailBloc, CoinDetailState>(
        builder: (context, state) {
          if (state.historyLoading || state.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return PriceLineChart(
            history: state.history,
            color: Theme.of(context).colorScheme.primary,
          );
        },
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final String? url;
  final String symbol;
  const _Icon({required this.url, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final fallback = CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(symbol.isEmpty ? '?' : symbol[0],
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
    if (url == null || url!.isEmpty || url!.endsWith('.svg')) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}

class _CoinPickerSheet extends StatefulWidget {
  const _CoinPickerSheet();

  @override
  State<_CoinPickerSheet> createState() => _CoinPickerSheetState();
}

class _CoinPickerSheetState extends State<_CoinPickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: l.search,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<CoinsListBloc, CoinsListState>(
                builder: (context, state) {
                  final query = _q.trim().toLowerCase();
                  final coins = query.isEmpty
                      ? state.coins
                      : state.coins
                          .where((c) =>
                              c.name.toLowerCase().contains(query) ||
                              c.symbol.toLowerCase().contains(query))
                          .toList();
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: coins.length,
                    itemBuilder: (_, i) {
                      final c = coins[i];
                      return ListTile(
                        leading: _Icon(url: c.iconUrl, symbol: c.symbol),
                        title: Text(c.name),
                        subtitle: Text(c.symbol),
                        onTap: () => Navigator.of(context).pop(c),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
