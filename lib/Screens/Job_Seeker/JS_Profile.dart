import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Constant/Profile_Sidebar.dart';
import '../../Top_Side_Nav.dart';
import 'Profile_Provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final Color addcolor = Color(0xFF006CFF);

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: MainLayout(
        activeIndex: 1,
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Consumer<ProfileProvider>(
                    builder: (context, provider, _) {
                      // If data is still loading, show a spinner
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // Once loaded, show two‐column layout:
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: existing tabs/form
                          Flexible(
                            flex: 2,
                            child: Form(
                              key: provider.formKey,
                              child: DefaultTabController(
                                // Updated to 6 because we now have 6 tabs
                                length: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeader(),
                                    const SizedBox(height: 16),
                                    _buildTabBar(context),
                                    const SizedBox(height: 24),
                                    Expanded(
                                      child: TabBarView(
                                        physics: const BouncingScrollPhysics(),
                                        children: [
                                          _buildProfileSummaryTab(provider),
                                          _buildEducationalSummaryTab(provider,context),
                                          _buildProfessionalExperienceTab(provider,context),
                                          _buildCertificationsTab(provider,context),
                                          _buildSkillsTab(provider, context), // pass context
                                          _buildAttachmentsTab(context),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Right column: sidebar
                          Flexible(
                            flex: 1,
                            child: ProfileSidebar(provider: provider),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Hero(
      tag: 'profile_header',
      child: Material(
        type: MaterialType.transparency,
        child: Text(
          'Job Seeker Profile',
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        isScrollable: true,
        indicatorColor: Theme.of(context).primaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.black87,
        unselectedLabelColor: const Color(0xFF5C738A),
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.all(
          Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        tabs: const [
          Tab(text: 'Profile Summary'),
          Tab(text: 'Educational Summary'),
          Tab(text: 'Professional Experience'),
          Tab(text: 'Certifications'),
          Tab(text: 'Skills & Interests'),
          Tab(text: 'Attachments'),
        ],
      ),
    );
  }

  Widget _buildAttachmentsTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            child: Text(
              'Upload Supporting Documents (If Any)',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
             child: _buildAnimatedUploadButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map((child) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: child,
                      ),
                    ))
                .toList(),
          );
        } else {
          return Column(
            children: children
                .map((child) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: child,
                    ))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildAnimatedField({
    required String label,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(label),
              const SizedBox(height: 8),
              child,
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required String hint,
    IconData? icon,
    bool isEmail = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    required void Function(String?) onSaved,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        validator: validator ??
            (val) {
              if (val == null || val.trim().isEmpty) return 'Required';
              if (isEmail && !val.contains('@')) return 'Enter valid email';
              return null;
            },
        onChanged: onChanged,
        onSaved: onSaved,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF5C738A), size: 20)
              : null,
          hintStyle: GoogleFonts.montserrat(
            color: const Color(0xFF5C738A),
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: const Color(0xFFEBEDF2),
          contentPadding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: icon != null ? 12 : 16,
          ),
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
            borderSide: const BorderSide(
              color: Color(0xFF006CFF),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildMulti_Line_TextArea({
    required String initialValue,
    required String hint,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    required void Function(String?) onSaved,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: 4,
        validator: validator ??
            (val) {
              if (val == null || val.trim().isEmpty) return 'Required';
              return null;
            },
        onChanged: onChanged,
        onSaved: onSaved,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.montserrat(
            color: const Color(0xFF5C738A),
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: const Color(0xFFEBEDF2),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
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
            borderSide: const BorderSide(
              color: Color(0xFF006CFF),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

    Widget _buildAnimatedUploadButton(BuildContext context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
             BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
             ),
            ],
          ),
         child: ElevatedButton.icon(
            onPressed: () {
              // File picker logic here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                     const Text('File picker functionality to be implemented'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
           icon: const Icon(Icons.upload_file_outlined, color: Colors.white),
            label: Text(
              'Choose File',
             style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return Theme.of(context).primaryColor.withOpacity(0.8);
                }
                return Theme.of(context).primaryColor;
              }),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
             )),
              elevation: WidgetStateProperty.all(0),
              overlayColor: WidgetStateProperty.all(
                Colors.white.withOpacity(0.1),
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        );
      }


  Widget _buildSkillsTab(ProfileProvider provider, BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAnimatedField(
            label: 'Add a Skill',

            child: TextFormField(
              //
              // Use the provider’s controller rather than initialValue:
              controller: provider.skillController,
              decoration: InputDecoration(
                hintText: 'Enter a skill and press Add',
                hintStyle: GoogleFonts.montserrat(
                  color: const Color(0xFF5C738A),
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: const Color(0xFFEBEDF2),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  borderSide: const BorderSide(
                    color: Color(0xFF006CFF),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              onFieldSubmitted: (_) => provider.addSkillEntry(context),
              onChanged: (val) => provider.updateTempSkill(val),
              validator: (val) => null,
            ),
          ),

          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => provider.addSkillEntry(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Skill'),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  addcolor.withOpacity(0.05),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                elevation: WidgetStateProperty.all(4),
                overlayColor: WidgetStateProperty.all(
                  Colors.white.withOpacity(0.1),
                ),
              ),
            ),

          ),

          const SizedBox(height: 24),
          if (provider.skillsList.isEmpty)
            Center(
              child: Text(
                'No skills added yet.',
                style: GoogleFonts.montserrat(color: Colors.grey.shade600),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.skillsList.map((skill) {
                return Chip(
                  label: Text(
                    skill,
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                  backgroundColor:CupertinoColors.activeGreen,
                  deleteIcon:
                  const Icon(Icons.close, size: 18, color: Colors.white),
                  onDeleted: () {
                    provider.skillsList.remove(skill);
                    provider.markSkillsDirty();
                    provider.notifyListeners();
                  },
                );
              }).toList(),
            ),

          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                if (provider.skillsList.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('At least one skill is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                provider.saveSkillsSection(context);
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Save Skills'),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    provider.getButtonColorForSection('skills')),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                elevation: WidgetStateProperty.all(4),
                overlayColor: WidgetStateProperty.all(
                  Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }


Widget _buildProfileSummaryTab(ProfileProvider provider) {
  return SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: Column(
      children: [
        _buildResponsiveRow([
         _buildAnimatedField(
            label: 'Summary',
            child: TextFormField(
              initialValue: provider.summary,
              maxLines: 5,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'A summary is required';
                }
                return null;
              },
              onChanged: (val) => provider.updateSummary(val),
              onSaved: (val) => provider.updateSummary(val!.trim()),
              decoration: InputDecoration(
                hintText: 'Write a brief summary about yourself (4-5 lines)',
                hintStyle: GoogleFonts.montserrat(
                  color: const Color(0xFF5C738A),
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: const Color(0xFFEBEDF2),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                  borderSide: const BorderSide(
                    color: Color(0xFF006CFF),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        _buildResponsiveRow([
          _buildAnimatedField(
            label: 'First Name',
            child: _buildTextField(
              initialValue: provider.firstName,
              hint: 'Enter first name',
              icon: Icons.person_outline,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                return null;
              },
              onChanged: (val) => provider.updateFirstName(val),
              onSaved: (val) => provider.updateFirstName(val!),
            ),
          ),
          _buildAnimatedField(
            label: 'Last Name',
            child: _buildTextField(
              initialValue: provider.lastName,
              hint: 'Enter last name',
              icon: Icons.person_outline,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                return null;
              },
              onChanged: (val) => provider.updateLastName(val),
              onSaved: (val) => provider.updateLastName(val!),
            ),
          ),
        ]),


        const SizedBox(height: 16),
        _buildResponsiveRow([
          _buildAnimatedField(
            label: 'Email',
            child: _buildTextField(
              initialValue: provider.email,
              hint: 'johndoe@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                if (!val.contains('@')) return 'Enter valid email';
                return null;
              },
              onChanged: (val) => provider.updateEmail(val),
              onSaved: (val) => provider.updateEmail(val!),
            ),
          ),
          _buildAnimatedField(
            label: 'Phone',
            child: _buildTextField(
              initialValue: provider.phone,
              hint: '+1 234 567 890',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                return null;
              },
              onChanged: (val) => provider.updatePhone(val),
              onSaved: (val) => provider.updatePhone(val!),
            ),
          ),
        ]),



        const SizedBox(height: 16),
        _buildResponsiveRow([
          _buildAnimatedField(
            label: 'Location',
            child: _buildTextField(
              initialValue: provider.location,
              hint: 'City, Country',
              icon: Icons.location_on_outlined,
              validator: null,
              onChanged: (val) => provider.updateLocation(val),
              onSaved: (val) => provider.updateLocation(val!),
            ),
          ),
          _buildAnimatedField(
            label: 'LinkedIn Profile',
            child: _buildTextField(
              initialValue: provider.linkedIn,
              hint: 'https://linkedin.com/in/username',
              icon: Icons.link_outlined,
              keyboardType: TextInputType.url,
              validator: null,
              onChanged: (val) => provider.updateLinkedIn(val),
              onSaved: (val) => provider.updateLinkedIn(val!),
            ),
          ),

        ]),




        const SizedBox(height: 16),
        Center(child:
        _buildResponsiveRow([

          _buildAnimatedField(
            label: 'Current Role',
            child: _buildTextField(
              initialValue: provider.current_job,
              hint: 'iOS Dev,Full Stack Dev....',
              icon: Icons.web_outlined,
              keyboardType: TextInputType.url,
              validator: null,
              onChanged: (val) => provider.updatecurrent_job(val),
              onSaved: (val) => provider.updatecurrent_job(val!),
            ),
          ),
        ]),
            ),
        const SizedBox(height: 32),

        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, _) {
            final btnColor = provider.getButtonColorForSection('personal');
            return Transform.scale(
              scale: value,
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate before saving
                      if (provider.formKey.currentState!.validate()) {
                        provider.formKey.currentState!.save();
                        provider.savePersonalSection(context);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(btnColor),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: WidgetStateProperty.all(4),
                      overlayColor: WidgetStateProperty.all(
                        Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.save_outlined,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Save & Go To Education Section',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}


  Widget _buildEducationalSummaryTab(ProfileProvider provider,BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAnimatedField(
            label: 'School/University',
            child: _buildTextField(
              initialValue: provider.tempSchool,
              hint: 'Enter institution name',
              icon: Icons.school_outlined,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                return null;
              },
              onChanged: (val) => provider.updateTempSchool(val),
              onSaved: (val) => provider.updateTempSchool(val!),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedField(
                  label: 'Degree',
                  child: _buildTextField(
                    initialValue: provider.tempDegree,
                    hint: 'e.g. Bachelor of Science',
                    icon: Icons.school_outlined,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      return null;
                    },
                    onChanged: (val) => provider.updateTempDegree(val),
                    onSaved: (val) => provider.updateTempDegree(val!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAnimatedField(
                  label: 'Field of Study',
                  child: _buildTextField(
                    initialValue: provider.tempFieldOfStudy,
                    hint: 'e.g. Computer Science',
                    icon: Icons.book_outlined,
                    validator: null,
                    onChanged: (val) => provider.updateTempFieldOfStudy(val),
                    onSaved: (val) => provider.updateTempFieldOfStudy(val!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedField(
                  label: 'Start Year',
                  child: _buildTextField(
                    initialValue: provider.tempEduStart,
                    hint: 'YYYY',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      return null;
                    },
                    onChanged: (val) => provider.updateTempEduStart(val),
                    onSaved: (val) => provider.updateTempEduStart(val!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAnimatedField(
                  label: 'End Year',
                  child: _buildTextField(
                    initialValue: provider.tempEduEnd,
                    hint: 'YYYY',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      return null;
                    },
                    onChanged: (val) => provider.updateTempEduEnd(val),
                    onSaved: (val) => provider.updateTempEduEnd(val!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnimatedField(
            label: ' ',
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => provider.addEducationEntry(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Education'),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    addcolor.withOpacity(0.05),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(4),
                  overlayColor: WidgetStateProperty.all(
                    Colors.white.withOpacity(0.1),
                  ),
                ),
              ),

            ),
          ),
          const SizedBox(height: 24),
          if (provider.educationList.isEmpty)
            Center(
              child: Text(
                'No education entries yet.',
                style: GoogleFonts.montserrat(color: Colors.grey.shade600),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.educationList.length,
              itemBuilder: (context, index) {
                final edu = provider.educationList[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${edu['degree']} in ${edu['fieldOfStudy']}',
                      style:
                      GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${edu['school']} (${edu['eduStart']} – ${edu['eduEnd']})',
                      style: GoogleFonts.montserrat(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => provider.saveEducationSection(context),
              icon: const Icon(Icons.save, size: 18,color: Colors.white,),
              label: const Text('Save & Go To Experience Section',style: TextStyle(color:Colors.white),),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    provider.getButtonColorForSection('education')),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                ),
                elevation: WidgetStateProperty.all(4),
                overlayColor: WidgetStateProperty.all(
                  Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfessionalExperienceTab(ProfileProvider provider,BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAnimatedField(
            label: 'Company',
            child: _buildTextField(
              initialValue: provider.tempCompany,
              hint: 'Enter company name',
              icon: Icons.business_outlined,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                return null;
              },
              onChanged: (val) => provider.updateTempCompany(val),
              onSaved: (val) => provider.updateTempCompany(val!),
            ),
          ),
          const SizedBox(height: 16),
          _buildAnimatedField(
            label: 'Role/Position',
            child: _buildTextField(
              initialValue: provider.tempRole,
              hint: 'e.g. Software Engineer',
              icon: Icons.work_outline,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                return null;
              },
              onChanged: (val) => provider.updateTempRole(val),
              onSaved: (val) => provider.updateTempRole(val!),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedField(
                  label: 'Start Date',
                  child: _buildTextField(
                    initialValue: provider.tempExpStart,
                    hint: 'MM/YYYY',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.datetime,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      return null;
                    },
                    onChanged: (val) => provider.updateTempExpStart(val),
                    onSaved: (val) => provider.updateTempExpStart(val!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAnimatedField(
                  label: 'End Date',
                  child: _buildTextField(
                    initialValue: provider.tempExpEnd,
                    hint: 'MM/YYYY or Present',
                    icon: Icons.calendar_today_outlined,
                    validator: null,
                    onChanged: (val) => provider.updateTempExpEnd(val),
                    onSaved: (val) => provider.updateTempExpEnd(val!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAnimatedField(
            label: 'Description',
            child: _buildMulti_Line_TextArea(
              initialValue: provider.tempExpDescription,
              hint: 'Describe your role and responsibilities',
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                return null;
              },
              onChanged: (val) => provider.updateTempExpDescription(val),
              onSaved: (val) => provider.updateTempExpDescription(val!),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => provider.addExperienceEntry(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Experience'),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  addcolor.withOpacity(0.05),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                elevation: WidgetStateProperty.all(4),
                overlayColor: WidgetStateProperty.all(
                  Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (provider.experienceList.isEmpty)
            Center(
              child: Text(
                'No experience entries yet.',
                style: GoogleFonts.montserrat(color: Colors.grey.shade600),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.experienceList.length,
              itemBuilder: (context, index) {
                final exp = provider.experienceList[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      '${exp['role']} at ${exp['company']}',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '(${exp['expStart']} – ${exp['expEnd']})',
                          style: GoogleFonts.montserrat(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exp['expDescription'] ?? '',
                          style: GoogleFonts.montserrat(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => provider.saveExperienceSection(context),
              icon: const Icon(Icons.save, size: 18,color: Colors.white,),
              label: const Text('Save & Go To Certification Section',style: TextStyle(color:Colors.white),),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    provider.getButtonColorForSection('experience')),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                ),
                elevation: WidgetStateProperty.all(4),
                overlayColor: WidgetStateProperty.all(
                  Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCertificationsTab(ProfileProvider provider,BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAnimatedField(
            label: 'Certification Name',
            child: _buildTextField(
              initialValue: provider.tempCertName,
              hint: 'Enter certification title',
              icon: Icons.verified_outlined,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Required';
                return null;
              },
              onChanged: (val) => provider.updateTempCertName(val),
              onSaved: (val) => provider.updateTempCertName(val!),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedField(
                  label: 'Issuing Institution',
                  child: _buildTextField(
                    initialValue: provider.tempCertInstitution,
                    hint: 'Enter institution name',
                    icon: Icons.business_outlined,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Required';
                      return null;
                    },
                    onChanged: (val) => provider.updateTempCertInstitution(val),
                    onSaved: (val) => provider.updateTempCertInstitution(val!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAnimatedField(
                  label: 'Year Obtained',
                  child: _buildTextField(
                    initialValue: provider.tempCertYear,
                    hint: 'YYYY',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    validator: null,
                    onChanged: (val) => provider.updateTempCertYear(val),
                    onSaved: (val) => provider.updateTempCertYear(val!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => provider.addCertificationEntry(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Certification'),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  addcolor.withOpacity(0.05),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                elevation: WidgetStateProperty.all(4),
                overlayColor: WidgetStateProperty.all(
                  Colors.white.withOpacity(0.1),
                ),
              ),
            ),

          ),
          const SizedBox(height: 24),
          if (provider.certificationsList.isEmpty)
            Center(
              child: Text(
                'No certifications yet.',
                style: GoogleFonts.montserrat(color: Colors.grey.shade600),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.certificationsList.length,
              itemBuilder: (context, index) {
                final cert = provider.certificationsList[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      cert['certName'] ?? '',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${cert['certInstitution']} (${cert['certYear']})',
                      style: GoogleFonts.montserrat(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => provider.saveCertificationsSection(context),
              icon: const Icon(Icons.save, size: 18,color: Colors.white,),
              label: const Text('Save & Go To Attachments',style: TextStyle(color:Colors.white),),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
    provider.getButtonColorForSection('certifications')),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                ),
                elevation: WidgetStateProperty.all(4),
                overlayColor: WidgetStateProperty.all(
                  Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
