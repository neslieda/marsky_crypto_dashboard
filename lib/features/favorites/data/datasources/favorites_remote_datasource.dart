import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/favorite_coin.dart';

abstract class FavoritesRemoteDataSource {
  Future<List<FavoriteCoin>> fetchAll(String userId);
  Future<void> upsert(String userId, FavoriteCoin coin);
  Future<void> delete(String userId, String uuid);
  Future<void> updateCategory(String userId, String uuid, String? category);
  Stream<List<FavoriteCoin>> watch(String userId);
  void disposeChannel();
}

class SupabaseFavoritesDataSource implements FavoritesRemoteDataSource {
  final SupabaseClient _client;
  RealtimeChannel? _channel;
  StreamController<List<FavoriteCoin>>? _controller;

  SupabaseFavoritesDataSource(this._client);

  static const String _table = 'favorites';

  FavoriteCoin _fromRow(Map<String, dynamic> row) => FavoriteCoin(
        uuid: row['uuid'] as String,
        name: row['name'] as String,
        symbol: row['symbol'] as String,
        iconUrl: row['icon_url'] as String?,
        addedAt: DateTime.parse(row['added_at'] as String),
        category: row['category'] as String?,
      );

  Map<String, dynamic> _toRow(String userId, FavoriteCoin c) => {
        'user_id': userId,
        'uuid': c.uuid,
        'name': c.name,
        'symbol': c.symbol,
        'icon_url': c.iconUrl,
        'added_at': c.addedAt.toUtc().toIso8601String(),
        'category': c.category,
      };

  @override
  Future<List<FavoriteCoin>> fetchAll(String userId) async {
    try {
      final res = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('added_at', ascending: false);
      return (res as List)
          .cast<Map<String, dynamic>>()
          .map(_fromRow)
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch favorites: $e');
    }
  }

  @override
  Future<void> upsert(String userId, FavoriteCoin coin) async {
    try {
      await _client.from(_table).upsert(_toRow(userId, coin));
    } catch (e) {
      throw ServerException('Failed to sync favorite: $e');
    }
  }

  @override
  Future<void> delete(String userId, String uuid) async {
    try {
      await _client
          .from(_table)
          .delete()
          .eq('user_id', userId)
          .eq('uuid', uuid);
    } catch (e) {
      throw ServerException('Failed to remove remote favorite: $e');
    }
  }

  @override
  Future<void> updateCategory(
      String userId, String uuid, String? category) async {
    try {
      await _client
          .from(_table)
          .update({'category': category})
          .eq('user_id', userId)
          .eq('uuid', uuid);
    } catch (e) {
      throw ServerException('Failed to update category remotely: $e');
    }
  }

  @override
  Stream<List<FavoriteCoin>> watch(String userId) {
    disposeChannel();
    final ctrl = StreamController<List<FavoriteCoin>>.broadcast();
    _controller = ctrl;

    Future<void> emitSnapshot() async {
      try {
        ctrl.add(await fetchAll(userId));
      } catch (_) {/* swallow; local-first */}
    }

    _channel = _client
        .channel('public:favorites:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => emitSnapshot(),
        )
        .subscribe();

    emitSnapshot();
    return ctrl.stream;
  }

  @override
  void disposeChannel() {
    _channel?.unsubscribe();
    _channel = null;
    _controller?.close();
    _controller = null;
  }
}
