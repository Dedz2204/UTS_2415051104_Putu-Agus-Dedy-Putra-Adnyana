import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase Project URL
  static const String supabaseUrl =
      'https://zcedhakrlutuksajjrxl.supabase.co';

  // Supabase Publishable Key
  static const String supabasePublishableKey =
      'sb_publishable_UnB5LyC8SzkeLPEC9QOISg__aBf4eFU';

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }

  // Supabase Client
  static SupabaseClient get client =>
      Supabase.instance.client;
}

