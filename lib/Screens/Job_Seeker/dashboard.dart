// dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Constant/Job_Carousel.dart';
import '../../Top_Side_Nav.dart';
import 'Dashboard_Provider.dart';

/// JobSeekerDashboard now wraps its ListView inside MainLayout with activeIndex = 0
class JobSeekerDashboard extends StatelessWidget {
  const JobSeekerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobProvider(),
      child: MainLayout(
        activeIndex: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Left Column
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _ProfileCard(),
                      SizedBox(height: 40),

                      // Wrap JobCarousel in a fixed-height SizedBox so that its overall
                      // height never changes during scaling animations.
                      SizedBox(
                        height: 340, // 300 for PageView + ~40 for indicators/padding
                        child: JobCarousel(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Right Column
              Expanded(
                flex: 1,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'New Module\nComing Soon',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ProfileCard extends StatelessWidget {
  const _ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back, Zain!',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your Quick Stats',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 24),

        // Stats Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _StatCard(
              icon: Icons.visibility,
              value: '1,250',
              label: 'Profile Views',
              iconColor: Color(0xFF4C7EFF),
            ),
            _StatCard(
              icon: Icons.check_circle_outline,
              value: '25',
              label: 'Applications Sent',
              iconColor: Color(0xFF1AC98E),
            ),
            _StatCard(
              icon: Icons.bookmark_border,
              value: '12',
              label: 'Jobs Saved',
              iconColor: Color(0xFFFFC542),
            ),
            _StatCard(
              icon: Icons.notifications_none,
              value: '5',
              label: 'New Job Alerts',
              iconColor: Color(0xFFAC7EF4),
            ),
          ],
        ),
      ],
    );
  }
}
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Circle
          Container(
            height: 50,
            width: 50,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),

          // Text Column (aligned left)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
