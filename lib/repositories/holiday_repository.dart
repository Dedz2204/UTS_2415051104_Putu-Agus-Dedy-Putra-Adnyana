import '../models/public_holiday.dart';
import '../services/holiday_api_service.dart';

class HolidayRepository {
  final HolidayApiService _apiService;

  HolidayRepository({HolidayApiService? apiService})
      : _apiService = apiService ?? HolidayApiService();

  // Mengambil data hari libur dari API melalui service.
  Future<List<PublicHoliday>> getPublicHolidays(int year) async {
    return await _apiService.fetchPublicHolidays(year);
  }

  // Menutup service ketika tidak digunakan.
  void dispose() {
    _apiService.dispose();
  }
}
