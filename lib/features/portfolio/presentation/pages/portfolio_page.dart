import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../coins/domain/entities/coin.dart';
import '../../../coins/presentation/bloc/coins_list_bloc.dart';
import '../../../coins/presentation/widgets/coin_detail_sheet.dart';
import '../../domain/entities/portfolio_holding.dart';
import '../bloc/portfolio_bloc.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.portfolio)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddHoldingSheet(context),
        icon: const Icon(Icons.add),
        label: Text(l.addHolding),
      ),
      body: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, state) {
          if (state.status == PortfolioStatus.loading &&
              state.holdings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == PortfolioStatus.failure &&
              state.holdings.isEmpty) {
            return ErrorView(
              message: state.errorMessage ?? '-',
              onRetry: () {},
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<PortfolioBloc>()
                  .add(const PortfolioPricesRefreshed());
              await Future.delayed(const Duration(milliseconds: 400));
            },
            child: state.holdings.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      EmptyView(
                        icon: Icons.account_balance_wallet_outlined,
                        message: l.portfolioEmpty,
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _SummaryCard(state: state),
                      const SizedBox(height: 16),
                      ...state.holdings.map(
                        (h) => _HoldingTile(
                          holding: h,
                          price: state.prices[h.uuid],
                          onTap: () => CoinDetailSheet.show(context, h.uuid),
                          onEdit: () => _openAddHoldingSheet(context,
                              existing: h),
                          onDelete: () => context
                              .read<PortfolioBloc>()
                              .add(PortfolioHoldingRemoved(h.uuid)),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Future<void> _openAddHoldingSheet(
    BuildContext context, {
    PortfolioHolding? existing,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: _HoldingForm(
          existing: existing,
          coinsBloc: context.read<CoinsListBloc>(),
          onSave: (h) {
            context.read<PortfolioBloc>().add(PortfolioHoldingUpserted(h));
            Navigator.of(sheetCtx).pop();
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final PortfolioState state;
  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final value = state.totalValue;
    final cost = state.totalCost;
    final pnl = cost > 0 ? value - cost : 0.0;
    final pnlPct = cost > 0 ? (pnl / cost) * 100 : null;
    final positive = pnl >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.totalValue,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 6),
          Text(Formatters.price(value),
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          if (cost > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  positive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 18,
                  color: positive
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                ),
                const SizedBox(width: 4),
                Text(
                  '${positive ? '+' : ''}${Formatters.price(pnl)}'
                  '${pnlPct == null ? '' : ' (${pnlPct.toStringAsFixed(2)}%)'}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: positive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
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

class _HoldingTile extends StatelessWidget {
  final PortfolioHolding holding;
  final double? price;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _HoldingTile({
    required this.holding,
    required this.price,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final value = price == null ? null : price! * holding.amount;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: _Icon(url: holding.iconUrl, symbol: holding.symbol),
        title: Text(holding.name),
        subtitle: Text(
          '${holding.amount} ${holding.symbol}'
          '${price == null ? '' : ' • ${Formatters.price(price)}'}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value == null ? '-' : Formatters.price(value),
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  tooltip: l.edit,
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onDelete,
                  tooltip: l.delete,
                ),
              ],
            ),
          ],
        ),
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
      radius: 18,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(symbol.isEmpty ? '?' : symbol[0],
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
    if (url == null || url!.isEmpty || url!.endsWith('.svg')) return fallback;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}

class _HoldingForm extends StatefulWidget {
  final PortfolioHolding? existing;
  final CoinsListBloc coinsBloc;
  final ValueChanged<PortfolioHolding> onSave;

  const _HoldingForm({
    required this.coinsBloc,
    required this.onSave,
    this.existing,
  });

  @override
  State<_HoldingForm> createState() => _HoldingFormState();
}

class _HoldingFormState extends State<_HoldingForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _buyCtrl = TextEditingController();
  Coin? _selectedCoin;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _amountCtrl.text = ex.amount.toString();
      if (ex.buyPrice != null) _buyCtrl.text = ex.buyPrice!.toString();
      _selectedCoin = Coin(
        uuid: ex.uuid,
        name: ex.name,
        symbol: ex.symbol,
        iconUrl: ex.iconUrl,
      );
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _buyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCoin == null) return;
    final coin = _selectedCoin!;
    final holding = PortfolioHolding(
      uuid: coin.uuid,
      name: coin.name,
      symbol: coin.symbol,
      iconUrl: coin.iconUrl,
      amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
      buyPrice: _buyCtrl.text.trim().isEmpty
          ? null
          : double.parse(_buyCtrl.text.replaceAll(',', '.')),
      addedAt: widget.existing?.addedAt ?? DateTime.now(),
    );
    widget.onSave(holding);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  widget.existing == null ? l.addHolding : l.editHolding,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (widget.existing == null)
                _CoinPickerField(
                  coinsBloc: widget.coinsBloc,
                  selected: _selectedCoin,
                  onChanged: (c) => setState(() => _selectedCoin = c),
                )
              else
                ListTile(
                  leading: _Icon(
                      url: _selectedCoin!.iconUrl,
                      symbol: _selectedCoin!.symbol),
                  title: Text(_selectedCoin!.name),
                  subtitle: Text(_selectedCoin!.symbol),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l.amount,
                  prefixIcon: const Icon(Icons.numbers_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l.amountRequired;
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return l.amountInvalid;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _buyCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l.buyPriceOptional,
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed < 0) return l.amountInvalid;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _selectedCoin == null ? null : _submit,
                child: Text(l.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinPickerField extends StatelessWidget {
  final CoinsListBloc coinsBloc;
  final Coin? selected;
  final ValueChanged<Coin> onChanged;

  const _CoinPickerField({
    required this.coinsBloc,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final picked = await showModalBottomSheet<Coin>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => BlocProvider.value(
            value: coinsBloc,
            child: const _CoinPickerSheet(),
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l.coin,
          prefixIcon: const Icon(Icons.search),
        ),
        child: Text(selected == null
            ? l.selectCoin
            : '${selected!.name} (${selected!.symbol})'),
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
