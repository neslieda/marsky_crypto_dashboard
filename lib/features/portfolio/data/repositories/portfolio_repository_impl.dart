import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/portfolio_holding.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_local_datasource.dart';
import '../models/portfolio_holding_hive.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioLocalDataSource _ds;
  PortfolioRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, void>> open(String userId) async {
    try {
      await _ds.open(userId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<void> close() => _ds.close();

  @override
  List<PortfolioHolding> getAll() => _ds.getAll();

  @override
  Stream<List<PortfolioHolding>> watchAll() => _ds.watchAll();

  @override
  Future<Either<Failure, void>> upsert(PortfolioHolding holding) async {
    try {
      await _ds.upsert(PortfolioHoldingHive.fromEntity(holding));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> remove(String uuid) async {
    try {
      await _ds.remove(uuid);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
