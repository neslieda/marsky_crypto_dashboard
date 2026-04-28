import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../ai/domain/repositories/ai_repository.dart';
import '../../../coins/domain/entities/coin_detail.dart';
import '../../domain/entities/strategy_signal.dart';
import '../../domain/entities/trading_strategy.dart';

enum SignalStatus { idle, loading, success, failure }

class SignalState extends Equatable {
  final SignalStatus status;
  final StrategySignal? signal;
  final String? errorMessage;

  const SignalState({
    this.status = SignalStatus.idle,
    this.signal,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, signal, errorMessage];
}

class StrategySignalCubit extends Cubit<SignalState> {
  final AiRepository _ai;
  StrategySignalCubit(this._ai) : super(const SignalState());

  Future<void> evaluate({
    required TradingStrategy strategy,
    required CoinDetail coin,
    required List<CoinHistoryPoint> history,
    double? currentHoldingAmount,
    double? averageBuyPrice,
    double? totalPortfolioValue,
    required String languageCode,
  }) async {
    emit(const SignalState(status: SignalStatus.loading));
    final res = await _ai.evaluateStrategy(
      strategy: strategy,
      coin: coin,
      history: history,
      currentHoldingAmount: currentHoldingAmount,
      averageBuyPrice: averageBuyPrice,
      totalPortfolioValue: totalPortfolioValue,
      languageCode: languageCode,
    );
    res.fold(
      (f) => emit(SignalState(
          status: SignalStatus.failure, errorMessage: f.message)),
      (s) => emit(SignalState(status: SignalStatus.success, signal: s)),
    );
  }

  void reset() => emit(const SignalState());
}
