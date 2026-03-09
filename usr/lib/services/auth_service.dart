// Mock AuthService for Supabase Phone Auth
// Note: Since no Supabase project is currently connected, this service uses mock delays.
// Once a project is connected, you can replace these with actual Supabase SDK calls.

class AuthService {
  /// Simulates sending an OTP to the user's phone number.
  /// Future implementation: await supabase.auth.signInWithOtp(phone: phoneNumber);
  Future<bool> sendOtp(String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock success
    return true;
  }

  /// Simulates verifying the OTP sent to the user's phone.
  /// Future implementation: await supabase.auth.verifyOTP(phone: phoneNumber, token: otp, type: OtpType.sms);
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock verification (accepts '123456' for testing purposes)
    return otp == '123456';
  }
  
  /// Simulates logging out.
  /// Future implementation: await supabase.auth.signOut();
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
