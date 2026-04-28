import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_env.dart';
import 'core/di/injection.dart';
import 'features/favorites/data/models/favorite_coin_hive.dart';
import 'features/portfolio/data/models/portfolio_holding_hive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = const _AppBlocObserver();

  await dotenv.load(fileName: '.env');

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(FavoriteCoinAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(PortfolioHoldingAdapter());
  }

  if (AppEnv.supabaseUrl.isNotEmpty && AppEnv.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
      debug: false,
    );
  }

  String? hiveCachePath;
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    hiveCachePath = dir.path;
  }
  await configureDependencies(hiveCachePath: hiveCachePath);

  runApp(const MarskyApp());
}

class _AppBlocObserver extends BlocObserver {
  const _AppBlocObserver();

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('[Bloc] ${bloc.runtimeType} error: $error');
    super.onError(bloc, error, stackTrace);
  }
}
