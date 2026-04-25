import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/coin_detail.dart';
import '../entities/coin_sort.dart';
import '../repositories/coins_repository.dart';

class GetCoinHistory {
  final CoinsRepository repository;
  GetCoinHistory(this.repository);

  Future<Either<Failure, List<CoinHistoryPoint>>> call({
    required String uuid,
    required CoinHistoryPeriod period,
  }) {
    return repository.getCoinHistory(uuid: uuid, period: period);
  }
}
