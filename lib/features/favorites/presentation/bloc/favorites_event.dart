part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class FavoritesUserChanged extends FavoritesEvent {
  final String userId;
  const FavoritesUserChanged(this.userId);
  @override
  List<Object?> get props => [userId];
}

class FavoritesUserCleared extends FavoritesEvent {
  const FavoritesUserCleared();
}

class FavoritesRefreshed extends FavoritesEvent {
  const FavoritesRefreshed();
}

class FavoritesToggled extends FavoritesEvent {
  final FavoriteCoin coin;
  const FavoritesToggled(this.coin);
  @override
  List<Object?> get props => [coin];
}

class _FavoritesUpdated extends FavoritesEvent {
  final List<FavoriteCoin> favorites;
  final String? error;
  const _FavoritesUpdated(this.favorites) : error = null;
  const _FavoritesUpdated.error(String message)
      : favorites = const [],
        error = message;
  @override
  List<Object?> get props => [favorites, error];
}
