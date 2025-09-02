import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderNav extends StatelessWidget {
  const HeaderNav({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: const Border(bottom: BorderSide(color: Colors.black12, width: 0.6)),
          ),
          child: Row(
            children: [
              // Logo
              Image.asset(
                'images/logo.jpeg',
                height: 50,
                fit: BoxFit.cover,
              ),

              const SizedBox(width: 40),

              // Navigation Links
              _NavLink(
                label: "Home",
                onTap: () => context.go('/'),
              ),
              _NavLink(
                label: "Create Profile",
                onTap: () => context.go('/register'),
              ),
              _NavLink(
                label: "Find a Job",
                onTap: () => context.go('/login'),
              ),

              const Spacer(),

              // Recruiter CTA
              TextButton.icon(
                onPressed: () => context.go('/recruiter-signup'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.business_center, size: 18),
                label: Text("For Recruiters", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
              ),

              const SizedBox(width: 20),

              // Login & Register buttons
              OutlinedButton(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  foregroundColor: primaryColor,
                ),
                child: Text("Login", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
              ),

              const SizedBox(width: 12),

              ElevatedButton(
                onPressed: () => context.go('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Register", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
