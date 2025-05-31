import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'Screens/Job_Seeker/Signup_Provider.dart';
import 'Screens/Job_Seeker/Login.dart';              // ← Login screen
import 'Screens/Job_Seeker/Sign Up.dart';            // ← Signup screen
import 'Screens/Job_Seeker/login_provider.dart';
import 'Screens/Splash.dart';
import 'Web_routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Force‐load a dummy Montserrat text so it’s pre-cached
    TextPainter(
      text: TextSpan(text: " ", style: GoogleFonts.montserrat()),
      textDirection: TextDirection.ltr,
    ).layout();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),  // ← add LoginProvider
      ],
      child: const JobPortalApp(),
    ),
  );
}

class JobPortalApp extends StatelessWidget {
  const JobPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hire Flow',
      debugShowCheckedModeBanner: false,
      routerConfig: router, // ← use GoRouter configuration
      theme: ThemeData(
        primaryColor: const Color(0xFF006CFF),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF006CFF),
          secondary: const Color(0xFF006CFF),
        ),
        fontFamily: GoogleFonts.montserrat().fontFamily,
        textTheme: GoogleFonts.montserratTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          buttonColor: const Color(0xFF006CFF),
          textTheme: ButtonTextTheme.primary,
        ),
      ),
    );
  }
}

/// RoleProvider: holds the selected role (job seeker / recruiter)
class RoleProvider extends ChangeNotifier {
  /// Either "Job Seeker" or "Recruiter"
  String? _selectedRole;
  String? get selectedRole => _selectedRole;

  void setRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }
}
