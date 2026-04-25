import 'package:equatable/equatable.dart';

class FavoriteCoin extends Equatable {
  final String uuid;
  final String name;
  final String symbol;
  final String? iconUrl;
  final DateTime addedAt;

  const FavoriteCoin({
    required this.uuid,
    required this.name,
    required this.symbol,
    required this.addedAt,
    this.iconUrl,
  });

  @override
  List<Object?> get props => [uuid, name, symbol, iconUrl, addedAt];
}
