import 'package:go_router/go_router.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/home/home_screen.dart';
import '../features/mosques/mosques_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/qibla', builder: (context, state) => const QiblaScreen()),
    GoRoute(path: '/calendar', builder: (context, state) => const CalendarScreen()),
    GoRoute(path: '/mosques', builder: (context, state) => const MosquesScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
  ],
);
