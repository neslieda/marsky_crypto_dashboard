import 'package:dio/dio.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/news_item.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsItem>> latest();
}

/// Fetches latest crypto news from CryptoPanic public RSS-like JSON endpoint.
/// Uses the public/free `?public=true` endpoint that does not require an API key.
class CryptoPanicDataSource implements NewsRemoteDataSource {
  CryptoPanicDataSource()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://cryptopanic.com',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json'},
        ));

  final Dio _dio;

  @override
  Future<List<NewsItem>> latest() async {
    try {
      final res = await _dio.get(
        '/api/v1/posts/',
        queryParameters: {'public': 'true', 'kind': 'news'},
      );
      final body = res.data as Map<String, dynamic>;
      final results = (body['results'] as List?) ?? const [];
      return results
          .cast<Map<String, dynamic>>()
          .map(_mapPost)
          .where((n) => n != null)
          .cast<NewsItem>()
          .toList();
    } on DioException catch (e) {
      throw mapDioToException(e);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  NewsItem? _mapPost(Map<String, dynamic> p) {
    final id = p['id']?.toString();
    final title = p['title']?.toString();
    final url = p['url']?.toString();
    if (id == null || title == null || url == null) return null;
    final source = p['source'] as Map<String, dynamic>?;
    final published = p['published_at']?.toString();
    final currencies = (p['currencies'] as List?)
            ?.cast<Map<String, dynamic>>()
            .map((c) => c['code']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList() ??
        const <String>[];
    return NewsItem(
      id: id,
      title: title,
      url: url,
      sourceName: source?['title']?.toString(),
      publishedAt: published == null ? null : DateTime.tryParse(published),
      currencies: currencies,
    );
  }
}
