import 'package:capitalflow/core/env/env.dart';

class SupabaseConfig {
  static final url = Env.supabaseUrl;
  static final anonKey = Env.supabaseAnonKey;

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
