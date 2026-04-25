import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../favorites/domain/entities/favorite_coin.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../domain/entities/coin.dart';
import '../bloc/coins_list_bloc.dart';
import '../widgets/coin_detail_sheet.dart';
import '../widgets/coin_tile.dart';
import '../widgets/sort_bottom_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoinsListBloc(getCoinsPaginated: sl())
        ..add(const CoinsListLoadRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 240) {
      context.read<CoinsListBloc>().add(const CoinsListLoadMoreRequested());
    }
  }

  Future<void> _openSort(BuildContext context) async {
    final bloc = context.read<CoinsListBloc>();
    final result = await SortBottomSheet.show(
      context,
      initialSortBy: bloc.state.sortBy,
      initialDirection: bloc.state.direction,
    );
    if (result != null) {
      bloc.add(CoinsListSortChanged(
        sortBy: result.sortBy,
        direction: result.direction,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoinsListBloc, CoinsListState>(
      listenWhen: (p, c) =>
          p.errorMessage != c.errorMessage && c.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        Widget body;
        if (state.status == CoinsListStatus.loading && state.coins.isEmpty) {
          body = const Center(child: CircularProgressIndicator());
        } else if (state.status == CoinsListStatus.failure &&
            state.coins.isEmpty) {
          body = ErrorView(
            message: state.errorMessage ?? 'Failed to load coins.',
            onRetry: () => context
                .read<CoinsListBloc>()
                .add(const CoinsListLoadRequested()),
          );
        } else if (state.coins.isEmpty) {
          body = const EmptyView(message: 'No coins available.');
        } else {
          body = RefreshIndicator(
            onRefresh: () async {
              context
                  .read<CoinsListBloc>()
                  .add(const CoinsListRefreshed());
              await context
                  .read<CoinsListBloc>()
                  .stream
                  .firstWhere((s) => s.status != CoinsListStatus.loading);
            },
            child: ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.coins.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index >= state.coins.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final coin = state.coins[index];
                return BlocBuilder<FavoritesBloc, FavoritesState>(
                  buildWhen: (p, c) =>
                      _isFav(p.favorites, coin.uuid) !=
                      _isFav(c.favorites, coin.uuid),
                  builder: (context, favState) {
                    final isFav = _isFav(favState.favorites, coin.uuid);
                    return CoinTile(
                      coin: coin,
                      isFavorite: isFav,
                      onTap: () => CoinDetailSheet.show(context, coin.uuid),
                      onFavoriteToggle: () => _toggleFavorite(context, coin),
                    );
                  },
                );
              },
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Coins'),
            actions: [
              IconButton(
                onPressed: () => _openSort(context),
                icon: const Icon(Icons.sort),
                tooltip: 'Sort: ${state.sortBy.label}',
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }

  bool _isFav(List<FavoriteCoin> list, String uuid) =>
      list.any((f) => f.uuid == uuid);

  void _toggleFavorite(BuildContext context, Coin coin) {
    context.read<FavoritesBloc>().add(
          FavoritesToggled(
            FavoriteCoin(
              uuid: coin.uuid,
              name: coin.name,
              symbol: coin.symbol,
              iconUrl: coin.iconUrl,
              addedAt: DateTime.now(),
            ),
          ),
        );
  }
}
