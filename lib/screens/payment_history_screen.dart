
import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final BillProvider provider;

  const PaymentHistoryScreen({
    super.key,
    required this.provider,
  });

  @override
  State<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _query = '';

  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF5F7FB);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color success = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearch);
  }

  void _handleSearch() {
    setState(() {
      _query = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearch);
    _searchController.dispose();
    super.dispose();
  }

  List<Bill> get _filteredBills {
    final bills = widget.provider.paidBills;

    if (_query.isEmpty) return bills;

    return bills.where((bill) {
      return bill.name.toLowerCase().contains(_query) ||
          bill.providerName.toLowerCase().contains(_query) ||
          categoryLabel(bill.category).toLowerCase().contains(_query);
    }).toList();
  }

  String _rupiah(num amount) {
    final value = amount.round().toString();
    final result = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      result.write(value[i]);

      final remaining = value.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        result.write('.');
      }
    }

    return 'Rp$result';
  }

  String _date(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _monthYear(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April',
      'Mei', 'Juni', 'Juli', 'Agustus',
      'September', 'Oktober', 'November', 'Desember',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  DateTime _paymentDate(Bill bill) {
    return bill.paidAt ?? bill.dueDate;
  }

  IconData _billIcon(Bill bill) {
    switch (bill.category) {
      case BillCategory.listrik:
        return Icons.bolt_rounded;
      case BillCategory.air:
        return Icons.water_drop_rounded;
      case BillCategory.internet:
        return Icons.wifi_rounded;
      case BillCategory.telepon:
        return Icons.smartphone_rounded;
      case BillCategory.lainnya:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bills = _filteredBills;

    // Menghitung total dari tagihan lunas yang tercatat.
    final totalPaid = widget.provider.totalPaid;
    final transactionCount = widget.provider.paidBills.length;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Riwayat Pembayaran',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 650;
            final horizontalPadding = wide ? 32.0 : 20.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding, 12, horizontalPadding, 28,
              ),
              children: [
                _buildSummary(
                  totalPaid: totalPaid,
                  transactionCount: transactionCount,
                  wide: wide,
                ),
                const SizedBox(height: 26),
                _buildSearch(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Transaksi Pembayaran',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${bills.length} transaksi',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (widget.provider.paidBills.isEmpty)
                  _buildEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum Ada Pembayaran',
                    message:
                        'Tagihan yang sudah ditandai lunas akan muncul di sini.',
                  )
                else if (bills.isEmpty)
                  _buildEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Transaksi Tidak Ditemukan',
                    message:
                        'Coba kata kunci lain untuk mencari transaksi.',
                    action: OutlinedButton.icon(
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Hapus pencarian'),
                    ),
                  )
                else
                  ..._buildGroupedTransactions(bills),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummary({
    required double totalPaid,
    required int transactionCount,
    required bool wide,
  }) {
    final countCard = _summaryCard(
      color: primary,
      icon: Icons.check_circle_outline_rounded,
      label: 'Transaksi Lunas',
      value: '$transactionCount',
      description: 'Pembayaran selesai',
      light: true,
    );

    final amountCard = _summaryCard(
      color: Colors.white,
      icon: Icons.account_balance_wallet_outlined,
      label: 'Total Dibayarkan',
      value: _rupiah(totalPaid),
      description: 'Akumulasi pembayaran',
      light: false,
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: countCard),
          const SizedBox(width: 14),
          Expanded(child: amountCard),
        ],
      );
    }

    return Column(
      children: [
        countCard,
        const SizedBox(height: 12),
        amountCard,
      ],
    );
  }

  Widget _summaryCard({
    required Color color,
    required IconData icon,
    required String label,
    required String value,
    required String description,
    required bool light,
  }) {
    final foreground = light ? Colors.white : textPrimary;
    final muted = light ? const Color(0xFFDBEAFE) : textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: light
            ? null
            : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: light ? Colors.white : primary,
            size: 27,
          ),
          const SizedBox(height: 17),
          Text(
            label,
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: foreground,
                fontSize: light ? 29 : 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari nama tagihan atau penyedia...',
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: textSecondary,
        ),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: _searchController.clear,
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedTransactions(List<Bill> bills) {
    final groups = <String, List<Bill>>{};

    for (final bill in bills) {
      final date = _paymentDate(bill);
      final key = '${date.year}-${date.month}';
      groups.putIfAbsent(key, () => []).add(bill);
    }

    final widgets = <Widget>[];

    for (final group in groups.values) {
      final date = _paymentDate(group.first);

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 12),
          child: Text(
            _monthYear(date),
            style: const TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      for (final bill in group) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _transactionCard(bill),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _transactionCard(Bill bill) {
    final paymentDate = _paymentDate(bill);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EDF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              _billIcon(bill),
              color: primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  bill.providerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_date(paymentDate)}'
                  ' • ${categoryLabel(bill.category)}',
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: success,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Lunas',
                        style: TextStyle(
                          color: success,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 112),
              child: Text(
                _rupiah(bill.amount),
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 34,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action,
          ],
        ],
      ),
    );
  }
}
