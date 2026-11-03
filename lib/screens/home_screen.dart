import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../providers/bill_provider.dart';
import '../providers/holiday_provider.dart';
import '../widgets/bill_card.dart';
import '../widgets/responsive_layout.dart';
import 'add_bill_screen.dart';
import 'bill_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final BillProvider provider;
  final HolidayProvider holidayProvider;
  final ValueChanged<int> onNavigate;

  const HomeScreen({
    super.key,
    required this.provider,
    required this.holidayProvider,
    required this.onNavigate,
  });

  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: AnimatedBuilder(
        animation: provider,
        builder: (context, child) {
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
              final width = constraints.maxWidth;
              final isMobile = width < ResponsiveLayout.mobileBreakpoint;
              final isCompact = width < 420;

              return ResponsiveLayout(
                maxContentWidth: 1200,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16 : 24,
                    vertical: isCompact ? 20 : 28,
                  ),
                  children: [
                    _buildWelcomeHeader(now),
                    const SizedBox(height: 24),

                    _buildHeroCard(
                      context,
                      isMobile: isMobile,
                      totalUnpaid: totalUnpaid,
                      unpaidCount: unpaidBills.length,
                      overdueCount: overdueCount,
                    ),
                    const SizedBox(height: 30),

                    _buildSectionHeader(
                      'Ringkasan Keuangan',
                      'Pantau kondisi pembayaran tagihanmu',
                    ),
                    const SizedBox(height: 14),

                    _buildSummaryGrid(
                      width: width,
                      totalUnpaid: totalUnpaid,
                      totalPaid: totalPaid,
                      unpaidCount: unpaidBills.length,
                      paidCount: paidBills.length,
                      overdueCount: overdueCount,
                    ),
                    const SizedBox(height: 30),

                    _buildSectionHeader(
                      'Tagihan Mendatang',
                      'Tagihan yang perlu kamu perhatikan',
                      trailing: TextButton(
                        onPressed: () => onNavigate(1),
                        child: const Text('Lihat Semua'),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (unpaidBills.isEmpty)
                      _buildEmptyBills(context)
                    else
                      ..._getUpcomingBills(unpaidBills).map(
                        (bill) => BillCard(
                          bill: bill,
                          onTap: () => _openBillDetail(context, bill),
                        ),
                      ),

                    const SizedBox(height: 18),

                    _buildSectionHeader(
                      'Aksi Cepat',
                      'Akses fitur PayTrack dengan mudah',
                    ),
                    const SizedBox(height: 14),

                    _buildQuickActions(context, width: width),
                    const SizedBox(height: 30),

                    _buildSectionHeader(
                      'Informasi Hari Libur',
                      'Jadwal hari libur nasional Indonesia',
                    ),
                    const SizedBox(height: 14),

                    _buildHolidaySection(),
                    const SizedBox(height: 28),

                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'PayTrack • Kelola tagihan lebih teratur',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: muted, fontSize: 11),
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

  // Header sapaan berdasarkan waktu.
  Widget _buildWelcomeHeader(DateTime now) {
    final hour = now.hour;

    final greeting = hour < 11
        ? 'Selamat pagi,'
        : hour < 15
        ? 'Selamat siang,'
        : hour < 18
        ? 'Selamat sore,'
        : 'Selamat malam,';

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final date = '${now.day} ${months[now.month - 1]} ${now.year}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kelola Keuanganmu',
                style: TextStyle(
                  color: dark,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(date, style: const TextStyle(color: muted, fontSize: 12)),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: border),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: primary,
            size: 23,
          ),
        ),
      ],
    );
  }

  // Hero card total tagihan.
  Widget _buildHeroCard(
    BuildContext context, {
    required bool isMobile,
    required double totalUnpaid,
    required int unpaidCount,
    required int overdueCount,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Total Tagihan Belum Dibayar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFFBFDBFE),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _formatRupiah(totalUnpaid),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 27 : 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$unpaidCount tagihan menunggu pembayaran',
            style: const TextStyle(color: Color(0xFFDBEAFE), fontSize: 12),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 9,
            runSpacing: 9,
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
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openAddBill(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'Tambah Tagihan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
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
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }

  // Kartu ringkasan responsif.
  Widget _buildSummaryGrid({
    required double width,
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
        color: const Color(0xFFD97706),
      ),
      _summaryCard(
        title: 'Sudah Dibayar',
        amount: _formatRupiah(totalPaid),
        subtitle: '$paidCount tagihan',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF059669),
      ),
      _summaryCard(
        title: 'Terlambat',
        amount: '$overdueCount',
        subtitle: 'Perlu diperhatikan',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFDC2626),
      ),
    ];

    final crossAxisCount = width < 600
        ? 1
        : width < 1024
        ? 2
        : 3;

    if (crossAxisCount == 1) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 132,
      ),
      itemBuilder: (context, index) => cards[index],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: dark.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
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

  // Daftar tagihan diurutkan berdasarkan tanggal jatuh tempo.
  List<Bill> _getUpcomingBills(List<Bill> bills) {
    final sortedBills = List<Bill>.from(bills);

    sortedBills.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return sortedBills.take(3).toList();
  }

  Widget _buildEmptyBills(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.task_alt_rounded, color: primary, size: 32),
          ),
          const SizedBox(height: 15),
          const Text(
            'Semua tagihan terkendali!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Belum ada tagihan yang perlu dibayar. '
            'Tambahkan tagihan baru jika diperlukan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _openAddBill(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Tagihan'),
          ),
        ],
      ),
    );
  }

  // Aksi cepat.
  Widget _buildQuickActions(BuildContext context, {required double width}) {
    final actions = [
      _QuickAction(
        title: 'Tambah Tagihan',
        subtitle: 'Catat tagihan baru',
        icon: Icons.add_card_rounded,
        color: const Color(0xFF2563EB),
        onTap: () => _openAddBill(context),
      ),
      _QuickAction(
        title: 'Daftar Tagihan',
        subtitle: 'Kelola semua tagihan',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => onNavigate(1),
      ),
      _QuickAction(
        title: 'Riwayat Pembayaran',
        subtitle: 'Lihat transaksi',
        icon: Icons.history_rounded,
        color: const Color(0xFF059669),
        onTap: () => onNavigate(2),
      ),
      _QuickAction(
        title: 'Tentang Aplikasi',
        subtitle: 'Informasi PayTrack',
        icon: Icons.info_outline_rounded,
        color: const Color(0xFFD97706),
        onTap: () => onNavigate(3),
      ),
    ];

    final columns = width < 600
        ? 2
        : width < 1024
        ? 2
        : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 126,
      ),
      itemBuilder: (context, index) {
        return _QuickActionCard(action: actions[index]);
      },
    );
  }

  // Informasi hari libur dari REST API.
  Widget _buildHolidaySection() {
    return AnimatedBuilder(
      animation: holidayProvider,
      builder: (context, child) {
        if (holidayProvider.isLoading) {
          return _holidayState(
            icon: Icons.hourglass_top_rounded,
            message: 'Memuat informasi hari libur...',
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (holidayProvider.hasError) {
          return _holidayState(
            icon: Icons.wifi_off_rounded,
            message: 'Gagal memuat informasi hari libur.',
            child: OutlinedButton.icon(
              onPressed: () => holidayProvider.retry(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          );
        }

        if (holidayProvider.isEmpty) {
          return _holidayState(
            icon: Icons.event_busy_rounded,
            message: 'Belum ada data hari libur untuk tahun ini.',
          );
        }

        final holidays = holidayProvider.holidays;

        return Column(
          children: holidays.map((holiday) {
            final date = holiday.date;

            final formattedDate =
                '${date.day.toString().padLeft(2, '0')} '
                '${_monthName(date.month)} ${date.year}';

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event_rounded,
                      color: primary,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          holiday.localName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: dark,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formattedDate,
                          style: const TextStyle(color: muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF10B981),
                    size: 19,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _holidayState({
    required IconData icon,
    required String message,
    Widget? child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(icon, color: primary, size: 30),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          if (child != null) ...[const SizedBox(height: 13), child],
        ],
      ),
    );
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
      MaterialPageRoute(builder: (_) => AddBillScreen(provider: provider)),
    );
  }

  void _openBillDetail(BuildContext context, Bill bill) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BillDetailScreen(bill: bill, provider: provider),
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(action.icon, color: action.color, size: 21),
              ),
              const SizedBox(height: 9),
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
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
