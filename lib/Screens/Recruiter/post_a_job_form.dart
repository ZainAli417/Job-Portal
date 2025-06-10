import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'job_posting_provider.dart';

class PostJobDialog extends StatefulWidget {
  const PostJobDialog({Key? key}) : super(key: key);

  @override
  _PostJobDialogState createState() => _PostJobDialogState();
}

class _PostJobDialogState extends State<PostJobDialog> {
  final _formKey = GlobalKey<FormState>();
  static const Color primary = Color(0xFF006CFF);
  static const Color white = Color(0xFFFAFAFA);
  static const Color paleWhite = Color(0xFFF5F5F5);
  static Color primaryLight = primary.withOpacity(0.2);
  static Color primaryDark = primary.withOpacity(0.8);

  final List<String> skillOptions = [
    'Flutter','Dart','React','JavaScript','Python','Java',
    'Node.js','MongoDB','Firebase','AWS','Docker','Git',
    'UI/UX Design','Project Management','Agile','Scrum'
  ];

  final List<String> benefitOptions = [
    'Health Insurance','Dental Insurance','Vision Insurance',
    'Retirement Plan','Flexible Hours','Work from Home',
    'Paid Time Off','Professional Development','Gym Membership',
    'Free Meals','Stock Options','Bonus Eligibility',
    'Transportation Allowance','Childcare Support'
  ];

