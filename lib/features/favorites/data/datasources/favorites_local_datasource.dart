import 'dart:async';

import 'package:hive/hive.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/favorite_coin_hive.dart';

abstract class FavoritesLocalDataSource {
  Future<void> open(String userId);
  Future<void> close();
  List<FavoriteCoinHive> getAll();
  Stream<List<FavoriteCoinHive>> watchAll();
  Future<bool> toggle(FavoriteCoinHive coin);
  Future<void> updateCategory(String uuid, String? category);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  Box<FavoriteCoinHive>? _box;

  @override
  Future<void> open(String userId) async {
    final boxName = '${AppConstants.favoritesBoxPrefix}$userId';
    if (_box != null && _box!.isOpen && _box!.name == boxName) return;
    await _box?.close();
    try {
      _box = await Hive.openBox<FavoriteCoinHive>(boxName);
    } catch (e) {
      throw CacheException('Failed to open favorites: $e');
    }
  }

  @override
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  Box<FavoriteCoinHive> _requireBox() {
    final b = _box;
    if (b == null || !b.isOpen) {
      throw const CacheException('Favorites box is not open.');
    }
    return b;
  }

  @override
  List<FavoriteCoinHive> getAll() {
    final box = _requireBox();
    final list = box.values.toList();
    list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return list;
  }

  @override
  Stream<List<FavoriteCoinHive>> watchAll() async* {
    final box = _requireBox();
    yield getAll();
    yield* box.watch().map((_) => getAll());
  }

  @override
  Future<bool> toggle(FavoriteCoinHive coin) async {
    final box = _requireBox();
    if (box.containsKey(coin.uuid)) {
      await box.delete(coin.uuid);
      return false;
    }
    await box.put(coin.uuid, coin);
    return true;
  }

  @override
  Future<void> updateCategory(String uuid, String? category) async {
    final box = _requireBox();
    final existing = box.get(uuid);
    if (existing == null) return;
    final updated = FavoriteCoinHive(
      uuid: existing.uuid,
      name: existing.name,
      symbol: existing.symbol,
      iconUrl: existing.iconUrl,
      addedAt: existing.addedAt,
      category: category,
    );
    await box.put(uuid, updated);
  }
}
