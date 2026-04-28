import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/resend_confirmation.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/watch_auth_state.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;
  final WatchAuthState watchAuthState;
  final GetCurrentUser getCurrentUser;
  final ResetPassword resetPassword;
  final ResendConfirmation resendConfirmation;

  StreamSubscription<AuthUser?>? _authSub;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.watchAuthState,
    required this.getCurrentUser,
    required this.resetPassword,
    required this.resendConfirmation,
  }) : super(const AuthState.unknown()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthResendConfirmationRequested>(_onResendConfirmation);
    on<_AuthUserChanged>(_onUserChanged);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final current = getCurrentUser();
    if (current != null) {
      emit(AuthState.authenticated(current));
    } else {
      emit(const AuthState.unauthenticated());
    }
    await _authSub?.cancel();
    _authSub = watchAuthState().listen(
      (user) => add(_AuthUserChanged(user)),
    );
  }

  void _onUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user == null) {
      emit(const AuthState.unauthenticated());
    } else {
      emit(AuthState.authenticated(event.user!));
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.authenticating());
    final result = await signIn(email: event.email, password: event.password);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.authenticating());
    final result = await signUp(email: event.email, password: event.password);
    result.fold(
      (failure) {
        if (failure is EmailConfirmationFailure) {
          emit(AuthState.emailConfirmationPending(event.email));
        } else {
          emit(AuthState.error(failure.message));
        }
      },
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onResendConfirmation(
    AuthResendConfirmationRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await resendConfirmation(event.email);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(AuthState.emailConfirmationResent(event.email)),
    );
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.authenticating());
    final result = await resetPassword(event.email);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.passwordResetSent()),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await signOut();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }
}
