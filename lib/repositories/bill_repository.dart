import '../models/bill.dart';

class BillRepository {
  final List<Bill> _bills = [
    Bill(
      id: '1',
      name: 'Tagihan Internet',
      providerName: 'IndiHome',
      amount: 250000,
      dueDate: DateTime(2026, 10, 28),
      category: BillCategory.internet,
    ),
    Bill(
      id: '2',
      name: 'Tagihan Listrik',
      providerName: 'PLN',
      amount: 350000,
      dueDate: DateTime(2026, 10, 30),
      category: BillCategory.listrik,
    ),
    Bill(
      id: '3',
      name: 'Langganan Bulanan',
      providerName: 'Layanan Digital',
      amount: 150000,
      dueDate: DateTime(2026, 11, 2),
      category: BillCategory.lainnya,
    ),
    Bill(
      id: '4',
      name: 'Tagihan Air',
      providerName: 'PDAM',
      amount: 75000,
      dueDate: DateTime(2026, 10, 25),
      category: BillCategory.air,
      isPaid: true,
      paidAt: DateTime(2026, 10, 24),
    ),
    Bill(
      id: '5',
      name: 'Paket Telepon',
      providerName: 'Operator Seluler',
      amount: 425000,
      dueDate: DateTime(2026, 10, 20),
      category: BillCategory.telepon,
      isPaid: true,
      paidAt: DateTime(2026, 10, 19),
    ),
  ];

    Future<List<Bill>> getBills() async {
    return List.unmodifiable(_bills);
  }

  Future<void> addBill(Bill bill) async {
    _bills.add(bill);
  }

  Future<void> updateBill(Bill bill) async {
    final index = _bills.indexWhere((item) => item.id == bill.id);

    if (index == -1) {
      throw StateError('Tagihan tidak ditemukan.');
    }

    _bills[index] = bill;
  }

  Future<void> deleteBill(String id) async {
    _bills.removeWhere((bill) => bill.id == id);
  }
}
