part of 'coins_list_bloc.dart';

enum CoinsListStatus { initial, loading, loadingMore, success, failure }

class CoinsListState extends Equatable {
  final CoinsListStatus status;
  final List<Coin> coins;
  final bool hasMore;
  final int total;
  final CoinSortBy sortBy;
  final CoinSortDirection direction;
  final String? errorMessage;

  const CoinsListState({
    this.status = CoinsListStatus.initial,
    this.coins = const [],
    this.hasMore = true,
    this.total = 0,
    this.sortBy = CoinSortBy.marketCap,
    this.direction = CoinSortDirection.desc,
    this.errorMessage,
  });

  CoinsListState copyWith({
    CoinsListStatus? status,
    List<Coin>? coins,
    bool? hasMore,
    int? total,
    CoinSortBy? sortBy,
    CoinSortDirection? direction,
    String? errorMessage,
  }) {
    return CoinsListState(
      status: status ?? this.status,
      coins: coins ?? this.coins,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      sortBy: sortBy ?? this.sortBy,
      direction: direction ?? this.direction,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        coins,
        hasMore,
        total,
        sortBy,
        direction,
        errorMessage,
      ];
}
