import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/coin_detail.dart';
import '../../domain/entities/coin_sort.dart';
import '../../domain/usecases/get_coin_detail.dart';
import '../../domain/usecases/get_coin_history.dart';

part 'coin_detail_event.dart';
part 'coin_detail_state.dart';

class _HistoryCacheEntry {
  final List<CoinHistoryPoint> history;
  final DateTime fetchedAt;
  _HistoryCacheEntry(this.history, this.fetchedAt);
}

class CoinDetailBloc extends Bloc<CoinDetailEvent, CoinDetailState> {
  final GetCoinDetail getCoinDetail;
  final GetCoinHistory getCoinHistory;

  static final Map<String, _HistoryCacheEntry> _historyCache = {};
  static const Duration _ttl = Duration(seconds: 60);

  static String _key(String uuid, CoinHistoryPeriod p) => '$uuid:${p.apiValue}';

  CoinDetailBloc({
    required this.getCoinDetail,
    required this.getCoinHistory,
  }) : super(const CoinDetailState()) {
    on<CoinDetailOpened>(_onOpened);
    on<CoinDetailPeriodChanged>(_onPeriodChanged);
  }

  List<CoinHistoryPoint>? _cached(String uuid, CoinHistoryPeriod p) {
    final entry = _historyCache[_key(uuid, p)];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.fetchedAt) > _ttl) {
      _historyCache.remove(_key(uuid, p));
      return null;
    }
    return entry.history;
  }

  void _store(String uuid, CoinHistoryPeriod p, List<CoinHistoryPoint> h) {
    _historyCache[_key(uuid, p)] = _HistoryCacheEntry(h, DateTime.now());
  }

  void _prefetchOtherPeriods(String uuid, CoinHistoryPeriod skip) {
    for (final p in CoinHistoryPeriod.values) {
      if (p == skip) continue;
      if (_cached(uuid, p) != null) continue;
      // fire-and-forget
      getCoinHistory(uuid: uuid, period: p).then((res) {
        res.fold((_) {}, (h) => _store(uuid, p, h));
      });
    }
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
    final cached = _cached(event.uuid, state.period);
    final detailFuture = getCoinDetail(event.uuid);
    final historyFuture = cached != null
        ? Future.value(null)
        : getCoinHistory(uuid: event.uuid, period: state.period);
    final detailResult = await detailFuture;
    final historyResult = await historyFuture;
    detailResult.fold(
      (failure) => emit(state.copyWith(
        status: CoinDetailStatus.failure,
        errorMessage: failure.message,
      )),
      (detail) {
        if (cached != null) {
          emit(state.copyWith(
            status: CoinDetailStatus.success,
            detail: detail,
            history: cached,
          ));
          _prefetchOtherPeriods(event.uuid, state.period);
          return;
        }
        historyResult!.fold(
          (failure) => emit(state.copyWith(
            status: CoinDetailStatus.failure,
            detail: detail,
            errorMessage: failure.message,
          )),
          (history) {
            _store(event.uuid, state.period, history);
            emit(state.copyWith(
              status: CoinDetailStatus.success,
              detail: detail,
              history: history,
            ));
            _prefetchOtherPeriods(event.uuid, state.period);
          },
        );
      },
    );
  }

  Future<void> _onPeriodChanged(
    CoinDetailPeriodChanged event,
    Emitter<CoinDetailState> emit,
  ) async {
    if (state.uuid == null) return;
    final cached = _cached(state.uuid!, event.period);
    if (cached != null) {
      emit(state.copyWith(
        period: event.period,
        history: cached,
        historyLoading: false,
        errorMessage: null,
      ));
      return;
    }
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
      (history) {
        _store(state.uuid!, event.period, history);
        emit(state.copyWith(
          historyLoading: false,
          history: history,
        ));
      },
    );
  }

  static void clearHistoryCache() => _historyCache.clear();
}
