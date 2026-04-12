import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<void> signInWithOtp(String email, {Map<String, dynamic>? data}) async {
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
      data: data,
    );
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      type: OtpType.email, // magiclink covers OTP codes sent via signInWithOtp
      token: token,
      email: email,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
