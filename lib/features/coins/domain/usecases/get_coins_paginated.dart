import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/coin.dart';
import '../entities/coin_sort.dart';
import '../repositories/coins_repository.dart';

class GetCoinsPaginated {
  final CoinsRepository repository;
  GetCoinsPaginated(this.repository);

  Future<Either<Failure, CoinsPage>> call({
    required int limit,
    required int offset,
    required CoinSortBy orderBy,
    required CoinSortDirection direction,
  }) {
    return repository.getCoins(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      orderDirection: direction,
    );
  }
}
