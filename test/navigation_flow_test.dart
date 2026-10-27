
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_task/main.dart';

void main() {
  group('ExpenseTask Navigation Flow', () {
    testWidgets('navigasi desktop berfungsi', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ExpenseTaskApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('ExpenseTask'), findsOneWidget);
      expect(find.text('MENU UTAMA'), findsOneWidget);

      const menus = [
        'Beranda',
        'Daftar Tagihan',
        'Riwayat Pembayaran',
        'Tentang Aplikasi',
      ];

      for (final menu in menus) {
        final menuFinder = find.text(menu).first;

        await tester.ensureVisible(menuFinder);
        await tester.tap(menuFinder);
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text(menu), findsWidgets);
      }
    });

    testWidgets('navigasi bawah mobile berfungsi', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ExpenseTaskApp());
      await tester.pump(const Duration(milliseconds: 500));

      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);

      const menus = [
        'Beranda',
        'Tagihan',
        'Riwayat',
        'Tentang',
      ];

      for (var index = 0; index < menus.length; index++) {
        final menuFinder = find.descendant(
          of: navigationBar,
          matching: find.text(menus[index]),
        );

        expect(menuFinder, findsOneWidget);

        await tester.tap(menuFinder);
        await tester.pump(const Duration(milliseconds: 500));

        final bar = tester.widget<NavigationBar>(navigationBar);
        expect(bar.selectedIndex, index);
      }
    });
  });
}
