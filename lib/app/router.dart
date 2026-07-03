import 'package:actpod_studio/features/create_story/create_story.dart';
import 'package:actpod_studio/features/donation/donation.dart';
import 'package:actpod_studio/features/interactive_managment/interactive_managment.dart';
import 'package:actpod_studio/features/login_page.dart';
import 'package:actpod_studio/features/statistic/statistic.dart';
import 'package:actpod_studio/features/withdraw/withdraw.dart';
import 'package:actpod_studio/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/stories_list_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      if (!hasLogin) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          // child: const DashboardPage(),
          child: const LoginPage(),
          // child: const ApiTestPage(),
          // child: PublishFlowPage(stepIndex: 0),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/stories',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StoriesListPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/statistics',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StatisticPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/donations',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DonationPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/withdraws',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WithdrawPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/interactive_managment',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const InteractiveManagmentPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/publish/:step',
        builder: (ctx, st) {
          final step = int.tryParse(st.pathParameters['step'] ?? '0') ?? 0;
          return PublishFlowPage(stepIndex: step);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (ctx, st) {
          return LoginPage();
        },
      ),
    ],
  );
});
