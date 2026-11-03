import 'package:flutter_test/flutter_test.dart';
import 'package:expense_task/models/bill.dart';
import 'package:expense_task/providers/bill_provider.dart';
import 'package:expense_task/repositories/bill_repository.dart';

class FakeBillRepository extends BillRepository {
  FakeBillRepository({
    List<Bill> initialBills = const [],
    this.shouldFailLoading = false,
    this.shouldFailAdding = false,
    this.shouldFailUpdating = false,
    this.shouldFailDeleting = false,
  }) : _testBills = List<Bill>.from(initialBills);

  final List<Bill> _testBills;

  bool shouldFailLoading;
  final bool shouldFailAdding;
  final bool shouldFailUpdating;
  final bool shouldFailDeleting;

  @override
  Future<List<Bill>> getBills() async {
    if (shouldFailLoading) {
      throw Exception('Simulasi kegagalan memuat data');
    }

    return List<Bill>.unmodifiable(_testBills);
  }

  @override
  Future<Bill> addBill(Bill bill) async {
    if (shouldFailAdding) {
      throw Exception('Simulasi kegagalan menyimpan tagihan');
    }

    _testBills.add(bill);
    return bill;
  }

  @override
  Future<void> updateBill(Bill bill) async {
    if (shouldFailUpdating) {
      throw Exception('Simulasi kegagalan update');
    }

    final index = _testBills.indexWhere(
      (item) => item.id == bill.id,
    );

    if (index == -1) {
      throw StateError('Tagihan tidak ditemukan');
    }

    _testBills[index] = bill;
  }

  @override
  Future<void> deleteBill(String id) async {
    if (shouldFailDeleting) {
      throw Exception('Simulasi kegagalan menghapus data');
    }

    final index = _testBills.indexWhere(
      (bill) => bill.id == id,
    );

    if (index == -1) {
      throw StateError('Tagihan tidak ditemukan');
    }

    _testBills.removeAt(index);
  }
}

Bill createBill({
  String id = 'test-1',
  String name = 'Tagihan Internet',
  double amount = 250000,
  bool isPaid = false,
  DateTime? paidAt,
}) {
  return Bill(
    id: id,
    name: name,
    providerName: 'IndiHome',
    amount: amount,
    dueDate: DateTime(2026, 11, 1),
    category: BillCategory.internet,
    isPaid: isPaid,
    paidAt: paidAt ??
        (isPaid ? DateTime(2026, 10, 27) : null),
  );
}

