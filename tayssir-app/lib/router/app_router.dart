import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tayssir/debug/app_logger.dart';
import 'package:tayssir/features/auth/presentation/verify-email/verify_email_screen.dart';
import 'package:tayssir/features/leaderboard/leaderboard_screen.dart';
import 'package:tayssir/features/notifications/presentation/notifications_screen.dart';
import 'package:tayssir/features/settings/contact_us/contact_us_screen.dart';
import 'package:tayssir/features/settings/security/change_email/change_email_screen.dart';
import 'package:tayssir/features/subscriptions/presentation/chargily/chargily_init_screen.dart';
import 'package:tayssir/features/subscriptions/presentation/chargily/chargily_web_view_screen.dart';
import 'package:tayssir/features/subscriptions/presentation/subscription_options_screen.dart';
import 'package:tayssir/features/subscriptions/presentation/paper/subscription_paper_screen.dart';
import 'package:tayssir/features/subscriptions/presentation/payments_methodes_screen.dart';
import 'package:tayssir/features/auth/presentation/auth_screen.dart';
import 'package:tayssir/features/auth/presentation/forget-password/forget_password_screen.dart';
import 'package:tayssir/features/auth/presentation/login/login_screen.dart';
import 'package:tayssir/features/auth/presentation/register/register_screen.dart';
import 'package:tayssir/features/exercice/presentation/exercice_result_screen.dart';
import 'package:tayssir/features/exercice/presentation/exercice_screen.dart';
import 'package:tayssir/features/exercice/presentation/post_exercise_screen.dart';
import 'package:tayssir/features/home/presentation/home_screen.dart';
import 'package:tayssir/features/profile/profile_screen.dart';
import 'package:tayssir/features/profile/achievement_log_screen.dart';
import 'package:tayssir/features/settings/security/security_screen.dart';
import 'package:tayssir/features/tools/bacs/bacs_screen.dart';
import 'package:tayssir/features/tools/grade_calc/grade_calculator_screen.dart';
import 'package:tayssir/features/tools/pomodoro/pomodoro_screen.dart';
import 'package:tayssir/features/splash/splash_screen.dart';
import 'package:tayssir/features/tools/card_swipper/card_swipper_screen.dart';
import 'package:tayssir/features/tools/common/pdf_content_screen.dart';
import 'package:tayssir/features/tools/resumes/resumes_screen.dart';
import '../features/ai_planner/presentation/ai_planner_popup.dart';
import 'package:tayssir/features/chapters/lesson_screen.dart';
import 'package:tayssir/features/chapters/lesson_result_screen.dart';
import 'package:tayssir/router/app_transitions.dart';

import '../features/chapters/chapters_screen.dart';
import '../features/settings/security/reset_password_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/subscriptions/presentation/card/subscription_card_screen.dart';
import '../features/tools/tools_screen.dart';
import '../features/units/units_screen.dart';
import 'package:tayssir/features/streaks/presentation/streak_screen.dart';
import 'package:tayssir/features/challanges/challenges_screen.dart';
import 'package:tayssir/features/challanges/presentation/matchmaking_screen.dart';
import 'package:tayssir/features/challanges/presentation/arena_screen.dart';
import 'package:tayssir/features/challanges/presentation/challenge_dashboard_screen.dart';
import 'package:tayssir/features/challanges/presentation/social_screen.dart';
import 'package:tayssir/features/onboarding/onboarding_screen.dart';
import 'bottom_navigation/main_scaffold.dart';
import 'not_found_screen.dart';
import 'routes_service.dart';

