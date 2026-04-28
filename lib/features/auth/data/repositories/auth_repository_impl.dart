import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/supabase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource);

  AuthUser _toEntity(sb.User user) =>
      AuthUser(id: user.id, email: user.email);

  @override
  AuthUser? get currentUser {
    final u = _dataSource.currentUser;
    return u == null ? null : _toEntity(u);
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _dataSource.authStateChanges().map((state) {
      final session = state.session;
      if (session == null) return null;
      return _toEntity(session.user);
    });
  }

  @override
  Future<Either<Failure, AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signIn(email: email, password: password);
      return Right(_toEntity(user));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signUp(email: email, password: password);
      return Right(_toEntity(user));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _dataSource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> resendConfirmation(String email) async {
    try {
      await _dataSource.resendConfirmation(email);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
