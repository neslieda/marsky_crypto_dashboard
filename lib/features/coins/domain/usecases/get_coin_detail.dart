import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/coin_detail.dart';
import '../repositories/coins_repository.dart';

class GetCoinDetail {
  final CoinsRepository repository;
  GetCoinDetail(this.repository);

  Future<Either<Failure, CoinDetail>> call(String uuid) {
    return repository.getCoinDetail(uuid);
  }
}
