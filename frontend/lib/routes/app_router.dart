import 'package:go_router/go_router.dart';
import '../core/widgets/responsive_layout_wrapper.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/home/home_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/voice/presentation/voice_screen.dart';
import '../features/vision/presentation/vision_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/billing_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/home/explore_screen.dart';
import '../features/home/documents_screen.dart';
import '../features/home/document_detail_screen.dart';
import '../features/home/calendar_screen.dart';
import '../features/journal/presentation/create_journal_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/mood/presentation/mood_selection_screen.dart';
import '../features/profile/presentation/choose_plan_screen.dart';
import '../features/profile/presentation/purchase_summary_screen.dart';
import '../features/profile/presentation/payment_screen.dart';
import '../features/profile/presentation/payment_processing_screen.dart';
import '../features/profile/presentation/payment_success_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ResponsiveLayoutWrapper(usePhoneFrame: true, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/voice',
          name: 'voice',
          builder: (context, state) => const VoiceAssistantScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/billing',
          name: 'billing',
          builder: (context, state) => const BillingScreen(),
        ),
        GoRoute(
          path: '/choose-plan',
          name: 'choose-plan',
          builder: (context, state) => const ChoosePlanScreen(),
        ),
        GoRoute(
          path: '/purchase-summary',
          name: 'purchase-summary',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return PurchaseSummaryScreen(
              plan: extra['plan'] as String,
              price: extra['price'] as double,
            );
          },
        ),
        GoRoute(
          path: '/payment',
          name: 'payment',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return PaymentScreen(
              plan: extra['plan'] as String,
              price: extra['price'] as double,
            );
          },
        ),
        GoRoute(
          path: '/payment-processing',
          name: 'payment-processing',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return PaymentProcessingScreen(
              plan: extra['plan'] as String,
              paymentMethod: extra['paymentMethod'] as String,
            );
          },
        ),
        GoRoute(
          path: '/payment-success',
          name: 'payment-success',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return PaymentSuccessScreen(
              plan: extra['plan'] as String,
            );
          },
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/explore',
          name: 'explore',
          builder: (context, state) => const ExploreScreen(),
        ),
        GoRoute(
          path: '/documents',
          name: 'documents',
          builder: (context, state) => const DocumentsScreen(),
        ),
        GoRoute(
          path: '/document-detail',
          name: 'document-detail',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return DocumentDetailScreen(
              name: extra['name'] as String,
              size: extra['size'] as String,
              type: extra['type'] as String,
            );
          },
        ),
        GoRoute(
          path: '/calendar',
          name: 'calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/create-journal',
          name: 'create-journal',
          builder: (context, state) => const CreateJournalScreen(),
        ),
        GoRoute(
          path: '/mood-selection',
          name: 'mood-selection',
          builder: (context, state) => const MoodSelectionScreen(),
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ResponsiveLayoutWrapper(usePhoneFrame: false, child: child);
      },
      routes: [
        GoRoute(
          path: '/chat',
          name: 'chat',
          builder: (context, state) =>
              ChatScreen(documentContext: state.extra as String?),
        ),
        GoRoute(
          path: '/vision',
          name: 'vision',
          builder: (context, state) => const VisionAnalysisScreen(),
        ),
      ],
    ),
  ],
);
