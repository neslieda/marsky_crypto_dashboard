import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthUser>> signUp({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  AuthUser? get currentUser;

  Stream<AuthUser?> authStateChanges();
}
