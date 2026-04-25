import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  AuthUser? call() => repository.currentUser;
}
