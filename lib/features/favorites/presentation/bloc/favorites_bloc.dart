import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/favorite_coin.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/watch_favorites.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository repository;
  final WatchFavorites watchFavorites;
  final ToggleFavorite toggleFavorite;

  StreamSubscription<List<FavoriteCoin>>? _sub;

  FavoritesBloc({
    required this.repository,
    required this.watchFavorites,
    required this.toggleFavorite,
  }) : super(const FavoritesState()) {
    on<FavoritesUserChanged>(_onUserChanged);
    on<FavoritesUserCleared>(_onUserCleared);
    on<_FavoritesUpdated>(_onUpdated);
    on<FavoritesToggled>(_onToggled);
  }

  Future<void> _onUserChanged(
    FavoritesUserChanged event,
    Emitter<FavoritesState> emit,
  ) async {
    await _sub?.cancel();
    emit(state.copyWith(status: FavoritesStatus.loading));
    final openResult = await repository.open(event.userId);
    final failed = openResult.fold((f) => f.message, (_) => null);
    if (failed != null) {
      emit(state.copyWith(
        status: FavoritesStatus.failure,
        errorMessage: failed,
      ));
      return;
    }
    _sub = watchFavorites().listen(
      (list) => add(_FavoritesUpdated(list)),
      onError: (e) => add(_FavoritesUpdated.error(e.toString())),
    );
  }

  Future<void> _onUserCleared(
    FavoritesUserCleared event,
    Emitter<FavoritesState> emit,
  ) async {
    await _sub?.cancel();
    _sub = null;
    await repository.close();
    emit(const FavoritesState());
  }

  void _onUpdated(_FavoritesUpdated event, Emitter<FavoritesState> emit) {
    if (event.error != null) {
      emit(state.copyWith(
        status: FavoritesStatus.failure,
        errorMessage: event.error,
      ));
      return;
    }
    emit(state.copyWith(
      status: FavoritesStatus.success,
      favorites: event.favorites,
      errorMessage: null,
    ));
  }

  Future<void> _onToggled(
    FavoritesToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await toggleFavorite(event.coin);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {},
    );
  }

  bool isFavorite(String uuid) =>
      state.favorites.any((f) => f.uuid == uuid);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await repository.close();
    return super.close();
  }
}
