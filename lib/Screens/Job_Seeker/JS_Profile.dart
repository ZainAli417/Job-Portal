// profile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Top_Side_Nav.dart';
import 'Profile_Provider.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {

  return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: MainLayout(
        activeIndex: 1,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              return Form(
                key: provider.formKey,
                child: DefaultTabController(
                  length: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Seeker Profile',
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TabBar(
                        isScrollable: true,
                        indicatorColor: Theme.of(context).primaryColor,
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
                        tabs: const [
                          Tab(text: 'Profile Summary'),
                          Tab(text: 'Educational Summary'),
                          Tab(text: 'Professional Experience'),
                          Tab(text: 'Certifications'),
                          Tab(text: 'Attachments'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Profile Summary
                            ListView(
                              children: [
                                _buildLabel('First Name'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.firstName,
                                  hint: 'Enter first name',
                                  onSaved: (val) => provider.firstName = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('Last Name'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.lastName,
                                  hint: 'Enter last name',
                                  onSaved: (val) => provider.lastName = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('Email'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.email,
                                  hint: 'johndoe@email.com',
                                  isEmail: true,
                                  onSaved: (val) => provider.email = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('Phone'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.phone,
                                  hint: '+1 234 567 890',
                                  keyboardType: TextInputType.phone,
                                  onSaved: (val) => provider.phone = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('Location'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.location,
                                  hint: 'City, Country',
                                  onSaved: (val) => provider.location = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('LinkedIn Profile'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.linkedIn,
                                  hint: 'https://linkedin.com/in/username',
                                  onSaved: (val) => provider.linkedIn = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('Portfolio Website'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.portfolio,
                                  hint: 'https://portfolio.com',
                                  onSaved: (val) => provider.portfolio = val!.trim(),
                                ),
                                const SizedBox(height: 32),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () => provider.saveProfile(context),
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          Theme.of(context).primaryColor),
                                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      )),
                                      elevation: WidgetStateProperty.all(0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      child: Text(
                                        'Save Changes',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Educational Summary
                            ListView(
                              children: [
                                _buildLabel('School/University'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.school,
                                  hint: 'Enter institution name',
                                  onSaved: (val) => provider.school = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('Degree'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.degree,
                                  hint: 'e.g. Bachelor of Science',
                                  onSaved: (val) => provider.degree = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('Field of Study'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.fieldOfStudy,
                                  hint: 'e.g. Computer Science',
                                  onSaved: (val) => provider.fieldOfStudy = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Start Year'),
                                          const SizedBox(height: 8),
                                          _buildTextField(
                                            initialValue: provider.eduStart,
                                            hint: 'YYYY',
                                            keyboardType: TextInputType.number,
                                            onSaved: (val) => provider.eduStart = val!.trim(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('End Year'),
                                          const SizedBox(height: 8),
                                          _buildTextField(
                                            initialValue: provider.eduEnd,
                                            hint: 'YYYY',
                                            keyboardType: TextInputType.number,
                                            onSaved: (val) => provider.eduEnd = val!.trim(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Professional Experience
                            ListView(
                              children: [
                                _buildLabel('Company'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.company,
                                  hint: 'Enter company name',
                                  onSaved: (val) => provider.company = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('Role/Position'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.role,
                                  hint: 'e.g. Software Engineer',
                                  onSaved: (val) => provider.role = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('Start Date'),
                                          const SizedBox(height: 8),
                                          _buildTextField(
                                            initialValue: provider.expStart,
                                            hint: 'MM/YYYY',
                                            keyboardType: TextInputType.datetime,
                                            onSaved: (val) => provider.expStart = val!.trim(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel('End Date'),
                                          const SizedBox(height: 8),
                                          _buildTextField(
                                            initialValue: provider.expEnd,
                                            hint: 'MM/YYYY or Present',
                                            onSaved: (val) => provider.expEnd = val!.trim(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('Description'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: provider.expDescription,
                                  maxLines: 4,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'Required';
                                    return null;
                                  },
                                  onSaved: (val) => provider.expDescription = val!.trim(),
                                  decoration: InputDecoration(
                                    hintText: 'Describe your role and responsibilities',
                                    hintStyle: GoogleFonts.montserrat(
                                      color: const Color(0xFF5C738A),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFEBEDF2),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
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
                                      borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor,
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
                                ),
                              ],
                            ),
                            // Certifications
                            ListView(
                              children: [
                                _buildLabel('Certification Name'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.certName,
                                  hint: 'Enter certification title',
                                  onSaved: (val) => provider.certName = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('Issuing Institution'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.certInstitution,
                                  hint: 'Enter institution name',
                                  onSaved: (val) => provider.certInstitution = val!.trim(),
                                ),
                                const SizedBox(height: 16),
                                _buildLabel('Year Obtained'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  initialValue: provider.certYear,
                                  hint: 'YYYY',
                                  keyboardType: TextInputType.number,
                                  onSaved: (val) => provider.certYear = val!.trim(),
                                ),
                              ],
                            ),
                            // Attachments
                            ListView(
                              children: [
                                Text(
                                  'Upload Resume or Supporting Documents',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                        Theme.of(context).primaryColor),
                                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    )),
                                    elevation: WidgetStateProperty.all(0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    child: Text(
                                      'Choose File',
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
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
    bool isEmail = false,
    TextInputType? keyboardType,
    required void Function(String?) onSaved,
    
  }) {
    
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Required';
        if (isEmail && !val.contains('@')) return 'Enter valid email';
        return null;
      },
      
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
          vertical: 12,
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
          borderSide: BorderSide(
            color:Color(0xFF006CFF),
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
    );
  }
}
