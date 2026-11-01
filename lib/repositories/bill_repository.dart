import '../models/bill.dart';
import '../services/supabase_bill_service.dart';

class BillRepository {
  final SupabaseBillService _service;

  BillRepository({SupabaseBillService? service})
      : _service = service ?? SupabaseBillService();

  Future<List<Bill>> getBills() {
    return _service.getBills();
  }

  Future<Bill> addBill(Bill bill) {
    return _service.addBill(bill);
  }

  Future<void> updateBill(Bill bill) {
    return _service.updateBill(bill);
  }

  Future<void> deleteBill(String id) {
    return _service.deleteBill(id);
  }
}
