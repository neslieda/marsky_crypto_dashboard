import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_constants.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';

class MarskyApp extends StatefulWidget {
  const MarskyApp({super.key});

  @override
  State<MarskyApp> createState() => _MarskyAppState();
}

class _MarskyAppState extends State<MarskyApp> {
  late final AuthBloc _authBloc;
  late final FavoritesBloc _favoritesBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthStarted());
    _favoritesBloc = FavoritesBloc(
      repository: sl(),
      watchFavorites: sl(),
      toggleFavorite: sl(),
    );
    _appRouter = AppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _favoritesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _favoritesBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.user?.id != c.user?.id,
        listener: (context, state) {
          if (state.isAuthenticated) {
            _favoritesBloc.add(FavoritesUserChanged(state.user!.id));
          } else {
            _favoritesBloc.add(const FavoritesUserCleared());
          }
        },
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}
