import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Add a slight delay to ensure the widget is mounted and for smooth transition
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // Check if the user is already logged in
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session != null) {
      // User is logged in, go to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // User is not logged in, go to login screen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_golf, size: 80, color: Colors.green),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.green),
          ],
        ),
      ),
    );
  }
}
