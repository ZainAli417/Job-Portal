// top_nav.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'Top_Nav_Provider.dart';

/// ─── MainLayout ───
/// Wraps any "child" screen in a consistent top bar + side nav.
/// AnimatedSwitcher now sees a new ValueKey(activeIndex) each time the route changes.
class MainLayout extends StatefulWidget {
  final Widget child;
  final int activeIndex; // 0 = Dashboard, 1 = Profile, etc.
  final Key? key;

  const MainLayout({
    this.key,
    required this.child,
    required this.activeIndex,
  }) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TopNavProvider>(
      create: (_) => TopNavProvider(),
      child: RepaintBoundary(child: _buildScaffold(context)),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final unselectedColor = const Color(0xFF5C738A);
    final backgroundGray = const Color(0xFFF5F8FA);
    final userProv = Provider.of<TopNavProvider>(context);
    final initials = userProv.initials;

    return Scaffold(
      backgroundColor: backgroundGray,
      body: Row(
        children: [
          // ─── Side Navigation (full height, scrollable if content grows) ───
          RepaintBoundary(
            child: Container(
              width: 240,
              decoration: BoxDecoration(
                color: backgroundGray,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(2, 0), // Right-side shadow
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                // ensure rounded corners clip scrollable content
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // ─── Logo inside Side Nav ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'LOGO_HERE',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                       Divider(
                        thickness: 1,
                        color: Color(0xFFCCCCCC),
                      ),
                      // ─── Avatar + Name/Title in a Row ───
                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Square avatar with 10px rounded corners & light-blue border
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Name + Subtitle stacked vertically
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Zain Ali',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Full Stack Dev.',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF5C738A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Email Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.email_outlined,
                                size: 16, color: Color(0xFF5C738A)),
                            const SizedBox(width: 6),
                            Text(
                              'zain.ali@example.com',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5C738A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Phone Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 16, color: Color(0xFF5C738A)),
                            const SizedBox(width: 6),
                            Text(
                              '(123) 456-7890',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5C738A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Location Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 16, color: Color(0xFF5C738A)),
                            const SizedBox(width: 6),
                            Text(
                              'San Francisco, CA',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF5C738A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Short Bio / Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Highly skilled Full Stack Developer with 5+ years of experience in designing, developing, and implementing web applications. Proven ability to work with various technologies and frameworks.',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF5C738A),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // “View Full Profile →” Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: primaryColor.withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              // Navigate to full profile page
                              context.go('/profile');
                            },
                            child: Text(
                              'View Full Profile  →',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ─── Light-grey Divider ───
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── Dashboard Button ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.dashboard_outlined,
                          label: 'Dashboard',
                          isActive: widget.activeIndex == 0,
                          onTap: () {
                            if (widget.activeIndex != 0) {
                              context.go('/dashboard');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ─── Create Profile Button ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.person_outline,
                          label: 'Create Profile',
                          isActive: widget.activeIndex == 1,
                          onTap: () {
                            if (widget.activeIndex != 1) {
                              context.go('/profile');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ─── Saved Jobs ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.bookmark_border,
                          label: 'Saved Jobs',
                          isActive: widget.activeIndex == 2,
                          onTap: () {
                            if (widget.activeIndex != 2) {
                              context.go('/saved');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ─── Job Alerts ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.notifications_none,
                          label: 'Job Alerts',
                          isActive: widget.activeIndex == 3,
                          onTap: () {
                            if (widget.activeIndex != 3) {
                              context.go('/alerts');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── Bottom Divider + Logout ───
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _LogoutButton(
                          key: const ValueKey('nav_logout'),
                          onTap: () {
                            // handle logout
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Right Side: Top Bar (without Logo) + Main Content ───
          Expanded(
            child: Column(
              children: [
                // ─── Top Bar (Search, Notification, Avatar) ───
                Container(
                  // White background with subtle elevation
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  // Add top & bottom padding so the search bar isn't flush to the container edges
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      // ─── Search Field ───────────────────────────
                      Padding(
                        // Add horizontal padding around the search field if desired
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SizedBox(
                          width: 360, // match screenshot width
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22), // fully round for 44px height
                              border: Border.all(
                                color: const Color(0xFFD1D9E5), // light gray border
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFF5C738A),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: TextField(
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      hintText: 'Search jobs, keywords, or companies...',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFB0B0B0), // very-light grey
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(width: 24),

                      // ─── Notification Icon ───────────────────────
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFF5C738A),
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // ─── Profile Avatar ──────────────────────────
                      GestureDetector(
                        onTap: () {},
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: primaryColor,
                          child: Text(
                            initials.isNotEmpty ? initials : '–',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Main Content Area ────────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }
}

/// Single navigation button in the side-rail.
/// Highlights itself if isActive == true.
class _SideNavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SideNavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : super();

  @override
  State<_SideNavButton> createState() => _SideNavButtonState();
}

class _SideNavButtonState extends State<_SideNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final unselectedColor = const Color(0xFF5C738A);

    Color bgColor() {
      if (widget.isActive) {
        return primaryColor.withOpacity(0.1);
      } else if (_isHovered) {
        return primaryColor.withOpacity(0.05);
      } else {
        return Colors.transparent;
      }
    }

    Color iconColor() {
      if (widget.isActive) return primaryColor;
      if (_isHovered) return primaryColor;
      return unselectedColor;
    }

    Color textColor() {
      if (widget.isActive) return primaryColor;
      if (_isHovered) return primaryColor;
      return unselectedColor;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: iconColor()),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  final VoidCallback onTap;
  final Key? key;

  const _LogoutButton({
    this.key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final unselectedColor = const Color(0xFF5C738A);

    Color bgColor() {
      if (_isHovered) return Colors.red.shade100;
      return Colors.transparent;
    }

    Color iconColor() {
      if (_isHovered) return Colors.red;
      return unselectedColor;
    }

    Color textColor() {
      if (_isHovered) return Colors.red;
      return unselectedColor;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.logout, color: iconColor()),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
