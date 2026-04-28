import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../coins/domain/entities/coin.dart';
import '../../../coins/domain/entities/coin_detail.dart';
import '../../../news/domain/entities/news_item.dart';
import '../../../portfolio/domain/entities/portfolio_holding.dart';
import '../../domain/entities/ai_insight.dart';
import '../../domain/repositories/ai_repository.dart';

enum AiStatus { idle, loading, success, failure }

class AiState extends Equatable {
  final AiStatus status;
  final AiInsight? insight;
  final String? errorMessage;

  const AiState({
    this.status = AiStatus.idle,
    this.insight,
    this.errorMessage,
  });

  AiState copyWith({
    AiStatus? status,
    AiInsight? insight,
    String? errorMessage,
  }) =>
      AiState(
        status: status ?? this.status,
        insight: insight ?? this.insight,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, insight, errorMessage];
}

class AiCubit extends Cubit<AiState> {
  final AiRepository _repository;
  AiCubit(this._repository) : super(const AiState());

  Future<void> analyzeCoin({
    required CoinDetail coin,
    required List<CoinHistoryPoint> history,
    required String languageCode,
  }) async {
    emit(state.copyWith(status: AiStatus.loading, errorMessage: null));
    final res = await _repository.analyzeCoin(
      coin: coin,
      history: history,
      languageCode: languageCode,
    );
    res.fold(
      (f) => emit(AiState(status: AiStatus.failure, errorMessage: f.message)),
      (i) => emit(AiState(status: AiStatus.success, insight: i)),
    );
  }

  Future<void> advisePortfolio({
    required List<PortfolioHolding> holdings,
    required Map<String, CoinDetail> coins,
    required String languageCode,
  }) async {
    emit(state.copyWith(status: AiStatus.loading, errorMessage: null));
    final res = await _repository.advisePortfolio(
      holdings: holdings,
      coins: coins,
      languageCode: languageCode,
    );
    res.fold(
      (f) => emit(AiState(status: AiStatus.failure, errorMessage: f.message)),
      (i) => emit(AiState(status: AiStatus.success, insight: i)),
    );
  }

  Future<void> summarizeNews({
    required List<NewsItem> items,
    required String languageCode,
  }) async {
    emit(state.copyWith(status: AiStatus.loading, errorMessage: null));
    final res = await _repository.summarizeNews(
      items: items,
      languageCode: languageCode,
    );
    res.fold(
      (f) => emit(AiState(status: AiStatus.failure, errorMessage: f.message)),
      (i) => emit(AiState(status: AiStatus.success, insight: i)),
    );
  }

  void reset() => emit(const AiState());
}
