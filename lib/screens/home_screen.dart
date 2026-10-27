import 'package:flutter/material.dart';

import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';
import 'add_bill_screen.dart';
import 'bill_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final BillProvider provider;
  final ValueChanged<int> onNavigate;

  const HomeScreen({
    super.key,
    required this.provider,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: provider,
      builder: (context, _) {
        final unpaid = provider.unpaidBills;
        final paid = provider.paidBills;
        final upcoming = unpaid.take(3).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.account_balance_wallet, color: Color(0xFF2563EB)),
                SizedBox(width: 10),
                Text(
                  'ExpenseTask',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Belum ada notifikasi baru.')),
                  );
                },
                icon: const Icon(Icons.notifications_none),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddBillScreen(provider: provider),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Tagihan'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Kelola tagihanmu dengan lebih mudah.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF2864F0),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Tagihan Belum Dibayar',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatRupiah(provider.totalUnpaid),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${unpaid.length} tagihan belum dibayar',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      title: 'Belum Dibayar',
                      amount: provider.totalUnpaid,
                      count: unpaid.length,
                      icon: Icons.access_time,
                      color: const Color(0xFFEA580C),
                      background: const Color(0xFFFFF7ED),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryTile(
                      title: 'Sudah Dibayar',
                      amount: provider.totalPaid,
                      count: paid.length,
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF16A34A),
                      background: const Color(0xFFF0FDF4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tagihan Terdekat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => onNavigate(1),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (upcoming.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 45,
                        color: Colors.green,
                      ),
                      SizedBox(height: 8),
                      Text('Semua tagihan sudah dibayar.'),
                    ],
                  ),
                )
              else
                ...upcoming.map(
                  (bill) => BillCard(
                    bill: bill,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BillDetailScreen(provider: provider, bill: bill),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final double amount;
  final int count;
  final IconData icon;
  final Color color;
  final Color background;

  const _SummaryTile({
    required this.title,
    required this.amount,
    required this.count,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          Text(
            formatRupiah(amount),
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text('$count tagihan', style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
