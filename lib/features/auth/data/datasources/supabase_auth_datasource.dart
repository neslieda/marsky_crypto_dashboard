import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/error/exceptions.dart' as core;

abstract class SupabaseAuthDataSource {
  Future<sb.User> signIn({required String email, required String password});
  Future<sb.User> signUp({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword(String email);
  sb.User? get currentUser;
  Stream<sb.AuthState> authStateChanges();
}

class SupabaseAuthDataSourceImpl implements SupabaseAuthDataSource {
  final sb.SupabaseClient _client;
  SupabaseAuthDataSourceImpl(this._client);

  @override
  sb.User? get currentUser => _client.auth.currentUser;

  @override
  Stream<sb.AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  @override
  Future<sb.User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw const core.AuthException('Sign-in failed.');
      }
      return user;
    } on sb.AuthApiException catch (e) {
      throw core.AuthException(e.message);
    } on sb.AuthException catch (e) {
      throw core.AuthException(e.message);
    } catch (e) {
      throw core.AuthException(e.toString());
    }
  }

  @override
  Future<sb.User> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(email: email, password: password);
      final user = res.user;
      if (user == null) {
        throw const core.AuthException(
          'Sign-up failed. You may need to confirm your email.',
        );
      }
      return user;
    } on sb.AuthApiException catch (e) {
      throw core.AuthException(e.message);
    } on sb.AuthException catch (e) {
      throw core.AuthException(e.message);
    } catch (e) {
      throw core.AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw core.AuthException(e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on sb.AuthException catch (e) {
      throw core.AuthException(e.message);
    } catch (e) {
      throw core.AuthException(e.toString());
    }
  }
}
