import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/public_holiday.dart';

class HolidayApiService {
  static const String _baseUrl = 'https://date.nager.at/api/v3';

  final http.Client _client;

  HolidayApiService({http.Client? client})
      : _client = client ?? http.Client();

  // Mengambil data hari libur berdasarkan tahun.
  Future<List<PublicHoliday>> fetchPublicHolidays(int year) async {
    final uri = Uri.parse(
      '$_baseUrl/PublicHolidays/$year/ID',
    );

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is! List) {
          throw const FormatException(
            'Format respons API bukan JSON array.',
          );
        }

        return decodedData.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
              'Format data hari libur tidak valid.',
            );
          }

          return PublicHoliday.fromJson(item);
        }).toList();
      }

      throw Exception(
        'Gagal mengambil data hari libur. '
        'HTTP Status: ${response.statusCode}',
      );
    } on http.ClientException catch (error) {
      throw Exception('Kesalahan koneksi API: $error');
    } on FormatException catch (error) {
      throw Exception('Format JSON tidak valid: $error');
    } on Exception {
      rethrow;
    } catch (error) {
      throw Exception('Terjadi kesalahan: $error');
    }
  }

  // Menutup HTTP client.
  void dispose() {
    _client.close();
  }
}
