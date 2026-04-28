import 'package:equatable/equatable.dart';

class FavoriteCoin extends Equatable {
  final String uuid;
  final String name;
  final String symbol;
  final String? iconUrl;
  final DateTime addedAt;

  /// Free-text watchlist category label (e.g. "DeFi", "Layer 1").
  /// Null means "Uncategorised / Default".
  final String? category;

  const FavoriteCoin({
    required this.uuid,
    required this.name,
    required this.symbol,
    required this.addedAt,
    this.iconUrl,
    this.category,
  });

  FavoriteCoin copyWith({String? category, bool clearCategory = false}) =>
      FavoriteCoin(
        uuid: uuid,
        name: name,
        symbol: symbol,
        iconUrl: iconUrl,
        addedAt: addedAt,
        category: clearCategory ? null : category ?? this.category,
      );

  @override
  List<Object?> get props => [uuid, name, symbol, iconUrl, addedAt, category];
}
