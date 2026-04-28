import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/app_constants.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/settings/settings_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/coins/presentation/bloc/coins_list_bloc.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
import 'features/news/presentation/bloc/news_bloc.dart';
import 'features/portfolio/presentation/bloc/portfolio_bloc.dart';
import 'features/strategy/presentation/cubit/strategy_cubit.dart';
import 'l10n/generated/app_localizations.dart';

class MarskyApp extends StatefulWidget {
  const MarskyApp({super.key});

  @override
  State<MarskyApp> createState() => _MarskyAppState();
}

class _MarskyAppState extends State<MarskyApp> {
  late final AuthBloc _authBloc;
  late final FavoritesBloc _favoritesBloc;
  late final SettingsCubit _settingsCubit;
  late final CoinsListBloc _coinsListBloc;
  late final PortfolioBloc _portfolioBloc;
  late final NewsBloc _newsBloc;
  late final StrategyCubit _strategyCubit;
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
    _settingsCubit = sl<SettingsCubit>();
    _coinsListBloc = sl<CoinsListBloc>()..add(const CoinsListLoadRequested());
    _portfolioBloc = sl<PortfolioBloc>();
    _newsBloc = sl<NewsBloc>()..add(const NewsLoadRequested());
    _strategyCubit = sl<StrategyCubit>();
    _appRouter = AppRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _favoritesBloc.close();
    _coinsListBloc.close();
    _portfolioBloc.close();
    _newsBloc.close();
    _strategyCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _favoritesBloc),
        BlocProvider.value(value: _settingsCubit),
        BlocProvider.value(value: _coinsListBloc),
        BlocProvider.value(value: _portfolioBloc),
        BlocProvider.value(value: _newsBloc),
        BlocProvider.value(value: _strategyCubit),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.user?.id != c.user?.id,
        listener: (context, state) {
          if (state.isAuthenticated) {
            _favoritesBloc.add(FavoritesUserChanged(state.user!.id));
            _portfolioBloc.add(PortfolioOpened(state.user!.id));
            _strategyCubit.bootstrap(state.user!.id);
          } else {
            _favoritesBloc.add(const FavoritesUserCleared());
            _portfolioBloc.add(const PortfolioClosed());
          }
        },
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: settings.themeMode,
              locale: settings.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: _appRouter.router,
            );
          },
        ),
      ),
    );
  }
}
