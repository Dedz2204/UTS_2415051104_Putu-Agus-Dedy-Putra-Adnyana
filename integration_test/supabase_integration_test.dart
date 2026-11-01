import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:expense_task/config/supabase_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Supabase Integration Test', () {
    setUpAll(() async {
      await SupabaseConfig.initialize();

      if (SupabaseConfig.client.auth.currentSession == null) {
        await SupabaseConfig.client.auth.signInAnonymously();
      }
    });

    testWidgets('Berhasil terhubung dan membaca data tabel bills',
        (tester) async {
      final client = SupabaseConfig.client;

      expect(client.auth.currentUser, isNotNull);

      final userId = client.auth.currentUser!.id;
      expect(userId, isNotEmpty);

      final response = await client
          .from('bills')
          .select()
          .eq('user_id', userId);

      expect(response, isA<List>());

      for (final bill in response) {
        expect(bill, isA<Map<String, dynamic>>());
        expect(bill['bill_name'], isNotNull);
      }
    });
  });
}
