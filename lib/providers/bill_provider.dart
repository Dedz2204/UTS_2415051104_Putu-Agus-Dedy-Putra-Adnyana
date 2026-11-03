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
  bool _isAdding = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  String? _errorMessage;

  List<Bill> get bills => List.unmodifiable(_bills);

  bool get isLoading => _isLoading;
  bool get isAdding => _isAdding;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;

  bool get isSaving => _isAdding || _isUpdating;

  bool get isProcessing => isSaving || _isDeleting;

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

  String _getFriendlyError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('connection refused')) {
      return 'Tidak dapat terhubung ke internet. Periksa koneksi kamu.';
    }

    if (message.contains('timeout')) {
      return 'Koneksi terlalu lama. Silakan coba kembali.';
    }

    if (message.contains('permission') ||
        message.contains('unauthorized') ||
        message.contains('401') ||
        message.contains('403')) {
      return 'Akses data ditolak. Silakan periksa autentikasi akun.';
    }

    return 'Terjadi kesalahan saat mengakses data. Silakan coba kembali.';
  }

  Future<void> loadBills() async {
    if (_isLoading || isProcessing) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bills = (await _repository.getBills()).toList();
    } catch (error) {
      _errorMessage =
          'Gagal memuat tagihan. ${_getFriendlyError(error)}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    await loadBills();
  }

  Future<void> addBill(Bill bill) async {
    if (isProcessing || _isLoading) return;

    _isAdding = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedBill = await _repository.addBill(bill);

      _bills = [..._bills, savedBill];
    } catch (error) {
      _errorMessage =
          'Gagal menambahkan tagihan. ${_getFriendlyError(error)}';
      rethrow;
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }

  Future<void> updateBill(Bill updated) async {
    if (isProcessing || _isLoading) return;

    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _bills.indexWhere(
        (bill) => bill.id == updated.id,
      );

      if (index == -1) {
        throw StateError('Tagihan tidak ditemukan.');
      }

      await _repository.updateBill(updated);

      _bills[index] = updated;
    } catch (error) {
      _errorMessage =
          'Gagal memperbarui tagihan. ${_getFriendlyError(error)}';
      rethrow;
    } finally {
      _isUpdating = false;
      notifyListeners();
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
    if (isProcessing || _isLoading) return;

    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteBill(id);

      _bills = _bills.where((bill) => bill.id != id).toList();
    } catch (error) {
      _errorMessage =
          'Gagal menghapus tagihan. ${_getFriendlyError(error)}';
      rethrow;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}