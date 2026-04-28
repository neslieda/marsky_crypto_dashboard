import 'package:dartz/dartz.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../coins/domain/entities/coin.dart';
import '../../../coins/domain/entities/coin_detail.dart';
import '../../../news/domain/entities/news_item.dart';
import '../../../portfolio/domain/entities/portfolio_holding.dart';
import '../../domain/entities/ai_insight.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/openai_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final OpenAiDataSource _client;
  AiRepositoryImpl(this._client);

  static const _system = '''
You are a concise, neutral crypto market analyst inside a mobile dashboard app.
Rules:
- Be factual and brief (max ~150 words).
- Never give financial advice; instead describe trends and risk factors.
- Use bullet points where it improves clarity.
- Always reply in the requested language.
- End with a one-line "Disclaimer" that this is not investment advice.
''';

  String _lang(String code) =>
      switch (code) { 'tr' => 'Turkish', _ => 'English' };

  @override
  Future<Either<Failure, AiInsight>> analyzeCoin({
    required CoinDetail coin,
    required List<CoinHistoryPoint> history,
    required String languageCode,
  }) async {
    try {
      final prices = history
          .map((h) => h.price)
          .whereType<double>()
          .toList(growable: false);
      final first = prices.isNotEmpty ? prices.first : null;
      final last = prices.isNotEmpty ? prices.last : null;
      final pct = (first != null && last != null && first != 0)
          ? ((last - first) / first) * 100
          : null;
      final hi = prices.isEmpty
          ? null
          : prices.reduce((a, b) => a > b ? a : b);
      final lo = prices.isEmpty
          ? null
          : prices.reduce((a, b) => a < b ? a : b);

      final user = '''
Analyze the following coin in ${_lang(languageCode)}:
Name: ${coin.coin.name} (${coin.coin.symbol})
Rank: ${coin.coin.rank}
Price: ${coin.coin.price}
24h change %: ${coin.coin.change}
Market cap: ${coin.coin.marketCap}
24h volume: ${coin.coin.volume24h}
All-time high: ${coin.allTimeHigh}
Number of markets: ${coin.numberOfMarkets}
History window: ${history.length} points
Period change %: ${pct?.toStringAsFixed(2)}
Period high: $hi
Period low: $lo
${(coin.description != null && coin.description!.isNotEmpty) ? "Description (truncated): ${coin.description!.substring(0, coin.description!.length.clamp(0, 400))}" : ""}

Produce a short market overview, recent trend interpretation, and 2-3 risk factors. Reply in ${_lang(languageCode)}.''';

      final out = await _client.complete(
        systemPrompt: _system,
        userPrompt: user,
      );
      return Right(AiInsight(content: out, generatedAt: DateTime.now()));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AiInsight>> advisePortfolio({
    required List<PortfolioHolding> holdings,
    required Map<String, CoinDetail> coins,
    required String languageCode,
  }) async {
    try {
      if (holdings.isEmpty) {
        return Right(AiInsight(
          content: languageCode == 'tr'
              ? 'Portföy boş. Önce bir varlık ekleyin.'
              : 'Portfolio is empty. Add a holding first.',
          generatedAt: DateTime.now(),
        ));
      }

      double totalValue = 0;
      final lines = <String>[];
      for (final h in holdings) {
        final detail = coins[h.uuid];
        final price = detail?.coin.price;
        final value = (price ?? 0) * h.amount;
        totalValue += value;
        final change = detail?.coin.change;
        lines.add(
          '- ${h.symbol} (${h.name}): amount=${h.amount}, price=$price, value=${value.toStringAsFixed(2)}, 24h%=${change?.toStringAsFixed(2)}, buyPrice=${h.buyPrice}',
        );
      }
      final concentration = StringBuffer();
      for (final h in holdings) {
        final detail = coins[h.uuid];
        final price = detail?.coin.price;
        final value = (price ?? 0) * h.amount;
        final share = totalValue > 0 ? (value / totalValue) * 100 : 0;
        concentration.writeln(
            '${h.symbol}: ${share.toStringAsFixed(1)}%');
      }

      final user = '''
Analyze the following crypto portfolio in ${_lang(languageCode)}.
Total value: ${totalValue.toStringAsFixed(2)}
Holdings:
${lines.join('\n')}

Concentration:
$concentration

Produce:
1) Portfolio summary (size, dominant assets).
2) Diversification & concentration risk.
3) Notable 24h movers in the portfolio.
4) 2-3 actionable suggestions framed as observations (not advice).

Reply in ${_lang(languageCode)}.''';

      final out = await _client.complete(
        systemPrompt: _system,
        userPrompt: user,
        maxTokens: 700,
      );
      return Right(AiInsight(content: out, generatedAt: DateTime.now()));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AiInsight>> summarizeNews({
    required List<NewsItem> items,
    required String languageCode,
  }) async {
    try {
      if (items.isEmpty) {
        return Right(AiInsight(
          content: languageCode == 'tr'
              ? 'Özetlenecek haber yok.'
              : 'No news to summarize.',
          generatedAt: DateTime.now(),
        ));
      }
      final lines = items.take(20).map((n) {
        final src = n.sourceName ?? 'Unknown';
        final coins =
            n.currencies.isEmpty ? '' : ' [${n.currencies.join(', ')}]';
        return '- ($src) ${n.title}$coins';
      }).join('\n');
      final user = '''
Summarize today's crypto news in ${_lang(languageCode)} based on the following headlines:
$lines

Produce:
1) Overall market sentiment (bullish / bearish / neutral) with reasoning.
2) 3-5 key themes.
3) Any coins mentioned multiple times.

Reply in ${_lang(languageCode)}.''';

      final out = await _client.complete(
        systemPrompt: _system,
        userPrompt: user,
        maxTokens: 700,
      );
      return Right(AiInsight(content: out, generatedAt: DateTime.now()));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
