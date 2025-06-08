// web_routes.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Constant/CV_Generator.dart';
import 'Constant/Forget Password.dart';
import 'Screens/Job_Seeker/JS_Profile.dart';
import 'Screens/Job_Seeker/Login.dart';
import 'Screens/Job_Seeker/Sign Up.dart';
import 'Screens/Job_Seeker/dashboard.dart';
import 'Screens/Recruiter/Login_Recruiter.dart';
import 'Screens/Recruiter/Sign Up_Recruiter.dart';
import 'Constant/Splash.dart';
import 'Screens/Recruiter/dashboard_Recruiter.dart';

class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _authSubscription;

  AuthNotifier() {
    // Listen to auth state changes and notify listeners.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

CustomTransitionPage<T> _buildPageWithAnimation<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 370),
    reverseTransitionDuration: const Duration(milliseconds: 370),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      final scaleAnimation = Tween<double>(begin: 0.99, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      );
    },
  );
}

// Create a single, top-level instance of the AuthNotifier.
final _authNotifier = AuthNotifier();

final GoRouter router = GoRouter(
  initialLocation: '/',
  // Use the AuthNotifier instance for the refreshListenable.
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isOnSplash = state.fullPath == '/';
    final isOnAuthPages = [
      '/login',
      '/register',
      '/recruiter-login',
      '/recruiter-signup',
      '/recover-password'
    ].contains(state.fullPath);

    // If user is not logged in and tries to access a protected route
    if (!isLoggedIn && !isOnAuthPages && !isOnSplash) {
      return '/login';
    }

    // If user is logged in and tries to access an auth page
    if (isLoggedIn && isOnAuthPages) {
      return '/dashboard';
    }

    // Optional: Already logged in and lands on '/' splash screen — skip it
    if (isLoggedIn && isOnSplash) {
      return '/dashboard';
    }

    // Otherwise, allow navigation as is
    return null;
  },
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
    GoRoute(
      path: '/recruiter-dashboard',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const Recruiter_Dashboard(),
        context: context,
        state: state,
      ),
    ),
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
    GoRoute(
      path: '/download-cv',
      pageBuilder: (context, state) => _buildPageWithAnimation(
        child: const CVGeneratorDialog(),
        context: context,
        state: state,
      ),
    ),
  ],
);