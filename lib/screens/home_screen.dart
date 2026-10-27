import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/summary_card.dart';
import 'add_bill_screen.dart';
import 'bill_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final BillProvider provider;
  final ValueChanged<int> onNavigate;

  const HomeScreen({
    super.key,
    required this.provider,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: provider,
        builder: (context, _) {
          final bills = provider.bills;
          final unpaidBills = bills.where((bill) => !bill.isPaid).toList();
          final paidBills = bills.where((bill) => bill.isPaid).toList();

          final totalUnpaid = unpaidBills.fold<double>(
            0,
            (total, bill) => total + bill.amount,
          );

          final totalPaid = paidBills.fold<double>(
            0,
            (total, bill) => total + bill.amount,
          );

          final upcomingBills = [...unpaidBills]
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final isCompact = constraints.maxWidth < 420;

              return ResponsiveLayout(
                maxContentWidth: 1200,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(0, isMobile ? 12 : 24, 0, 32),
                  children: [
                    // Header halaman tanpa logo atau judul aplikasi ganda.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _WelcomeHeader(
                            title: 'Ringkasan Tagihan',
                            subtitle:
                                'Pantau pembayaranmu agar tidak terlewat.',
                            isMobile: isMobile,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: IconButton(
                            tooltip: 'Riwayat Pembayaran',
                            onPressed: () => onNavigate(2),
                            icon: const Icon(Icons.history_rounded),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isMobile ? 18 : 24),

                    // Ringkasan tagihan responsif.
                    _SummaryGrid(
                      totalUnpaid: totalUnpaid,
                      totalPaid: totalPaid,
                      unpaidCount: unpaidBills.length,
                      paidCount: paidBills.length,
                      isCompact: isCompact,
                    ),

                    SizedBox(height: isMobile ? 24 : 32),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Tagihan Mendatang',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => onNavigate(1),
                          child: const Text('Lihat Semua'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (upcomingBills.isEmpty)
                      const _EmptyBills()
                    else
                      ...upcomingBills
                          .take(3)
                          .map(
                            (bill) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: BillCard(
                                bill: bill,
                                onTap: () => _openBillDetail(context, bill),
                              ),
                            ),
                          ),

                    SizedBox(height: isMobile ? 24 : 32),

                    const Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _QuickActions(
                      isCompact: isCompact,
                      onAddBill: () => _openAddBill(context),
                      onViewBills: () => onNavigate(1),
                      onViewHistory: () => onNavigate(2),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openAddBill(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddBillScreen(provider: provider)),
    );
  }

  void _openBillDetail(BuildContext context, Bill bill) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BillDetailScreen(provider: provider, bill: bill),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isMobile;

  const _WelcomeHeader({
    required this.title,
    required this.subtitle,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 21 : 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isMobile ? 12 : 15,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final double totalUnpaid;
  final double totalPaid;
  final int unpaidCount;
  final int paidCount;
  final bool isCompact;

  const _SummaryGrid({
    required this.totalUnpaid,
    required this.totalPaid,
    required this.unpaidCount,
    required this.paidCount,
    required this.isCompact,
  });

  String _formatRupiah(double amount) {
    final value = amount.round().toString();
    final formatted = value.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: isCompact ? 1 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isCompact ? 2.4 : 1.65,
      children: [
        SummaryCard(
          title: 'Belum Dibayar',
          amount: _formatRupiah(totalUnpaid),
          subtitle: '$unpaidCount tagihan',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF2563EB),
        ),
        SummaryCard(
          title: 'Sudah Dibayar',
          amount: _formatRupiah(totalPaid),
          subtitle: '$paidCount tagihan',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF16A34A),
        ),
      ],
    );
  }
}

class _EmptyBills extends StatelessWidget {
  const _EmptyBills();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 42, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text(
            'Tidak ada tagihan mendatang',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            'Tambahkan tagihan agar lebih mudah dipantau.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final bool isCompact;
  final VoidCallback onAddBill;
  final VoidCallback onViewBills;
  final VoidCallback onViewHistory;

  const _QuickActions({
    required this.isCompact,
    required this.onAddBill,
    required this.onViewBills,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickActionData(
        title: 'Tambah Tagihan',
        subtitle: 'Catat tagihan baru',
        icon: Icons.add_circle_outline_rounded,
        onTap: onAddBill,
      ),
      _QuickActionData(
        title: 'Daftar Tagihan',
        subtitle: 'Kelola tagihanmu',
        icon: Icons.receipt_long_rounded,
        onTap: onViewBills,
      ),
      _QuickActionData(
        title: 'Riwayat',
        subtitle: 'Lihat pembayaran',
        icon: Icons.history_rounded,
        onTap: onViewHistory,
      ),
    ];

    if (isCompact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: actions
            .map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QuickActionCard(action: action),
              ),
            )
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: actions
          .map(
            (action) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _QuickActionCard(action: action),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _QuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickActionData action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
