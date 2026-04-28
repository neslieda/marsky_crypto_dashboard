import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/trading_strategy.dart';

abstract class StrategyRepository {
  Future<void> open(String userId);
  Future<void> close();

  Stream<List<TradingStrategy>> watchAll();
  List<TradingStrategy> getAll();
  TradingStrategy? get active;
  Stream<TradingStrategy?> watchActive();

  Future<Either<Failure, TradingStrategy>> upsert(TradingStrategy strategy);
  Future<Either<Failure, void>> remove(String id);
  Future<Either<Failure, void>> setActive(String? id);
}
