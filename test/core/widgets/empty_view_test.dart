import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:marsky_crypto_dashboard/core/widgets/empty_view.dart';

void main() {
  group('EmptyView', () {
    testWidgets('renders message and default icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: EmptyView(message: 'Nothing here')),
      ));

      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders custom icon and action button', (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: EmptyView(
            message: 'Empty',
            icon: Icons.search_off_rounded,
            actionLabel: 'Retry',
            onAction: () => tapped = true,
          ),
        ),
      ));

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
