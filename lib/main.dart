import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/screens/auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:todo_app/screens/auth_redirector.dart';
import 'package:todo_app/screens/home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  String supabaseKey = dotenv.env['SUPABASE_KEY']!;

  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthRedirector(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
      },
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system, // Adjusts theme based on system preference
    );
  }
}

// Light Theme
ThemeData _buildLightTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
      brightness: Brightness.light,
      primary: Colors.blueAccent,
      secondary: Colors.teal,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      surface: Colors.grey[200]!,
    ),
    textTheme: GoogleFonts.ubuntuTextTheme(base.textTheme).copyWith(
      displayLarge: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      titleLarge: const TextStyle(fontSize: 30, fontStyle: FontStyle.normal, color: Colors.black87),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.blue[100]!,
      selectedColor: Colors.teal[200],
      labelStyle: const TextStyle(color: Colors.black87),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

// Dark Theme
ThemeData _buildDarkTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
      brightness: Brightness.dark,
      primary: Colors.blueAccent,
      secondary: Colors.tealAccent,
      error: Colors.redAccent,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      surface: Colors.grey[850]!,
    ),
    textTheme: GoogleFonts.ubuntuTextTheme(base.textTheme).copyWith(
      displayLarge: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      titleLarge: const TextStyle(fontSize: 30, fontStyle: FontStyle.normal, color: Colors.white),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.blue[700]!,
      selectedColor: Colors.teal[700],
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent[400],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
