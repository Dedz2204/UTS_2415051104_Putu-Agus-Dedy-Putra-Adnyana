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
  static const Color _primaryColor = Color(0xFF2563EB);
  static const Color _textColor = Color(0xFF0F172A);
  static const Color _mutedColor = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _successColor = Color(0xFF16A34A);
  static const Color _warningColor = Color(0xFFF59E0B);

  bool _isUpdatingPayment = false;
  bool _isDeleting = false;

  bool get _isProcessing => _isUpdatingPayment || _isDeleting;

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
    if (_isProcessing) return;

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
    if (_isProcessing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.red,
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
              backgroundColor: Colors.red,
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
      await widget.provider.deleteBill(bill.id);

      if (!mounted) return;

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

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: _primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _mutedColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isPaid) {
    final color = isPaid ? _successColor : _warningColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle : Icons.pending_actions,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 7),
          Text(
            isPaid ? 'Sudah Dibayar' : 'Belum Dibayar',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            Icons.circle,
            color: color,
            size: 7,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Bill bill) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isProcessing
                ? null
                : () => _changePaymentStatus(
                      context,
                      billId: bill.id,
                      markAsPaid: !bill.isPaid,
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
                    bill.isPaid
                        ? Icons.undo_rounded
                        : Icons.check_circle_outline,
                  ),
            label: Text(
              _isUpdatingPayment
                  ? 'Memperbarui...'
                  : bill.isPaid
                      ? 'Kembalikan ke Belum Dibayar'
                      : 'Tandai Sudah Dibayar',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: bill.isPaid ? _warningColor : _successColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _mutedColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isProcessing
                ? null
                : () => _editBill(context, bill),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Tagihan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryColor,
              side: const BorderSide(color: _borderColor),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isProcessing
                ? null
                : () => _deleteBill(context, bill),
            icon: _isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline_rounded),
            label: Text(_isDeleting ? 'Menghapus...' : 'Hapus Tagihan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Color(0xFFFECACA)),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(Bill bill) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 32,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2563EB),
                Color(0xFF1D4ED8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Tagihan',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatCurrency(bill.amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _buildStatusBadge(bill.isPaid),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Informasi Tagihan',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 14),

        _buildDetailItem(
          icon: Icons.receipt_long_outlined,
          title: 'Nama Tagihan',
          value: bill.name,
        ),
        _buildDetailItem(
          icon: Icons.business_outlined,
          title: 'Penyedia',
          value: bill.providerName,
        ),
        _buildDetailItem(
          icon: Icons.category_outlined,
          title: 'Kategori',
          value: categoryLabel(bill.category),
        ),
        _buildDetailItem(
          icon: Icons.calendar_month_outlined,
          title: 'Jatuh Tempo',
          value: _formatDate(bill.dueDate),
        ),
        if (bill.isPaid && bill.paidAt != null)
          _buildDetailItem(
            icon: Icons.check_circle_outline,
            title: 'Tanggal Pembayaran',
            value: _formatDate(bill.paidAt!),
          ),
        _buildDetailItem(
          icon: Icons.notes_outlined,
          title: 'Catatan',
          value: bill.note == null || bill.note!.trim().isEmpty
              ? '-'
              : bill.note!,
        ),
        const SizedBox(height: 12),

        _buildActionButtons(bill),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Tagihan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        backgroundColor: _backgroundColor,
        foregroundColor: _textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Edit tagihan',
            onPressed: _isProcessing
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
            onPressed: _isProcessing
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
                    child: CircularProgressIndicator(strokeWidth: 2),
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
              child: Text(
                'Tagihan sudah tidak tersedia.',
                style: TextStyle(color: _mutedColor),
              ),
            );
          }

          return ResponsiveLayout(
            maxContentWidth: 850,
            child: _buildContent(currentBill),
          );
        },
      ),
    );
  }
}