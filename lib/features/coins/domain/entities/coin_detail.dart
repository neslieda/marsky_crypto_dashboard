import 'package:equatable/equatable.dart';

import 'coin.dart';

class CoinDetail extends Equatable {
  final Coin coin;
  final String? description;
  final String? websiteUrl;
  final double? allTimeHigh;
  final int? numberOfMarkets;
  final int? numberOfExchanges;

  const CoinDetail({
    required this.coin,
    this.description,
    this.websiteUrl,
    this.allTimeHigh,
    this.numberOfMarkets,
    this.numberOfExchanges,
  });

  @override
  List<Object?> get props => [
        coin,
        description,
        websiteUrl,
        allTimeHigh,
        numberOfMarkets,
        numberOfExchanges,
      ];
}

class CoinHistoryPoint extends Equatable {
  final double? price;
  final DateTime timestamp;

  const CoinHistoryPoint({required this.price, required this.timestamp});

  @override
  List<Object?> get props => [price, timestamp];
}
