import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/trading_strategy.dart';
import '../../domain/repositories/strategy_repository.dart';
import '../datasources/strategy_local_datasource.dart';

class StrategyRepositoryImpl implements StrategyRepository {
  final StrategyLocalDataSource _local;
  StrategyRepositoryImpl(this._local);

  @override
  Future<void> open(String userId) => _local.open(userId);

  @override
  Future<void> close() => _local.close();

  @override
  List<TradingStrategy> getAll() {
    try {
      return _local.getAll();
    } catch (_) {
      return const [];
    }
  }

  @override
  Stream<List<TradingStrategy>> watchAll() async* {
    yield getAll();
    await for (final _ in _local.watchChanges()) {
      yield getAll();
    }
  }

  @override
  TradingStrategy? get active {
    final id = _local.activeId;
    if (id == null) return null;
    return getAll().firstWhere(
      (s) => s.id == id,
      orElse: () => _Sentinel.instance,
    ).let((s) => s == _Sentinel.instance ? null : s);
  }

  @override
  Stream<TradingStrategy?> watchActive() async* {
    yield active;
    await for (final _ in _local.watchChanges()) {
      yield active;
    }
  }

  @override
  Future<Either<Failure, TradingStrategy>> upsert(TradingStrategy s) async {
    try {
      await _local.upsert(s);
      return Right(s);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> remove(String id) async {
    try {
      await _local.remove(id);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> setActive(String? id) async {
    try {
      await _local.setActiveId(id);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

class _Sentinel extends TradingStrategy {
  _Sentinel._()
      : super(
          id: '__sentinel__',
          name: '',
          style: StrategyStyle.balanced,
          horizon: StrategyHorizon.medium,
          maxAllocationPerCoinPct: 0,
          buyConditions: '',
          sellConditions: '',
          createdAt: DateTime(0),
          updatedAt: DateTime(0),
        );
  static final _Sentinel instance = _Sentinel._();
}
