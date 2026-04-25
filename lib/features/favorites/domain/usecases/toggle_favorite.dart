import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/favorite_coin.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavorite {
  final FavoritesRepository repository;
  ToggleFavorite(this.repository);

  Future<Either<Failure, bool>> call(FavoriteCoin coin) =>
      repository.toggle(coin);
}
