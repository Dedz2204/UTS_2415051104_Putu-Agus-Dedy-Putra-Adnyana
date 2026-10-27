import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';
import 'edit_bill_screen.dart';

class BillDetailScreen extends StatelessWidget {
  final BillProvider provider;
  final Bill bill;

  const BillDetailScreen({
    super.key,
    required this.provider,
    required this.bill,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: provider,
      builder: (context, child) {
        final matches = provider.bills.where((item) => item.id == bill.id);

        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Tagihan')),
            body: const Center(
              child: Text('Tagihan tidak ditemukan atau sudah dihapus.'),
            ),
          );
        }

        final currentBill = matches.first;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Detail Tagihan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: 'Edit tagihan',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditBillScreen(provider: provider, bill: currentBill),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Hapus tagihan',
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Hapus tagihan?'),
                      content: const Text(
                        'Tagihan ini akan dihapus secara permanen.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    provider.deleteBill(currentBill.id);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2864F0),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 38,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      currentBill.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatRupiah(currentBill.amount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentBill.isPaid ? 'Sudah dibayar' : 'Belum dibayar',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _DetailItem(
                label: 'Penyedia layanan',
                value: currentBill.providerName,
              ),
              _DetailItem(
                label: 'Kategori',
                value: categoryLabel(currentBill.category),
              ),
              _DetailItem(
                label: 'Jatuh tempo',
                value: formatDate(currentBill.dueDate),
              ),
              _DetailItem(
                label: 'Tanggal dibayar',
                value: currentBill.paidAt == null
                    ? '-'
                    : formatDate(currentBill.paidAt!),
              ),
              _DetailItem(
                label: 'Catatan',
                value: currentBill.note?.isNotEmpty == true
                    ? currentBill.note!
                    : '-',
              ),
              const SizedBox(height: 24),
              if (!currentBill.isPaid)
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () {
                      provider.markPaid(currentBill.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tagihan berhasil ditandai lunas.'),
                        ),
                      );

                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Tandai Sudah Dibayar'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
