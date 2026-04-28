import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/settings/currency.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../coins/presentation/pages/home_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../news/presentation/pages/news_page.dart';
import '../../../portfolio/presentation/pages/portfolio_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  Future<void> _confirmLogout(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    final l = AppLocalizations.of(context);
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.signOut),
        content: Text(l.signOutConfirm),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(const AuthSignOutRequested());
    }
  }

  void _openSettings(BuildContext context) {
    final settings = context.read<SettingsCubit>();
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => BlocBuilder<SettingsCubit, SettingsState>(
        bloc: settings,
        builder: (_, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l.themeSystem.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l.themeLight),
                          icon: const Icon(Icons.light_mode_outlined)),
                      ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(l.themeDark),
                          icon: const Icon(Icons.dark_mode_outlined)),
                      ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l.themeSystem),
                          icon: const Icon(Icons.brightness_auto_outlined)),
                    ],
                    selected: {state.themeMode},
                    onSelectionChanged: (s) => settings.setThemeMode(s.first),
                  ),
                  const SizedBox(height: 16),
                  Text(l.language.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Auto'),
                        selected: state.locale == null,
                        onSelected: (_) => settings.setLocale(null),
                      ),
                      ChoiceChip(
                        label: const Text('English'),
                        selected: state.locale?.languageCode == 'en',
                        onSelected: (_) =>
                            settings.setLocale(const Locale('en')),
                      ),
                      ChoiceChip(
                        label: const Text('Türkçe'),
                        selected: state.locale?.languageCode == 'tr',
                        onSelected: (_) =>
                            settings.setLocale(const Locale('tr')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(l.currency.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<AppCurrency>(
                    segments: const [
                      ButtonSegment(
                          value: AppCurrency.usd, label: Text('USD')),
                      ButtonSegment(
                          value: AppCurrency.eur, label: Text('EUR')),
                      ButtonSegment(
                          value: AppCurrency.tryLira, label: Text('TRY')),
                    ],
                    selected: {state.currency},
                    onSelectionChanged: (s) => settings.setCurrency(s.first),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.biometric),
                    value: state.biometricEnabled,
                    onChanged: (v) async {
                      if (v) {
                        final ok = await sl<BiometricService>().isAvailable();
                        if (!ok) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l.biometricUnavailable)),
                            );
                          }
                          return;
                        }
                      }
                      settings.setBiometricEnabled(v);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const FavoritesPage(),
      const PortfolioPage(),
      if (!kIsWeb) const NewsPage(),
    ];
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            IndexedStack(index: _index, children: pages),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => _openSettings(context),
                    tooltip: 'Settings',
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () => _confirmLogout(context),
                    tooltip: l.signOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.show_chart_rounded),
            label: l.coins,
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_rounded),
            label: l.favorites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_rounded),
            label: l.portfolio,
          ),
          if (!kIsWeb)
            NavigationDestination(
              icon: const Icon(Icons.article_outlined),
              label: l.news,
            ),
        ],
      ),
    );
  }
}
