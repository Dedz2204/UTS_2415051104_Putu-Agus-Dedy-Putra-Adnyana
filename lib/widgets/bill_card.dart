import 'package:flutter/material.dart';

import '../models/bill.dart';

String formatRupiah(double value) {
  final amount = value.toStringAsFixed(0);
  final formatted = amount.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return 'Rp$formatted';
}

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} '
      '${_monthName(date.month)} ${date.year}';
}

String _monthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return months[month - 1];
}

class BillCard extends StatelessWidget {
  final Bill bill;
  final VoidCallback? onTap;

  const BillCard({super.key, required this.bill, this.onTap});

  @override
  Widget build(BuildContext context) {
    final overdue = !bill.isPaid && bill.dueDate.isBefore(DateTime.now());

    final color = bill.isPaid
        ? Colors.green
        : overdue
        ? Colors.red
        : Colors.orange;

    final icon = switch (bill.category) {
      BillCategory.listrik => Icons.bolt,
      BillCategory.air => Icons.water_drop_outlined,
      BillCategory.internet => Icons.wifi,
      BillCategory.telepon => Icons.phone_android,
      BillCategory.lainnya => Icons.receipt_long,
    };

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEFF6FF),
          child: Icon(icon, color: const Color(0xFF2563EB)),
        ),
        title: Text(
          bill.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${bill.providerName} • ${formatDate(bill.dueDate)}'),
              const SizedBox(height: 5),
              Text(
                bill.isPaid
                    ? 'Sudah dibayar'
                    : overdue
                    ? 'Terlambat'
                    : 'Belum dibayar',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing: Text(
          formatRupiah(bill.amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
