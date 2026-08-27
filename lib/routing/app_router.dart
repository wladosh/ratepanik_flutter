import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';
import '../features/landing/landing_screen.dart';
import '../features/lobby/lobby_screen.dart';
import '../features/match/match_shell.dart';
import '../features/shop/shop_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/friends/friends_screen.dart';
import '../features/achievements/achievements_screen.dart';

abstract final class RpRoutes {
  static const landing = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const lobby = '/lobby';
  static const match = '/match';
  static const shop = '/shop';
  static const profile = '/profile';
  static const friends = '/friends';
  static const achievements = '/achievements';
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
      path: RpRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RpRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: RpRoutes.lobby,
      builder: (context, state) => const LobbyScreen(),
    ),
    GoRoute(
      path: RpRoutes.match,
      builder: (context, state) => const MatchShell(),
    ),
    GoRoute(
      path: RpRoutes.shop,
      builder: (context, state) => const ShopScreen(),
    ),
    GoRoute(
      path: RpRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: RpRoutes.friends,
      builder: (context, state) => const FriendsScreen(),
    ),
    GoRoute(
      path: RpRoutes.achievements,
      builder: (context, state) => const AchievementsScreen(),
    ),
  ],
);
