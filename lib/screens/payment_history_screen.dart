import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';
import '../widgets/responsive_layout.dart';
import 'bill_detail_screen.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final BillProvider provider;

  const PaymentHistoryScreen({super.key, required this.provider});

  String _formatCurrency(double amount) {
    final value = amount.toStringAsFixed(0);
    final result = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      result.write(value[i]);

      final remaining = value.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) result.write('.');
    }

    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedBuilder(
        animation: provider,
        builder: (context, _) {
          final List<Bill> paidBills =
              provider.bills.where((bill) => bill.isPaid).toList()
                ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

          final totalPaid = paidBills.fold<double>(
            0,
            (total, bill) => total + bill.amount,
          );

          return ResponsiveLayout(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Total Pembayaran',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCurrency(totalPaid),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${paidBills.length} transaksi selesai',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Pembayaran Selesai',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${paidBills.length} transaksi',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (paidBills.isEmpty)
                  const _EmptyPaymentHistory()
                else
                  ...paidBills.map(
                    (bill) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BillCard(
                        bill: bill,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BillDetailScreen(
                                bill: bill,
                                provider: provider,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyPaymentHistory extends StatelessWidget {
  const _EmptyPaymentHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 52,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Riwayat',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(
            'Tagihan yang sudah ditandai sebagai lunas akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
