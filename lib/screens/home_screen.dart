import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../widgets/bill_card.dart';
import '../widgets/responsive_layout.dart';
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

  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF5F7FB);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: AnimatedBuilder(
        animation: provider,
        builder: (context, child) {
          // Semua data ringkasan menggunakan sumber yang sama.
          final unpaidBills = provider.unpaidBills;
          final paidBills = provider.paidBills;
          final totalUnpaid = provider.totalUnpaid;
          final totalPaid = provider.totalPaid;

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final overdueCount = unpaidBills.where((bill) {
            final dueDate = DateTime(
              bill.dueDate.year,
              bill.dueDate.month,
              bill.dueDate.day,
            );
            return dueDate.isBefore(today);
          }).length;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final isCompact = constraints.maxWidth < 420;

              return ResponsiveLayout(
                maxContentWidth: 1200,
                child: ListView(
                  padding: EdgeInsets.all(isCompact ? 16 : 24),
                  children: [
                    _buildHeroCard(
                      context,
                      isMobile: isMobile,
                      totalUnpaid: totalUnpaid,
                      unpaidCount: unpaidBills.length,
                      overdueCount: overdueCount,
                    ),
                    const SizedBox(height: 26),

                    _buildSectionHeader(
                      'Ringkasan',
                      'Lihat kondisi tagihanmu',
                    ),
                    const SizedBox(height: 14),

                    _buildSummaryGrid(
                      isMobile: isMobile,
                      totalUnpaid: totalUnpaid,
                      totalPaid: totalPaid,
                      unpaidCount: unpaidBills.length,
                      paidCount: paidBills.length,
                      overdueCount: overdueCount,
                    ),
                    const SizedBox(height: 28),

                    _buildSectionHeader(
                      'Tagihan Mendatang',
                      'Prioritaskan pembayaranmu',
                      trailing: TextButton(
                        onPressed: () => onNavigate(1),
                        child: const Text('Lihat Semua'),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (unpaidBills.isEmpty)
                      _buildEmptyBills(context)
                    else
                      ...unpaidBills.take(3).map(
                        (bill) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BillCard(
                            bill: bill,
                            onTap: () => _openBillDetail(context, bill),
                          ),
                        ),
                      ),

                    const SizedBox(height: 18),

                    _buildSectionHeader(
                      'Aksi Cepat',
                      'Kelola tagihan dengan mudah',
                    ),
                    const SizedBox(height: 14),

                    _buildQuickActions(isMobile: isMobile),

                    const SizedBox(height: 28),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'ExpenseTask • Kelola tagihan lebih teratur',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                          ),
                        ),
                      ),
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

  Widget _buildHeroCard(
    BuildContext context, {
    required bool isMobile,
    required double totalUnpaid,
    required int unpaidCount,
    required int overdueCount,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Total Tagihan Belum Dibayar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            _formatRupiah(totalUnpaid),
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 29 : 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$unpaidCount tagihan menunggu pembayaran',
            style: const TextStyle(
              color: Color(0xFFDCE7FF),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroBadge(
                Icons.receipt_long_rounded,
                '$unpaidCount Belum Dibayar',
              ),
              _heroBadge(
                Icons.warning_amber_rounded,
                '$overdueCount Terlambat',
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openAddBill(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Tagihan'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: dark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildSummaryGrid({
    required bool isMobile,
    required double totalUnpaid,
    required double totalPaid,
    required int unpaidCount,
    required int paidCount,
    required int overdueCount,
  }) {
    final cards = [
      _summaryCard(
        title: 'Belum Dibayar',
        amount: _formatRupiah(totalUnpaid),
        subtitle: '$unpaidCount tagihan',
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _summaryCard(
        title: 'Sudah Dibayar',
        amount: _formatRupiah(totalPaid),
        subtitle: '$paidCount tagihan',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF10B981),
      ),
      _summaryCard(
        title: 'Terlambat',
        amount: '$overdueCount',
        subtitle: 'Perlu diperhatikan',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFEF4444),
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1) const SizedBox(width: 14),
        ],
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: dark,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBills(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Semua tagihan terkendali!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Belum ada tagihan yang perlu dibayar. '
            'Tambahkan tagihan baru jika diperlukan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => _openAddBill(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Tagihan'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions({required bool isMobile}) {
    final actions = [
      _QuickAction(
        title: 'Tambah Tagihan',
        subtitle: 'Catat tagihan baru',
        icon: Icons.add_card_rounded,
        color: const Color(0xFF2563EB),
        onTap: () => _openAddBillFromContext(),
      ),
      _QuickAction(
        title: 'Daftar Tagihan',
        subtitle: 'Kelola semua tagihan',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => onNavigate(1),
      ),
      _QuickAction(
        title: 'Riwayat',
        subtitle: 'Lihat pembayaran',
        icon: Icons.history_rounded,
        color: const Color(0xFF10B981),
        onTap: () => onNavigate(2),
      ),
      _QuickAction(
        title: 'Tentang Aplikasi',
        subtitle: 'Informasi ExpenseTask',
        icon: Icons.info_outline_rounded,
        color: const Color(0xFFF59E0B),
        onTap: () => onNavigate(3),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 132,
      ),
      itemBuilder: (context, index) {
        return _QuickActionCard(action: actions[index]);
      },
    );
  }

  void _openAddBillFromContext() {
    onNavigate(1);
  }

  String _formatRupiah(double amount) {
    final value = amount.round().toString();
    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'Rp $formatted';
  }

  Future<void> _openAddBill(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddBillScreen(provider: provider),
      ),
    );
  }

  void _openBillDetail(BuildContext context, Bill bill) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BillDetailScreen(
          bill: bill,
          provider: provider,
        ),
      ),
    );
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                action.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
