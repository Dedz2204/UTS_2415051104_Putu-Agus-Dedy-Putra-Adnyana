import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';
import '../widgets/responsive_layout.dart';
import 'add_bill_screen.dart';
import 'bill_detail_screen.dart';

class BillListScreen extends StatefulWidget {
  final BillProvider provider;

  const BillListScreen({
    super.key,
    required this.provider,
  });

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  static const Color _primary = Color(0xFF2563EB);
  static const Color _background = Color(0xFFF5F7FB);
  static const Color _dark = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);

  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String _filter = 'Semua';

  final List<String> _filters = const [
    'Semua',
    'Belum Dibayar',
    'Sudah Dibayar',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Bill> _getFilteredBills(List<Bill> bills) {
    final normalizedQuery = _query.trim().toLowerCase();

    final filtered = bills.where((bill) {
      final matchesQuery =
          bill.name.toLowerCase().contains(normalizedQuery) ||
          bill.providerName.toLowerCase().contains(normalizedQuery) ||
          bill.category.toString().toLowerCase().contains(normalizedQuery);

      final matchesStatus = switch (_filter) {
        'Belum Dibayar' => !bill.isPaid,
        'Sudah Dibayar' => bill.isPaid,
        _ => true,
      };

      return matchesQuery && matchesStatus;
    }).toList();

    filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tagihan',
              style: TextStyle(
                color: _dark,
                fontSize: 23,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Kelola semua pembayaranmu',
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.provider,
        builder: (context, _) {
          final allBills = widget.provider.bills;
          final filteredBills = _getFilteredBills(allBills);
          final unpaidCount = allBills.where((bill) => !bill.isPaid).length;
          final paidCount = allBills.where((bill) => bill.isPaid).length;

          return ResponsiveLayout(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    _buildOverview(
                      total: allBills.length,
                      unpaid: unpaidCount,
                      paid: paidCount,
                      isMobile: isMobile,
                    ),

                    const SizedBox(height: 22),

                    _buildSearchField(),

                    const SizedBox(height: 14),

                    _buildFilters(),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Daftar pembayaran',
                            style: TextStyle(
                              color: _dark,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${filteredBills.length} tagihan',
                            style: const TextStyle(
                              color: _primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Expanded(
                      child: filteredBills.isEmpty
                          ? _EmptySearchResult(
                              hasBills: allBills.isNotEmpty,
                              hasQuery: _query.isNotEmpty,
                              onReset: _resetFilters,
                              onAdd: _openAddBill,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: filteredBills.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final bill = filteredBills[index];

                                return BillCard(
                                  bill: bill,
                                  onTap: () => _openBillDetail(bill),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddBill,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 5,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Tagihan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildOverview({
    required int total,
    required int unpaid,
    required int paid,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 17 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _primary.withAlpha(28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan tagihan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Pantau status pembayaranmu',
                      style: TextStyle(
                        color: Color(0xFFDCE8FF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            height: 1,
            color: Colors.white.withAlpha(45),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _OverviewItem(
                  label: 'Total tagihan',
                  value: '$total',
                  icon: Icons.description_outlined,
                ),
              ),
              Expanded(
                child: _OverviewItem(
                  label: 'Belum dibayar',
                  value: '$unpaid',
                  icon: Icons.schedule_rounded,
                ),
              ),
              Expanded(
                child: _OverviewItem(
                  label: 'Lunas',
                  value: '$paid',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _query = value;
          });
        },
        style: const TextStyle(
          color: _dark,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'Cari nama atau penyedia tagihan...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _primary,
            size: 22,
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _muted,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: _primary,
              width: 1.4,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final selected = _filter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) {
                setState(() {
                  _filter = filter;
                });
              },
              labelStyle: TextStyle(
                color: selected ? Colors.white : _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: Colors.white,
              selectedColor: _primary,
              side: BorderSide(
                color: selected
                    ? _primary
                    : const Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 9,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = 'Semua';
    });
  }

  Future<void> _openAddBill() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddBillScreen(provider: widget.provider),
      ),
    );
  }

  void _openBillDetail(Bill bill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BillDetailScreen(
          bill: bill,
          provider: widget.provider,
        ),
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _OverviewItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFFDCE8FF),
            size: 19,
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            style: const TextStyle(
              color: Color(0xFFDCE8FF),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  final bool hasBills;
  final bool hasQuery;
  final VoidCallback onReset;
  final VoidCallback onAdd;

  const _EmptySearchResult({
    required this.hasBills,
    required this.hasQuery,
    required this.onReset,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final title = !hasBills
        ? 'Belum ada tagihan'
        : hasQuery
            ? 'Tagihan tidak ditemukan'
            : 'Tidak ada tagihan pada filter ini';

    final description = !hasBills
        ? 'Mulai catat pembayaranmu agar tidak terlewat.'
        : 'Coba kata kunci atau filter status yang berbeda.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE7ECF3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 34,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              if (!hasBills)
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Tambah Tagihan'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset Pencarian dan Filter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(
                      color: Color(0xFF2563EB),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}