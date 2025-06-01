// lib/screens/Splash.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../main.dart'; // for RoleProvider
import 'Header_Nav.dart';
// SignUp screen (reads role from Provider)

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late ImageProvider _backgroundImage;
  bool _hoverJobSeeker = false;
  bool _hoverRecruiter = false;

  @override
  void initState() {
    super.initState();
    _backgroundImage = const AssetImage('images/splash.webp');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(_backgroundImage, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1) Full-screen background
          Positioned.fill(
            child: Image(
              image: _backgroundImage,
              fit: BoxFit.cover,
            ),
          ),

          // 2) Semi-transparent black overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          // 3) Content (HeaderNav + hero buttons)
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
                        // Hero title
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

                        // Buttons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ── Job Seeker Button ──
                            MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _hoverJobSeeker = true),
                              onExit: (_) =>
                                  setState(() => _hoverJobSeeker = false),
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
                              onEnter: (_) =>
                                  setState(() => _hoverRecruiter = true),
                              onExit: (_) =>
                                  setState(() => _hoverRecruiter = false),
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

  // Helper: fade-transition navigation
}
