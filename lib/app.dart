import 'package:flutter/material.dart';

import 'routing/app_router.dart';
import 'services/game_service.dart';
import 'theme/rp_theme.dart';

class RatepanikApp extends StatefulWidget {
  const RatepanikApp({super.key});

  /// Global access to the game service for convenience.
  static GameService gameOf(BuildContext context) =>
      context.findAncestorStateOfType<_RatepanikAppState>()!.gameService;

  @override
  State<RatepanikApp> createState() => _RatepanikAppState();
}

class _RatepanikAppState extends State<RatepanikApp> {
  late final GameService gameService = GameService();

  @override
  void dispose() {
    gameService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameService,
      builder: (context, _) => MaterialApp.router(
        title: 'Ratepanik',
        debugShowCheckedModeBanner: false,
        theme: buildRpTheme(),
        routerConfig: appRouter,
      ),
    );
  }
}
