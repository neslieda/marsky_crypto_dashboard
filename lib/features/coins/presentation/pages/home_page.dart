import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/coin_tile_skeleton.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
    return BlocProvider.value(
      value: sl<CoinsListBloc>(),
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
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context
          .read<CoinsListBloc>()
          .add(CoinsListSearchChanged(_searchCtrl.text));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
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
    final l = AppLocalizations.of(context);
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
          body = const CoinListSkeleton();
        } else if (state.status == CoinsListStatus.failure &&
            state.coins.isEmpty) {
          body = ErrorView(
            message: state.errorMessage ?? 'Failed to load coins.',
            onRetry: () => context
                .read<CoinsListBloc>()
                .add(const CoinsListLoadRequested()),
          );
        } else if (state.coins.isEmpty) {
          body = RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: ListView(
              children: [
                const SizedBox(height: 80),
                EmptyView(
                  icon: state.searchQuery.isEmpty
                      ? Icons.inbox_rounded
                      : Icons.search_off_rounded,
                  message: l.noCoins,
                ),
              ],
            ),
          );
        } else {
          body = RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: ListView.separated(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.coins.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index >= state.coins.length) {
                  return const CoinTileSkeleton();
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
                      onTap: () =>
                          CoinDetailSheet.show(context, coin.uuid),
                      onFavoriteToggle: () =>
                          _toggleFavorite(context, coin),
                    );
                  },
                );
              },
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l.coins),
            actions: [
              IconButton(
                onPressed: () =>
                    GoRouter.of(context).push('/compare'),
                icon: const Icon(Icons.compare_arrows_rounded),
                tooltip: l.compare,
              ),
              IconButton(
                onPressed: () => _openSort(context),
                icon: const Icon(Icons.sort),
                tooltip: l.sortCoins,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: l.search,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _searchCtrl.clear(),
                          ),
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),
          body: body,
        );
      },
    );
  }

  bool _isFav(List<FavoriteCoin> list, String uuid) =>
      list.any((f) => f.uuid == uuid);

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<CoinsListBloc>();
    bloc.add(const CoinsListRefreshed());
    await bloc.stream.firstWhere(
      (s) => s.status != CoinsListStatus.loading,
    );
  }

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
