import 'package:dio/dio.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/coin.dart';
import '../../domain/entities/coin_sort.dart';
import '../models/coin_detail_model.dart';
import '../models/coin_model.dart';

abstract class CoinsRemoteDataSource {
  Future<CoinsPage> getCoins({
    required int limit,
    required int offset,
    required CoinSortBy orderBy,
    required CoinSortDirection direction,
    String? search,
  });

  Future<CoinDetailModel> getCoinDetail(String uuid);

  Future<List<CoinHistoryPointModel>> getCoinHistory({
    required String uuid,
    required CoinHistoryPeriod period,
  });
}

class CoinsRemoteDataSourceImpl implements CoinsRemoteDataSource {
  final Dio dio;
  CoinsRemoteDataSourceImpl(this.dio);

  @override
  Future<CoinsPage> getCoins({
    required int limit,
    required int offset,
    required CoinSortBy orderBy,
    required CoinSortDirection direction,
    String? search,
  }) async {
    try {
      final res = await dio.get(
        '/coins',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'orderBy': orderBy.apiValue,
          'orderDirection': direction.apiValue,
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
      );
      final body = res.data as Map<String, dynamic>;
      _ensureSuccess(body);
      final data = body['data'] as Map<String, dynamic>;
      final stats = data['stats'] as Map<String, dynamic>?;
      final list = (data['coins'] as List).cast<Map<String, dynamic>>();
      final coins = list.map(CoinModel.fromJson).toList();
      final total = (stats?['total'] as num?)?.toInt() ?? coins.length;
      return CoinsPage(
        coins: coins,
        total: total,
        offset: offset,
        limit: limit,
      );
    } on DioException catch (e) {
      throw mapDioToException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<CoinDetailModel> getCoinDetail(String uuid) async {
    try {
      final res = await dio.get('/coin/$uuid');
      final body = res.data as Map<String, dynamic>;
      _ensureSuccess(body);
      final data = body['data'] as Map<String, dynamic>;
      final coin = data['coin'] as Map<String, dynamic>;
      return CoinDetailModel.fromJson(coin);
    } on DioException catch (e) {
      throw mapDioToException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CoinHistoryPointModel>> getCoinHistory({
    required String uuid,
    required CoinHistoryPeriod period,
  }) async {
    try {
      final res = await dio.get(
        '/coin/$uuid/history',
        queryParameters: {'timePeriod': period.apiValue},
      );
      final body = res.data as Map<String, dynamic>;
      _ensureSuccess(body);
      final data = body['data'] as Map<String, dynamic>;
      final history = (data['history'] as List).cast<Map<String, dynamic>>();
      return history
          .map(CoinHistoryPointModel.fromJson)
          .toList()
          .reversed
          .toList(); // ascending by time
    } on DioException catch (e) {
      throw mapDioToException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  void _ensureSuccess(Map<String, dynamic> body) {
    final status = body['status'];
    if (status != null && status != 'success') {
      final msg = body['message']?.toString() ?? 'Request failed.';
      throw ServerException(msg);
    }
  }
}
