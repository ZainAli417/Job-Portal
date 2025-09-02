import 'dart:math' as math;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _hoverJobSeeker = false;
  bool _hoverRecruiter = false;
  bool _checkingUser = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late AnimationController _morphController;
  late AnimationController _breatheController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _morphAnimation;
  late Animation<double> _breatheAnimation;

  final ScrollController _scrollController = ScrollController();

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color snowWhite = Color(0xFFFAFAFA);
  static const Color paleGray = Color(0xFFF5F5F7);
  static const Color lightGray = Color(0xFFE5E5EA);
  static const Color subtleGray = Color(0xFFD1D1D6);
  static Color charcoalGray = Colors.black87;
  static const Color softShadow = Color(0x08000000);
  static const Color mediumShadow = Color(0x12000000);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkLoggedInUser();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900), // smooth but not too slow
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 6), // slower pulse
      vsync: this,
    )..repeat(reverse: true);
    _floatingController = AnimationController(
      duration: const Duration(seconds: 10), // much slower floating
      vsync: this,
    )..repeat(reverse: true);
    _morphController = AnimationController(
      duration: const Duration(seconds: 12), // slow morph for bars etc.
      vsync: this,
    )..repeat();
    _breatheController = AnimationController(
      duration: const Duration(seconds: 6), // slow breathing
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    // Slide from slightly above down into place (subtle top-to-down movement)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.06), // small top -> down offset (subtle)
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // scale (used where you already have ScaleTransition) — smaller range for subtlety
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    _rotationAnimation =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(_rotationController);

    // pulse reduced amplitude to avoid jumpiness
    _pulseAnimation = Tween<double>(begin: 0.985, end: 1.015).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // floating translate reduced amplitude
    _floatingAnimation = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOutSine),
    );

    // morph uses a smooth sine-like easing
    _morphAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOutSine),
    );

    // breathe — tiny scale up
    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );
  }

  Future<void> _checkLoggedInUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    await Future.delayed(const Duration(seconds: 2));

    if (user != null) {
      final uid = user.uid;
      try {
        final jobSeeker =
            await firestore.collection('Job_Seeker').doc(uid).get();
        if (jobSeeker.exists) {
          if (mounted) context.go('/dashboard');
          return;
        }

        final recruiter =
            await firestore.collection('Recruiter').doc(uid).get();
        if (recruiter.exists) {
          if (mounted) context.go('/recruiter-dashboard');
          return;
        }

        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('Error checking user role: $e');
        await FirebaseAuth.instance.signOut();
      }
    }

    if (mounted) {
      setState(() => _checkingUser = false);
      _startAnimations();
    }
  }
  void _startAnimations() {
    // start the fade (page-level) and then slide/scale to produce smoky top->down appearance
    _fadeController.forward();

    // small stagger so fade begins immediately, slide slightly after for smoky effect
    Future.delayed(const Duration(milliseconds: 120), () {
      _slideController.forward();
    });

    // scale in content slightly after slide begins to give smooth depth
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }


  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _floatingController.dispose();
    _morphController.dispose();
    _breatheController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingUser) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: pureWhite,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _buildMinimalHeader(),
                    _buildExcitingHeroSection(),
                    _buildFloatingFeaturesSection(),
                    _buildElegantStatsSection(),
                    _buildTestimonialsSection(),
                    _buildCleanFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: pureWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _breatheController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breatheAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: pureWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: softShadow,
                          blurRadius: 40,
                          spreadRadius: 0,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: mediumShadow,
                          blurRadius: 80,
                          spreadRadius: 0,
                          offset: const Offset(0, 40),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_awesome_outlined,
                      color: Colors.indigo.shade900,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
            Text(
              'Maha Services',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: charcoalGray,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 200,
              height: 3,
              child: AnimatedBuilder(
                animation: _morphController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: (_morphAnimation.value * 2) % 1,
                    backgroundColor: Colors.indigo.shade900,
                    valueColor: AlwaysStoppedAnimation<Color>(charcoalGray),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalHeader() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: pureWhite.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: lightGray.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCleanLogo(),
            _buildMinimalNav(),
            _buildHeaderActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanLogo() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 0.1, // Subtle rotation
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade900,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: mediumShadow,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_outlined,
                    color: pureWhite, size: 28),
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        Text(
          'Maha Services',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Colors.indigo.shade900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalNav() {
    return Row(
      children: [
        _buildNavItem('Build Your CV'),
        _buildNavItem('Analyze CV'),
        _buildNavItem('Recruiter? Post A  Job'),
        _buildNavItem('Training as a Service(TaaS)'),
      ],
    );
  }

  Widget _buildNavItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: charcoalGray.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        _buildCleanButton('Sign In', false, () {}),
        const SizedBox(width: 16),
        _buildCleanButton('Get Started', true, () {}),
      ],
    );
  }

  Widget _buildCleanButton(
      String text, bool isPrimary, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? Colors.indigo.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? null : Border.all(color: lightGray, width: 1),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: mediumShadow,
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isPrimary ? pureWhite : charcoalGray,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildExcitingHeroSection() {
    return SizedBox(
      height: 900,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildExcitingBadge(),
                      const SizedBox(height: 50),
                      _buildDramaticTitle(),
                      const SizedBox(height: 40),
                      _buildCleanSubtitle(),
                      const SizedBox(height: 60),
                      _buildModernCTAs(),
                      const SizedBox(height: 50),
                      _buildMinimalTrustIndicators(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 100),
            Expanded(
              flex: 5,
              child: _buildExcitingHeroVisual(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExcitingBadge() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: lightGray, width: 1),
              boxShadow: [
                BoxShadow(
                  color: softShadow,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI-Powered • Next Generation Recruiting Platform',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDramaticTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reduced "Where"
        Text(
          'Where',
          style: GoogleFonts.poppins(
            fontSize: 48,               // reduced size
            fontWeight: FontWeight.w200, // lighter weight
            color: Color(0xFF800000).withOpacity(0.55), // subtle mahroon tint
            height: 0.95,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 8),

        // "Meets" + "Talent + Icon" in one line
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // reduced "Meets"
            Text(
              'Meets',
              style: GoogleFonts.poppins(
                fontSize: 28,               // much smaller than Talent
                fontWeight: FontWeight.w300, // light
                color: Color(0xFF800000).withOpacity(0.65), // muted mahroon
                height: 1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 18),

            // Emphasized "Talent"
            Text(
              'Talent',
              style: GoogleFonts.poppins(
                fontSize: 84,               // prominent
                fontWeight: FontWeight.w900, // heavy
                color: Color(0xFF800000),    // mahroon (emphasis)
                height: 0.95,
                letterSpacing: -3,
              ),
            ),

            const SizedBox(width: 18),

            // Animated icon beside Talent (keeps breathe animation)
            AnimatedBuilder(
              animation: _breatheController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breatheAnimation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFF800000), // mahroon icon background (emphasis)
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: mediumShadow,
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.storm, color: pureWhite, size: 28),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Big emphasized "Innovation"
        Text(
          'Innovation',
          style: GoogleFonts.poppins(
            fontSize: 96,                 // slightly larger to emphasize
            fontWeight: FontWeight.w900,  // heavy
            color: Color(0xFF800000),     // mahroon (strong emphasis)
            height: 0.9,
            letterSpacing: -3,
          ),
        ),
      ],
    );
  }

  Widget _buildCleanSubtitle() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Text(
        'Experience the future of recruitment with intelligent matching, seamless workflows, and meaningful connections that transform careers.',
        style: GoogleFonts.poppins(
          fontSize: 22,
          color: charcoalGray.withOpacity(0.7),
          height: 1.6,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildModernCTAs() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Row(
        children: [
          _buildExcitingCTAButton(
            'Explore Opportunities',
            Icons.arrow_forward_rounded,
            () => context.go('/register'),
            true,
            _hoverJobSeeker,
            (hover) => setState(() => _hoverJobSeeker = hover),
          ),
          const SizedBox(width: 24),
          _buildExcitingCTAButton(
            'Hire Top Talent',
            Icons.people_outline,
            () => context.go('/recruiter-signup'),
            false,
            _hoverRecruiter,
            (hover) => setState(() => _hoverRecruiter = hover),
          ),
          const SizedBox(width: 40),
          _buildWatchDemoButton(),
        ],
      ),
    );
  }

  Widget _buildExcitingCTAButton(
      String text,
      IconData icon,
      VoidCallback onPressed,
      bool isPrimary,
      bool isHovered,
      Function(bool) onHover) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: isHovered
            ? Matrix4.translationValues(0, -6, 0)
            : Matrix4.identity(),
        child: Container(
          decoration: BoxDecoration(
            color: isPrimary ? Colors.indigo.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary ? null : Border.all(color: lightGray, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: isHovered ? mediumShadow : softShadow,
                blurRadius: isHovered ? 30 : 15,
                offset: Offset(0, isHovered ? 12 : 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: isPrimary ? pureWhite : charcoalGray,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchDemoButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade900,
                    shape: BoxShape.circle,
                    border: Border.all(color: lightGray, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: softShadow,
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 24),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Text(
            'Experience TaaS',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: charcoalGray.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalTrustIndicators() {
    return Row(
      children: [
        Text(
          'Trusted by',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: charcoalGray.withOpacity(0.5),
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 32),
        ...['Google', 'Meta', 'Apple', 'Netflix'].map(
          (company) => Padding(
            padding: const EdgeInsets.only(right: 32),
            child: Text(
              company,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w200,
                color: charcoalGray.withOpacity(0.7),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExcitingHeroVisual() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.5),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Stack(
              children: [
                // Main floating dashboard
                _buildFloatingDashboard(),
                // Exciting floating elements
                ..._buildExcitingFloatingElements(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingDashboard() {
    return Container(
      height: 1000,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
            color: Colors.indigo.shade900.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade900.withOpacity(0.06),
            blurRadius: 60,
            offset: const Offset(0, 30),
          ),
          BoxShadow(
            color: Colors.indigo.shade900.withOpacity(0.08),
            blurRadius: 120,
            offset: const Offset(0, 60),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDashboardHeader(),
            const SizedBox(height: 20),
            _buildDashboardMetrics(),
            const SizedBox(height: 20),
            _buildDashboardChart(),
            const SizedBox(height: 20),
            _buildDashboardActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.indigo.shade900.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.shade900.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.dashboard_outlined,
              color: Colors.indigo.shade900, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recruiting Overview',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade900,
                ),
              ),
              Text(
                'Real-time insights',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.indigo.shade900.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.indigo.shade900, // mahroon status indicator
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardMetrics() {
    return Row(
      children: [
        _buildMetricCard('2.4K', 'Applications', 0),
        const SizedBox(width: 20),
        _buildMetricCard('847', 'Matches', 1),
        const SizedBox(width: 20),
        _buildMetricCard('23', 'Interviews', 2),
      ],
    );
  }

  Widget _buildMetricCard(String value, String label, int index) {
    // stat-specific accent colours (mahroon / indigo / mahroon-alt)
    final Color accentBorder = index == 0
        ? Colors.indigo.shade900.withOpacity(0.18)
        : index == 1
            ? Colors.indigo.shade900.withOpacity(0.18)
            : Colors.indigo.shade900.withOpacity(0.12);

    final Color valueColor = index == 0
        ? Colors.indigo.shade900
        : index == 1
            ? Colors.indigo.shade900
            : Colors.indigo.shade900;

    final Color cardBg = Colors.white;

    return Expanded(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 +
                (math.sin(_pulseController.value * 2 * math.pi + index) * 0.02),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.shade900.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.indigo.shade900.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.shade900.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade900.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Activity',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.indigo.shade900, // switched heading to mahroon for emphasis
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final heights = [0.3, 0.7, 0.5, 0.9, 0.4, 0.8, 0.6];

                  // palette cycling through mahroon + indigo variants
                  final List<Color> barColors = [
                  Colors.indigo.shade800,                 // mahroon (primary)
                    Colors.indigo.shade900,           // indigo (accent)
                    Colors.indigo.shade700,                // darker mahroon
                    Colors.indigo.shade600,           // lighter indigo
                    Colors.indigo.shade900,               // warm mahroon tint
                    Colors.indigo.shade400,           // pale indigo
                  Colors.indigo.shade600, // mahroon slightly faded
                  ];

                  final baseColor = barColors[index % barColors.length];
                  final barOpacity = 0.12 + (heights[index] * 0.6);

                  return AnimatedBuilder(
                    animation: _morphController,
                    builder: (context, child) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + index * 100),
                        width: 20,
                        height: (heights[index] * 120) *
                            (1 +
                                math.sin(_morphController.value * 2 * math.pi +
                                    index) *
                                    0.1),
                        decoration: BoxDecoration(
                          color: baseColor.withOpacity(barOpacity),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardActivity() {
    return Column(
      children: List.generate(4, (index) {
        final activities = [
          {'icon': Icons.person_add_outlined, 'text': 'New candidate applied'},
          {'icon': Icons.message_outlined, 'text': 'Interview scheduled'},
          {'icon': Icons.check_circle_outline, 'text': 'Profile reviewed'},
          {'icon': Icons.star_border, 'text': 'Match found'},
        ];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    math.sin(_floatingController.value * 2 * math.pi + index) *
                        2,
                    0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? Colors.white
                        : Colors.indigo.shade50.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.indigo.shade900.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.indigo.shade900.withOpacity(0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.shade900.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          activities[index]['icon'] as IconData,
                          size: 16,
                          color: Colors.indigo.shade900.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          activities[index]['text'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.indigo.shade900.withOpacity(0.85),
                          ),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade900.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  List<Widget> _buildExcitingFloatingElements() {
    return [
      // Floating notification card
      Positioned(
        top: 60,
        right: -40,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_floatingAnimation.value * 0.3,
                  math.sin(_floatingController.value * 2 * math.pi) * 15),
              child: Transform.rotate(
                angle: math.sin(_floatingController.value * 2 * math.pi) * 0.05,
                child: _buildFloatingNotificationCard(),
              ),
            );
          },
        ),
      ),
      // Floating profile cards
      Positioned(
        bottom: 80,
        left: -60,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_floatingAnimation.value * 0.4),
              child: _buildFloatingProfileStack(),
            );
          },
        ),
      ),
      // Floating search bar
      Positioned(
        top: 200,
        right: 50,
        child: AnimatedBuilder(
          animation: _breatheController,
          builder: (context, child) {
            return Transform.scale(
              scale: _breatheAnimation.value * 0.95,
              child: _buildFloatingSearchBar(),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildFloatingNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade900.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade200,
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.shade900.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.notifications_none,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Perfect Match!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade900,
                ),
              ),
              Text(
                'Senior Developer • Google',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.indigo.shade900.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingProfileStack() {
    return Stack(
      children: List.generate(3, (index) {
        return Transform.translate(
          offset: Offset(index * 20.0, index * 15.0),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 +
                    (math.sin(_pulseController.value * 2 * math.pi + index) *
                        0.05),
                child: Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.indigo.shade900.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade900.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? Colors.white
                              : index == 1
                                  ? Colors.indigo.shade50
                                  : Colors.indigo.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.indigo.shade900.withOpacity(0.12)),
                        ),
                        child: Icon(
                          [
                            Icons.person_outline,
                            Icons.work_outline,
                            Icons.star_border
                          ][index],
                          size: 20,
                          color: Colors.indigo.shade900.withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade900.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildFloatingSearchBar() {
    return Container(
      width: 280,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.indigo.shade900.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade100,
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(Icons.search,
              color: Colors.indigo.shade900.withOpacity(0.5), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search for dream jobs...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Colors.indigo.shade900.withOpacity(0.5),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingFeaturesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 140, horizontal: 80),
      child: Column(
        children: [
          _buildCleanSectionHeader(
            'Revolutionary Features',
            'Advanced tools designed for the modern workforce',
          ),
          const SizedBox(height: 100),
          _buildMinimalFeatureGrid(),
        ],
      ),
    );
  }

  Widget _buildCleanSectionHeader(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 52,
            fontWeight: FontWeight.w200,
            color: charcoalGray,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: charcoalGray.withOpacity(0.6),
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalFeatureGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 40,
        mainAxisSpacing: 40,
        childAspectRatio: 1.2,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildMinimalFeatureCard(index),
    );
  }

  Widget _buildMinimalFeatureCard(int index) {
    final features = [
      {
        'icon': Icons.psychology_outlined,
        'title': 'AI Matching',
        'desc': 'Neural networks analyze compatibility and potential'
      },
      {
        'icon': Icons.analytics_outlined,
        'title': 'Smart Analytics',
        'desc': 'Real-time insights with predictive intelligence'
      },
      {
        'icon': Icons.video_call_outlined,
        'title': 'Virtual Interviews',
        'desc': 'Seamless video interviews with smart scheduling'
      },
      {
        'icon': Icons.school_outlined,
        'title': 'Skill Assessment',
        'desc': 'Automated testing with instant verification'
      },
      {
        'icon': Icons.group_outlined,
        'title': 'Team Collaboration',
        'desc': 'Streamlined workflows for hiring teams'
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Enterprise Security',
        'desc': 'Bank-level encryption and compliance'
      },
    ];

    final feature = features[index];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0,
                math.sin(_floatingController.value * 2 * math.pi + index) * 8),
            child: Container(
              decoration: BoxDecoration(
                color: pureWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: lightGray.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: softShadow,
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: mediumShadow,
                    blurRadius: 50,
                    offset: const Offset(0, 30),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _breatheController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 +
                              (math.sin(_breatheController.value * 2 * math.pi +
                                      index) *
                                  0.05),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: snowWhite,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: lightGray.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: softShadow,
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              feature['icon'] as IconData,
                              size: 36,
                              color: charcoalGray.withOpacity(0.8),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      feature['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: charcoalGray,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      feature['desc'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: charcoalGray.withOpacity(0.6),
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildElegantStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 120, horizontal: 80),
      padding: const EdgeInsets.all(80),
      decoration: BoxDecoration(
        color: snowWhite,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: lightGray.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: softShadow,
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Platform Impact',
            style: GoogleFonts.poppins(
              fontSize: 42,
              fontWeight: FontWeight.w200,
              color: charcoalGray,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 2,
            decoration: BoxDecoration(
              color: charcoalGray.withOpacity(0.1),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 80),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildElegantStatItem(
                  '50K+', 'Active Positions', Icons.work_outline),
              _buildElegantStatItem(
                  '100K+', 'Talented Professionals', Icons.people_outline),
              _buildElegantStatItem(
                  '2K+', 'Partner Companies', Icons.business_outlined),
              _buildElegantStatItem(
                  '98%', 'Success Rate', Icons.trending_up_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElegantStatItem(String number, String label, IconData icon) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.03,
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: pureWhite,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: lightGray.withOpacity(0.3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: softShadow,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child:
                    Icon(icon, size: 40, color: charcoalGray.withOpacity(0.8)),
              ),
              const SizedBox(height: 32),
              Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: charcoalGray,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: charcoalGray.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestimonialsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 140, horizontal: 80),
      child: Column(
        children: [
          _buildCleanSectionHeader(
            'Success Stories',
            'Hear from our community of professionals and recruiters',
          ),
          const SizedBox(height: 100),
          SizedBox(
            height: 420,
            child: PageView.builder(
              itemCount: 3,
              itemBuilder: (context, index) =>
                  _buildMinimalTestimonialCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalTestimonialCard(int index) {
    final testimonials = [
      {
        'name': 'Sarah Chen',
        'role': 'Senior Developer • Meta',
        'content':
            'TalentHub\'s intelligent matching found me the perfect role that aligned with my career aspirations. The entire process was remarkably seamless.',
        'initial': 'S',
      },
      {
        'name': 'Marcus Johnson',
        'role': 'HR Director • Stripe',
        'content':
            'We reduced our hiring timeline by 70% while significantly improving candidate quality. This platform is genuinely transformative.',
        'initial': 'M',
      },
      {
        'name': 'Elena Rodriguez',
        'role': 'UX Designer • Airbnb',
        'content':
            'The skill assessment and cultural analysis helped me discover a company where I truly belong and can grow professionally.',
        'initial': 'E',
      },
    ];

    final testimonial = testimonials[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0,
                math.sin(_floatingController.value * 2 * math.pi + index) * 5),
            child: Container(
              decoration: BoxDecoration(
                color: pureWhite,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: lightGray.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: softShadow,
                    blurRadius: 40,
                    offset: const Offset(0, 25),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: snowWhite,
                        shape: BoxShape.circle,
                        border: Border.all(color: lightGray.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: softShadow,
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          testimonial['initial'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            color: charcoalGray,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '"${testimonial['content']}"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        color: charcoalGray.withOpacity(0.8),
                        height: 1.7,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      testimonial['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: charcoalGray,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      testimonial['role'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: charcoalGray.withOpacity(0.5),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCleanFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 80),
      decoration: BoxDecoration(
        color: snowWhite,
        border: Border(
          top: BorderSide(color: lightGray.withOpacity(0.3), width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildFooterCTA(),
          const SizedBox(height: 80),
          _buildFooterContent(),
          const SizedBox(height: 60),
          // _buildFooterBottom(),
        ],
      ),
    );
  }

  Widget _buildFooterCTA() {
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: lightGray.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: softShadow,
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to Transform\nYour Career Journey?',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w300,
                    color: charcoalGray,
                    height: 1.2,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Join thousands of professionals who discovered their perfect opportunities.',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: charcoalGray.withOpacity(0.6),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 60),
          _buildExcitingCTAButton(
            'Begin Journey',
            Icons.arrow_forward_rounded,
            () => context.go('/register'),
            true,
            false,
            (hover) {},
          ),
        ],
      ),
    );
  }

  Widget _buildFooterContent() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          flex: 2,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildCleanLogo(),
            const SizedBox(height: 32),
            Text(
              'The future of recruitment.\nBuilt for the modern workforce.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: charcoalGray.withOpacity(0.6),
                height: 1.6,
                letterSpacing: 0.3,
              ),
            )
          ]))
    ]);
  }
}
