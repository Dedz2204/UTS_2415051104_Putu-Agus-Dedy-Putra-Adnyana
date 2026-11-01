import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/bill.dart';

class SupabaseBillService {
  final SupabaseClient? _injectedClient;

  SupabaseBillService({SupabaseClient? client})
      : _injectedClient = client;

  SupabaseClient get _client =>
      _injectedClient ?? SupabaseConfig.client;

  String get _userId {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw StateError('Pengguna belum login.');
    }

    return user.id;
  }

  Future<List<Bill>> getBills() async {
    final response = await _client
        .from('bills')
        .select()
        .eq('user_id', _userId)
        .order('due_date', ascending: true);

    return response.map((json) => Bill.fromJson(json)).toList();
  }

  Future<Bill> addBill(Bill bill) async {
    final response = await _client
        .from('bills')
        .insert({
          'bill_name': bill.name,
          'provider_name': bill.providerName,
          'amount': bill.amount,
          'category': bill.category.name,
          'due_date': bill.dueDate.toIso8601String().split('T').first,
          'payment_status': bill.isPaid ? 'paid' : 'unpaid',
          'paid_at': bill.paidAt?.toIso8601String(),
          'note': bill.note,
          'user_id': _userId,
        })
        .select()
        .single();

    return Bill.fromJson(response);
  }

  Future<void> updateBill(Bill bill) async {
    final response = await _client
        .from('bills')
        .update({
          'bill_name': bill.name,
          'provider_name': bill.providerName,
          'amount': bill.amount,
          'category': bill.category.name,
          'due_date': bill.dueDate.toIso8601String().split('T').first,
          'payment_status': bill.isPaid ? 'paid' : 'unpaid',

          // Status Unpaid akan mengosongkan paid_at.
          'paid_at': bill.isPaid
              ? (bill.paidAt ?? DateTime.now()).toIso8601String()
              : null,

          'note': bill.note,
        })
        .eq('id', int.parse(bill.id))
        .eq('user_id', _userId)
        .select()
        .maybeSingle();

    if (response == null) {
      throw StateError(
        'Tagihan tidak ditemukan atau tidak memiliki akses untuk diperbarui.',
      );
    }
  }

  Future<void> deleteBill(String id) async {
    await _client
        .from('bills')
        .delete()
        .eq('id', int.parse(id))
        .eq('user_id', _userId);
  }
}