void main() {
  group('BillProvider', () {
    test('memuat daftar tagihan dari repository', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(
          initialBills: [createBill()],
        ),
      );

      await Future<void>.delayed(Duration.zero);

      expect(provider.bills.length, 1);
      expect(provider.bills.first.name, 'Tagihan Internet');
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);

      provider.dispose();
    });

    test('menambahkan tagihan dan memperbarui state', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(),
      );

      await Future<void>.delayed(Duration.zero);
      await provider.addBill(createBill());

      expect(provider.bills.length, 1);
      expect(provider.bills.first.id, 'test-1');

      provider.dispose();
    });

    test('tidak menambahkan tagihan jika penyimpanan gagal', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(
          shouldFailAdding: true,
        ),
      );

      await Future<void>.delayed(Duration.zero);

      try {
        await expectLater(
          provider.addBill(createBill()),
          throwsException,
        );

        expect(provider.bills, isEmpty);
        expect(provider.isAdding, isFalse);
        expect(provider.hasError, isTrue);
        expect(
          provider.errorMessage,
          contains('Gagal menambahkan tagihan'),
        );
      } finally {
        provider.dispose();
      }
    });

    test('memperbarui nama dan jumlah tagihan', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(
          initialBills: [createBill()],
        ),
      );

      await Future<void>.delayed(Duration.zero);

      await provider.updateBill(
        createBill(
          name: 'Tagihan Internet Diperbarui',
          amount: 350000,
        ),
      );

      expect(
        provider.bills.first.name,
        'Tagihan Internet Diperbarui',
      );
      expect(provider.bills.first.amount, 350000);

      provider.dispose();
    });

    test('tidak mengubah state jika update gagal', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(
          initialBills: [createBill()],
          shouldFailUpdating: true,
        ),
      );

      await Future<void>.delayed(Duration.zero);

      try {
        await expectLater(
          provider.updateBill(
            createBill(name: 'Nama Baru'),
          ),
          throwsException,
        );

        expect(provider.bills.first.name, 'Tagihan Internet');
        expect(provider.isUpdating, isFalse);
        expect(provider.hasError, isTrue);
      } finally {
        provider.dispose();
      }
    });

    test('mengubah status tagihan menjadi Paid', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(
          initialBills: [createBill()],
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await provider.markPaid('test-1');

      expect(provider.bills.first.isPaid, isTrue);
      expect(provider.bills.first.paidAt, isNotNull);
      expect(provider.paidBills.length, 1);
      expect(provider.unpaidBills, isEmpty);

      provider.dispose();
    });

    test('mengubah status tagihan kembali menjadi Unpaid', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(
          initialBills: [
            createBill(
              isPaid: true,
              paidAt: DateTime(2026, 10, 27),
            ),
          ],
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await provider.markUnpaid('test-1');

      expect(provider.bills.first.isPaid, isFalse);
      expect(provider.bills.first.paidAt, isNull);
      expect(provider.unpaidBills.length, 1);
      expect(provider.paidBills, isEmpty);

      provider.dispose();
    });

    test('menghapus tagihan dari state', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(
          initialBills: [createBill()],
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await provider.deleteBill('test-1');

      expect(provider.bills, isEmpty);
      expect(provider.isEmpty, isTrue);

      provider.dispose();
    });

    test('tidak mengubah state jika delete gagal', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(
          initialBills: [createBill()],
          shouldFailDeleting: true,
        ),
      );

      await Future<void>.delayed(Duration.zero);

      try {
        await expectLater(
          provider.deleteBill('test-1'),
          throwsException,
        );

        expect(provider.bills.length, 1);
        expect(provider.bills.first.id, 'test-1');
        expect(
          provider.bills.first.name,
          'Tagihan Internet',
        );
        expect(provider.isEmpty, isFalse);
        expect(provider.isDeleting, isFalse);
        expect(provider.hasError, isTrue);
      } finally {
        provider.dispose();
      }
    });

    test('menangani daftar tagihan kosong', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(),
      );

      await Future<void>.delayed(Duration.zero);

      expect(provider.bills, isEmpty);
      expect(provider.isEmpty, isTrue);
      expect(provider.hasError, isFalse);

      provider.dispose();
    });

    test('menangani kegagalan memuat tagihan', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(
          shouldFailLoading: true,
        ),
      );

      await Future<void>.delayed(Duration.zero);

      expect(provider.hasError, isTrue);
      expect(
        provider.errorMessage,
        contains('Gagal memuat tagihan'),
      );
      expect(provider.isLoading, isFalse);

      provider.dispose();
    });

    test('berhasil retry setelah kegagalan memuat tagihan', () async {
      final repository = FakeBillRepository(
        shouldFailLoading: true,
      );

      final provider = BillProvider(
        repository: repository,
      );

      await Future<void>.delayed(Duration.zero);

      expect(provider.hasError, isTrue);
      expect(provider.bills, isEmpty);

      repository.shouldFailLoading = false;

      try {
        await provider.retry();

        expect(provider.hasError, isFalse);
        expect(provider.isLoading, isFalse);
        expect(provider.bills, isEmpty);
      } finally {
        provider.dispose();
      }
    });

    test('mengirim notifikasi ketika state berubah', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(),
      );

      await Future<void>.delayed(Duration.zero);

      var notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      await provider.addBill(createBill());

      expect(notificationCount, greaterThan(0));

      provider.dispose();
    });

    test('mengirim notifikasi ketika delete berhasil', () async {
      final provider = BillProvider(
        repository: FakeBillRepository(
          initialBills: [createBill()],
        ),
      );

      await Future<void>.delayed(Duration.zero);

      var notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      await provider.deleteBill('test-1');

      expect(notificationCount, greaterThan(0));
      expect(provider.bills, isEmpty);

      provider.dispose();
    });
  });
}