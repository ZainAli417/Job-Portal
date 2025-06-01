// dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the updated MainLayout (adjust the path if needed)
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
        activeIndex: 0, // “Dashboard” is index 0
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Consumer<JobProvider>(
            builder: (context, provider, _) {
              return ListView.separated(
                key: const ValueKey('dashboard_list'),
                itemCount: provider.jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _JobCard(job: provider.jobs[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

}

class _JobCard extends StatefulWidget {
  final Job job;
  const _JobCard({required this.job});

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform:
        _isHovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
              blurRadius: _isHovered ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // ─── Job Info ───
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.job.company,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5C738A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF5C738A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.job.location,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xFF5C738A),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Color(0xFF5C738A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.job.salary,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xFF5C738A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Apply Button ───
            ElevatedButton(
              onPressed: () {
                // TODO: Handle Apply action
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(primaryColor),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                elevation: MaterialStateProperty.all(0),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Apply',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
