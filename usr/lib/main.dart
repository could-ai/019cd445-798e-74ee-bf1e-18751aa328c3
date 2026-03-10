import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'integrations/supabase.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/home_screen.dart';
import 'screens/club_selection_screen.dart';
import 'screens/selection_summary_screen.dart';
import 'screens/active_round_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling async methods
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with the project's URL and Anon Key
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Phone Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // CRITICAL: Always explicitly set initialRoute to '/' and register it in routes
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/otp': (context) => const OtpScreen(),
        '/home': (context) => const HomeScreen(),
        '/club_selection': (context) => const ClubSelectionScreen(),
        '/summary': (context) => const SelectionSummaryScreen(),
        '/active_round': (context) => const ActiveRoundScreen(),
      },
    );
  }
}
