class AppConstants {
  const AppConstants._();

  static const String appName = 'Marsky Crypto';

  // Pagination
  static const int coinsPageSize = 25;

  // Hive
  static const String favoritesBoxPrefix = 'favorites_';

  // Sort options stored as String for persistence/UI mapping
  static const String defaultOrderBy = 'marketCap';
  static const String defaultOrderDirection = 'desc';
}
