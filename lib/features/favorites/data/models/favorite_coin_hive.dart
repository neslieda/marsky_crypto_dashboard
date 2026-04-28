import 'package:hive/hive.dart';

import '../../domain/entities/favorite_coin.dart';

class FavoriteCoinHive extends FavoriteCoin {
  const FavoriteCoinHive({
    required super.uuid,
    required super.name,
    required super.symbol,
    required super.addedAt,
    super.iconUrl,
    super.category,
  });

  factory FavoriteCoinHive.fromEntity(FavoriteCoin e) => FavoriteCoinHive(
        uuid: e.uuid,
        name: e.name,
        symbol: e.symbol,
        iconUrl: e.iconUrl,
        addedAt: e.addedAt,
        category: e.category,
      );
}

class FavoriteCoinAdapter extends TypeAdapter<FavoriteCoinHive> {
  @override
  final int typeId = 1;

  @override
  FavoriteCoinHive read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return FavoriteCoinHive(
      uuid: fields[0] as String,
      name: fields[1] as String,
      symbol: fields[2] as String,
      iconUrl: fields[3] as String?,
      addedAt: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
      category: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteCoinHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.symbol)
      ..writeByte(3)
      ..write(obj.iconUrl)
      ..writeByte(4)
      ..write(obj.addedAt.millisecondsSinceEpoch)
      ..writeByte(5)
      ..write(obj.category);
  }
}
