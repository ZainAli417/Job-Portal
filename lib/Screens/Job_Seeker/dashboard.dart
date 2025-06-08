// dashboard.dart - Enhanced Version
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Constant/Job_Carousel.dart';
import '../../Top_Side_Nav.dart';
import 'Dashboard_Provider.dart';

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
    return ChangeNotifierProvider(
      create: (_) => JobProvider(),
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _EnhancedProfileCard(),
                  const SizedBox(height: 32),
                  const JobCarousel(),
                ],
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
}

class _EnhancedProfileCard extends StatefulWidget {
  const _EnhancedProfileCard();

  @override
  State<_EnhancedProfileCard> createState() => _EnhancedProfileCardState();
}

class _EnhancedProfileCardState extends State<_EnhancedProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 32),
                _buildStatsGrid(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back, Zain! 👋',
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









/// Enhanced AI Assistant with modern chat interface
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
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFAFBFC),
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAIHeader(),
            const SizedBox(height: 24),
            _buildMessageInput(primaryColor),
            const SizedBox(height: 40),
            _buildProfileAnalysisSection(primaryColor),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'AI Assistant',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Ask me anything about your profile or job search journey.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(Color primaryColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: widget.isMessageFocused
              ? primaryColor.withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
          width: widget.isMessageFocused ? 2 : 1,
        ),
        boxShadow: widget.isMessageFocused
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(

        controller: widget.messageController,
        focusNode: widget.messageFocusNode,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintText: 'Type your message...',
          filled: false,
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          suffixIcon: _buildSendButton(primaryColor),
        ),
      ),
    );
  }

  Widget _buildSendButton(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _handleSendMessage,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAnalysisSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Color(0xFF10B981),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Profile Analysis',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Get AI-powered insights to optimize your profile for better job matches.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 24),
        _buildAnalyzeButton(primaryColor),
      ],
    );
  }

  Widget _buildAnalyzeButton(Color primaryColor) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isAnalyzing ? _pulseAnimation.value : 1.0,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isAnalyzing ? primaryColor.withOpacity(0.8) : primaryColor,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isAnalyzing ? null : _handleAnalyzeProfile,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isAnalyzing) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else ...[
                    const Icon(
                      Icons.auto_awesome_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _isAnalyzing ? 'Analyzing...' : 'Analyze Profile',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSendMessage() {
    if (widget.messageController.text.trim().isNotEmpty) {
      // TODO: Implement send message logic
      widget.messageController.clear();
      widget.messageFocusNode.unfocus();
    }
  }

  void _handleAnalyzeProfile() async {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate analysis delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
      });
      // TODO: Navigate to profile analysis results
    }
  }
}
