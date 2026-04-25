part of 'auth_bloc.dart';

enum AuthStatus { unknown, unauthenticated, authenticating, authenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);
  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);
  const AuthState.authenticating()
      : this._(status: AuthStatus.authenticating);
  const AuthState.authenticated(AuthUser user)
      : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.error(String message)
      : this._(status: AuthStatus.error, errorMessage: message);

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  @override
  List<Object?> get props => [status, user, errorMessage];
}
