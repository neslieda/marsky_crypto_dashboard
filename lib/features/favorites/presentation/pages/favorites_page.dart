import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../coins/presentation/widgets/coin_detail_sheet.dart';
import '../../domain/entities/favorite_coin.dart';
import '../bloc/favorites_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.loading ||
              state.status == FavoritesStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == FavoritesStatus.failure) {
            return ErrorView(
              message: state.errorMessage ?? 'Failed to load favorites.',
            );
          }
          if (state.favorites.isEmpty) {
            return const EmptyView(
              icon: Icons.star_border_rounded,
              message: 'No favorites yet.\nTap the star on a coin to add it.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.favorites.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final fav = state.favorites[index];
              return _FavoriteTile(
                favorite: fav,
                onTap: () => CoinDetailSheet.show(context, fav.uuid),
                onRemove: () => context
                    .read<FavoritesBloc>()
                    .add(FavoritesToggled(fav)),
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final FavoriteCoin favorite;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _FavoriteTile({
    required this.favorite,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: useFallback
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
      title: Text(
        favorite.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${favorite.symbol} • Added ${Formatters.date(favorite.addedAt)}',
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.star_rounded,
          color: Color(0xFFFFB300),
        ),
        onPressed: onRemove,
        tooltip: 'Remove from favorites',
      ),
    );
  }
}
