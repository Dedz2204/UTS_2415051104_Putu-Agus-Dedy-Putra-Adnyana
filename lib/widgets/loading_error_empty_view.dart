import 'package:flutter/material.dart';

class LoadingErrorEmptyView extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;

  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;

  final String loadingMessage;
  final VoidCallback? onRetry;

  const LoadingErrorEmptyView({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.isEmpty,
    this.emptyTitle = 'Belum Ada Data',
    this.emptyMessage = 'Data belum tersedia saat ini.',
    this.emptyIcon = Icons.inbox_outlined,
    this.loadingMessage = 'Memuat data...',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state.
    if (isLoading) {
      return const Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF2563EB),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat data...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Error state.
    if (errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 36,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Terjadi Kesalahan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Empty state.
    if (isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  emptyIcon,
                  size: 38,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}