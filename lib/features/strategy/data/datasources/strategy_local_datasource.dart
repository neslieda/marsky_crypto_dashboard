import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/trading_strategy.dart';

abstract class StrategyLocalDataSource {
  Future<void> open(String userId);
  Future<void> close();
  List<TradingStrategy> getAll();
  Stream<void> watchChanges();
  Future<void> upsert(TradingStrategy s);
  Future<void> remove(String id);

  String? get activeId;
  Future<void> setActiveId(String? id);
}

class StrategyLocalDataSourceImpl implements StrategyLocalDataSource {
  // Single string-keyed box: keys are strategy ids storing JSON strings.
  // Special key '__active' stores the id of the active strategy.
  Box<String>? _box;
  static const _activeKey = '__active';

  String _boxName(String userId) => 'strategies_$userId';

  @override
  Future<void> open(String userId) async {
    final name = _boxName(userId);
    if (_box != null && _box!.isOpen && _box!.name == name) return;
    await _box?.close();
    try {
      _box = await Hive.openBox<String>(name);
    } catch (e) {
      throw CacheException('Failed to open strategies: $e');
    }
  }

  @override
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  Box<String> _requireBox() {
    final b = _box;
    if (b == null || !b.isOpen) {
      throw const CacheException('Strategies box is not open.');
    }
    return b;
  }

  @override
  List<TradingStrategy> getAll() {
    final box = _requireBox();
    final out = <TradingStrategy>[];
    for (final key in box.keys) {
      if (key == _activeKey) continue;
      final raw = box.get(key);
      if (raw == null) continue;
      try {
        out.add(
          TradingStrategy.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (_) {
        // skip corrupt entries
      }
    }
    out.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return out;
  }

  @override
  Stream<void> watchChanges() {
    return _requireBox().watch().map((_) {});
  }

  @override
  Future<void> upsert(TradingStrategy s) async {
    await _requireBox().put(s.id, jsonEncode(s.toJson()));
  }

  @override
  Future<void> remove(String id) async {
    final box = _requireBox();
    await box.delete(id);
    if (box.get(_activeKey) == id) {
      await box.delete(_activeKey);
    }
  }

  @override
  String? get activeId => _box?.get(_activeKey);

  @override
  Future<void> setActiveId(String? id) async {
    final box = _requireBox();
    if (id == null) {
      await box.delete(_activeKey);
    } else {
      await box.put(_activeKey, id);
    }
  }
}
