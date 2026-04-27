import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';

/// Builds a Dio cache interceptor that stores GET responses for ~5 minutes
/// to enable an offline-friendly experience.
class HttpCache {
  HttpCache._();

  static Future<DioCacheInterceptor> build({String? hivePath}) async {
    final CacheStore store;
    if (kIsWeb) {
      // HiveCacheStore needs a directory path; on web fall back to memory.
      store = MemCacheStore();
    } else {
      store = HiveCacheStore(hivePath, hiveBoxName: 'http_cache');
    }
    final options = CacheOptions(
      store: store,
      policy: CachePolicy.request,
      maxStale: const Duration(days: 1),
      priority: CachePriority.normal,
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      allowPostMethod: false,
    );
    return DioCacheInterceptor(options: options);
  }
}
