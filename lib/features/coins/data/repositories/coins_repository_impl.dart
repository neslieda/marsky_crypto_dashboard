import 'package:dartz/dartz.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/coin.dart';
import '../../domain/entities/coin_detail.dart';
import '../../domain/entities/coin_sort.dart';
import '../../domain/repositories/coins_repository.dart';
import '../datasources/coins_remote_datasource.dart';

class CoinsRepositoryImpl implements CoinsRepository {
  final CoinsRemoteDataSource _remote;
  CoinsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, CoinsPage>> getCoins({
    required int limit,
    required int offset,
    required CoinSortBy orderBy,
    required CoinSortDirection orderDirection,
    String? search,
  }) async {
    try {
      final page = await _remote.getCoins(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        direction: orderDirection,
        search: search,
      );
      return Right(page);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, CoinDetail>> getCoinDetail(String uuid) async {
    try {
      final detail = await _remote.getCoinDetail(uuid);
      return Right(detail);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<CoinHistoryPoint>>> getCoinHistory({
    required String uuid,
    required CoinHistoryPeriod period,
  }) async {
    try {
      final history = await _remote.getCoinHistory(uuid: uuid, period: period);
      return Right(history);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
