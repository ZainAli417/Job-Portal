// web_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'Constant/Forget Password.dart';
import 'Screens/Job_Seeker/JS_Profile.dart';
import 'Screens/Job_Seeker/Login.dart';
import 'Screens/Job_Seeker/Sign Up.dart';
import 'Screens/Job_Seeker/dashboard.dart';
import 'Screens/Recruiter/Login_Recruiter.dart';
import 'Screens/Recruiter/Sign Up_Recruiter.dart';
import 'Constant/Splash.dart';

/// A helper for your fade+slide transitions (unchanged).
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
      final slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutSine));
      final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInCirc),
      );

      return SlideTransition(
        position: slideAnim,
        child: FadeTransition(opacity: fadeAnim, child: child),
      );
    },
  );
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _buildPageWithAnimation(child: const SplashScreen(), context: context, state: state),
    ),

    GoRoute(
      path: '/recover-password',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const ForgotPasswordScreen(),
        context: context,
        state: state,
      ),
    ),

    // Job Seeker Auth
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const JobSeekerLoginScreen(),
        context: context,
        state: state,
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const JobSeekerSignUpScreen(),
        context: context,
        state: state,
      ),
    ),

    // Recruiter Auth
    GoRoute(
      path: '/recruiter-login',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const Recruiter_LoginScreen(),
        context: context,
        state: state,
      ),
    ),
    GoRoute(
      path: '/recruiter-signup',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const Recruiter_SignUpScreen(),
        context: context,
        state: state,
      ),
    ),

    // Job Seeker Screens (each wraps in MainLayout)
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const JobSeekerDashboard(),
        context: context,
        state: state,
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const ProfileScreen(),
        context: context,
        state: state,
      ),
    ),
    // (Add /saved, /alerts if you define those screens…)
  ],
);
