import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists user preferences for theme + locale.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._prefs) : super(SettingsState.fromPrefs(_prefs));

  final SharedPreferences _prefs;

  static const _kTheme = 'settings.theme';
  static const _kLocale = 'settings.locale';

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
}

class SettingsState {
  const SettingsState({this.themeMode = ThemeMode.system, this.locale});

  final ThemeMode themeMode;
  final Locale? locale;

  factory SettingsState.fromPrefs(SharedPreferences prefs) {
    final themeName = prefs.getString(_kThemeKey);
    final localeName = prefs.getString(_kLocaleKey);
    return SettingsState(
      themeMode: switch (themeName) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      locale: localeName == null ? null : Locale(localeName),
    );
  }

  static const _kThemeKey = 'settings.theme';
  static const _kLocaleKey = 'settings.locale';

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : locale ?? this.locale,
    );
  }
}
