// top_nav.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_portal/Screens/Recruiter/sidebar_provider.dart';
import 'package:provider/provider.dart';

class Recruiter_MainLayout extends StatefulWidget {
  final Widget child;
  final int activeIndex; // 0 = Dashboard, 1 = Profile, etc.
  final Key? key;

  const Recruiter_MainLayout({
    this.key,
    required this.child,
    required this.activeIndex,
  }) : super(key: key);

  @override
  State<Recruiter_MainLayout> createState() => _Recruiter_MainLayoutState();
}

class _Recruiter_MainLayoutState extends State<Recruiter_MainLayout> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();
  final Color _cardWhite = Color(0xFFFAFAFA);
  final Color _textPrimary = Color(0xFF1E293B);
  final Color _textSecondary = Color(0xFF64748B);
  final Color _borderColor = Color(0xFFE2E8F0);
  final Color _hoverColor = Color(0xFFF1F5F9);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final bool _isSearchFocused = false;

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
    return ChangeNotifierProvider<R_TopNavProvider>(
      create: (_) => R_TopNavProvider(),
      child: RepaintBoundary(child: _buildScaffold(context)),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final initials = context.watch<R_TopNavProvider>().initials;
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Row(
        children: [
          RepaintBoundary(
            child: Container(
              width: 240,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),

              ),
              child: ClipRRect(
                // ensure rounded corners clip scrollable content
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(height: 24),
                      _buildUserProfileSection(primaryColor),
                      const SizedBox(height: 12),
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
                              context.go('/recruiter-dashboard');
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
                          label: 'Post A Job',
                          isActive: widget.activeIndex == 1,
                          onTap: () {
                            if (widget.activeIndex != 1) {
                              context.go('/job-posting');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ─── Saved Jobs ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.file_copy,
                          label: 'View Applications',
                          isActive: widget.activeIndex == 2,
                          onTap: () {
                            if (widget.activeIndex != 2) {
                              context.go('/view-applications');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ─── Job Alerts ───
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.broadcast_on_home_rounded,
                          label: 'Interviews',
                          isActive: widget.activeIndex == 2,
                          onTap: () {
                            if (widget.activeIndex != 2) {
                              context.go('/interviews');
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _SideNavButton(
                          icon: Icons.notifications_none,
                          label: 'Settings',
                          isActive: widget.activeIndex == 3,
                          onTap: () {
                            if (widget.activeIndex != 3) {
                              context.go('/settings');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _LogoutButton(
                          key: const ValueKey('nav_logout'),
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            context.pushReplacement('/');
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
                _buildTopBar(primaryColor, initials),
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

  bool _isDarkMode = false;
  int? _activeMenu; // 0 for Notifications, 1 for Messages, etc.

// A helper for colors to support dark mode
  Color get _iconColor => _isDarkMode ? Colors.grey.shade400 : _textSecondary;
  Color get _iconHoverBg => _isDarkMode ? Colors.grey.shade800 : _hoverColor;
  Color get _appBarBg => _isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFF4F4F4);
  Color get _appBarBorder => _isDarkMode ? Colors.grey.shade800 : _borderColor;





  Widget _buildTopBar(Color primaryColor, String initials) {
    return Container(
      height: 70,
      width: 600, // It's better to let the parent control the width for responsiveness
      decoration: BoxDecoration(
        color: _appBarBg, // Use dynamic color
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          bottom: BorderSide(
            color: _appBarBorder, // Use dynamic color
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // ─── Search Field (Unchanged as requested) ───
          // ─── Action Widgets ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- NEW: Primary Action Button ---
              _buildPrimaryActionButton(
                text: 'Post a Job',
                icon: Icons.add_circle_outline_rounded,
                onPressed: () => print('Navigate to Post Job page'),
              ),

              const SizedBox(width: 24),

              // --- NEW: Quick Links / Apps Menu ---
              _buildIconButton(
                tooltip: 'Quick Links',
                icon: Icons.apps_rounded,
                onPressed: () => _showQuickLinks(context),
                isActive: _activeMenu == 2,
              ),

              const SizedBox(width: 10),

              // --- ENHANCED: Notifications with badge ---
              _buildIconButton(
                tooltip: 'Notifications',
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_rounded,
                onPressed: () => setState(() => _activeMenu = 0),
                badge: 3,
                isActive: _activeMenu == 0,
              ),

              const SizedBox(width: 10),

              // --- ENHANCED: Messages ---
              _buildIconButton(
                tooltip: 'Messages',
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                onPressed: () => setState(() => _activeMenu = 1),
                isActive: _activeMenu == 1,
              ),

              // A visual separator for clarity
              VerticalDivider(
                  color: _appBarBorder,
                  width: 32,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10),

              // --- NEW: Help & Support ---
              _buildIconButton(
                tooltip: 'Help & Support',
                icon: Icons.help_outline_rounded,
                onPressed: () => _showHelpCenter(context),
              ),

              const SizedBox(width: 10),

              // --- NEW: Theme Toggle ---
              _buildIconButton(
                tooltip: _isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                icon: _isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
              ),

              const SizedBox(width: 20),

              // --- Profile Menu ---
              _buildProfileMenu(primaryColor, initials),
            ],
          ),
        ],
      ),
    );
  }


  /// Builds a new, prominent CTA button.
  Widget _buildPrimaryActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor, // Text and icon color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }


  /// A heavily enhanced icon button that supports hover, active states,
  /// dynamic tooltips, and notification badges.
  Widget _buildIconButton({
    required String tooltip,
    required IconData icon,
    IconData? activeIcon, // Optional icon for the active state
    required VoidCallback onPressed,
    int? badge,
    bool isActive = false,
  }) {
    final hoverProvider = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: hoverProvider,
      builder: (context, isHovering, child) {
        final isHighlighted = isHovering || isActive;
        return Tooltip(
          message: tooltip,
          waitDuration: const Duration(milliseconds: 500),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                onTap: onPressed,
                onHover: (value) => hoverProvider.value = value,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isHighlighted ? _iconHoverBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive ? (activeIcon ?? icon) : icon,
                    color: isActive ? Theme.of(context).primaryColor : _iconColor,
                    size: 24, // Standardized size
                  ),
                ),
              ),
              if (badge != null && badge > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(color: _appBarBg, width: 2),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      badge.toString(),
                      style: GoogleFonts.montserrat(
                          fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  void _showQuickLinks(BuildContext context) => print('Showing Quick Links menu');
  void _showHelpCenter(BuildContext context) => print('Showing Help Center');

  Widget _buildProfileMenu(Color primaryColor, String initials) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _borderColor,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: primaryColor,
          child: Text(
            initials.isNotEmpty ? initials : 'ZA',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      itemBuilder: (context) => [
        _buildPopupMenuItem('Profile', Icons.person_outline_rounded, () {
          context.go('/profile');
        }),
        _buildPopupMenuItem('Settings', Icons.settings_outlined, () {
          context.go('/');
        }),
        _buildPopupMenuItem('Help', Icons.help_outline_rounded, () {
          // Handle help
        }),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          onTap: () {
            _showLogoutDialog(context);
          },
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 18,
                color: Colors.red.shade500,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Logout',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: title.toLowerCase(),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? Colors.red.shade500 : _textSecondary,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red.shade500 : _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    // Placeholder: show a bottom sheet or dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('You have new notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMessages(BuildContext context) {
    // Placeholder: show a bottom sheet or dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Messages'),
        content: const Text('You have new messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirm Logout',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              context.pushReplacement('/');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zain Ali',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'HOD HR Section',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

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
      cursor: SystemMouseCursors.click,
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
      return Color(0xFFF5F5F5);
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
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _logout(context),
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
  // In your dashboard screen's state widget (e.g., _JobSeekerDashboardState)

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.pushReplacement('/');
    }
  }
}
