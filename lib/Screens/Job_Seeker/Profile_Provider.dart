// Profile_Provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Section data fields ---
  // Personal
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String location = '';
  String linkedIn = '';
  String current_job = '';
  String summary = '';

  // Education
  List<Map<String, String>> educationList = [];
  String tempSchool = '';
  String tempDegree = '';
  String tempFieldOfStudy = '';
  String tempEduStart = '';
  String tempEduEnd = '';

  // Experience
  List<Map<String, String>> experienceList = [];
  String tempCompany = '';
  String tempRole = '';
  String tempExpStart = '';
  String tempExpEnd = '';
  String tempExpDescription = '';

  // Skills & Interests
  List<String> skillsList = [];
  String tempSkill = '';
  /// Controller to keep focus when typing skills
  final TextEditingController skillController = TextEditingController();

  // Certifications
  List<Map<String, String>> certificationsList = [];
  String tempCertName = '';
  String tempCertInstitution = '';
  String tempCertYear = '';

  // --- Internal state flags ---
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  bool _isDirtyPersonal = false;
  bool _isDirtyEducation = false;
  bool _isDirtyExperience = false;
  bool _isDirtySkills = false;
  bool _isDirtyCertifications = false;

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ProfileProvider() {
    _loadAllSectionsOnce();
  }

  @override
  void dispose() {
    skillController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSectionsOnce() async {
    if (_hasLoadedOnce) return;
    _hasLoadedOnce = true;
    _isLoading = true;
    notifyListeners();

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final docRef = _firestore
          .collection('Job_Seeker')
          .doc(uid)
          .collection('user_profile')
          .doc('sections');
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data()!;

        // Personal
        firstName = data['personal']?['firstName'] ?? '';
        lastName = data['personal']?['lastName'] ?? '';
        email = data['personal']?['email'] ?? '';
        phone = data['personal']?['phone'] ?? '';
        location = data['personal']?['location'] ?? '';
        linkedIn = data['personal']?['linkedIn'] ?? '';
        current_job = data['personal']?['current_job'] ?? '';
        summary = data['personal']?['summary'] ?? '';

        // Education
        if (data['education'] is List) {
          final List raw = data['education'];
          educationList = raw
              .whereType<Map<String, dynamic>>()
              .map((e) => e.map((k, v) => MapEntry(k, v.toString())))
              .toList();
        }

        // Experience
        if (data['experience'] is List) {
          final List raw = data['experience'];
          experienceList = raw
              .whereType<Map<String, dynamic>>()
              .map((e) => e.map((k, v) => MapEntry(k, v.toString())))
              .toList();
        }

        // Skills
        if (data['skills'] is List) {
          final List raw = data['skills'];
          skillsList = raw.whereType<String>().toList();
        }

        // Certifications
        if (data['certifications'] is List) {
          final List raw = data['certifications'];
          certificationsList = raw
              .whereType<Map<String, dynamic>>()
              .map((e) => e.map((k, v) => MapEntry(k, v.toString())))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error loading profile sections: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  void markPersonalDirty() {
    _isDirtyPersonal = true;
    notifyListeners();
  }

  void markEducationDirty() {
    _isDirtyEducation = true;
    notifyListeners();
  }

  void markExperienceDirty() {
    _isDirtyExperience = true;
    notifyListeners();
  }

  void markSkillsDirty() {
    _isDirtySkills = true;
    notifyListeners();
  }

  void markCertificationsDirty() {
    _isDirtyCertifications = true;
    notifyListeners();
  }

  Color getButtonColorForSection(String section) {
    switch (section) {
      case 'personal':
        if (_isDirtyPersonal) return Colors.red;
        return const Color(0xFF006CFF);
      case 'education':
        if (_isDirtyEducation) return Colors.red;
        return const Color(0xFF006CFF);
      case 'experience':
        if (_isDirtyExperience) return Colors.red;
        return const Color(0xFF006CFF);
      case 'skills':
        if (_isDirtySkills) return Colors.red;
        return const Color(0xFF006CFF);
      case 'certifications':
        if (_isDirtyCertifications) return Colors.red;
        return const Color(0xFF006CFF);
      default:
        return const Color(0xFF006CFF);
    }
  }

  Future<void> _flashButtonGreen(String section) async {
    switch (section) {
      case 'personal':
        _isDirtyPersonal = false;
        notifyListeners();
        break;
      case 'education':
        _isDirtyEducation = false;
        notifyListeners();
        break;
      case 'experience':
        _isDirtyExperience = false;
        notifyListeners();
        break;
      case 'skills':
        _isDirtySkills = false;
        notifyListeners();
        break;
      case 'certifications':
        _isDirtyCertifications = false;
        notifyListeners();
        break;
    }
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }

  // ---------------- Personal ----------------
  Future<void> savePersonalSection(BuildContext context) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final docRef = _firestore
        .collection('Job_Seeker')
        .doc(uid)
        .collection('user_profile')
        .doc('sections');

    final personalData = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'location': location,
      'current_job': current_job,
      'summary': summary,
    };

    try {
      await docRef.set({'personal': personalData}, SetOptions(merge: true));
      await _flashButtonGreen('personal');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal section saved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error saving personal section: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving personal section'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------- Education ----------------
  Future<void> addEducationEntry(BuildContext context) async {
    if (tempSchool.trim().isEmpty ||
        tempDegree.trim().isEmpty ||
        tempEduStart.trim().isEmpty ||
        tempEduEnd.trim().isEmpty) {
      return;
    }
    final newEntry = {
      'school': tempSchool.trim(),
      'degree': tempDegree.trim(),
      'fieldOfStudy': tempFieldOfStudy.trim(),
      'eduStart': tempEduStart.trim(),
      'eduEnd': tempEduEnd.trim(),
    };
    educationList.add(newEntry);

    // Clear temporary fields
    tempSchool = '';
    tempDegree = '';
    tempFieldOfStudy = '';
    tempEduStart = '';
    tempEduEnd = '';
    await _saveEducationList(context);
    markEducationDirty();
  }

  Future<void> _saveEducationList(BuildContext context) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final docRef = _firestore
        .collection('Job_Seeker')
        .doc(uid)
        .collection('user_profile')
        .doc('sections');
    try {
      await docRef.set({'education': educationList}, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving education list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving education section'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveEducationSection(BuildContext context) async {
    await _saveEducationList(context);
    await _flashButtonGreen('education');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Education section finalized'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ---------------- Experience ----------------
  Future<void> addExperienceEntry(BuildContext context) async {
    if (tempCompany.trim().isEmpty ||
        tempRole.trim().isEmpty ||
        tempExpStart.trim().isEmpty ||
        tempExpDescription.trim().isEmpty) {
      return;
    }
    final newEntry = {
      'company': tempCompany.trim(),
      'role': tempRole.trim(),
      'expStart': tempExpStart.trim(),
      'expEnd': tempExpEnd.trim(),
      'expDescription': tempExpDescription.trim(),
    };
    experienceList.add(newEntry);

    // Clear temporary fields
    tempCompany = '';
    tempRole = '';
    tempExpStart = '';
    tempExpEnd = '';
    tempExpDescription = '';
    await _saveExperienceList(context);
    markExperienceDirty();
  }

  Future<void> _saveExperienceList(BuildContext context) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final docRef = _firestore
        .collection('Job_Seeker')
        .doc(uid)
        .collection('user_profile')
        .doc('sections');
    try {
      await docRef.set({'experience': experienceList}, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving experience list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving experience section'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveExperienceSection(BuildContext context) async {
    await _saveExperienceList(context);
    await _flashButtonGreen('experience');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Experience section finalized'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ---------------- Skills ----------------
  Future<void> addSkillEntry(BuildContext context) async {
    final trimmedSkill = tempSkill.trim();
    if (trimmedSkill.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skill cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!skillsList.contains(trimmedSkill)) {
      skillsList.add(trimmedSkill);
      markSkillsDirty();
      notifyListeners();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Skill already added'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    // Clear both tempSkill and the controller without losing focus
    tempSkill = '';
    skillController.clear();
    notifyListeners();

    await _saveSkillsList(context);
  }

  Future<void> _saveSkillsList(BuildContext context) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore
        .collection('Job_Seeker')
        .doc(uid)
        .collection('user_profile')
        .doc('sections');

    try {
      await docRef.set({'skills': skillsList}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving skills list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving skills section'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveSkillsSection(BuildContext context) async {
    if (skillsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one skill is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _saveSkillsList(context);
    await _flashButtonGreen('skills');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Skills section finalized'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ---------------- Certifications ----------------
  Future<void> addCertificationEntry(BuildContext context) async {
    if (tempCertName.trim().isEmpty || tempCertInstitution.trim().isEmpty) {
      return;
    }
    final newEntry = {
      'certName': tempCertName.trim(),
      'certInstitution': tempCertInstitution.trim(),
      'certYear': tempCertYear.trim(),
    };
    certificationsList.add(newEntry);

    // Clear temporary fields
    tempCertName = '';
    tempCertInstitution = '';
    tempCertYear = '';
    await _saveCertificationsList(context);
    markCertificationsDirty();
  }

  Future<void> _saveCertificationsList(BuildContext context) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final docRef = _firestore
        .collection('Job_Seeker')
        .doc(uid)
        .collection('user_profile')
        .doc('sections');
    try {
      await docRef
          .set({'certifications': certificationsList}, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving certifications list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving certifications section'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveCertificationsSection(BuildContext context) async {
    await _saveCertificationsList(context);
    await _flashButtonGreen('certifications');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Certifications section finalized'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ---------------- FIELD SETTERS ----------------

  // Personal
  void updateFirstName(String val) {
    if (val.trim() != firstName) {
      firstName = val.trim();
      markPersonalDirty();
    }
  }

  void updateLastName(String val) {
    if (val.trim() != lastName) {
      lastName = val.trim();
      markPersonalDirty();
    }
  }

  void updateEmail(String val) {
    if (val.trim() != email) {
      email = val.trim();
      markPersonalDirty();
    }
  }

  void updatePhone(String val) {
    if (val.trim() != phone) {
      phone = val.trim();
      markPersonalDirty();
    }
  }

  void updateLocation(String val) {
    if (val.trim() != location) {
      location = val.trim();
      markPersonalDirty();
    }
  }

  void updateLinkedIn(String val) {
    if (val.trim() != linkedIn) {
      linkedIn = val.trim();
      markPersonalDirty();
    }
  }

  void updatecurrent_job(String val) {
    if (val.trim() != current_job) {
      current_job = val.trim();
      markPersonalDirty();
    }
  }

  void updateSummary(String val) {
    if (val.trim() != summary) {
      summary = val.trim();
      markPersonalDirty();
    }
  }

  // Skills
  void updateTempSkill(String val) {
    tempSkill = val;
    notifyListeners();
  }

  // Education
  void updateTempSchool(String val) {
    tempSchool = val;
    notifyListeners();
  }

  void updateTempDegree(String val) {
    tempDegree = val;
    notifyListeners();
  }

  void updateTempFieldOfStudy(String val) {
    tempFieldOfStudy = val;
    notifyListeners();
  }

  void updateTempEduStart(String val) {
    tempEduStart = val;
    notifyListeners();
  }

  void updateTempEduEnd(String val) {
    tempEduEnd = val;
    notifyListeners();
  }

  // Experience
  void updateTempCompany(String val) {
    tempCompany = val;
    notifyListeners();
  }

  void updateTempRole(String val) {
    tempRole = val;
    notifyListeners();
  }

  void updateTempExpStart(String val) {
    tempExpStart = val;
    notifyListeners();
  }

  void updateTempExpEnd(String val) {
    tempExpEnd = val;
    notifyListeners();
  }

  void updateTempExpDescription(String val) {
    tempExpDescription = val;
    notifyListeners();
  }

  // Certifications
  void updateTempCertName(String val) {
    tempCertName = val;
    notifyListeners();
  }

  void updateTempCertInstitution(String val) {
    tempCertInstitution = val;
    notifyListeners();
  }

  void updateTempCertYear(String val) {
    tempCertYear = val;
    notifyListeners();
  }
}
