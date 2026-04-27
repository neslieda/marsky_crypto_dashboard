import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marsky_crypto_dashboard/features/coins/domain/entities/coin.dart';
import 'package:marsky_crypto_dashboard/features/coins/presentation/widgets/coin_tile.dart';
import 'package:marsky_crypto_dashboard/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  const sample = Coin(
    uuid: 'btc-uuid',
    name: 'Bitcoin',
    symbol: 'BTC',
    rank: 1,
    price: 65000.0,
    change: 2.5,
  );

  group('CoinTile', () {
    testWidgets('renders coin name, symbol, and rank', (tester) async {
      await tester.pumpWidget(_wrap(CoinTile(
        coin: sample,
        isFavorite: false,
        onTap: () {},
        onFavoriteToggle: () {},
      )));

      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('BTC'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    });

    testWidgets('shows filled star when favorite', (tester) async {
      await tester.pumpWidget(_wrap(CoinTile(
        coin: sample,
        isFavorite: true,
        onTap: () {},
        onFavoriteToggle: () {},
      )));

      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('invokes callbacks on tap', (tester) async {
      var tapped = 0;
      var favTapped = 0;
      await tester.pumpWidget(_wrap(CoinTile(
        coin: sample,
        isFavorite: false,
        onTap: () => tapped++,
        onFavoriteToggle: () => favTapped++,
      )));

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      expect(tapped, 1);

      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(favTapped, 1);
    });
  });
}
