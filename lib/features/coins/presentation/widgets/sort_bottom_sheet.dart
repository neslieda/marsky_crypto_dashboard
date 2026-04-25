import 'package:flutter/material.dart';

import '../../domain/entities/coin_sort.dart';

class SortBottomSheet extends StatefulWidget {
  final CoinSortBy initialSortBy;
  final CoinSortDirection initialDirection;

  const SortBottomSheet({
    super.key,
    required this.initialSortBy,
    required this.initialDirection,
  });

  static Future<({CoinSortBy sortBy, CoinSortDirection direction})?> show(
    BuildContext context, {
    required CoinSortBy initialSortBy,
    required CoinSortDirection initialDirection,
  }) {
    return showModalBottomSheet<
        ({CoinSortBy sortBy, CoinSortDirection direction})>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SortBottomSheet(
        initialSortBy: initialSortBy,
        initialDirection: initialDirection,
      ),
    );
  }

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late CoinSortBy _sortBy = widget.initialSortBy;
  late CoinSortDirection _direction = widget.initialDirection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'Sort coins',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...CoinSortBy.values.map(
              (s) => RadioListTile<CoinSortBy>(
                value: s,
                groupValue: _sortBy,
                onChanged: (v) => setState(() => _sortBy = v ?? _sortBy),
                title: Text(s.label),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const Divider(height: 24),
            SegmentedButton<CoinSortDirection>(
              segments: const [
                ButtonSegment(
                  value: CoinSortDirection.desc,
                  label: Text('Descending'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: CoinSortDirection.asc,
                  label: Text('Ascending'),
                  icon: Icon(Icons.arrow_upward),
                ),
              ],
              selected: {_direction},
              onSelectionChanged: (s) =>
                  setState(() => _direction = s.first),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                (sortBy: _sortBy, direction: _direction),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