enum AppRoutes {
  splash,
  home,
  login,
  units,
  chapters,
  exercices,
  tools,
  leaderboard,
  challanges,
  challengeDashboard,
  challengeMatchmaking,
  challengeArena,
  settings,
  register,
  welcome,
  results,
  forgetPassword,
  profile,
  midResults,
  pomodoro,
  gradeCalculator,
  resumes,
  bacaluratSolutions,
  notifcations,
  security,
  changeUserInfo,
  subCard,
  subscriptions,
  aboutUs,
  version,
  contactUs,
  subscriptionOptions,
  resetPassword,
  postExercise,
  changeEmail,
  cardSwipper,
  pdfContent,
  bacs,
  verifyEmail,
  subscriptionPaper,
  chargilyWebView,
  chargilyInit,
  streak,
  achievementLog,
  onboarding,
  social,
  aiPlanner,
  lesson,
  lessonResults,
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.onDispose(() {
    AppLogger.logDebug('disposing app router');
  });
  final routesManager = ref.watch(routesServiceProvider);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: false,
    redirect: routesManager.onRedirect,
    errorBuilder: (context, state) {
      return const NotFoundScreen();
    },
    refreshListenable: Listenable.merge(routesManager.refreshables),
    initialLocation: '/startup',
    routes: [
      TayssirCustomGoRoute(
        name: AppRoutes.splash.name,
        path: '/startup',
        pageBuilder: (context, state) {
          return const SplashScreen();
        },
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              TayssirCustomGoRoute(
                path: '/tools',
                name: AppRoutes.tools.name,
                pageBuilder: (context, state) => const ToolsScreen(),
                transitionType: TransitionType.sharedAxis,
                duration: const Duration(milliseconds: 450),
                routes: [
                  TayssirCustomGoRoute(
                    path: 'pomodoro',
                    name: AppRoutes.pomodoro.name,
                    pageBuilder: (context, state) => const PomodoroScreen(),
                    transitionType: TransitionType.sharedAxis,
                    slideDirection: SlideDirection.left,
                    duration: const Duration(milliseconds: 600),
                  ),
                  TayssirCustomGoRoute(
                    path: 'grade-calc',
                    name: AppRoutes.gradeCalculator.name,
                    pageBuilder: (context, state) => const GradeCalculatorScreen(),
                    transitionType: TransitionType.sharedAxis,
                    slideDirection: SlideDirection.left,
                    duration: const Duration(milliseconds: 600),
                  ),
                  TayssirCustomGoRoute(
                    name: AppRoutes.cardSwipper.name,
                    path: '/card-swipper',
                    pageBuilder: (context, state) => const CardSwipperScreen(),
                    transitionType: TransitionType.sharedAxis,
                    slideDirection: SlideDirection.left,
                    duration: const Duration(milliseconds: 300),
                  ),
                  TayssirCustomGoRoute(
                    name: AppRoutes.resumes.name,
                    path: '/resumes',
                    pageBuilder: (context, state) => const ResumesScreen(),
                    routes: [
                      TayssirCustomGoRoute(
                        name: AppRoutes.pdfContent.name,
                        path: 'content',
                        pageBuilder: (context, state) {
                          final data = state.extra! as Map<String, dynamic>;
                          return PdfContentScreen(pdfUrl: data['pdfUrl']);
                        },
                      )
                    ],
                    transitionType: TransitionType.sharedAxis,
                    slideDirection: SlideDirection.left,
                    duration: const Duration(milliseconds: 300),
                  ),
                  TayssirCustomGoRoute(
                    name: AppRoutes.bacs.name,
                    path: '/bacs',
                    pageBuilder: (context, state) => const BacsScreen(),
                    transitionType: TransitionType.sharedAxis,
                    slideDirection: SlideDirection.left,
                    duration: const Duration(milliseconds: 300),
                  ),
                  TayssirCustomGoRoute(
                    name: AppRoutes.aiPlanner.name,
                    path: 'ai-planner',
                    pageBuilder: (context, state) => const Scaffold(
                      backgroundColor: Colors.transparent,
                      body: AIPlannerPopup(),
                    ),
                    transitionType: TransitionType.fade,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              TayssirCustomGoRoute(
                name: AppRoutes.leaderboard.name,
                path: '/leaderboard',
                pageBuilder: (context, state) => const LeaderboardScreen(),
                transitionType: TransitionType.sharedAxis,
                duration: const Duration(milliseconds: 450),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              TayssirCustomGoRoute(
                name: AppRoutes.home.name,
                path: '/home',
                pageBuilder: (context, state) => const HomeScreen(),
                transitionType: TransitionType.fadeThrough,
                duration: const Duration(milliseconds: 400),
                routes: [
                  TayssirCustomGoRoute(
                    path: 'units/:courseId',
                    name: AppRoutes.units.name,
                    pageBuilder: (context, state) {
                      final courseId = state.pathParameters['courseId'];
                      return UnitsScreen(courseId: int.parse(courseId!));
                    },
                    transitionType: TransitionType.fadeThrough,
                    duration: const Duration(milliseconds: 400),
                    routes: [
                      TayssirCustomGoRoute(
                        name: AppRoutes.chapters.name,
                        path: 'chapters/:unitId',
                        pageBuilder: (context, state) {
                          final unitId = state.pathParameters['unitId'];
                          return ChaptersScreen(unitId: int.parse(unitId!));
                        },
                        transitionType: TransitionType.fadeThrough,
                        duration: const Duration(milliseconds: 400),
                      ),
                    ],
                  ),
                  TayssirCustomGoRoute(
                    name: AppRoutes.subscriptionOptions.name,
                    path: 'sub-options',
                    pageBuilder: (context, state) => const SubscriptionOptionsScreen(),
                    transitionType: TransitionType.sharedAxis,
                    duration: const Duration(milliseconds: 300),
                    routes: [
                      TayssirCustomGoRoute(
                        name: AppRoutes.subscriptions.name,
                        path: 'subscriptions',
                        pageBuilder: (context, state) {
                          final data = state.extra! as Map<String, dynamic>;
                          return SubscriptionsScreen(subscription: data['subscription']);
                        },
                        transitionType: TransitionType.sharedAxis,
                        duration: const Duration(milliseconds: 300),
                        routes: [
                          TayssirCustomGoRoute(
                            name: AppRoutes.subCard.name,
                            path: 'card',
                            pageBuilder: (context, state) {
                              final data = state.extra! as Map<String, dynamic>;
                              return SubscriptionCardScreen(subscription: data['subscription']);
                            },
                            transitionType: TransitionType.sharedAxis,
                            duration: const Duration(milliseconds: 300),
                          ),
                          TayssirCustomGoRoute(
                            name: AppRoutes.subscriptionPaper.name,
                            path: 'paper',
                            pageBuilder: (context, state) {
                              final data = state.extra! as Map<String, dynamic>;
                              return SubscriptionPaperScreen(subscription: data['subscription']);
                            },
                            transitionType: TransitionType.sharedAxis,
                            duration: const Duration(milliseconds: 300),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/challanges',
                name: AppRoutes.challanges.name,
                pageBuilder: (context, state) => CupertinoPage(
                  key: state.pageKey,
                  child: const ChallengesScreen(),
                ),
                routes: [
                  TayssirCustomGoRoute(
                    name: AppRoutes.challengeDashboard.name,
                    path: 'dashboard',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => const ChallengeDashboardScreen(),
                    transitionType: TransitionType.fade,
                    duration: const Duration(milliseconds: 100),
                  ),
                  TayssirCustomGoRoute(
                    name: AppRoutes.challengeMatchmaking.name,
                    path: 'matchmaking',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final data = state.extra! as Map<String, dynamic>;
                      return MatchmakingScreen(
                        unitId: data['unitId'] as int,
                        courseTitle: data['courseTitle'] as String,
                        initialSearchMode: data['initialSearchMode'] as String?,
                        invitationCode: data['invitationCode'] as String?,
                      );
                    },
                    transitionType: TransitionType.sharedAxis,
                    duration: const Duration(milliseconds: 300),
                  ),
                  TayssirCustomGoRoute(
                    name: AppRoutes.challengeArena.name,
                    path: 'arena',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final data = state.extra! as Map<String, dynamic>;
                      return ArenaScreen(
                        matchId: data['matchId'] as String,
                        unitId: data['unitId'] as int,
                        courseTitle: data['courseTitle'] as String,
                      );
                    },
                    transitionType: TransitionType.sharedAxis,
                    duration: const Duration(milliseconds: 300),
                  ),
                  TayssirCustomGoRoute(
                    name: AppRoutes.social.name,
                    path: 'social',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => const SocialScreen(),
                    transitionType: TransitionType.sharedAxis,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              TayssirCustomGoRoute(
                path: '/settings',
                name: AppRoutes.settings.name,
                pageBuilder: (context, state) => const SettingsScreen(),
                transitionType: TransitionType.sharedAxis,
                duration: const Duration(milliseconds: 450),
                routes: [
                  TayssirCustomGoRoute(
                    path: 'profile',
                    name: AppRoutes.profile.name,
                    pageBuilder: (context, state) => const ProfileScreen(),
                    transitionType: TransitionType.sharedAxis,
                    duration: const Duration(milliseconds: 300),
                  ),
                  TayssirCustomGoRoute(
                    path: 'notificatios',
                    name: AppRoutes.notifcations.name,
                    pageBuilder: (context, state) => const NotificationsScreen(),
                    transitionType: TransitionType.sharedAxis,
                    duration: const Duration(milliseconds: 300),
                  ),
                  TayssirCustomGoRoute(
                    path: 'security',
                    name: AppRoutes.security.name,
                    pageBuilder: (context, state) => const SecurityScreen(),
                    transitionType: TransitionType.sharedAxis,
                    duration: const Duration(milliseconds: 300),
                    routes: [
                      TayssirCustomGoRoute(
                        path: 'change-email',
                        name: AppRoutes.changeEmail.name,
                        pageBuilder: (context, state) => const ChangeEmailScreen(),
                        transitionType: TransitionType.sharedAxis,
                        duration: const Duration(milliseconds: 300),
                      ),
                      TayssirCustomGoRoute(
                        path: 'reset-password',
                        name: AppRoutes.resetPassword.name,
                        pageBuilder: (context, state) => const ResetPasswordScreen(),
                        transitionType: TransitionType.sharedAxis,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                  TayssirCustomGoRoute(
                    path: 'contact-us',
                    name: AppRoutes.contactUs.name,
                    pageBuilder: (context, state) => const ContactUsScreen(),
                    transitionType: TransitionType.sharedAxis,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.exercices.name,
        path: '/exercices',
        pageBuilder: (context, state) => const ExerciceScreen(),
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.lesson.name,
        path: '/lesson',
        pageBuilder: (context, state) => const LessonScreen(),
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.onboarding.name,
        path: '/onboarding',
        pageBuilder: (context, state) => const OnboardingScreen(),
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 400),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.login.name,
        path: '/login',
        pageBuilder: (context, state) => const LoginScreen(),
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.results.name,
        path: '/results',
        pageBuilder: (context, state) => const ExerciceResultScreen(),
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.lessonResults.name,
        path: '/lesson-results',
        pageBuilder: (context, state) {
          final data = state.extra! as Map<String, dynamic>;
          return LessonResultScreen(
            chapterId: data['chapterId'] as int,
            points: data['points'] as int,
            elapsedTime: data['elapsedTime'] as Duration,
          );
        },
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.midResults.name,
        path: '/mid-results',
        pageBuilder: (context, state) => const MidResultScreen(),
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.register.name,
        path: '/register',
        pageBuilder: (context, state) => const RegisterScreen(),
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.verifyEmail.name,
        path: '/verify-email',
        pageBuilder: (context, state) => const VerifyEmailScreen(),
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.welcome.name,
        path: '/welcome',
        pageBuilder: (context, state) => const AuthScreen(),
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.forgetPassword.name,
        path: '/forget-password',
        pageBuilder: (context, state) => const ForgetPasswordView(),
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.chargilyWebView.name,
        path: '/chargily',
        pageBuilder: (context, state) {
          final data = state.extra! as Map<String, dynamic>;
          final checkoutUrl = data['checkoutUrl'] as String;
          return CheckoutWebView(checkoutUrl: checkoutUrl);
        },
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.chargilyInit.name,
        path: '/chargily-init',
        pageBuilder: (context, state) {
          final data = state.extra! as Map<String, dynamic>;
          final subscription = data['subscription'];
          return ChargilyInitScreen(subscription: subscription);
        },
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.streak.name,
        path: '/streak',
        pageBuilder: (context, state) {
          final data = state.extra! as Map<String, dynamic>;
          final streak = data['streak'];
          final unitId = data['unitId'] as int;
          return StreakScreen(streak: streak, unitId: unitId);
        },
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
      TayssirCustomGoRoute(
        name: AppRoutes.achievementLog.name,
        path: '/achievement-log',
        pageBuilder: (context, state) => const AchievementLogScreen(),
        transitionType: TransitionType.sharedAxis,
        duration: const Duration(milliseconds: 300),
      ),
    ],
  );
});
