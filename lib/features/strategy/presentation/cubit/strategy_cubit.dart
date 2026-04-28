import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/trading_strategy.dart';
import '../../domain/repositories/strategy_repository.dart';

class StrategyState extends Equatable {
  final List<TradingStrategy> strategies;
  final TradingStrategy? active;
  final bool ready;
  final String? errorMessage;

  const StrategyState({
    this.strategies = const [],
    this.active,
    this.ready = false,
    this.errorMessage,
  });

  StrategyState copyWith({
    List<TradingStrategy>? strategies,
    TradingStrategy? active,
    bool clearActive = false,
    bool? ready,
    String? errorMessage,
  }) =>
      StrategyState(
        strategies: strategies ?? this.strategies,
        active: clearActive ? null : (active ?? this.active),
        ready: ready ?? this.ready,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [strategies, active, ready, errorMessage];
}

class StrategyCubit extends Cubit<StrategyState> {
  final StrategyRepository _repository;
  StreamSubscription? _subAll;
  StreamSubscription? _subActive;

  StrategyCubit(this._repository) : super(const StrategyState());

  Future<void> bootstrap(String userId) async {
    await _repository.open(userId);
    emit(state.copyWith(
      strategies: _repository.getAll(),
      active: _repository.active,
      clearActive: _repository.active == null,
      ready: true,
    ));
    await _subAll?.cancel();
    _subAll = _repository.watchAll().listen(
          (list) => emit(state.copyWith(strategies: list)),
        );
    await _subActive?.cancel();
    _subActive = _repository.watchActive().listen((s) =>
        emit(state.copyWith(active: s, clearActive: s == null)));
  }

  Future<void> save(TradingStrategy s) async {
    final res = await _repository.upsert(s);
    res.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (_) {},
    );
  }

  Future<void> delete(String id) async {
    await _repository.remove(id);
  }

  Future<void> setActive(String? id) async {
    await _repository.setActive(id);
  }

  @override
  Future<void> close() async {
    await _subAll?.cancel();
    await _subActive?.cancel();
    return super.close();
  }
}
