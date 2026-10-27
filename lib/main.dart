import 'package:flutter/material.dart';

import 'providers/bill_provider.dart';
import 'screens/home_screen.dart';
import 'screens/bill_list_screen.dart';
import 'screens/payment_history_screen.dart';
import 'screens/about_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        provider: provider,
        onNavigate: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2864F0)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: selectedIndex, children: pages),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          destinations: const [
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
          ],
        ),
      ),
    );
  }
}
