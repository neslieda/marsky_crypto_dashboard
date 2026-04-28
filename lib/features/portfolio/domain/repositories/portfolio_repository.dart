import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/portfolio_holding.dart';

abstract class PortfolioRepository {
  Future<Either<Failure, void>> open(String userId);
  Future<void> close();
  List<PortfolioHolding> getAll();
  Stream<List<PortfolioHolding>> watchAll();
  Future<Either<Failure, void>> upsert(PortfolioHolding holding);
  Future<Either<Failure, void>> remove(String uuid);
}
