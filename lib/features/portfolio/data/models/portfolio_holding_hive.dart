import 'package:hive/hive.dart';

import '../../domain/entities/portfolio_holding.dart';

class PortfolioHoldingHive extends PortfolioHolding {
  const PortfolioHoldingHive({
    required super.uuid,
    required super.name,
    required super.symbol,
    required super.amount,
    required super.addedAt,
    super.iconUrl,
    super.buyPrice,
  });

  factory PortfolioHoldingHive.fromEntity(PortfolioHolding e) =>
      PortfolioHoldingHive(
        uuid: e.uuid,
        name: e.name,
        symbol: e.symbol,
        iconUrl: e.iconUrl,
        amount: e.amount,
        buyPrice: e.buyPrice,
        addedAt: e.addedAt,
      );
}

class PortfolioHoldingAdapter extends TypeAdapter<PortfolioHoldingHive> {
  @override
  final int typeId = 2;

  @override
  PortfolioHoldingHive read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return PortfolioHoldingHive(
      uuid: fields[0] as String,
      name: fields[1] as String,
      symbol: fields[2] as String,
      iconUrl: fields[3] as String?,
      amount: (fields[4] as num).toDouble(),
      buyPrice: (fields[5] as num?)?.toDouble(),
      addedAt: DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
    );
  }

  @override
  void write(BinaryWriter writer, PortfolioHoldingHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.symbol)
      ..writeByte(3)
      ..write(obj.iconUrl)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.buyPrice)
      ..writeByte(6)
      ..write(obj.addedAt.millisecondsSinceEpoch);
  }
}
