part of 'coins_list_bloc.dart';

abstract class CoinsListEvent extends Equatable {
  const CoinsListEvent();
  @override
  List<Object?> get props => [];
}

class CoinsListLoadRequested extends CoinsListEvent {
  const CoinsListLoadRequested();
}

class CoinsListLoadMoreRequested extends CoinsListEvent {
  const CoinsListLoadMoreRequested();
}

class CoinsListRefreshed extends CoinsListEvent {
  const CoinsListRefreshed();
}

class CoinsListSortChanged extends CoinsListEvent {
  final CoinSortBy sortBy;
  final CoinSortDirection direction;
  const CoinsListSortChanged({
    required this.sortBy,
    required this.direction,
  });

  @override
  List<Object?> get props => [sortBy, direction];
}

class CoinsListSearchChanged extends CoinsListEvent {
  final String query;
  const CoinsListSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}
