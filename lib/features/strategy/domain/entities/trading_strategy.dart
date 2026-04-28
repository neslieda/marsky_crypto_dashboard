import 'package:equatable/equatable.dart';

enum StrategyStyle { conservative, balanced, aggressive }

enum StrategyHorizon { short, medium, long }

extension StrategyStyleX on StrategyStyle {
  String get label => switch (this) {
        StrategyStyle.conservative => 'Conservative',
        StrategyStyle.balanced => 'Balanced',
        StrategyStyle.aggressive => 'Aggressive',
      };
}

extension StrategyHorizonX on StrategyHorizon {
  String get label => switch (this) {
        StrategyHorizon.short => 'Short term (days/weeks)',
        StrategyHorizon.medium => 'Medium term (1-6 months)',
        StrategyHorizon.long => 'Long term (6+ months)',
      };
}

class TradingStrategy extends Equatable {
  final String id;
  final String name;
  final StrategyStyle style;
  final StrategyHorizon horizon;

  /// Maximum percentage of portfolio that may sit in a single coin.
  final double maxAllocationPerCoinPct;

  /// Stop-loss threshold (percent below entry). Null disables.
  final double? stopLossPct;

  /// Take-profit threshold (percent above entry). Null disables.
  final double? takeProfitPct;

  /// Free-form: when does the user want to BUY? (e.g. "RSI<30, dip on 7d chart").
  final String buyConditions;

  /// Free-form: when does the user want to SELL? (e.g. "+25% gain or trend break").
  final String sellConditions;

  /// Optional notes (avoided coins, sectors, max drawdown tolerance, etc.).
  final String notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  const TradingStrategy({
    required this.id,
    required this.name,
    required this.style,
    required this.horizon,
    required this.maxAllocationPerCoinPct,
    required this.buyConditions,
    required this.sellConditions,
    required this.createdAt,
    required this.updatedAt,
    this.stopLossPct,
    this.takeProfitPct,
    this.notes = '',
  });

  TradingStrategy copyWith({
    String? name,
    StrategyStyle? style,
    StrategyHorizon? horizon,
    double? maxAllocationPerCoinPct,
    double? stopLossPct,
    double? takeProfitPct,
    String? buyConditions,
    String? sellConditions,
    String? notes,
    DateTime? updatedAt,
  }) =>
      TradingStrategy(
        id: id,
        name: name ?? this.name,
        style: style ?? this.style,
        horizon: horizon ?? this.horizon,
        maxAllocationPerCoinPct:
            maxAllocationPerCoinPct ?? this.maxAllocationPerCoinPct,
        stopLossPct: stopLossPct ?? this.stopLossPct,
        takeProfitPct: takeProfitPct ?? this.takeProfitPct,
        buyConditions: buyConditions ?? this.buyConditions,
        sellConditions: sellConditions ?? this.sellConditions,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'style': style.name,
        'horizon': horizon.name,
        'maxAllocationPerCoinPct': maxAllocationPerCoinPct,
        'stopLossPct': stopLossPct,
        'takeProfitPct': takeProfitPct,
        'buyConditions': buyConditions,
        'sellConditions': sellConditions,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory TradingStrategy.fromJson(Map<String, dynamic> j) => TradingStrategy(
        id: j['id'] as String,
        name: j['name'] as String,
        style: StrategyStyle.values
            .firstWhere((e) => e.name == j['style'], orElse: () => StrategyStyle.balanced),
        horizon: StrategyHorizon.values
            .firstWhere((e) => e.name == j['horizon'], orElse: () => StrategyHorizon.medium),
        maxAllocationPerCoinPct:
            (j['maxAllocationPerCoinPct'] as num).toDouble(),
        stopLossPct: (j['stopLossPct'] as num?)?.toDouble(),
        takeProfitPct: (j['takeProfitPct'] as num?)?.toDouble(),
        buyConditions: j['buyConditions'] as String? ?? '',
        sellConditions: j['sellConditions'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );

  @override
  List<Object?> get props => [
        id,
        name,
        style,
        horizon,
        maxAllocationPerCoinPct,
        stopLossPct,
        takeProfitPct,
        buyConditions,
        sellConditions,
        notes,
        updatedAt,
      ];
}
