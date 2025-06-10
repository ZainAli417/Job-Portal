// job_posting_screen.dart

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_portal/Screens/Recruiter/post_a_job_form.dart';
import 'package:job_portal/Screens/Recruiter/posted_jobs_grid.dart';
import 'package:job_portal/Screens/Recruiter/recruiter_Sidebar.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../Constant/recruiter_AI.dart';
import 'job_posting_provider.dart';

/// Main screen showing “Post a Job” + grid of existing jobs on the left,
/// and a vertical “COMING SOON” card on the right.
class JobPostingScreen extends StatefulWidget {
  const JobPostingScreen({Key? key}) : super(key: key);

  @override
  JobPostingScreenState createState() => JobPostingScreenState();
}

class JobPostingScreenState extends State<JobPostingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Recruiter_MainLayout(
      activeIndex: 1,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildJobPosting(context),
        ),
      ),
    );
  }

  Widget _buildJobPosting(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ChangeNotifierProvider<JobPostingProvider>(
          create: (_) => JobPostingProvider(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left Column: Welcome + Carousel of job cards ──
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome text and “Post a New Job” button in one row
                      Row(
                        children: [
                          Expanded(child: _buildWelcomeSection()),
                          ElevatedButton.icon(
                            onPressed: () => _openPostJobDialog(context),
                            icon: const Icon(Icons.post_add, size: 22),
                            label: Text(
                              'Post a New Job',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).primaryColor),
                              foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 18),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              elevation: MaterialStateProperty.all(5),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Carousel or Placeholder
                      Expanded(
                        child: Consumer<JobPostingProvider>(
                          builder: (context, provider, _) {
                            if (provider.jobList.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Replace with your SVG or placeholder
                                    SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Center(
                                        child: Text(
                                          'No jobs posted yet.\nTap “Post a New Job” to get started.',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            // Show two cards side by side in a carousel
                            return RepaintBoundary(
                              child: Center(

                              child: JobsCarousel(),
                            )
                            );                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 5),

                // ── Right Column: Coming Soon or other placeholder ──
                Expanded(
                  flex: 1,
                  child: GeminiChatWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  /// Opens a popup dialog containing the “Post a Job” form.
  void _openPostJobDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const PostJobDialog();
      },
    );
  }

  /// Enhanced welcome message widget.
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),

      ),
      child: Row(
        children: [
          Icon(
            Icons.work_outline_rounded,
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Got New Openings?',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Post a job and manage your applicants in real‐time',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
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
