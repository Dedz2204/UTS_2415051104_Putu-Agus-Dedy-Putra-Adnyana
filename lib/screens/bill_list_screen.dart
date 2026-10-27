import 'package:flutter/material.dart';

import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';
import 'bill_detail_screen.dart';
import 'add_bill_screen.dart';

class BillListScreen extends StatefulWidget {
  final BillProvider provider;

  const BillListScreen({super.key, required this.provider});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  String _query = '';
  String _filter = 'Semua';

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
    final bills = widget.provider.bills.where((bill) {
      final matchesSearch = '${bill.name} ${bill.providerName}'
          .toLowerCase()
          .contains(_query.toLowerCase());

      final matchesFilter =
          _filter == 'Semua' ||
          (_filter == 'Belum dibayar' && !bill.isPaid) ||
          (_filter == 'Sudah dibayar' && bill.isPaid);

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Tagihan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddBillScreen(provider: widget.provider),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tagihan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari nama tagihan...',
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Semua', 'Belum dibayar', 'Sudah dibayar']
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(item),
                        selected: _filter == item,
                        onSelected: (_) => setState(() => _filter = item),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: bills.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 56,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Tagihan tidak ditemukan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Coba ubah pencarian atau filter.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: bills.length,
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      return BillCard(
                        bill: bill,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BillDetailScreen(
                                provider: widget.provider,
                                bill: bill,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
