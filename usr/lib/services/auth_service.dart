import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  /// Sends an OTP to the user's phone number using Supabase.
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phoneNumber);
      return true;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  /// Verifies the OTP sent to the user's phone using Supabase.
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.sms,
      );
      // If session is not null, the user is successfully logged in
      return response.session != null;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }
  
  /// Logs out the current user.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Gets the current authenticated user
  User? get currentUser => _supabase.auth.currentUser;
}
