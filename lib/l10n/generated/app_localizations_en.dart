// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Marsky Crypto';

  @override
  String get coins => 'Coins';

  @override
  String get favorites => 'Favorites';

  @override
  String get search => 'Search coins...';

  @override
  String get sortCoins => 'Sort coins';

  @override
  String get apply => 'Apply';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get retry => 'Retry';

  @override
  String get noCoins => 'No coins available.';

  @override
  String get noFavorites =>
      'No favorites yet.\nTap the star on a coin to add it.';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to track your favorite coins';

  @override
  String get createAccount => 'Create your account';

  @override
  String get createAccountSubtitle => 'It only takes a moment';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get passwordMin => 'Password must be at least 6 chars';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get noAccountYet => 'Don\'t have an account? Sign up';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetPasswordSent => 'Password reset email sent.';

  @override
  String get resetPasswordSubtitle => 'We\'ll email you a reset link.';

  @override
  String get send => 'Send';

  @override
  String get high => 'High';

  @override
  String get low => 'Low';

  @override
  String get marketCap => 'Market Cap';

  @override
  String get volume24h => '24h Volume';

  @override
  String get description => 'Description';

  @override
  String get website => 'Website';

  @override
  String get allTimeHigh => 'All-time high';

  @override
  String rank(int n) {
    return 'Rank #$n';
  }

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String addedOn(String date) {
    return 'Added $date';
  }

  @override
  String get language => 'Language';

  @override
  String get portfolio => 'Portfolio';

  @override
  String get news => 'News';

  @override
  String get compare => 'Compare';

  @override
  String get currency => 'Currency';

  @override
  String get biometric => 'Biometric login';

  @override
  String get biometricUnavailable =>
      'Biometric authentication is not available on this device.';

  @override
  String get all => 'All';

  @override
  String get assignCategory => 'Assign category';

  @override
  String get categoryHint => 'e.g. DeFi, Layer 1';

  @override
  String get clear => 'Clear';

  @override
  String get save => 'Save';

  @override
  String get addHolding => 'Add holding';

  @override
  String get editHolding => 'Edit holding';

  @override
  String get portfolioEmpty => 'No holdings yet.\nTap + to add one.';

  @override
  String get totalValue => 'Total value';

  @override
  String get totalCost => 'Total cost';

  @override
  String get profitLoss => 'P/L';

  @override
  String get amount => 'Amount';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get amountInvalid => 'Invalid amount';

  @override
  String get buyPriceOptional => 'Avg buy price (optional)';

  @override
  String get selectCoin => 'Select coin';

  @override
  String get coin => 'Coin';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirm => 'Delete this holding?';

  @override
  String get newsEmpty => 'No news available.';

  @override
  String get copyLink => 'Link copied';

  @override
  String get compareHint => 'Pick two coins to compare';

  @override
  String get price => 'Price';

  @override
  String get change24h => '24h change';
}
