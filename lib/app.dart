import 'package:flutter/material.dart';

import 'routing/app_router.dart';
import 'theme/rp_theme.dart';

class RatepanikApp extends StatelessWidget {
  const RatepanikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ratepanik',
      debugShowCheckedModeBanner: false,
      theme: buildRpTheme(),
      routerConfig: appRouter,
    );
  }
}
