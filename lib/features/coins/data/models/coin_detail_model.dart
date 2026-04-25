import '../../domain/entities/coin_detail.dart';
import 'coin_model.dart';

class CoinDetailModel extends CoinDetail {
  const CoinDetailModel({
    required super.coin,
    super.description,
    super.websiteUrl,
    super.allTimeHigh,
    super.numberOfMarkets,
    super.numberOfExchanges,
  });

  factory CoinDetailModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final coin = CoinModel.fromJson(json);
    final ath = json['allTimeHigh'];
    return CoinDetailModel(
      coin: coin,
      description: json['description'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      allTimeHigh: ath is Map ? toDouble(ath['price']) : null,
      numberOfMarkets: json['numberOfMarkets'] is int
          ? json['numberOfMarkets'] as int
          : int.tryParse('${json['numberOfMarkets']}'),
      numberOfExchanges: json['numberOfExchanges'] is int
          ? json['numberOfExchanges'] as int
          : int.tryParse('${json['numberOfExchanges']}'),
    );
  }
}

class CoinHistoryPointModel extends CoinHistoryPoint {
  const CoinHistoryPointModel({required super.price, required super.timestamp});

  factory CoinHistoryPointModel.fromJson(Map<String, dynamic> json) {
    final ts = json['timestamp'];
    final tsInt = ts is int ? ts : int.tryParse('$ts') ?? 0;
    return CoinHistoryPointModel(
      price: json['price'] == null
          ? null
          : double.tryParse(json['price'].toString()),
      timestamp: DateTime.fromMillisecondsSinceEpoch(tsInt * 1000),
    );
  }
}
