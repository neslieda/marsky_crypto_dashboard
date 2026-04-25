import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marsky_crypto_dashboard/core/error/failures.dart';
import 'package:marsky_crypto_dashboard/features/auth/domain/entities/auth_user.dart';
import 'package:marsky_crypto_dashboard/features/auth/domain/usecases/get_current_user.dart';
import 'package:marsky_crypto_dashboard/features/auth/domain/usecases/sign_in.dart';
import 'package:marsky_crypto_dashboard/features/auth/domain/usecases/sign_out.dart';
import 'package:marsky_crypto_dashboard/features/auth/domain/usecases/sign_up.dart';
import 'package:marsky_crypto_dashboard/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:marsky_crypto_dashboard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockSignIn extends Mock implements SignIn {}

class _MockSignUp extends Mock implements SignUp {}

class _MockSignOut extends Mock implements SignOut {}

class _MockWatchAuthState extends Mock implements WatchAuthState {}

class _MockGetCurrentUser extends Mock implements GetCurrentUser {}

void main() {
  late _MockSignIn signIn;
  late _MockSignUp signUp;
  late _MockSignOut signOut;
  late _MockWatchAuthState watchAuthState;
  late _MockGetCurrentUser getCurrentUser;

  const user = AuthUser(id: 'u1', email: 'a@b.com');

  setUp(() {
    signIn = _MockSignIn();
    signUp = _MockSignUp();
    signOut = _MockSignOut();
    watchAuthState = _MockWatchAuthState();
    getCurrentUser = _MockGetCurrentUser();
    when(() => watchAuthState()).thenAnswer((_) => const Stream.empty());
  });

  AuthBloc build() => AuthBloc(
        signIn: signIn,
        signUp: signUp,
        signOut: signOut,
        watchAuthState: watchAuthState,
        getCurrentUser: getCurrentUser,
      );

  test('initial state is unknown', () {
    expect(build().state.status, AuthStatus.unknown);
  });

  group('AuthStarted', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated when current user exists',
      setUp: () => when(() => getCurrentUser()).thenReturn(user),
      build: build,
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        const AuthState.authenticated(user),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated when no current user',
      setUp: () => when(() => getCurrentUser()).thenReturn(null),
      build: build,
      act: (bloc) => bloc.add(const AuthStarted()),
      expect: () => [
        const AuthState.unauthenticated(),
      ],
    );
  });

  group('AuthSignInRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticating then authenticated on success',
      setUp: () {
        when(
          () => signIn(email: any(named: 'email'), password: any(named: 'password')),
        ).thenAnswer((_) async => const Right(user));
      },
      build: build,
      act: (bloc) => bloc.add(
        const AuthSignInRequested(email: 'a@b.com', password: 'pass'),
      ),
      expect: () => [
        const AuthState.authenticating(),
        const AuthState.authenticated(user),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits authenticating then error on failure',
      setUp: () {
        when(
          () => signIn(email: any(named: 'email'), password: any(named: 'password')),
        ).thenAnswer((_) async => const Left(AuthFailure('bad creds')));
      },
      build: build,
      act: (bloc) => bloc.add(
        const AuthSignInRequested(email: 'a@b.com', password: 'wrong'),
      ),
      expect: () => [
        const AuthState.authenticating(),
        const AuthState.error('bad creds'),
      ],
    );
  });

  group('AuthSignUpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits authenticated on success',
      setUp: () {
        when(
          () => signUp(email: any(named: 'email'), password: any(named: 'password')),
        ).thenAnswer((_) async => const Right(user));
      },
      build: build,
      act: (bloc) => bloc.add(
        const AuthSignUpRequested(email: 'a@b.com', password: 'pass'),
      ),
      expect: () => [
        const AuthState.authenticating(),
        const AuthState.authenticated(user),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits error on failure',
      setUp: () {
        when(
          () => signUp(email: any(named: 'email'), password: any(named: 'password')),
        ).thenAnswer((_) async => const Left(ServerFailure('taken')));
      },
      build: build,
      act: (bloc) => bloc.add(
        const AuthSignUpRequested(email: 'a@b.com', password: 'pass'),
      ),
      expect: () => [
        const AuthState.authenticating(),
        const AuthState.error('taken'),
      ],
    );
  });

  group('AuthSignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits unauthenticated on success',
      setUp: () => when(() => signOut()).thenAnswer((_) async => const Right(null)),
      build: build,
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [
        const AuthState.unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits error on failure',
      setUp: () => when(() => signOut())
          .thenAnswer((_) async => const Left(UnknownFailure('oops'))),
      build: build,
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [
        const AuthState.error('oops'),
      ],
    );
  });
}
