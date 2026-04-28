import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/favorite_coin.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';
import '../datasources/favorites_remote_datasource.dart';
import '../models/favorite_coin_hive.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource _local;
  final FavoritesRemoteDataSource? _remote;
  final Logger _log = Logger();
  String? _userId;
  StreamSubscription<List<FavoriteCoin>>? _remoteSub;

  FavoritesRepositoryImpl(this._local, [this._remote]);

  @override
  Future<Either<Failure, void>> open(String userId) async {
    try {
      await _local.open(userId);
      _userId = userId;
      unawaited(_bootstrapRemote(userId));
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  Future<void> _bootstrapRemote(String userId) async {
    final remote = _remote;
    if (remote == null) return;
    try {
      final remoteList = await remote.fetchAll(userId);
      final localList = _local.getAll();

      // Merge: remote canonical for items it owns; push local-only items.
      for (final r in remoteList) {
        await _local.upsertEntity(FavoriteCoinHive.fromEntity(r));
      }
      for (final l in localList) {
        if (!remoteList.any((r) => r.uuid == l.uuid)) {
          unawaited(remote.upsert(userId, l));
        }
      }

      await _remoteSub?.cancel();
      _remoteSub = remote.watch(userId).listen((list) async {
        final remoteUuids = list.map((e) => e.uuid).toSet();
        for (final r in list) {
          await _local.upsertEntity(FavoriteCoinHive.fromEntity(r));
        }
        for (final l in _local.getAll()) {
          if (!remoteUuids.contains(l.uuid)) {
            await _local.removeByUuid(l.uuid);
          }
        }
      });
    } catch (e) {
      _log.w('favorites remote bootstrap failed: $e');
    }
  }

  @override
  Future<Either<Failure, void>> close() async {
    try {
      await _remoteSub?.cancel();
      _remoteSub = null;
      _remote?.disposeChannel();
      await _local.close();
      _userId = null;
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<FavoriteCoin>>> getAll() async {
    try {
      return Right(_local.getAll());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Stream<List<FavoriteCoin>> watchAll() => _local.watchAll();

  @override
  Future<Either<Failure, bool>> toggle(FavoriteCoin coin) async {
    try {
      final hive = FavoriteCoinHive.fromEntity(coin);
      final added = await _local.toggle(hive);
      final uid = _userId;
      if (_remote != null && uid != null) {
        if (added) {
          unawaited(_remote.upsert(uid, coin));
        } else {
          unawaited(_remote.delete(uid, coin.uuid));
        }
      }
      return Right(added);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(
      String uuid, String? category) async {
    try {
      await _local.updateCategory(uuid, category);
      final uid = _userId;
      if (_remote != null && uid != null) {
        unawaited(_remote.updateCategory(uid, uuid, category));
      }
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
