import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderNav extends StatelessWidget {
  const HeaderNav({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return ClipPath(
      // Optional: Add a custom clipper here if you want a curved bottom
      child: Container(
        color: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: double.infinity),
          child: Row(
            children: [
              const SizedBox(width: 40),

              // LOGO text
              Text(
                'LOGO',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(width: 60),

              // Simple nav items
              TextButton(
                onPressed: () {
context.pushReplacement('/');                },
                child: Text(
                  'Home',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              TextButton(
                onPressed: () {
context.go('/register');                },
                child: Text(
                  'Create Your Profile',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,

                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              TextButton(
                onPressed: () {
                  context.go('/login');                    },
                child: Text(
                  'Find a Job',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 16,

                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const Spacer(),

              // LOGIN Button
              OutlinedButton(
                onPressed: () {
                  GoRouter.of(context).replace('/login');
                  },
                style: OutlinedButton.styleFrom(
                  backgroundColor: primaryColor,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(width: 20),

              // REGISTER Button
              TextButton(
                onPressed: () {
                  GoRouter.of(context).replace('/register');

                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  foregroundColor: primaryColor,
                  textStyle: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                child: const Text('Register'),

              ),
              const SizedBox(width: 20),

              // FOR RECRUITER Button
              TextButton(
                onPressed: () {
                  context.go('/register');
                },

                child: GestureDetector(
                  onTap: () {
                    context.go('/recruiter-signup');

                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'For Recruiter',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          textStyle: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios_sharp,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                    ],
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
