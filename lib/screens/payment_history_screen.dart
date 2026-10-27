import 'package:flutter/material.dart';

import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final BillProvider provider;

  const PaymentHistoryScreen({super.key, required this.provider});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    widget.provider.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.provider.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bills = widget.provider.paidBills;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Pembayaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF159B73), Color(0xFF42C99A)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Total Pembayaran Selesai',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupiah(widget.provider.totalPaid),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${bills.length} transaksi telah dibayar',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Transaksi Terakhir',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (bills.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 45),
              child: Column(
                children: [
                  Icon(Icons.history, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat pembayaran',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tagihan yang sudah dibayar akan muncul di sini.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...bills.map((bill) => BillCard(bill: bill)),
        ],
      ),
    );
  }
}
