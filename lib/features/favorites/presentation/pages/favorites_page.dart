import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../coins/presentation/widgets/coin_detail_sheet.dart';
import '../../domain/entities/favorite_coin.dart';
import '../bloc/favorites_bloc.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String? _selectedCategory; // null = All

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.favorites)),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.loading ||
              state.status == FavoritesStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == FavoritesStatus.failure) {
            return ErrorView(message: state.errorMessage ?? '-');
          }

          final categories = <String?>{
            null,
            ...state.favorites.map((f) => f.category).whereType<String>(),
          }.toList();
          final filtered = _selectedCategory == null
              ? state.favorites
              : state.favorites
                  .where((f) => f.category == _selectedCategory)
                  .toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FavoritesBloc>().add(const FavoritesRefreshed());
              await Future<void>.delayed(const Duration(milliseconds: 350));
            },
            child: Column(
              children: [
                if (state.favorites.isNotEmpty)
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final cat = categories[i];
                        final selected = cat == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: ChoiceChip(
                            label: Text(cat ?? l.all),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = cat),
                          ),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: filtered.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            EmptyView(
                              icon: Icons.star_border_rounded,
                              message: l.noFavorites,
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final fav = filtered[index];
                            return _FavoriteTile(
                              favorite: fav,
                              onTap: () =>
                                  CoinDetailSheet.show(context, fav.uuid),
                              onRemove: () => context
                                  .read<FavoritesBloc>()
                                  .add(FavoritesToggled(fav)),
                              onAssignCategory: () =>
                                  _promptCategory(context, fav),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _promptCategory(BuildContext context, FavoriteCoin fav) async {
    final l = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: fav.category ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.assignCategory),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: l.categoryHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('__clear__'),
            child: Text(l.clear),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (result == null) return;
    final value = result == '__clear__' || result.isEmpty ? null : result;
    context
        .read<FavoritesBloc>()
        .add(FavoritesCategoryChanged(fav.uuid, value));
  }
}

class _FavoriteTile extends StatelessWidget {
  final FavoriteCoin favorite;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onAssignCategory;
  const _FavoriteTile({
    required this.favorite,
    required this.onTap,
    required this.onRemove,
    required this.onAssignCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final fallback = CircleAvatar(
      radius: 18,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Text(
        favorite.symbol.isEmpty ? '?' : favorite.symbol[0],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
    final url = favorite.iconUrl;
    final useFallback = url == null || url.isEmpty || url.endsWith('.svg');
    return ListTile(
      onTap: onTap,
      onLongPress: onAssignCategory,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Hero(
        tag: 'coin-icon-${favorite.uuid}',
        flightShuttleBuilder: (_, __, ___, ____, _____) =>
            const Material(type: MaterialType.transparency),
        child: useFallback
            ? fallback
            : ClipOval(
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => fallback,
                  errorWidget: (_, __, ___) => fallback,
                ),
              ),
      ),
      title: Text(favorite.name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${favorite.symbol} • ${l.addedOn(Formatters.date(favorite.addedAt))}'
        '${favorite.category == null ? '' : ' • ${favorite.category}'}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.label_outline_rounded, size: 20),
            tooltip: l.assignCategory,
            onPressed: onAssignCategory,
          ),
          IconButton(
            icon: const Icon(Icons.star_rounded, color: Color(0xFFFFB300)),
            onPressed: onRemove,
            tooltip: l.removeFavorite,
          ),
        ],
      ),
    );
  }
}
