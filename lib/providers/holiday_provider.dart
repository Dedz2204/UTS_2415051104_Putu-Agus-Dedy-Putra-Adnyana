import 'package:flutter/foundation.dart';

import '../models/public_holiday.dart';
import '../repositories/holiday_repository.dart';

class HolidayProvider extends ChangeNotifier {
  HolidayProvider({HolidayRepository? repository})
      : _repository = repository ?? HolidayRepository() {
    loadHolidays();
  }

  final HolidayRepository _repository;

  List<PublicHoliday> _holidays = [];

  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedYear;

  List<PublicHoliday> get holidays =>
      List.unmodifiable(_holidays);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool get isEmpty => !_isLoading && _holidays.isEmpty;

  String _getFriendlyError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('connection refused')) {
      return 'Tidak dapat terhubung ke internet. Periksa koneksi kamu.';
    }

    if (message.contains('timeout')) {
      return 'Permintaan terlalu lama. Silakan coba kembali.';
    }

    if (message.contains('404')) {
      return 'Data hari libur tidak ditemukan.';
    }

    if (message.contains('500') ||
        message.contains('502') ||
        message.contains('503')) {
      return 'Server sedang bermasalah. Silakan coba kembali nanti.';
    }

    return 'Gagal mengambil data hari libur. Silakan coba kembali.';
  }

  Future<void> loadHolidays({int? year}) async {
    if (_isLoading) return;

    _selectedYear = year ?? DateTime.now().year;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getPublicHolidays(
        _selectedYear!,
      );

      _holidays = result;
    } catch (error) {
      _errorMessage = _getFriendlyError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    await loadHolidays(year: _selectedYear);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
