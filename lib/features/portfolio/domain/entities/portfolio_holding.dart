import 'package:equatable/equatable.dart';

class PortfolioHolding extends Equatable {
  final String uuid;
  final String name;
  final String symbol;
  final String? iconUrl;

  /// Amount of coin held by the user (e.g. 0.5 BTC).
  final double amount;

  /// Average buy price per coin in user's reference currency at time of entry.
  /// Optional — used for unrealised P/L when set.
  final double? buyPrice;

  final DateTime addedAt;

  const PortfolioHolding({
    required this.uuid,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.addedAt,
    this.iconUrl,
    this.buyPrice,
  });

  PortfolioHolding copyWith({
    double? amount,
    double? buyPrice,
  }) =>
      PortfolioHolding(
        uuid: uuid,
        name: name,
        symbol: symbol,
        iconUrl: iconUrl,
        amount: amount ?? this.amount,
        buyPrice: buyPrice ?? this.buyPrice,
        addedAt: addedAt,
      );

  @override
  List<Object?> get props => [uuid, amount, buyPrice];
}
