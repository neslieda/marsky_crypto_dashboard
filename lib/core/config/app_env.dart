import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads environment variables loaded from `.env`.
class AppEnv {
  const AppEnv._();

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get coinRankingBaseUrl =>
      dotenv.env['COINRANKING_BASE_URL'] ?? 'https://api.coinranking.com/v2';
  static String get coinRankingApiKey =>
      dotenv.env['COINRANKING_API_KEY'] ?? '';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      coinRankingApiKey.isNotEmpty;
}
