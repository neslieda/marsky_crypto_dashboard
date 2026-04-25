import 'package:equatable/equatable.dart';

class Coin extends Equatable {
  final String uuid;
  final int? rank;
  final String name;
  final String symbol;
  final String? iconUrl;
  final String? color;
  final double? price;
  final double? marketCap;
  final double? volume24h;
  final double? change;
  final int? listedAt;
  final List<double?> sparkline;

  const Coin({
    required this.uuid,
    required this.name,
    required this.symbol,
    this.rank,
    this.iconUrl,
    this.color,
    this.price,
    this.marketCap,
    this.volume24h,
    this.change,
    this.listedAt,
    this.sparkline = const [],
  });

  @override
  List<Object?> get props => [
        uuid,
        rank,
        name,
        symbol,
        iconUrl,
        color,
        price,
        marketCap,
        volume24h,
        change,
        listedAt,
        sparkline,
      ];
}

class CoinsPage extends Equatable {
  final List<Coin> coins;
  final int total;
  final int offset;
  final int limit;

  const CoinsPage({
    required this.coins,
    required this.total,
    required this.offset,
    required this.limit,
  });

  bool get hasMore => offset + coins.length < total;

  @override
  List<Object?> get props => [coins, total, offset, limit];
}
