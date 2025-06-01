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
      body: Column(
        children: [
          // ───────── Top Bar ─────────
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: backgroundGray,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
// Logo / App Name
                Text(
                  'LOGO_HERE',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),

                const Spacer(),

// ─── Search Field (single Container; no “stacked boxes”) ───
                SizedBox(
                  width: 500,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: Color(
                                0xFF5C738A)), // :contentReference[oaicite:0]{index=0}
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search',
                              hintStyle: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: unselectedColor,
                              ),
                            ),
                            style: GoogleFonts.montserrat(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 24),

// Notification Icon
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none,
                      color: Color(0xFF5C738A)),
                ),

                const SizedBox(width: 16),

// ─── Profile Avatar: either an image or the initial letter ───
                GestureDetector(
                  onTap: () {
// Tapping could open a profile dropdown, etc.
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryColor,
                    backgroundImage:
                    null, // If you have a Network/ImageProvider, supply it here :contentReference[oaicite:1]{index=1}
                    child: Text(
                      'A', // Fallback to user’s initial letter if no image loaded
                      style: GoogleFonts.montserrat(
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





          // ───────── Body: Side Nav + Main Content ─────────
          Expanded(
            child: Row(
              children: [
                // ─── Side Navigation ───
                RepaintBoundary(
                  child: Container(
                    width: 240,
                    color: backgroundGray,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Upper Section: avatar, name, menu buttons
                        Column(
                          children: [
                            const SizedBox(height: 24),
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: primaryColor.withOpacity(0.1),
                              child: Icon(Icons.person,
                                  size: 32, color: primaryColor),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Zain Ali',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Light‐grey Divider
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFFCCCCCC),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ─── Dashboard Button ───
                            _SideNavButton(
                              icon: Icons.dashboard_outlined,
                              label: 'Dashboard',
                              isActive: widget.activeIndex == 0,
                              onTap: () {
                                if (widget.activeIndex != 0) {
                                  context.go('/dashboard');
                                }
                              },
                            ),
                            const SizedBox(height: 8),

                            // ─── Create Profile Button ───
                            _SideNavButton(
                              icon: Icons.person_outline,
                              label: 'Create Profile',
                              isActive: widget.activeIndex == 1,
                              onTap: () {
                                if (widget.activeIndex != 1) {
                                  context.go('/profile');
                                }
                              },
                            ),
                            const SizedBox(height: 8),

                            // ─── Saved Jobs ───
                            _SideNavButton(
                              icon: Icons.bookmark_border,
                              label: 'Saved Jobs',
                              isActive: widget.activeIndex == 2,
                              onTap: () {
                                if (widget.activeIndex != 2) {
                                  context.go('/saved');
                                }
                              },
                            ),
                            const SizedBox(height: 8),

                            // ─── Job Alerts ───
                            _SideNavButton(
                              icon: Icons.notifications_none,
                              label: 'Job Alerts',
                              isActive: widget.activeIndex == 3,
                              onTap: () {
                                if (widget.activeIndex != 3) {
                                  context.go('/alerts');
                                }
                              },
                            ),
                          ],
                        ),

                        // Bottom Section: Divider + Logout
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFFCCCCCC),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _LogoutButton(
                              key: const ValueKey('nav_logout'),
                              onTap: () {
                                // handle logout
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Main Content Area ───
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

/// Single navigation button in the side‐rail.
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
  });

  @override
  State<_SideNavButton> createState() => _SideNavButtonState();
}

class _SideNavButtonState extends State<_SideNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final unselectedColor = const Color(0xFF5C738A);

// Determine background / text/icon color based on active/hover
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
      child:Center(
    child:

      GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 48,
          width: 200,
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
    ),
    );
  }
}

/// ─── Logout Button ─────────────────────────────────
/// Adds Key? key to constructor so super(key: key) is used properly.
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
      child: Center(
        child: Material(
          color: Colors.transparent, // eliminate grey splash
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 48,
              width: 200,
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
        ),
      ),
    );
  }
}
