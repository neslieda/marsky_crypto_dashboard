import 'package:equatable/equatable.dart';

enum SignalAction { buy, sell, hold, avoid }

extension SignalActionX on SignalAction {
  String get label => switch (this) {
        SignalAction.buy => 'BUY',
        SignalAction.sell => 'SELL',
        SignalAction.hold => 'HOLD',
        SignalAction.avoid => 'AVOID',
      };

  static SignalAction parse(String? raw) {
    final v = raw?.toLowerCase().trim();
    return switch (v) {
      'buy' => SignalAction.buy,
      'sell' => SignalAction.sell,
      'hold' => SignalAction.hold,
      'avoid' => SignalAction.avoid,
      _ => SignalAction.hold,
    };
  }
}

class StrategySignal extends Equatable {
  final SignalAction action;

  /// 0-100 confidence the AI assigned.
  final int confidence;

  /// Short rationale text.
  final String reasoning;

  /// Optional suggested entry / exit prices.
  final double? suggestedEntry;
  final double? suggestedExit;

  /// Optional suggested allocation (percent of portfolio) for a BUY signal.
  final double? suggestedAllocationPct;

  final DateTime generatedAt;

  const StrategySignal({
    required this.action,
    required this.confidence,
    required this.reasoning,
    required this.generatedAt,
    this.suggestedEntry,
    this.suggestedExit,
    this.suggestedAllocationPct,
  });

  factory StrategySignal.fromJson(Map<String, dynamic> j) => StrategySignal(
        action: SignalActionX.parse(j['action'] as String?),
        confidence: ((j['confidence'] as num?) ?? 50).toInt().clamp(0, 100),
        reasoning: (j['reasoning'] as String?)?.trim() ?? '',
        suggestedEntry: (j['suggestedEntry'] as num?)?.toDouble(),
        suggestedExit: (j['suggestedExit'] as num?)?.toDouble(),
        suggestedAllocationPct:
            (j['suggestedAllocationPct'] as num?)?.toDouble(),
        generatedAt: DateTime.now(),
      );

  @override
  List<Object?> get props => [
        action,
        confidence,
        reasoning,
        suggestedEntry,
        suggestedExit,
        suggestedAllocationPct,
        generatedAt,
      ];
}
