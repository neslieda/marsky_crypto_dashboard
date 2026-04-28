import 'dart:async';

import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/portfolio_holding_hive.dart';

abstract class PortfolioLocalDataSource {
  Future<void> open(String userId);
  Future<void> close();
  List<PortfolioHoldingHive> getAll();
  Stream<List<PortfolioHoldingHive>> watchAll();
  Future<void> upsert(PortfolioHoldingHive holding);
  Future<void> remove(String uuid);
}

class PortfolioLocalDataSourceImpl implements PortfolioLocalDataSource {
  Box<PortfolioHoldingHive>? _box;

  @override
  Future<void> open(String userId) async {
    final boxName = 'portfolio_$userId';
    if (_box != null && _box!.isOpen && _box!.name == boxName) return;
    await _box?.close();
    try {
      _box = await Hive.openBox<PortfolioHoldingHive>(boxName);
    } catch (e) {
      throw CacheException('Failed to open portfolio: $e');
    }
  }

  @override
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  Box<PortfolioHoldingHive> _requireBox() {
    final b = _box;
    if (b == null || !b.isOpen) {
      throw const CacheException('Portfolio box is not open.');
    }
    return b;
  }

  @override
  List<PortfolioHoldingHive> getAll() {
    final list = _requireBox().values.toList();
    list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return list;
  }

  @override
  Stream<List<PortfolioHoldingHive>> watchAll() async* {
    final box = _requireBox();
    yield getAll();
    yield* box.watch().map((_) => getAll());
  }

  @override
  Future<void> upsert(PortfolioHoldingHive holding) async {
    await _requireBox().put(holding.uuid, holding);
  }

  @override
  Future<void> remove(String uuid) async {
    await _requireBox().delete(uuid);
  }
}
