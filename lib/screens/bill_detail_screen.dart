import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/responsive_layout.dart';
import 'edit_bill_screen.dart';

class BillDetailScreen extends StatefulWidget {
  final Bill bill;
  final BillProvider provider;

  const BillDetailScreen({
    super.key,
    required this.bill,
    required this.provider,
  });

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  bool _isUpdatingPayment = false;
  bool _isDeleting = false;

  String _formatCurrency(double amount) {
    final value = amount.toStringAsFixed(0);
    final result = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      result.write(value[i]);

      final remaining = value.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        result.write('.');
      }
    }

    return 'Rp $result';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _editBill(BuildContext context, Bill bill) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditBillScreen(
          bill: bill,
          provider: widget.provider,
        ),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Tagihan berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _changePaymentStatus(
    BuildContext context, {
    required String billId,
    required bool markAsPaid,
  }) async {
    if (_isUpdatingPayment || _isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          markAsPaid
              ? 'Konfirmasi Pembayaran'
              : 'Batalkan Status Pembayaran',
        ),
        content: Text(
          markAsPaid
              ? 'Tandai tagihan ini sebagai sudah dibayar?'
              : 'Ubah status tagihan ini menjadi belum dibayar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              markAsPaid ? 'Ya, Sudah Dibayar' : 'Ya, Belum Dibayar',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isUpdatingPayment = true;
    });

    try {
      if (markAsPaid) {
        await widget.provider.markPaid(billId);
      } else {
        await widget.provider.markUnpaid(billId);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
            markAsPaid
                ? 'Tagihan berhasil ditandai sudah dibayar.'
                : 'Status tagihan berhasil diubah menjadi belum dibayar.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui pembayaran: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPayment = false;
        });
      }
    }
  }

  Future<void> _deleteBill(BuildContext context, Bill bill) async {
    if (_isDeleting || _isUpdatingPayment) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        title: const Text('Hapus Tagihan?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${bill.name}"? '
          'Data yang sudah dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      // Penghapusan melalui Provider -> Repository -> Service.
      await widget.provider.deleteBill(bill.id);

      if (!mounted) return;

      // Kembali ke halaman sebelumnya setelah penghapusan berhasil.
      Navigator.of(this.context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus tagihan: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tagihan'),
        actions: [
          IconButton(
            tooltip: 'Edit tagihan',
            onPressed: _isDeleting || _isUpdatingPayment
                ? null
                : () {
                    final bill = widget.provider.bills
                        .where((item) => item.id == widget.bill.id)
                        .firstOrNull;

                    if (bill != null) {
                      _editBill(context, bill);
                    }
                  },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Hapus tagihan',
            onPressed: _isDeleting || _isUpdatingPayment
                ? null
                : () {
                    final bill = widget.provider.bills
                        .where((item) => item.id == widget.bill.id)
                        .firstOrNull;

                    if (bill != null) {
                      _deleteBill(context, bill);
                    }
                  },
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.delete_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.provider,
        builder: (context, _) {
          final currentBill = widget.provider.bills
              .where((item) => item.id == widget.bill.id)
              .firstOrNull;

          if (currentBill == null) {
            return const Center(
              child: Text('Tagihan sudah tidak tersedia.'),
            );
          }

          return ResponsiveLayout(
            maxContentWidth: 850,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentBill.isPaid
                            ? 'Status Pembayaran'
                            : 'Total Tagihan',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCurrency(currentBill.amount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          currentBill.isPaid
                              ? 'Sudah Dibayar'
                              : 'Belum Dibayar',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Informasi Tagihan',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Nama Tagihan',
                  value: currentBill.name,
                ),
                _DetailItem(
                  icon: Icons.business_outlined,
                  title: 'Penyedia',
                  value: currentBill.providerName,
                ),
                _DetailItem(
                  icon: Icons.category_outlined,
                  title: 'Kategori',
                  value: categoryLabel(currentBill.category),
                ),
                _DetailItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'Jatuh Tempo',
                  value: _formatDate(currentBill.dueDate),
                ),
                if (currentBill.isPaid && currentBill.paidAt != null)
                  _DetailItem(
                    icon: Icons.check_circle_outline,
                    title: 'Tanggal Pembayaran',
                    value: _formatDate(currentBill.paidAt!),
                  ),
                _DetailItem(
                  icon: Icons.notes_outlined,
                  title: 'Catatan',
                  value: currentBill.note == null ||
                          currentBill.note!.trim().isEmpty
                      ? '-'
                      : currentBill.note!,
                ),
                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _isUpdatingPayment || _isDeleting
                      ? null
                      : () => _changePaymentStatus(
                            context,
                            billId: currentBill.id,
                            markAsPaid: !currentBill.isPaid,
                          ),
                  icon: _isUpdatingPayment
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          currentBill.isPaid
                              ? Icons.undo_rounded
                              : Icons.check_circle_outline,
                        ),
                  label: Text(
                    _isUpdatingPayment
                        ? 'Memperbarui...'
                        : currentBill.isPaid
                            ? 'Kembalikan ke Belum Dibayar'
                            : 'Tandai Sudah Dibayar',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: currentBill.isPaid
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF16A34A),
                  ),
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _isDeleting || _isUpdatingPayment
                      ? null
                      : () => _editBill(context, currentBill),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Tagihan'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _isDeleting || _isUpdatingPayment
                      ? null
                      : () => _deleteBill(context, currentBill),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  label: Text(
                    _isDeleting ? 'Menghapus...' : 'Hapus Tagihan',
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(
                      color: Colors.red,
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

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}