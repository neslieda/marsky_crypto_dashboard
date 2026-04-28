import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../coins/domain/entities/coin.dart';
import '../../../coins/domain/entities/coin_detail.dart';
import '../../../news/domain/entities/news_item.dart';
import '../../../portfolio/domain/entities/portfolio_holding.dart';
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
}
