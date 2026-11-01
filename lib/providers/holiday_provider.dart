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

  List<PublicHoliday> get holidays =>
      List.unmodifiable(_holidays);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool get isEmpty => !_isLoading && _holidays.isEmpty;

  Future<void> loadHolidays({int? year}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final selectedYear = year ?? DateTime.now().year;

      _holidays = await _repository.getPublicHolidays(
        selectedYear,
      );
    } catch (error) {
      _errorMessage = 'Gagal memuat hari libur: $error';
      _holidays = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    await loadHolidays();
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
