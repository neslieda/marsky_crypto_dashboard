import '../entities/favorite_coin.dart';
import '../repositories/favorites_repository.dart';

class WatchFavorites {
  final FavoritesRepository repository;
  WatchFavorites(this.repository);

  Stream<List<FavoriteCoin>> call() => repository.watchAll();
}