  final List<String> workModeOptions = [
    'Remote','Hybrid','On-site','Flexible'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JobPostingProvider>(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 800),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.work_rounded, color: primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Job Posting',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Fill in the details to post your job opening',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        title: 'Company & Basic Information',
                        icon: Icons.business_rounded,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLogoUploader(provider),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildTextField(
                                      label: 'Job Title',
                                      initialValue: provider.tempTitle,
                                      onChanged: provider.updateTempTitle,
                                      validator: (v) =>
                                      v!.trim().isEmpty ? 'Required' : null,
                                      icon: Icons.work_outline,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                            label: 'Company Name',
                                            initialValue: provider.tempCompany ?? '',
                                            onChanged: provider.updateTempCompany,
                                            validator: (v) =>
                                            v!.trim().isEmpty ? 'Required' : null,
                                            icon: Icons.apartment_rounded,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildTextField(
                                            label: 'Department',
                                            initialValue: provider.tempDepartment,
                                            onChanged: provider.updateTempDepartment,
                                            validator: (v) =>
                                            v!.trim().isEmpty ? 'Required' : null,
                                            icon: Icons.group_work_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'Job Description & Requirements',
                        icon: Icons.description_outlined,
                        children: [
                          _buildTextField(
                            label: 'Job Description',
                            initialValue: provider.tempDescription,
                            onChanged: provider.updateTempDescription,
                            validator: (v) =>
                            v!.trim().isEmpty ? 'Required' : null,
                            maxLines: 4,
                            icon: Icons.edit_note_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Key Responsibilities',
                            initialValue: provider.tempResponsibilities ?? '',
                            onChanged: provider.updateTempResponsibilities,
                            validator: (v) =>
                            v!.trim().isEmpty ? 'Required' : null,
                            maxLines: 3,
                            icon: Icons.checklist_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Minimum Qualifications',
                            initialValue: provider.tempQualifications ?? '',
                            onChanged: provider.updateTempQualifications,
                            validator: (v) =>
                            v!.trim().isEmpty ? 'Required' : null,
                            maxLines: 3,
                            icon: Icons.school_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'Compensation & Work Details',
                        icon: Icons.payments_outlined,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Salary Range',
                                  initialValue: provider.tempPay,
                                  onChanged: provider.updateTempPay,
                                  validator: (v) =>
                                  v!.trim().isEmpty ? 'Required' : null,
                                  icon: Icons.attach_money_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdownField(
                                  label: 'Job Type',
                                  value: provider.tempNature,
                                  items: const [
                                    'Full Time',
                                    'Part Time',
                                    'Contract',
                                    'montserratnship'
                                  ],
                                  onChanged: (val) =>
                                      provider.updateTempNature(val!),
                                  icon: Icons.schedule_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Experience Required',
                                  initialValue: provider.tempExperience,
                                  onChanged: provider.updateTempExperience,
                                  validator: (v) =>
                                  v!.trim().isEmpty ? 'Required' : null,
                                  icon: Icons.trending_up_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  label: 'Location',
                                  initialValue: provider.tempLocation ?? '',
                                  onChanged: provider.updateTempLocation,
                                  validator: (v) =>
                                  v!.trim().isEmpty ? 'Required' : null,
                                  icon: Icons.location_on_outlined,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'Work Mode & Required Skills',
                        icon: Icons.computer_rounded,
                        children: [
                          _buildPillSelector(
                            title: 'Work Mode',
                            selectedItems: provider.tempWorkModes,
                            availableItems: workModeOptions,
                            color: primary,
                            onToggle: provider.toggleWorkMode,
                          ),
                          const SizedBox(height: 16),
                          _buildPillSelector(
                            title: 'Required Skills',
                            selectedItems: provider.tempSkills,
                            availableItems: skillOptions,
                            color: const Color(0xFF00C851),
                            onToggle: provider.toggleSkill,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'Benefits & Perks',
                        icon: Icons.card_giftcard_rounded,
                        children: [
                          _buildPillSelector(
                            title: 'Employee Benefits',
                            selectedItems: provider.tempBenefits,
                            availableItems: benefitOptions,
                            color: const Color(0xFFFF6B35),
                            onToggle: provider.toggleBenefit,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'Application Details',
                        icon: Icons.send_rounded,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Application Deadline',
                                  initialValue: provider.tempDeadline ?? '',
                                  onChanged: provider.updateTempDeadline,
                                  validator: (v) =>
                                  v!.trim().isEmpty ? 'Required' : null,
                                  icon: Icons.calendar_today_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  label: 'Contact Email',
                                  initialValue: provider.tempContactEmail ?? '',
                                  onChanged: provider.updateTempContactEmail,
                                  validator: (v) {
                                    if (v!.trim().isEmpty) return 'Required';
                                    if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(v)) {
                                      return 'Invalid email';
                                    }
                                    return null;
                                  },
                                  icon: Icons.email_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Additional Instructions for Applicants',
                            initialValue: provider.tempInstructions ?? '',
                            onChanged: provider.updateTempInstructions,
                            maxLines: 2,
                            icon: Icons.info_outline_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [primary, primaryDark],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: provider.isPosting
                              ? null
                              : () async {
                            if (_formKey.currentState!.validate()) {
                              final error = await provider.addJob();
                              if (!context.mounted) return;
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Job posted successfully! 🎉'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: provider.isPosting
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.rocket_launch_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Post Job Now',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primary, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLogoUploader(JobPostingProvider provider) {
    return Column(
      children: [
        Text(
          'Company Logo',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              withData: true,
            );
            if (result != null && result.files.isNotEmpty) {
              final file = result.files.first;
              if (file.bytes != null) {
                provider.updateTempLogo(file.bytes!, file.name);
              }
            }
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: paleWhite,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: primaryLight, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: provider.tempLogoBytes != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: Image.memory(
                provider.tempLogoBytes!,
                fit: BoxFit.cover,
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_rounded,
                    size: 28, color: primary),
                const SizedBox(height: 4),
                Text(
                  'Upload',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: primary,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
    IconData? icon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      style: GoogleFonts.montserrat(
        fontSize: 15,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: primary, size: 30) : null,
        filled: true,
        fillColor: paleWhite,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        labelStyle: GoogleFonts.montserrat(
          color: Colors.grey.shade500,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: primary, size: 20) : null,
        filled: true,
        fillColor: paleWhite,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade600, fontSize: 13),
      ),
    );
  }

  Widget _buildPillSelector({
    required String title,
    required List<String> selectedItems,
    required List<String> availableItems,
    required Color color,
    required void Function(String) onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableItems.map((item) {
            final isSelected = selectedItems.contains(item);
            return GestureDetector(
              onTap: () => onToggle(item),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) Icon(Icons.check_rounded, size: 16, color: color),
                    if (isSelected) const SizedBox(width: 4),
                    Text(
                      item,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
