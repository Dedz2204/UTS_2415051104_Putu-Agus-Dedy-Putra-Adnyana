import 'package:flutter/foundation.dart';

import '../models/bill.dart';
import '../repositories/bill_repository.dart';

class BillProvider extends ChangeNotifier {
  BillProvider({BillRepository? repository})
      : _repository = repository ?? BillRepository() {
    loadBills();
  }

  final BillRepository _repository;

  List<Bill> _bills = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Bill> get bills => List.unmodifiable(_bills);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => !_isLoading && _bills.isEmpty;

  List<Bill> get unpaidBills {
    final result = _bills.where((bill) => !bill.isPaid).toList();
    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result;
  }

  List<Bill> get paidBills {
    final result = _bills.where((bill) => bill.isPaid).toList();

    result.sort(
      (a, b) =>
          (b.paidAt ?? b.dueDate).compareTo(a.paidAt ?? a.dueDate),
    );

    return result;
  }

  double get totalUnpaid =>
      unpaidBills.fold(0.0, (sum, bill) => sum + bill.amount);

  double get totalPaid =>
      paidBills.fold(0.0, (sum, bill) => sum + bill.amount);

  Future<void> loadBills() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bills = (await _repository.getBills()).toList();
    } catch (error) {
      _errorMessage = 'Gagal memuat tagihan: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBill(Bill bill) async {
    try {
      _errorMessage = null;

      final savedBill = await _repository.addBill(bill);

      _bills = [..._bills, savedBill];

      notifyListeners();
    } catch (error) {
      _errorMessage = 'Gagal menambahkan tagihan: $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBill(Bill updated) async {
    try {
      _errorMessage = null;

      await _repository.updateBill(updated);

      final index = _bills.indexWhere(
        (bill) => bill.id == updated.id,
      );

      if (index == -1) {
        throw StateError(
          'Tagihan tidak ditemukan di state aplikasi.',
        );
      }

      _bills[index] = updated;

      notifyListeners();
    } catch (error) {
      _errorMessage = 'Gagal memperbarui tagihan: $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markPaid(String id) async {
    final index = _bills.indexWhere((bill) => bill.id == id);

    if (index == -1) {
      throw StateError('Tagihan tidak ditemukan.');
    }

    final bill = _bills[index];

    if (bill.isPaid) return;

    final updatedBill = Bill(
      id: bill.id,
      name: bill.name,
      providerName: bill.providerName,
      amount: bill.amount,
      category: bill.category,
      dueDate: bill.dueDate,
      isPaid: true,
      paidAt: DateTime.now(),
      note: bill.note,
    );

    await updateBill(updatedBill);
  }

  Future<void> markUnpaid(String id) async {
    final index = _bills.indexWhere((bill) => bill.id == id);

    if (index == -1) {
      throw StateError('Tagihan tidak ditemukan.');
    }

    final bill = _bills[index];

    if (!bill.isPaid) return;

    final updatedBill = Bill(
      id: bill.id,
      name: bill.name,
      providerName: bill.providerName,
      amount: bill.amount,
      category: bill.category,
      dueDate: bill.dueDate,
      isPaid: false,
      paidAt: null,
      note: bill.note,
    );

    await updateBill(updatedBill);
  }

  Future<void> deleteBill(String id) async {
    try {
      _errorMessage = null;

      // Hapus data di database terlebih dahulu.
      await _repository.deleteBill(id);

      // Perbarui state hanya setelah database berhasil menghapus.
      _bills = _bills.where((bill) => bill.id != id).toList();

      notifyListeners();
    } catch (error) {
      // Data lokal tetap dipertahankan jika penghapusan gagal.
      _errorMessage = 'Gagal menghapus tagihan: $error';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}