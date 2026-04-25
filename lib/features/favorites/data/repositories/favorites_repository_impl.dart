import 'package:dartz/dartz.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/favorite_coin.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../models/favorite_coin_hive.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource _local;
  FavoritesRepositoryImpl(this._local);

  @override
  Future<Either<Failure, void>> open(String userId) async {
    try {
      await _local.open(userId);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> close() async {
    try {
      await _local.close();
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<FavoriteCoin>>> getAll() async {
    try {
      return Right(_local.getAll());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Stream<List<FavoriteCoin>> watchAll() {
    return _local.watchAll();
  }

  @override
  Future<Either<Failure, bool>> toggle(FavoriteCoin coin) async {
    try {
      final added = await _local.toggle(FavoriteCoinHive.fromEntity(coin));
      return Right(added);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
