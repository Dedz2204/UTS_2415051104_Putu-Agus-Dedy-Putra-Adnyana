import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:expense_task/services/holiday_api_service.dart';

void main() {
  group('HolidayApiService Tests', () {
    test('Berhasil mengambil dan parsing data hari libur', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.toString(),
          'https://date.nager.at/api/v3/PublicHolidays/2026/ID',
        );

        return http.Response(
          jsonEncode([
            {
              'date': '2026-01-01',
              'localName': 'Tahun Baru Masehi',
              'name': "New Year's Day",
              'countryCode': 'ID',
              'fixed': true,
              'global': true,
              'counties': null,
              'launchYear': null,
              'types': ['Public'],
            }
          ]),
          200,
        );
      });

      final service = HolidayApiService(client: client);
      addTearDown(service.dispose);

      final result = await service.fetchPublicHolidays(2026);

      expect(result.length, 1);
      expect(result.first.localName, 'Tahun Baru Masehi');
      expect(result.first.name, "New Year's Day");
      expect(result.first.countryCode, 'ID');
      expect(result.first.date, DateTime(2026, 1, 1));
    });

    test('Berhasil menangani respons API kosong', () async {
      final client = MockClient((request) async {
        return http.Response('[]', 200);
      });

      final service = HolidayApiService(client: client);
      addTearDown(service.dispose);

      final result = await service.fetchPublicHolidays(2026);

      expect(result, isEmpty);
    });

    test('Menangani kegagalan koneksi API', () async {
      final client = MockClient((request) async {
        throw http.ClientException('No internet connection');
      });

      final service = HolidayApiService(client: client);
      addTearDown(service.dispose);

      expect(
        service.fetchPublicHolidays(2026),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'error message',
            contains('Kesalahan koneksi API'),
          ),
        ),
      );
    });
  });
}
