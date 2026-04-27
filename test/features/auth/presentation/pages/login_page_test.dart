import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:marsky_crypto_dashboard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:marsky_crypto_dashboard/features/auth/presentation/pages/login_page.dart';
import 'package:marsky_crypto_dashboard/l10n/generated/app_localizations.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAuthEvent());
  });

  late _MockAuthBloc bloc;

  setUp(() {
    bloc = _MockAuthBloc();
    when(() => bloc.state).thenReturn(const AuthState.unknown());
  });

  Widget buildSubject() {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const SizedBox()),
        GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const SizedBox(),
        ),
      ],
    );
    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          BlocProvider<AuthBloc>.value(value: bloc, child: child!),
    );
  }

  group('LoginPage', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows validation errors when fields empty', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Two validators fire: invalid email + password too short.
      expect(find.textContaining(RegExp('mail|posta', caseSensitive: false)),
          findsWidgets);
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('dispatches AuthSignInRequested with valid input',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(1), 'secret123');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      verify(() => bloc.add(any(that: isA<AuthSignInRequested>()))).called(1);
    });
  });
}
