import 'package:flutter_test/flutter_test.dart';
import 'package:expense_task/models/bill.dart';

void main() {
  group('Bill model', () {
    test('parses complete JSON correctly', () {
      final bill = Bill.fromJson({
        'id': 'bill-001',
        'name': 'Tagihan Internet',
        'providerName': 'IndiHome',
        'amount': 250000,
        'dueDate': '2026-10-28',
        'category': 'internet',
        'isPaid': false,
        'paidAt': null,
        'note': 'Bayar sebelum jatuh tempo',
      });

      expect(bill.id, 'bill-001');
      expect(bill.name, 'Tagihan Internet');
      expect(bill.providerName, 'IndiHome');
      expect(bill.amount, 250000);
      expect(bill.category, BillCategory.internet);
      expect(bill.isPaid, false);
      expect(bill.paidAt, isNull);
      expect(bill.note, 'Bayar sebelum jatuh tempo');
    });

    test('handles incomplete JSON safely', () {
      final bill = Bill.fromJson({
        'id': 'bill-002',
        'amount': '125000',
      });

      expect(bill.id, 'bill-002');
      expect(bill.name, '');
      expect(bill.amount, 125000);
      expect(bill.category, BillCategory.lainnya);
      expect(bill.isPaid, false);
      expect(bill.paidAt, isNull);
      expect(bill.note, isNull);
    });

    test('converts model to JSON', () {
      final bill = Bill(
        id: 'bill-003',
        name: 'Tagihan Listrik',
        providerName: 'PLN',
        amount: 350000,
        dueDate: DateTime(2026, 10, 30),
        category: BillCategory.listrik,
      );

      final json = bill.toJson();

      expect(json['id'], 'bill-003');
      expect(json['amount'], 350000.0);
      expect(json['category'], 'listrik');
      expect(json['isPaid'], false);
    });
  });
}
