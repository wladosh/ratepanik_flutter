import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/supabase_config.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  await initSupabase();
  runApp(const RatepanikApp());
}
