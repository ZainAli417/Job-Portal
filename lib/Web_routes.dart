import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'Screens/Job_Seeker/Forget Password.dart';
import 'Screens/Job_Seeker/Login.dart';
import 'Screens/Job_Seeker/Sign Up.dart';
import 'Screens/Splash.dart';

/// A helper function that returns a CustomTransitionPage
/// with a slide‐up + fade transition:
CustomTransitionPage<T> _buildPageWithAnimation<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Slide up slightly + fade in
      final slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeIn),
      );

      return SlideTransition(
        position: slideAnim,
        child: FadeTransition(
          opacity: fadeAnim,
          child: child,
        ),
      );
    },
  );
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) {
        return _buildPageWithAnimation(
          context: context,
          state: state,
          child: const SplashScreen(),
        );
      },
    ),

    GoRoute(
      path: '/login',
      pageBuilder: (context, state) {
        return _buildPageWithAnimation(
          context: context,
          state: state,
          child: const JobSeekerLoginScreen(),
        );
      },
    ),

    GoRoute(
      path: '/register',
      pageBuilder: (context, state) {
        return _buildPageWithAnimation(
          context: context,
          state: state,
          child: const JobSeekerSignUpScreen(),
        );
      },
    ),

    GoRoute(
      path: '/recover-password',
      pageBuilder: (context, state) {
        return _buildPageWithAnimation(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        );
      },
    ),


  ],
);
