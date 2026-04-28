import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'currency.dart';

/// Persists user preferences for theme + locale + currency + biometric.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._prefs) : super(SettingsState.fromPrefs(_prefs)) {
    CurrencyHolder.instance.set(state.currency);
  }

  final SharedPreferences _prefs;

  static const _kTheme = 'settings.theme';
  static const _kLocale = 'settings.locale';
  static const _kCurrency = 'settings.currency';
  static const _kBiometric = 'settings.biometric';

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_kTheme, mode.name);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, locale.languageCode);
    }
    emit(state.copyWith(locale: locale, clearLocale: locale == null));
  }

  Future<void> setCurrency(AppCurrency currency) async {
    await _prefs.setString(_kCurrency, currency.code);
    CurrencyHolder.instance.set(currency);
    emit(state.copyWith(currency: currency));
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_kBiometric, enabled);
    emit(state.copyWith(biometricEnabled: enabled));
  }
}

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.currency = AppCurrency.usd,
    this.biometricEnabled = false,
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final AppCurrency currency;
  final bool biometricEnabled;

  factory SettingsState.fromPrefs(SharedPreferences prefs) {
    final themeName = prefs.getString(SettingsCubit._kTheme);
    final localeName = prefs.getString(SettingsCubit._kLocale);
    final currencyCode = prefs.getString(SettingsCubit._kCurrency);
    final biometric = prefs.getBool(SettingsCubit._kBiometric) ?? false;
    return SettingsState(
      themeMode: switch (themeName) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      locale: localeName == null ? null : Locale(localeName),
      currency: AppCurrency.fromCode(currencyCode),
      biometricEnabled: biometric,
    );
  }

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    AppCurrency? currency,
    bool? biometricEnabled,
    bool clearLocale = false,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : locale ?? this.locale,
      currency: currency ?? this.currency,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}
