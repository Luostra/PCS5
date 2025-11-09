import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_page.dart';

const supabaseUrl = 'https://ehiqncbnfmsilvrprzfc.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVoaXFuY2JuZm1zaWx2cnByemZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0MTI4NDAsImV4cCI6MjA3Nzk4ODg0MH0.OhjnMA4meU6jJp86GviXtjyxQhMxFoYHygt5AsbaOMY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Notes',
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
    );
  }
}
