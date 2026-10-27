import 'package:flutter_test/flutter_test.dart';
import 'package:expense_task/models/public_holiday.dart';

void main() {
  group('PublicHoliday model', () {
    test('parses complete JSON correctly', () {
      final holiday = PublicHoliday.fromJson({
        'date': '2026-01-01',
        'localName': 'Tahun Baru',
        'name': 'New Year\'s Day',
        'countryCode': 'ID',
        'fixed': true,
        'global': true,
        'counties': null,
        'launchYear': 1967,
        'types': ['Public'],
      });

      expect(holiday.date, DateTime(2026, 1, 1));
      expect(holiday.localName, 'Tahun Baru');
      expect(holiday.name, 'New Year\'s Day');
      expect(holiday.countryCode, 'ID');
      expect(holiday.fixed, true);
      expect(holiday.global, true);
      expect(holiday.launchYear, 1967);
      expect(holiday.types, ['Public']);
    });

    test('handles incomplete JSON safely', () {
      final holiday = PublicHoliday.fromJson({
        'name': 'Hari Libur',
      });

      expect(holiday.name, 'Hari Libur');
      expect(holiday.localName, '');
      expect(holiday.countryCode, '');
      expect(holiday.date, DateTime(2000, 1, 1));
      expect(holiday.fixed, false);
      expect(holiday.global, false);
      expect(holiday.counties, isEmpty);
      expect(holiday.launchYear, isNull);
      expect(holiday.types, isEmpty);
    });

    test('converts model to JSON', () {
      final holiday = PublicHoliday(
        date: DateTime(2026, 1, 1),
        localName: 'Tahun Baru',
        name: 'New Year\'s Day',
        countryCode: 'ID',
        global: true,
        types: const ['Public'],
      );

      final json = holiday.toJson();

      expect(json['date'], '2026-01-01');
      expect(json['name'], 'New Year\'s Day');
      expect(json['countryCode'], 'ID');
      expect(json['global'], true);
      expect(json['types'], ['Public']);
    });
  });
}
