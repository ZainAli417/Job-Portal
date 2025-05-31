// router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_portal/Screens/Job_Seeker/Login.dart';
import 'Screens/Job_Seeker/Sign Up.dart';
import 'Screens/Splash.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/Login',
      builder: (context, state) {
        return const JobSeekerLoginScreen();
      },
    ),
    GoRoute(
      path: '/Register',
      builder: (context, state) {
        // Same for SignUp: reads role from Provider in its build()
        return const JobSeekerSignUpScreen();
      },
    ),
  ],
);
