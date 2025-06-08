import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'Header_Nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hoverJobSeeker = false;
  bool _hoverRecruiter = false;
  bool _checkingUser = true;

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    // Optional: add delay for smoother experience
    await Future.delayed(const Duration(seconds: 2));

    if (user != null) {
      final uid = user.uid;

      try {
        final jobSeeker = await firestore.collection('Job_Seeker').doc(uid).get();
        if (jobSeeker.exists) {
          if (mounted) context.go('/dashboard');
          return;
        }

        final recruiter = await firestore.collection('Recruiter').doc(uid).get();
        if (recruiter.exists) {
          if (mounted) context.go('/recruiter-dashboard');
          return;
        }

        // If user found but not in any collection → log out
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('Error checking user role: $e');
        await FirebaseAuth.instance.signOut();
      }
    }

    // If not logged in → show splash
    if (mounted) {
      setState(() => _checkingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    if (_checkingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background SVG
          Positioned.fill(
            child: SvgPicture.asset(
              'images/bg.svg',
              fit: BoxFit.fitWidth,
            ),
          ),

          // 2. Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),

          // 3. Content: Header + Buttons
          Column(
            children: [
              const HeaderNav(),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Find your next opportunity',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ── Job Seeker Button ──
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) => setState(() => _hoverJobSeeker = true),
                              onExit: (_) => setState(() => _hoverJobSeeker = false),
                              child: SizedBox(
                                width: 230,
                                height: 50,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: _hoverJobSeeker
                                      ? Matrix4.translationValues(0, -6, 0)
                                      : Matrix4.identity(),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.go('/register');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'I am a Job Seeker',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 32),

                            // ── Recruiter Button ──
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) => setState(() => _hoverRecruiter = true),
                              onExit: (_) => setState(() => _hoverRecruiter = false),
                              child: SizedBox(
                                width: 230,
                                height: 50,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: _hoverRecruiter
                                      ? Matrix4.translationValues(0, -6, 0)
                                      : Matrix4.identity(),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      context.go('/recruiter-signup');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'I am a Recruiter',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
