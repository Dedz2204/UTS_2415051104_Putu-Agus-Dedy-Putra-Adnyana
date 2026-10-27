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
  final BillProvider provider = BillProvider();
  int selectedIndex = 0;

  static const destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Beranda',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: 'Tagihan',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: 'Riwayat',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Tentang',
    ),
  ];

  void _navigateTo(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(provider: provider, onNavigate: _navigateTo),
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
          seedColor: const Color(0xFF2864F0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: LayoutBuilder(
        builder: (context, constraints) {
          final isWide =
              constraints.maxWidth >= ResponsiveLayout.mobileBreakpoint;

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // Header tunggal untuk desktop, tablet, dan mobile.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F8FC),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              width: 32,
                              height: 32,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ExpenseTask',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Konten dan navigasi responsif.
                  Expanded(
                    child: Row(
                      children: [
                        if (isWide)
                          NavigationRail(
                            selectedIndex: selectedIndex,
                            onDestinationSelected: _navigateTo,
                            labelType: constraints.maxWidth >=
                                    ResponsiveLayout.desktopBreakpoint
                                ? NavigationRailLabelType.all
                                : NavigationRailLabelType.selected,
                            // Tidak ada logo atau tulisan kedua di sini.
                            destinations: const [
                              NavigationRailDestination(
                                icon: Icon(Icons.dashboard_outlined),
                                selectedIcon: Icon(Icons.dashboard),
                                label: Text('Beranda'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.receipt_long_outlined),
                                selectedIcon: Icon(Icons.receipt_long),
                                label: Text('Tagihan'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.history_outlined),
                                selectedIcon: Icon(Icons.history),
                                label: Text('Riwayat'),
                              ),
                              NavigationRailDestination(
                                icon: Icon(Icons.person_outline),
                                selectedIcon: Icon(Icons.person),
                                label: Text('Tentang'),
                              ),
                            ],
                          ),
                        Expanded(
                          child: IndexedStack(
                            index: selectedIndex,
                            children: pages,
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
                    onDestinationSelected: _navigateTo,
                    destinations: destinations,
                  ),
          );
        },
      ),
    );
  }
}