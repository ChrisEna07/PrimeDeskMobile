import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/cliente/client_dashboard.dart';
import 'screens/verify_email_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await initializeDateFormatting('es', null);
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://ynigfdldjybizqysmnaf.supabase.co',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'sb_publishable_1mSd8fQ2pRbUyKAjHqZzEw_pmstxGZ1',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: const PrimeDeskApp(),
    ),
  );
}

class PrimeDeskApp extends StatelessWidget {
  const PrimeDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrimeDesk - Rafa Motos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1113),
        primaryColor: const Color(0xFFFF6B00),
        secondaryHeaderColor: const Color(0xFF00B2FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B00),
          secondary: Color(0xFF00B2FF),
          surface: Color(0xFF1E2124),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E2124),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        useMaterial3: true,
      ),
      home: context.watch<AuthController>().user == null
          ? const LandingScreen()
          : (context.read<AuthController>().user!.idRol == 1 || context.read<AuthController>().user!.idRol == 2)
            ? const AdminDashboard()
            : const ClientDashboard(),
      routes: {
        '/landing': (context) => const LandingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verify_email': (context) => const VerifyEmailScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/admin_dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}
