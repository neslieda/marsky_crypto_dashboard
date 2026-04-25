import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/favorite_coin.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, void>> open(String userId);

  Future<Either<Failure, List<FavoriteCoin>>> getAll();

  Stream<List<FavoriteCoin>> watchAll();

  Future<Either<Failure, bool>> toggle(FavoriteCoin coin);

  Future<Either<Failure, void>> close();
}
