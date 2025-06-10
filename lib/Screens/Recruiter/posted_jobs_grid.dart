import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'job_posting_provider.dart';

/// Enhanced Jobs Carousel with compact design showing exactly 2 cards
/// Auto-scrolls only when there are more than 2 jobs
class JobsCarousel extends StatefulWidget {
  const JobsCarousel({Key? key}) : super(key: key);

  @override
  State<JobsCarousel> createState() => _JobsCarouselState();
}

class _JobsCarouselState extends State<JobsCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.52); // Slightly more than half for better spacing
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isHovering) return;
      final provider = Provider.of<JobPostingProvider>(context, listen: false);
      final itemCount = provider.jobList.length;

      // Only auto-scroll if there are more than 2 jobs
      if (itemCount <= 2) return;

      int nextPage = (_currentPage + 1) % itemCount;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobList = Provider.of<JobPostingProvider>(context).jobList;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Column(
        children: [
          // Compact carousel container
          Container(
            height: 540, // Reduced height for compact design
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1000), // Max width constraint
            child: jobList.length <= 2
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: jobList.asMap().entries.map((entry) {
                return Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: JobCard(jobData: entry.value),
                  ),
                );
              }).toList(),
            )
                : PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: jobList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: JobCard(jobData: jobList[index]),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Enhanced indicator dots (only show if more than 2 jobs)
          if (jobList.length > 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(jobList.length, (index) {
                final isActiveDot = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActiveDot ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActiveDot
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

/// Redesigned compact Job Card with enhanced UI/UX
class JobCard extends StatefulWidget {
  final Map<String, dynamic> jobData;
  const JobCard({Key? key, required this.jobData}) : super(key: key);

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getRelativeTime(Timestamp? ts) {
    if (ts == null) return '';
    final date = ts.toDate();
    return timeago.format(date, locale: 'en_short');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JobPostingProvider>(context, listen: false);
    final job = widget.jobData;
    final jobId = job['id'] as String;
    final status = job['status'] as String? ?? 'active';
    final isActive = status == 'active';

    // Extract data with fallbacks
    final title = job['title'] as String? ?? 'No Title';
    final department = job['department'] as String? ?? 'N/A';
    final company = job['company'] as String? ?? 'Unknown Company';
    final location = job['location'] as String? ?? 'Unknown Location';
    final description = job['description'] as String? ?? '';
    final responsibilities = job['responsibilities'] as String? ?? '';
    final qualifications = job['qualifications'] as String? ?? '';
    final deadline = job['deadline'] as String? ?? 'N/A';
    final contactEmail = job['contactEmail'] as String? ?? 'N/A';
    final skills = (job['skills'] as List<dynamic>?)?.cast<String>() ?? [];
    final benefits = (job['benefits'] as List<dynamic>?)?.cast<String>() ?? [];
    final workModes = (job['workModes'] as List<dynamic>?)?.cast<String>() ?? [];
    final pay = job['pay'] as String? ?? 'Competitive';
    final experience = job['experience'] as String? ?? 'Not specified';
    final nature = job['nature'] as String? ?? 'Full Time';
    final logoUrl = job['logoUrl'] as String?;
    final timestamp = job['timestamp'] as Timestamp?;
    final postedAgo = _getRelativeTime(timestamp);

    final primaryColor = Theme.of(context).primaryColor;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isActive ? 1.0 : 0.65,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isActive
                        ? [Colors.white, Colors.grey.shade50]
                        : [Colors.grey.shade100, Colors.grey.shade200],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isHovered
                        ? primaryColor.withOpacity(0.6)
                        : Colors.grey.shade200,
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? primaryColor.withOpacity(0.15)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: _isHovered ? 20 : 8,
                      offset: Offset(0, _isHovered ? 8 : 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      // Header with gradient background
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                         color: Color(0xFFF5F5F5)
                        ),
                        child: _buildHeader(logoUrl, title, company, department, location, postedAgo,contactEmail,deadline,),
                      ),

                      // Main content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildKeyInfo(pay, experience, nature),
                              const SizedBox(height: 8),
                              _buildDescription(description),
                              const SizedBox(height: 8),
                              _buildChipSections(workModes, skills, benefits),
                              const SizedBox(height: 8),
                              _buildDetailedSections(responsibilities, qualifications),
                              const Spacer(),
                              _buildFooter(deadline, contactEmail, isActive, jobId, status, provider, primaryColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String? logoUrl, String title, String company, String department, String location, String postedAgo, String contactEmail, String deadline) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.grey.shade100, Colors.white],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: logoUrl != null && logoUrl.isNotEmpty
              ? ClipOval(child: Image.network(logoUrl, fit: BoxFit.cover))
              : Icon(Icons.business_center, color: Color(0xFF64748B), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$company • $department',
                style: GoogleFonts.  montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                location,
                style: GoogleFonts.  montserrat(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        contactEmail,
                        style: GoogleFonts.  montserrat(fontSize: 12, color: Color(0xFF64748B),fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(width: 5,),
                    Text(
                      'Posted On: ',
                      style: GoogleFonts.  montserrat(fontSize: 10, color: Color(0xFF64748B)),

                      overflow: TextOverflow.ellipsis,
                    ),                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        deadline,
                        style: GoogleFonts.  montserrat(fontSize: 10, color: Color(0xFF64748B),fontWeight: FontWeight.w600),

                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),


            ],
          ),
        ),
        if (postedAgo.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF006CFF).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$postedAgo ago',
              style: GoogleFonts.  montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildKeyInfo(String pay, String experience, String nature) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CompactInfoChip(icon: Icons.attach_money, text: pay, color: Colors.green.shade700),
        const SizedBox(width: 8),
        _CompactInfoChip(icon: Icons.trending_up, text: experience, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        _CompactInfoChip(icon: Icons.schedule, text: nature, color: Colors.orange.shade700),
      ],
    );
  }

  Widget _buildDescription(String description) {
    if (description.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(text: 'Description'),
        Text(
          description,
          style: GoogleFonts.  montserrat(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildChipSections(List<String> workModes, List<String> skills, List<String> benefits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (workModes.isNotEmpty) _buildChipRow('Work Modes', workModes, Colors.indigo.shade700),
        if (skills.isNotEmpty) _buildChipRow('Skills', skills, Colors.teal.shade700),
        if (benefits.isNotEmpty) _buildChipRow('Benefits', benefits, Colors.purple.shade700),
      ],
    );
  }

  Widget _buildChipRow(String title, List<String> items, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(text: title),
          const SizedBox(height: 2),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: items.take(4).map((item) => _CompactChip(text: item, color: color)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSections(String responsibilities, String qualifications) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (responsibilities.isNotEmpty) _buildTextSection('Responsibilities', responsibilities),
        if (qualifications.isNotEmpty) _buildTextSection('Qualifications', qualifications),
      ],
    );
  }

  Widget _buildTextSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(text: title),
          Text(
            content,
            style: GoogleFonts.  montserrat(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.3,
              fontWeight: FontWeight.w500
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(String deadline, String contactEmail, bool isActive, String jobId, String status, JobPostingProvider provider, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          
          
          Row(
            children: [
            
            ],
          ),
          
          
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isActive ? 'Active' : 'Paused',
                    style: GoogleFonts.  montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.green : Colors.red,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isActive,
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (_) async {
                        await provider.toggleJobStatus(jobId, status);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: _ActionButton(
                      icon: Icons.edit,
                      label: 'Edit',
                      color: primaryColor,
                      onPressed: () {
                        //provider.loadJobForEditing();
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: _ActionButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red,
                      onPressed: () async {
                        await provider.deleteJob(jobId);
                      },
                    ),
                  ),
                ],
              )

            ],
          ),
        ],
      ),
    );
  }
}

// Helper Widgets
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.  montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _CompactInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _CompactInfoChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.  montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactChip extends StatelessWidget {
  final String text;
  final Color color;

  const _CompactChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: GoogleFonts.  montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.  montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}