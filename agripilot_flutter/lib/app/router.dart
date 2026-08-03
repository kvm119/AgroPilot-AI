import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/language_screen.dart';
import '../../features/onboarding/presentation/consent_screen.dart';
import '../../features/onboarding/presentation/farm_setup_1.dart';
import '../../features/onboarding/presentation/farm_setup_2.dart';
import '../../features/onboarding/presentation/farm_setup_3.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/dosage_recommendation_screen.dart';
import '../../features/dashboard/presentation/screens/farm_activity_logs_screen.dart';
import '../../features/dashboard/presentation/screens/expert_consultation_screen.dart';
import '../../features/government/presentation/screens/government_schemes_screen.dart';
import '../../features/copilot/presentation/screens/copilot_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) {
        final fromSettings = state.uri.queryParameters['fromSettings'] == 'true';
        return LanguageScreen(fromSettings: fromSettings);
      },
    ),
    GoRoute(
      path: '/consent',
      builder: (context, state) => const ConsentScreen(),
    ),
    GoRoute(
      path: '/setup/1',
      builder: (context, state) => const FarmSetup1(),
    ),
    GoRoute(
      path: '/setup/2',
      builder: (context, state) => const FarmSetup2(),
    ),
    GoRoute(
      path: '/setup/3',
      builder: (context, state) => const FarmSetup3(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(), 
    ),
    GoRoute(
      path: '/copilot',
      builder: (context, state) => const CopilotScreen(), 
    ),
    GoRoute(
      path: '/dosage',
      builder: (context, state) => const DosageRecommendationScreen(), 
    ),
    GoRoute(
      path: '/logs',
      builder: (context, state) => const FarmActivityLogsScreen(), 
    ),
    GoRoute(
      path: '/expert',
      builder: (context, state) => const ExpertConsultationScreen(), 
    ),
    GoRoute(
      path: '/schemes',
      builder: (context, state) => const GovernmentSchemesScreen(), 
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
