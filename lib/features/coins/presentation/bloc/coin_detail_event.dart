part of 'coin_detail_bloc.dart';

abstract class CoinDetailEvent extends Equatable {
  const CoinDetailEvent();
  @override
  List<Object?> get props => [];
}

class CoinDetailOpened extends CoinDetailEvent {
  final String uuid;
  const CoinDetailOpened(this.uuid);
  @override
  List<Object?> get props => [uuid];
}

class CoinDetailPeriodChanged extends CoinDetailEvent {
  final CoinHistoryPeriod period;
  const CoinDetailPeriodChanged(this.period);
  @override
  List<Object?> get props => [period];
}
