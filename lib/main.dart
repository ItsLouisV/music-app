import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_shell.dart';
import 'providers/audio_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty) {
    debugPrint('WARNING: SUPABASE_URL is empty. Falling back to hardcoded URL.');
    supabaseUrl = 'https://tibclgizbjekdnnghtmq.supabase.co';
  }
  
  if (supabaseAnonKey.isEmpty) {
    supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpYmNsZ2l6Ympla2RubmdodG1xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc4NTY3ODIsImV4cCI6MjA5MzQzMjc4Mn0.5PX2LFskMdcaDgblIFgw9_GmajTtb-KuHoBojZug-SE';
  }

  await Supabase.initialize(
    url: supabaseUrl.trim(),
    anonKey: supabaseAnonKey.trim(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MusicApp(),
    ),
  );
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Music App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: session == null ? const LoginScreen() : const MainShell(),
    );
  }
}
