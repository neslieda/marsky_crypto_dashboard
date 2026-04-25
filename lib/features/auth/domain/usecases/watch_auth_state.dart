import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthState {
  final AuthRepository repository;
  WatchAuthState(this.repository);

  Stream<AuthUser?> call() => repository.authStateChanges();
}
