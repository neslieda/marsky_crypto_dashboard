import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/trading_strategy.dart';
import '../cubit/strategy_cubit.dart';

class StrategyFormPage extends StatefulWidget {
  final TradingStrategy? existing;
  const StrategyFormPage({super.key, this.existing});

  @override
  State<StrategyFormPage> createState() => _StrategyFormPageState();
}

class _StrategyFormPageState extends State<StrategyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _maxAlloc;
  late final TextEditingController _stopLoss;
  late final TextEditingController _takeProfit;
  late final TextEditingController _buy;
  late final TextEditingController _sell;
  late final TextEditingController _notes;

  late StrategyStyle _style;
  late StrategyHorizon _horizon;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _maxAlloc = TextEditingController(
        text: (e?.maxAllocationPerCoinPct ?? 20).toStringAsFixed(0));
    _stopLoss = TextEditingController(
        text: e?.stopLossPct != null ? e!.stopLossPct!.toStringAsFixed(0) : '');
    _takeProfit = TextEditingController(
        text:
            e?.takeProfitPct != null ? e!.takeProfitPct!.toStringAsFixed(0) : '');
    _buy = TextEditingController(text: e?.buyConditions ?? '');
    _sell = TextEditingController(text: e?.sellConditions ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _style = e?.style ?? StrategyStyle.balanced;
    _horizon = e?.horizon ?? StrategyHorizon.medium;
  }

  @override
  void dispose() {
    _name.dispose();
    _maxAlloc.dispose();
    _stopLoss.dispose();
    _takeProfit.dispose();
    _buy.dispose();
    _sell.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final id = widget.existing?.id ??
        'str_${now.microsecondsSinceEpoch}_${now.hashCode}';
    final strategy = TradingStrategy(
      id: id,
      name: _name.text.trim(),
      style: _style,
      horizon: _horizon,
      maxAllocationPerCoinPct: double.tryParse(_maxAlloc.text) ?? 20,
      stopLossPct: double.tryParse(_stopLoss.text),
      takeProfitPct: double.tryParse(_takeProfit.text),
      buyConditions: _buy.text.trim(),
      sellConditions: _sell.text.trim(),
      notes: _notes.text.trim(),
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );
    context.read<StrategyCubit>().save(strategy);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit strategy' : 'New strategy'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Strategy name',
                hintText: 'e.g. Large-cap DCA',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name required' : null,
            ),
            const SizedBox(height: 16),
            const _Label('Style'),
            SegmentedButton<StrategyStyle>(
              segments: const [
                ButtonSegment(
                    value: StrategyStyle.conservative,
                    label: Text('Conservative')),
                ButtonSegment(
                    value: StrategyStyle.balanced, label: Text('Balanced')),
                ButtonSegment(
                    value: StrategyStyle.aggressive,
                    label: Text('Aggressive')),
              ],
              selected: {_style},
              onSelectionChanged: (s) => setState(() => _style = s.first),
            ),
            const SizedBox(height: 16),
            const _Label('Time horizon'),
            SegmentedButton<StrategyHorizon>(
              segments: const [
                ButtonSegment(
                    value: StrategyHorizon.short, label: Text('Short')),
                ButtonSegment(
                    value: StrategyHorizon.medium, label: Text('Medium')),
                ButtonSegment(
                    value: StrategyHorizon.long, label: Text('Long')),
              ],
              selected: {_horizon},
              onSelectionChanged: (s) => setState(() => _horizon = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxAlloc,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max allocation per coin (%)',
                suffixText: '%',
              ),
              validator: (v) {
                final d = double.tryParse(v ?? '');
                if (d == null || d <= 0 || d > 100) {
                  return 'Enter 1-100';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stopLoss,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stop loss (%)',
                      hintText: 'e.g. 10',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _takeProfit,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Take profit (%)',
                      hintText: 'e.g. 25',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _buy,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'When to BUY',
                hintText: 'e.g. dip > 8% on weekly chart, rank top-50',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sell,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'When to SELL',
                hintText: 'e.g. +25% gain or 30d trend break',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notes / coins to avoid',
                hintText: 'e.g. avoid memecoins, prefer L1s',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
      );
}
