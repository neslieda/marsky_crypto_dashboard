import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_constants.dart';
import '../../domain/entities/coin.dart';
import '../../domain/entities/coin_sort.dart';
import '../../domain/usecases/get_coins_paginated.dart';

part 'coins_list_event.dart';
part 'coins_list_state.dart';

class CoinsListBloc extends Bloc<CoinsListEvent, CoinsListState> {
  final GetCoinsPaginated getCoinsPaginated;

  CoinsListBloc({required this.getCoinsPaginated})
      : super(const CoinsListState()) {
    on<CoinsListLoadRequested>(_onLoadRequested);
    on<CoinsListLoadMoreRequested>(_onLoadMoreRequested);
    on<CoinsListSortChanged>(_onSortChanged);
    on<CoinsListRefreshed>(_onRefreshed);
    on<CoinsListSearchChanged>(_onSearchChanged);
  }

  Future<void> _onLoadRequested(
    CoinsListLoadRequested event,
    Emitter<CoinsListState> emit,
  ) async {
    emit(state.copyWith(status: CoinsListStatus.loading, errorMessage: null));
    final result = await getCoinsPaginated(
      limit: AppConstants.coinsPageSize,
      offset: 0,
      orderBy: state.sortBy,
      direction: state.direction,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CoinsListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: CoinsListStatus.success,
          coins: page.coins,
          hasMore: page.hasMore,
          total: page.total,
        ),
      ),
    );
  }

  Future<void> _onLoadMoreRequested(
    CoinsListLoadMoreRequested event,
    Emitter<CoinsListState> emit,
  ) async {
    if (state.status == CoinsListStatus.loadingMore || !state.hasMore) return;
    emit(state.copyWith(status: CoinsListStatus.loadingMore));
    final result = await getCoinsPaginated(
      limit: AppConstants.coinsPageSize,
      offset: state.coins.length,
      orderBy: state.sortBy,
      direction: state.direction,
      search: state.searchQuery.isEmpty ? null : state.searchQuery,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CoinsListStatus.success,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: CoinsListStatus.success,
          coins: [...state.coins, ...page.coins],
          hasMore: page.hasMore,
          total: page.total,
        ),
      ),
    );
  }

  Future<void> _onSortChanged(
    CoinsListSortChanged event,
    Emitter<CoinsListState> emit,
  ) async {
    emit(state.copyWith(
      sortBy: event.sortBy,
      direction: event.direction,
      coins: const [],
      hasMore: true,
    ));
    add(const CoinsListLoadRequested());
  }

  Future<void> _onRefreshed(
    CoinsListRefreshed event,
    Emitter<CoinsListState> emit,
  ) async {
    add(const CoinsListLoadRequested());
  }

  Future<void> _onSearchChanged(
    CoinsListSearchChanged event,
    Emitter<CoinsListState> emit,
  ) async {
    final q = event.query.trim();
    if (q == state.searchQuery) return;
    emit(state.copyWith(
      searchQuery: q,
      coins: const [],
      hasMore: true,
    ));
    add(const CoinsListLoadRequested());
  }
}
