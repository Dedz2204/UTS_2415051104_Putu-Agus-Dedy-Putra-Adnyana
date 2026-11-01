import '../models/bill.dart';
import '../services/supabase_bill_service.dart';

class BillRepository {
  final SupabaseBillService _service;

  BillRepository({SupabaseBillService? service})
      : _service = service ?? SupabaseBillService();

  Future<List<Bill>> getBills() async {
    return _service.getBills();
  }

  Future<Bill> addBill(Bill bill) async {
    return _service.addBill(bill);
  }

  Future<void> updateBill(Bill bill) async {
    await _service.updateBill(bill);
  }

  Future<void> deleteBill(String id) async {
    await _service.deleteBill(id);
  }
}