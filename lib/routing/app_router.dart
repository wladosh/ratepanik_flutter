import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/landing/landing_screen.dart';

abstract final class RpRoutes {
  static const landing = '/';
  static const login = '/login';
  static const home = '/home';
}

final appRouter = GoRouter(
  initialLocation: RpRoutes.landing,
  routes: [
    GoRoute(
      path: RpRoutes.landing,
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: RpRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RpRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
