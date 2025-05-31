import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/flutter_svg.dart' show  SvgPicture;

import '../Header_Nav.dart';
import 'Signup_Provider.dart';
import 'login_provider.dart'; // Assume this provider also has a `login(...)` method

class JobSeekerLoginScreen extends StatefulWidget {
  const JobSeekerLoginScreen({super.key});
  @override
  State<JobSeekerLoginScreen> createState() => _JobSeekerLoginScreenState();
}

class _JobSeekerLoginScreenState extends State<JobSeekerLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for email & password only
  final _email = TextEditingController();
  final _password = TextEditingController();

  double _opacity = 0;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Fade in the form
    WidgetsBinding.instance.addPostFrameCallback((_) {
       setState(() {
        _opacity = 1;
      });
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showFlushbar(BuildContext context, String message, bool isError) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.red : Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<LoginProvider>(context, listen: false);
    // Replace with your actual login method. For example:
    // final error = await provider.login(email: _email.text.trim(), password: _password.text, role: widget.role);
    final error = await provider.login(
      email: _email.text.trim(),
      password: _password.text,
    );

    if (error != null) {
      _showFlushbar(context, error, true);
    } else {
      _showFlushbar(context, "Login Successful!", false);
      // Navigate to the next screen, e.g. Dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const HeaderNav(),

          Expanded(
    child: Padding(
    padding: const EdgeInsets.fromLTRB(180,5,180,5),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;

                  return Row(
                    children: [
                      // ───── LEFT COLUMN: SVG IMAGE ─────
                      if (isWide)
                        SizedBox(
                          width: 700,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              "images/login.svg",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                      // ───── RIGHT COLUMN: LOGIN FORM ─────
                      Expanded(
                        flex: isWide ? 1 : 0,

                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // ─── Heading ───
                                    Center(
                                      child: Text(
                                        "Login to your account",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // ─── Email Field ───
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Email",
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildCapsuleField(
                                          controller: _email,
                                          hintText: "johndoe@email.com",
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          suffixIcon: Icons.email_outlined,
                                          isEmail: true,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // ─── Password Field ───
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Password",
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _password,
                                          obscureText: _obscurePassword,
                                          validator: (val) {
                                            if (val == null ||
                                                val.trim().isEmpty) {
                                              return "Required";
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Enter your password",
                                            hintStyle: GoogleFonts.montserrat(
                                              color: Colors.grey.shade600,
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade100,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.grey.shade600,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword =
                                                      !_obscurePassword;
                                                });
                                              },
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: primaryColor,
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),

                                    // ─── Login Button ───
                                    Consumer<SignUpProvider>(
                                      builder: (_, provider, __) {
                                        return SizedBox(
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: provider.isLoading
                                                ? null
                                                : _onLogin,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: provider.isLoading
                                                ? const CircularProgressIndicator(
                                                    color: Colors.white)
                                                : Text(
                                                    "Login",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // ─── Forgot & "New here? Create Account" Row ───
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
context.go('/recover-password');
},
                                          style: TextButton.styleFrom(
                                              foregroundColor: primaryColor),
                                          child: Text(
                                            "Forgot Password?",
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        TextButton(
                                          onPressed: () {
                                            context.go('/register');
                                          },
                                          style: TextButton.styleFrom(
                                              foregroundColor: primaryColor),
                                          child: Text(
                                            "New here? Create Account",
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },

            ),

    ),

          ),
        ],
      ),
    );
  }

  /// Builds a single capsule‐style text field without an internal label
  Widget _buildCapsuleField({
    required TextEditingController controller,
    required String hintText,
    bool isEmail = false,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: false,
      validator: validator ??
          (val) {
            if (val == null || val.trim().isEmpty) return "Required";
            if (isEmail && !val.contains("@")) return "Enter valid email";
            return null;
          },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.montserrat(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.grey.shade600)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
