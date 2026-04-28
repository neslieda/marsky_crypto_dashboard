import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../coins/domain/entities/coin.dart';
import '../../../coins/domain/entities/coin_detail.dart';
import '../../../news/domain/entities/news_item.dart';
import '../../../portfolio/domain/entities/portfolio_holding.dart';
import '../../../strategy/domain/entities/strategy_signal.dart';
import '../../../strategy/domain/entities/trading_strategy.dart';
import '../entities/ai_insight.dart';

abstract class AiRepository {
  Future<Either<Failure, AiInsight>> analyzeCoin({
    required CoinDetail coin,
    required List<CoinHistoryPoint> history,
    required String languageCode,
  });

  Future<Either<Failure, AiInsight>> advisePortfolio({
    required List<PortfolioHolding> holdings,
    required Map<String, CoinDetail> coins,
    required String languageCode,
  });

  Future<Either<Failure, AiInsight>> summarizeNews({
    required List<NewsItem> items,
    required String languageCode,
  });

  /// Evaluate a single coin against the user's [strategy]. Returns a
  /// structured signal (BUY/SELL/HOLD/AVOID + confidence + reasoning).
  Future<Either<Failure, StrategySignal>> evaluateStrategy({
    required TradingStrategy strategy,
    required CoinDetail coin,
    required List<CoinHistoryPoint> history,
    double? currentHoldingAmount,
    double? averageBuyPrice,
    double? totalPortfolioValue,
    required String languageCode,
  });
}
