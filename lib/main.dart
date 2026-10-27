import 'package:flutter/material.dart';

import 'providers/bill_provider.dart';
import 'screens/home_screen.dart';
import 'screens/bill_list_screen.dart';
import 'screens/payment_history_screen.dart';
import 'screens/about_screen.dart';
import 'widgets/responsive_layout.dart';

void main() {
  runApp(const ExpenseTaskApp());
}

class ExpenseTaskApp extends StatefulWidget {
  const ExpenseTaskApp({super.key});

  @override
  State<ExpenseTaskApp> createState() => _ExpenseTaskAppState();
}

class _ExpenseTaskAppState extends State<ExpenseTaskApp> {
  late final BillProvider provider = BillProvider();

  int selectedIndex = 0;

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF0F172A);
  static const Color mutedColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  static const List<String> pageTitles = [
    'Beranda',
    'Daftar Tagihan',
    'Riwayat Pembayaran',
    'Tentang Aplikasi',
  ];

  static const List<IconData> icons = [
    Icons.dashboard_rounded,
    Icons.receipt_long_rounded,
    Icons.history_rounded,
    Icons.person_rounded,
  ];

  static const List<IconData> outlinedIcons = [
    Icons.dashboard_outlined,
    Icons.receipt_long_outlined,
    Icons.history_outlined,
    Icons.person_outline_rounded,
  ];

  static const List<NavigationDestination> destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Beranda',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long_rounded),
      label: 'Tagihan',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history_rounded),
      label: 'Riwayat',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Tentang',
    ),
  ];

  void navigateTo(int index) {
    if (index < 0 || index >= pageTitles.length) return;

    if (selectedIndex != index) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        provider: provider,
        onNavigate: navigateTo,
      ),
      BillListScreen(provider: provider),
      PaymentHistoryScreen(provider: provider),
      const AboutScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExpenseTask',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: textColor,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borderColor),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: borderColor,
          thickness: 1,
          space: 1,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: primaryColor.withAlpha(25),
          elevation: 8,
          height: 68,
          labelBehavior:
              NavigationDestinationLabelBehavior.alwaysShow,
          labelTextStyle:
              WidgetStateProperty.resolveWith<TextStyle>((states) {
            return TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            );
          }),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: Colors.white,
          indicatorColor: primaryColor.withAlpha(25),
          selectedIconTheme: const IconThemeData(
            color: primaryColor,
            size: 23,
          ),
          unselectedIconTheme: const IconThemeData(
            color: mutedColor,
            size: 22,
          ),
          selectedLabelTextStyle: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelTextStyle: const TextStyle(
            color: mutedColor,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
      home: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isWide =
              width >= ResponsiveLayout.mobileBreakpoint;
          final isDesktop =
              width >= ResponsiveLayout.desktopBreakpoint;

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _Header(
                    title: pageTitles[selectedIndex],
                    isDesktop: isDesktop,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isWide) ...[
                          _Sidebar(
                            selectedIndex: selectedIndex,
                            isDesktop: isDesktop,
                            onSelected: navigateTo,
                          ),
                          const VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: borderColor,
                          ),
                        ],
                        Expanded(
                          child: ClipRect(
                            child: IndexedStack(
                              index: selectedIndex,
                              children: pages,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: isWide
                ? null
                : NavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: navigateTo,
                    destinations: destinations,
                  ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final bool isDesktop;

  const _Header({
    required this.title,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 30 : 18,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: _ExpenseTaskAppState.borderColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _ExpenseTaskAppState.primaryColor
                  .withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.receipt_long_rounded,
                    color: _ExpenseTaskAppState.primaryColor,
                    size: 27,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ExpenseTask',
                  style: TextStyle(
                    color: _ExpenseTaskAppState.textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Kelola tagihan dengan lebih mudah',
                  style: TextStyle(
                    color: _ExpenseTaskAppState.mutedColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const Icon(
              Icons.circle,
              size: 8,
              color: Color(0xFF22C55E),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: _ExpenseTaskAppState.textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final bool isDesktop;
  final ValueChanged<int> onSelected;

  const _Sidebar({
    required this.selectedIndex,
    required this.isDesktop,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDesktop ? 238 : 82,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 22 : 0,
              26,
              12,
              14,
            ),
            child: isDesktop
                ? const Text(
                    'MENU UTAMA',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
                  )
                : const Icon(
                    Icons.menu_rounded,
                    color: _ExpenseTaskAppState.mutedColor,
                  ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: List.generate(
                _ExpenseTaskAppState.pageTitles.length,
                (index) {
                  final selected = selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Tooltip(
                      message:
                          _ExpenseTaskAppState.pageTitles[index],
                      child: Material(
                        color: selected
                            ? _ExpenseTaskAppState.primaryColor
                                .withAlpha(20)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => onSelected(index),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 48,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 14 : 0,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: isDesktop
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.center,
                              children: [
                                Icon(
                                  selected
                                      ? _ExpenseTaskAppState.icons[index]
                                      : _ExpenseTaskAppState
                                          .outlinedIcons[index],
                                  color: selected
                                      ? _ExpenseTaskAppState.primaryColor
                                      : _ExpenseTaskAppState.mutedColor,
                                  size: 22,
                                ),
                                if (isDesktop) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _ExpenseTaskAppState
                                          .pageTitles[index],
                                      style: TextStyle(
                                        color: selected
                                            ? _ExpenseTaskAppState
                                                .primaryColor
                                            : _ExpenseTaskAppState
                                                .textColor,
                                        fontSize: 12,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: _ExpenseTaskAppState
                                          .primaryColor,
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (isDesktop)
            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _ExpenseTaskAppState.backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _ExpenseTaskAppState.borderColor,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: _ExpenseTaskAppState.primaryColor,
                    size: 23,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tips Pengelolaan',
                    style: TextStyle(
                      color: _ExpenseTaskAppState.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Catat tagihan dan periksa tanggal jatuh tempo secara rutin.',
                    style: TextStyle(
                      color: _ExpenseTaskAppState.mutedColor,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
            child: Text(
              isDesktop ? 'ExpenseTask  •  v1.0.0' : 'v1.0',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}