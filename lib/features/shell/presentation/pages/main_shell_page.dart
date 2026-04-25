import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../coins/presentation/pages/home_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  Future<void> _confirmLogout(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(const AuthSignOutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [HomePage(), FavoritesPage()];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            IndexedStack(index: _index, children: pages),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => _confirmLogout(context),
                tooltip: 'Sign out',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.show_chart_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_rounded),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
