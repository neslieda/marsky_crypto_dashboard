import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/dio_client.dart';
import '../network/http_cache.dart';
import '../settings/settings_cubit.dart';
import '../../features/auth/data/datasources/supabase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/reset_password.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/coins/data/datasources/coins_remote_datasource.dart';
import '../../features/coins/data/repositories/coins_repository_impl.dart';
import '../../features/coins/domain/repositories/coins_repository.dart';
import '../../features/coins/domain/usecases/get_coin_detail.dart';
import '../../features/coins/domain/usecases/get_coin_history.dart';
import '../../features/coins/domain/usecases/get_coins_paginated.dart';
import '../../features/favorites/data/datasources/favorites_local_datasource.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/toggle_favorite.dart';
import '../../features/favorites/domain/usecases/watch_favorites.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies({String? hiveCachePath}) async {
  // External
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  final cacheInterceptor = await HttpCache.build(hivePath: hiveCachePath);
  sl.registerLazySingleton<DioClient>(
    () => DioClient.coinRanking(cacheInterceptor: cacheInterceptor),
  );

  // Settings
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<SettingsCubit>(() => SettingsCubit(sl()));

  // ---------------- Auth ----------------
  sl.registerLazySingleton<SupabaseAuthDataSource>(
    () => SupabaseAuthDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerFactory(() => SignIn(sl()));
  sl.registerFactory(() => SignUp(sl()));
  sl.registerFactory(() => SignOut(sl()));
  sl.registerFactory(() => GetCurrentUser(sl()));
  sl.registerFactory(() => WatchAuthState(sl()));
  sl.registerFactory(() => ResetPassword(sl()));
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      watchAuthState: sl(),
      getCurrentUser: sl(),
      resetPassword: sl(),
    ),
  );

  // ---------------- Coins ----------------
  sl.registerLazySingleton<CoinsRemoteDataSource>(
    () => CoinsRemoteDataSourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<CoinsRepository>(
    () => CoinsRepositoryImpl(sl()),
  );
  sl.registerFactory(() => GetCoinsPaginated(sl()));
  sl.registerFactory(() => GetCoinDetail(sl()));
  sl.registerFactory(() => GetCoinHistory(sl()));

  // ---------------- Favorites ----------------
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl()),
  );
  sl.registerFactory(() => ToggleFavorite(sl()));
  sl.registerFactory(() => WatchFavorites(sl()));
}
