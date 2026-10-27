import 'package:flutter/foundation.dart';

import '../models/bill.dart';

class BillProvider extends ChangeNotifier {
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

  List<Bill> get bills => List.unmodifiable(_bills);

  List<Bill> get unpaidBills {
    final result = _bills.where((b) => !b.isPaid).toList();
    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result;
  }

  List<Bill> get paidBills {
    final result = _bills.where((b) => b.isPaid).toList();
    result.sort(
      (a, b) => (b.paidAt ?? b.dueDate).compareTo(a.paidAt ?? a.dueDate),
    );
    return result;
  }

  double get totalUnpaid => unpaidBills.fold(0.0, (sum, b) => sum + b.amount);

  double get totalPaid => paidBills.fold(0.0, (sum, b) => sum + b.amount);

  void addBill(Bill bill) {
    _bills.add(bill);
    notifyListeners();
  }

  void updateBill(Bill updated) {
    final index = _bills.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      _bills[index] = updated;
      notifyListeners();
    }
  }

  void deleteBill(String id) {
    _bills.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void markPaid(String id) {
    final index = _bills.indexWhere((b) => b.id == id);
    if (index == -1) return;

    _bills[index] = _bills[index].copyWith(
      isPaid: true,
      paidAt: DateTime.now(),
    );
    notifyListeners();
  }
}
