part of 'coin_detail_bloc.dart';

enum CoinDetailStatus { initial, loading, success, failure }

class CoinDetailState extends Equatable {
  final CoinDetailStatus status;
  final String? uuid;
  final CoinDetail? detail;
  final List<CoinHistoryPoint> history;
  final CoinHistoryPeriod period;
  final bool historyLoading;
  final String? errorMessage;

  const CoinDetailState({
    this.status = CoinDetailStatus.initial,
    this.uuid,
    this.detail,
    this.history = const [],
    this.period = CoinHistoryPeriod.h24,
    this.historyLoading = false,
    this.errorMessage,
  });

  CoinDetailState copyWith({
    CoinDetailStatus? status,
    String? uuid,
    CoinDetail? detail,
    List<CoinHistoryPoint>? history,
    CoinHistoryPeriod? period,
    bool? historyLoading,
    String? errorMessage,
  }) {
    return CoinDetailState(
      status: status ?? this.status,
      uuid: uuid ?? this.uuid,
      detail: detail ?? this.detail,
      history: history ?? this.history,
      period: period ?? this.period,
      historyLoading: historyLoading ?? this.historyLoading,
      errorMessage: errorMessage,
    );
  }

  double? get highest {
    final prices = history
        .map((e) => e.price)
        .whereType<double>()
        .toList();
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a > b ? a : b);
  }

  double? get lowest {
    final prices = history
        .map((e) => e.price)
        .whereType<double>()
        .toList();
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  @override
  List<Object?> get props => [
        status,
        uuid,
        detail,
        history,
        period,
        historyLoading,
        errorMessage,
      ];
}
