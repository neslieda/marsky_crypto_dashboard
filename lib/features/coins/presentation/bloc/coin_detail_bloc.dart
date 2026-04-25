import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/coin_detail.dart';
import '../../domain/entities/coin_sort.dart';
import '../../domain/usecases/get_coin_detail.dart';
import '../../domain/usecases/get_coin_history.dart';

part 'coin_detail_event.dart';
part 'coin_detail_state.dart';

class CoinDetailBloc extends Bloc<CoinDetailEvent, CoinDetailState> {
  final GetCoinDetail getCoinDetail;
  final GetCoinHistory getCoinHistory;

  CoinDetailBloc({
    required this.getCoinDetail,
    required this.getCoinHistory,
  }) : super(const CoinDetailState()) {
    on<CoinDetailOpened>(_onOpened);
    on<CoinDetailPeriodChanged>(_onPeriodChanged);
  }

  Future<void> _onOpened(
    CoinDetailOpened event,
    Emitter<CoinDetailState> emit,
  ) async {
    emit(state.copyWith(
      status: CoinDetailStatus.loading,
      uuid: event.uuid,
      errorMessage: null,
    ));
    final detailResult = await getCoinDetail(event.uuid);
    final historyResult = await getCoinHistory(
      uuid: event.uuid,
      period: state.period,
    );
    detailResult.fold(
      (failure) => emit(state.copyWith(
        status: CoinDetailStatus.failure,
        errorMessage: failure.message,
      )),
      (detail) {
        historyResult.fold(
          (failure) => emit(state.copyWith(
            status: CoinDetailStatus.failure,
            detail: detail,
            errorMessage: failure.message,
          )),
          (history) => emit(state.copyWith(
            status: CoinDetailStatus.success,
            detail: detail,
            history: history,
          )),
        );
      },
    );
  }

  Future<void> _onPeriodChanged(
    CoinDetailPeriodChanged event,
    Emitter<CoinDetailState> emit,
  ) async {
    if (state.uuid == null) return;
    emit(state.copyWith(
      period: event.period,
      historyLoading: true,
      errorMessage: null,
    ));
    final result = await getCoinHistory(
      uuid: state.uuid!,
      period: event.period,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        historyLoading: false,
        errorMessage: failure.message,
      )),
      (history) => emit(state.copyWith(
        historyLoading: false,
        history: history,
      )),
    );
  }
}
