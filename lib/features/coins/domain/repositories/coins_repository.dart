import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/coin.dart';
import '../entities/coin_detail.dart';
import '../entities/coin_sort.dart';

abstract class CoinsRepository {
  Future<Either<Failure, CoinsPage>> getCoins({
    required int limit,
    required int offset,
    required CoinSortBy orderBy,
    required CoinSortDirection orderDirection,
  });

  Future<Either<Failure, CoinDetail>> getCoinDetail(String uuid);

  Future<Either<Failure, List<CoinHistoryPoint>>> getCoinHistory({
    required String uuid,
    required CoinHistoryPeriod period,
  });
}
