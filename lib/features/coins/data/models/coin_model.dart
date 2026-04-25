import '../../domain/entities/coin.dart';

class CoinModel extends Coin {
  const CoinModel({
    required super.uuid,
    required super.name,
    required super.symbol,
    super.rank,
    super.iconUrl,
    super.color,
    super.price,
    super.marketCap,
    super.volume24h,
    super.change,
    super.listedAt,
    super.sparkline,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return CoinModel(
      uuid: json['uuid'] as String,
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      rank: toInt(json['rank']),
      iconUrl: json['iconUrl'] as String?,
      color: json['color'] as String?,
      price: toDouble(json['price']),
      marketCap: toDouble(json['marketCap']),
      volume24h: toDouble(json['24hVolume']),
      change: toDouble(json['change']),
      listedAt: toInt(json['listedAt']),
      sparkline: (json['sparkline'] as List?)
              ?.map((e) => e == null ? null : double.tryParse(e.toString()))
              .toList() ??
          const [],
    );
  }
}
