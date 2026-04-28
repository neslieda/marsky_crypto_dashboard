import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../coins/domain/entities/coin.dart';
import '../../../coins/domain/usecases/get_coin_detail.dart';
import '../../domain/entities/portfolio_holding.dart';
import '../../domain/repositories/portfolio_repository.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();
  @override
  List<Object?> get props => const [];
}

class PortfolioOpened extends PortfolioEvent {
  final String userId;
  const PortfolioOpened(this.userId);
  @override
  List<Object?> get props => [userId];
}

class PortfolioClosed extends PortfolioEvent {
  const PortfolioClosed();
}

class PortfolioHoldingUpserted extends PortfolioEvent {
  final PortfolioHolding holding;
  const PortfolioHoldingUpserted(this.holding);
  @override
  List<Object?> get props => [holding];
}

class PortfolioHoldingRemoved extends PortfolioEvent {
  final String uuid;
  const PortfolioHoldingRemoved(this.uuid);
  @override
  List<Object?> get props => [uuid];
}

class _HoldingsChanged extends PortfolioEvent {
  final List<PortfolioHolding> list;
  const _HoldingsChanged(this.list);
  @override
  List<Object?> get props => [list];
}

class PortfolioPricesRefreshed extends PortfolioEvent {
  const PortfolioPricesRefreshed();
}

enum PortfolioStatus { initial, loading, success, failure }

class PortfolioState extends Equatable {
  final PortfolioStatus status;
  final List<PortfolioHolding> holdings;

  /// Latest known price per coin uuid (in user's currency).
  final Map<String, double> prices;
  final String? errorMessage;
  final bool refreshing;

  const PortfolioState({
    this.status = PortfolioStatus.initial,
    this.holdings = const [],
    this.prices = const {},
    this.errorMessage,
    this.refreshing = false,
  });

  double get totalValue {
    var sum = 0.0;
    for (final h in holdings) {
      final p = prices[h.uuid];
      if (p == null) continue;
      sum += p * h.amount;
    }
    return sum;
  }

  double get totalCost {
    var sum = 0.0;
    for (final h in holdings) {
      if (h.buyPrice == null) continue;
      sum += h.buyPrice! * h.amount;
    }
    return sum;
  }

  PortfolioState copyWith({
    PortfolioStatus? status,
    List<PortfolioHolding>? holdings,
    Map<String, double>? prices,
    String? errorMessage,
    bool? refreshing,
    bool clearError = false,
  }) =>
      PortfolioState(
        status: status ?? this.status,
        holdings: holdings ?? this.holdings,
        prices: prices ?? this.prices,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        refreshing: refreshing ?? this.refreshing,
      );

  @override
  List<Object?> get props =>
      [status, holdings, prices, errorMessage, refreshing];
}

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final PortfolioRepository repository;
  final GetCoinDetail getCoinDetail;

  StreamSubscription<List<PortfolioHolding>>? _sub;

  PortfolioBloc({
    required this.repository,
    required this.getCoinDetail,
  }) : super(const PortfolioState()) {
    on<PortfolioOpened>(_onOpened);
    on<PortfolioClosed>(_onClosed);
    on<PortfolioHoldingUpserted>(_onUpsert);
    on<PortfolioHoldingRemoved>(_onRemove);
    on<_HoldingsChanged>(_onHoldingsChanged);
    on<PortfolioPricesRefreshed>(_onRefresh);
  }

  Future<void> _onOpened(
      PortfolioOpened event, Emitter<PortfolioState> emit) async {
    emit(state.copyWith(status: PortfolioStatus.loading, clearError: true));
    final res = await repository.open(event.userId);
    res.fold(
      (f) => emit(state.copyWith(
          status: PortfolioStatus.failure, errorMessage: f.message)),
      (_) {
        _sub?.cancel();
        _sub = repository.watchAll().listen(
              (list) => add(_HoldingsChanged(list)),
            );
      },
    );
  }

  Future<void> _onClosed(
      PortfolioClosed event, Emitter<PortfolioState> emit) async {
    await _sub?.cancel();
    _sub = null;
    await repository.close();
    emit(const PortfolioState());
  }

  Future<void> _onUpsert(
      PortfolioHoldingUpserted event, Emitter<PortfolioState> emit) async {
    final res = await repository.upsert(event.holding);
    res.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (_) {},
    );
  }

  Future<void> _onRemove(
      PortfolioHoldingRemoved event, Emitter<PortfolioState> emit) async {
    final res = await repository.remove(event.uuid);
    res.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (_) {},
    );
  }

  Future<void> _onHoldingsChanged(
      _HoldingsChanged event, Emitter<PortfolioState> emit) async {
    emit(state.copyWith(
      status: PortfolioStatus.success,
      holdings: event.list,
      clearError: true,
    ));
    await _refreshPrices(event.list, emit);
  }

  Future<void> _onRefresh(
      PortfolioPricesRefreshed event, Emitter<PortfolioState> emit) async {
    await _refreshPrices(state.holdings, emit);
  }

  Future<void> _refreshPrices(
      List<PortfolioHolding> list, Emitter<PortfolioState> emit) async {
    if (list.isEmpty) {
      emit(state.copyWith(prices: const {}, refreshing: false));
      return;
    }
    emit(state.copyWith(refreshing: true));
    final next = Map<String, double>.from(state.prices);
    for (final h in list) {
      final res = await getCoinDetail(h.uuid);
      res.fold((_) {}, (d) {
        if (d.coin.price != null) next[h.uuid] = d.coin.price!;
      });
    }
    emit(state.copyWith(prices: next, refreshing: false));
  }

  // Helper for UI to read coin price snapshot.
  // ignore: unused_element
  Coin? _coinFor(String _) => null;

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
