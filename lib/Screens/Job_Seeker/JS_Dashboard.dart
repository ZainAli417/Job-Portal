// JS_Dashboard.dart - Enhanced Version with Smooth, Web‑Friendly Scrolling
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Top_Side_Nav.dart';
import 'job_seeker_provider.dart';
import 'Job_seeker_Available_jobs.dart';

/// A ScrollBehavior that enables smooth inertia scrolling on web and desktop
class SmoothScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    // Allow touch, mouse, stylus...
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Use Clamping for Android, Bouncing for iOS; web/desktop will get a smooth curve
    return const BouncingScrollPhysics(parent: ClampingScrollPhysics());
  }
}

/// Enhanced JobSeekerDashboard with modern UI/UX and optimized performance
class JobSeekerDashboard extends StatefulWidget {
  const JobSeekerDashboard({super.key});

  @override
  State<JobSeekerDashboard> createState() => _JobSeekerDashboardState();
}

class _JobSeekerDashboardState extends State<JobSeekerDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  bool _isMessageFocused = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListener();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  void _setupFocusListener() {
    _messageFocusNode.addListener(() {
      setState(() {
        _isMessageFocused = _messageFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: SmoothScrollBehavior(),
      child: MainLayout(
        activeIndex: 0,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildDashboardContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Main Content
          Expanded(
            flex: 3,
            child: ScrollConfiguration(
              behavior: SmoothScrollBehavior(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 5),
                    _buildStatsGrid(),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 600, // Set a fixed height or calculate based on screen
                      child: Consumer<job_seeker_provider>(
                        builder: (context, provider, _) {
                          return StreamBuilder<List<Map<String, dynamic>>>(
                            stream: provider.publicJobsStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error loading jobs: ${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                );
                              }

                              final jobs = snapshot.data ?? [];

                              if (jobs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.work_outline_rounded,
                                          size: 80,
                                          color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No jobs available right now.\nPlease check back later.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return RepaintBoundary(
                                child: Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 20),
                                  child: LiveJobsForSeeker(jobs: jobs),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Right Column - AI Assistant
          Expanded(
            flex: 1,
            child: _EnhancedAIAssistant(
              messageController: _messageController,
              messageFocusNode: _messageFocusNode,
              isMessageFocused: _isMessageFocused,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back, Zain!',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here is your job search overview',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _EnhancedStatCard(
              icon: Icons.visibility_outlined,
              value: '1,250',
              label: 'Profile Views',
              iconColor: Color(0xFF6366F1),
              bgColor: Color(0xFFF0F0FF),
            ),
            _EnhancedStatCard(
              icon: Icons.send_outlined,
              value: '25',
              label: 'Applications',
              iconColor: Color(0xFF10B981),
              bgColor: Color(0xFFF0FDF4),
            ),
            _EnhancedStatCard(
              icon: Icons.bookmark_outline,
              value: '12',
              label: 'Saved Jobs',
              iconColor: Color(0xFFF59E0B),
              bgColor: Color(0xFFFFFBEB),
            ),
            _EnhancedStatCard(
              icon: Icons.notifications_none_outlined,
              value: '5',
              label: 'Job Alerts',
              iconColor: Color(0xFF8B5CF6),
              bgColor: Color(0xFFF5F3FF),
            ),
          ],
        );
      },
    );
  }
}



class _EnhancedStatCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color bgColor;

  const _EnhancedStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  State<_EnhancedStatCard> createState() => _EnhancedStatCardState();
}

class _EnhancedStatCardState extends State<_EnhancedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.iconColor.withOpacity(0.1),
                    blurRadius: 8 + _elevationAnimation.value,
                    offset: Offset(0, 2 + _elevationAnimation.value / 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildIconContainer(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatValue(),
                      const SizedBox(height: 4),
                      _buildStatLabel(),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        widget.icon,
        color: widget.iconColor,
        size: 30,
      ),
    );
  }

  Widget _buildStatValue() {
    return Text(
      widget.value,
      style: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A1A),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildStatLabel() {
    return Text(
      widget.label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6B7280),
        letterSpacing: -0.1,
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {});
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }
}




class _EnhancedAIAssistant extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode messageFocusNode;
  final bool isMessageFocused;

  const _EnhancedAIAssistant({
    required this.messageController,
    required this.messageFocusNode,
    required this.isMessageFocused,
  });

  @override
  State<_EnhancedAIAssistant> createState() => _EnhancedAIAssistantState();
}

class _EnhancedAIAssistantState extends State<_EnhancedAIAssistant>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isAnalyzing = false;

  // Air Force Color Palette
  static const Color airForceBlue = Color(0xFF1B365D);
  static const Color skyBlue = Color(0xFF3485E4);
  static const Color cloudWhite = Color(0xFFF8FAFC);
  static const Color steelGray = Color(0xFF64748B);
  static const Color accentGold = Color(0xFFCD9D08);
  static const Color jetBlack = Color(0xFF0F172A);
  static const Color successGreen = Color(0xFF07B67C);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cloudWhite,
            Colors.white.withOpacity(0.98),
            cloudWhite.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: skyBlue.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: airForceBlue.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: skyBlue.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAIHeader(),
            const SizedBox(height: 28),
            _buildMessageInput(),
            const SizedBox(height: 36),
            _buildQuickActions(),
            const SizedBox(height: 28),
            _buildProfileAnalysisSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAIHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: skyBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: skyBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.chat_outlined,
                color: airForceBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Career Assistant',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: jetBlack,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: successGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: successGreen.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Online & Ready',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: successGreen,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: skyBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: skyBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: skyBlue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ask me about your profile, career goals, or job search strategy.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: steelGray,
                    letterSpacing: -0.1,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    final isFocused = widget.isMessageFocused;
    final hasText = widget.messageController.text.trim().isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: isFocused ? Colors.white : Colors.grey[50],
        border: Border.all(
          color: isFocused ? skyBlue.withOpacity(0.8) : steelGray.withOpacity(0.15),
          width: isFocused ? 2.5 : 1,
        ),
        boxShadow: isFocused
            ? [
          BoxShadow(
            color: skyBlue.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: skyBlue.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ]
            : [
          BoxShadow(
            color: jetBlack.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            _buildAttachmentButton(),
            const SizedBox(width: 12),

            // Text input field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 44,
                  maxHeight: 120,
                ),
                child: TextField(
                  controller: widget.messageController,
                 // focusNode: widget.messageFocusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: jetBlack,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message ...',
                    filled: false,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: steelGray.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Voice/Send button
            _buildActionButton(),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _handleAttachment,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.attach_file_rounded,
              color: steelGray.withOpacity(0.7),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final hasText = widget.messageController.text.trim().isNotEmpty;
    final isFocused = widget.isMessageFocused;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(6),
      child: Material(
        color: hasText
            ? skyBlue
            : (isFocused ? skyBlue.withOpacity(0.1) : steelGray.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(24),
        elevation: hasText ? 2 : 0,
        shadowColor: skyBlue.withOpacity(0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: hasText ? _handleSendMessage : _handleVoiceInput,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                hasText ? Icons.send_rounded : Icons.mic_rounded,
                key: ValueKey(hasText),
                color: hasText
                    ? Colors.white
                    : (isFocused ? skyBlue : steelGray.withOpacity(0.8)),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

// Additional helper methods to implement
  void _handleAttachment() {
    // Implement attachment functionality
    // Show bottom sheet with options: Camera, Gallery, Files, etc.
  }

  void _handleVoiceInput() {
    // Implement voice input functionality
    // Start voice recording
  }

  void _handleSendMessage() {
    // Your existing send message implementation
  }
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: jetBlack,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildQuickActionCard(
              icon: Icons.work_outline_rounded,
              title: 'Job Match',
              subtitle: 'Find roles',
              color: successGreen,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickActionCard(
              icon: Icons.trending_up_rounded,
              title: 'Skill Gap',
              subtitle: 'Analyze',
              color: accentGold,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickActionCard(
              icon: Icons.article_outlined,
              title: 'Resume',
              subtitle: 'Optimize',
              color: skyBlue,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Implement quick action
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: jetBlack,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: steelGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [successGreen, successGreen.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: successGreen.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Analysis',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: jetBlack,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'AI-powered insights & recommendations',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: steelGray,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildAnalyzeButton(),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isAnalyzing ? _pulseAnimation.value : 1.0,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAnalyzing
                    ? steelGray.withOpacity(0.7)
                    : airForceBlue,
                elevation: _isAnalyzing ? 0 : 8,
                shadowColor: airForceBlue.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _isAnalyzing ? null : _handleAnalyzeProfile,
              child: _isAnalyzing
                  ? _buildAnalyzingContent()
                  : _buildAnalyzeContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyzeContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Analyze My Profile',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white,
          size: 18,
        ),
      ],
    );
  }

  Widget _buildAnalyzingContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Analyzing Profile...',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }


  void _handleAnalyzeProfile() async {
    setState(() {
      _isAnalyzing = true;
    });

    _shimmerController.repeat();

    // Simulate analysis delay
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
      });
      _shimmerController.stop();
      // TODO: Navigate to profile analysis results
    }
  }
}