import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 設定
class SupabaseConfig {
  static const String supabaseUrl = 'https://gnxtjyqjmmztlkogojyp.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdueHRqeXFqbW16dGxrb2dvanlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NTM3MjIsImV4cCI6MjA4MDIyOTcyMn0.cGywVnqkjztem6hyntrPgkoqYOAB1obfrAru4zcC8mo';

  /// Supabase初期化
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

/// Supabase クライアントへのショートカット
final supabase = Supabase.instance.client;
