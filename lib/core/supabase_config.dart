import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://uwbhgveknypqvrwazleq.supabase.co',
);

const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> initSupabase() async {
  assert(
    _supabaseAnonKey.isNotEmpty,
    'SUPABASE_ANON_KEY must be set via --dart-define=SUPABASE_ANON_KEY=…',
  );
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
}

SupabaseClient get supabase => Supabase.instance.client;
