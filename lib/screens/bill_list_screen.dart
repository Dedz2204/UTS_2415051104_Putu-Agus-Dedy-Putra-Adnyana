import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';
import '../widgets/responsive_layout.dart';
import 'add_bill_screen.dart';
import 'bill_detail_screen.dart';

class BillListScreen extends StatefulWidget {
  final BillProvider provider;

  const BillListScreen({super.key, required this.provider});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
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
      appBar: AppBar(
        title: const Text(
          'Daftar Tagihan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.provider,
        builder: (context, _) {
          final allBills = widget.provider.bills;
          final filteredBills = _getFilteredBills(allBills);

          return ResponsiveLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau penyedia tagihan...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            tooltip: 'Hapus pencarian',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: _filter == filter,
                          onSelected: (_) {
                            setState(() {
                              _filter = filter;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Daftar Tagihan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${filteredBills.length} tagihan',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: filteredBills.isEmpty
                      ? _EmptySearchResult(
                          hasBills: allBills.isNotEmpty,
                          hasQuery: _query.isNotEmpty,
                          onReset: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                              _filter = 'Semua';
                            });
                          },
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddBill,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Tagihan'),
      ),
    );
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
        builder: (_) => BillDetailScreen(bill: bill, provider: widget.provider),
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  final bool hasBills;
  final bool hasQuery;
  final VoidCallback onReset;

  const _EmptySearchResult({
    required this.hasBills,
    required this.hasQuery,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final title = !hasBills
        ? 'Belum ada tagihan'
        : hasQuery
        ? 'Tagihan tidak ditemukan'
        : 'Tidak ada tagihan pada filter ini';

    final description = !hasBills
        ? 'Tekan tombol Tambah Tagihan untuk mulai mencatat pembayaran.'
        : 'Coba kata kunci atau filter status yang berbeda.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasBills) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onReset,
                child: const Text('Reset Pencarian dan Filter'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
