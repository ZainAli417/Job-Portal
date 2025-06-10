import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class JobPostingProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String tempTitle = '';
  String tempDepartment = '';
  String tempDescription = '';
  String tempPay = '';
  String tempExperience = '';
  String tempNature = 'Full Time';
  String? tempCompany = '';
  String? tempLocation = '';
  String? tempResponsibilities = '';
  String? tempQualifications = '';
  String? tempDeadline = '';
  String? tempContactEmail = '';
  String? tempInstructions = '';
  List<String> tempSkills = [];
  List<String> tempBenefits = [];
  List<String> tempWorkModes = [];
  Uint8List? tempLogoBytes;
  String? tempLogoFilename;
  bool isPosting = false;
  final List<Map<String, dynamic>> _jobList = [];
  List<Map<String, dynamic>> get jobList => List.unmodifiable(_jobList);
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _jobsSubscription;

  JobPostingProvider() {
    _initRealtimeListener();
  }

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initRealtimeListener() async {
    final user = _auth.currentUser;
    if (user == null) return;
    _jobsSubscription = _firestore
        .collection('Recruiter')
        .doc(user.uid)
        .collection('Posted_jobs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _jobList
        ..clear()
        ..addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Map<String, dynamic>.from(data);
        }));
      notifyListeners();
    }, onError: (_) {
      notifyListeners();
    });
  }

  void updateTempTitle(String v) { tempTitle = v.trim(); notifyListeners(); }
  void updateTempDepartment(String v) { tempDepartment = v.trim(); notifyListeners(); }
  void updateTempDescription(String v) { tempDescription = v.trim(); notifyListeners(); }
  void updateTempPay(String v) { tempPay = v.trim(); notifyListeners(); }
  void updateTempExperience(String v) { tempExperience = v.trim(); notifyListeners(); }
  void updateTempNature(String v) { tempNature = v; notifyListeners(); }
  void updateTempCompany(String v) { tempCompany = v.trim(); notifyListeners(); }
  void updateTempLocation(String v) { tempLocation = v.trim(); notifyListeners(); }
  void updateTempResponsibilities(String v) { tempResponsibilities = v.trim(); notifyListeners(); }
  void updateTempQualifications(String v) { tempQualifications = v.trim(); notifyListeners(); }
  void updateTempDeadline(String v) { tempDeadline = v.trim(); notifyListeners(); }
  void updateTempContactEmail(String v) { tempContactEmail = v.trim(); notifyListeners(); }
  void updateTempInstructions(String v) { tempInstructions = v.trim(); notifyListeners(); }

  void toggleSkill(String skill) {
    if (tempSkills.contains(skill)) tempSkills.remove(skill);
    else tempSkills.add(skill);
    notifyListeners();
  }

  void toggleBenefit(String benefit) {
    if (tempBenefits.contains(benefit)) tempBenefits.remove(benefit);
    else tempBenefits.add(benefit);
    notifyListeners();
  }

  void toggleWorkMode(String workMode) {
    if (tempWorkModes.contains(workMode)) tempWorkModes.remove(workMode);
    else tempWorkModes.add(workMode);
    notifyListeners();
  }

  void updateTempLogo(Uint8List bytes, String filename) {
    tempLogoBytes = bytes;
    tempLogoFilename = filename;
    notifyListeners();
  }

  void _clearTempFields() {
    tempTitle = '';
    tempDepartment = '';
    tempDescription = '';
    tempPay = '';
    tempExperience = '';
    tempNature = 'Full Time';
    tempCompany = '';
    tempLocation = '';
    tempResponsibilities = '';
    tempQualifications = '';
    tempDeadline = '';
    tempContactEmail = '';
    tempInstructions = '';
    tempSkills.clear();
    tempBenefits.clear();
    tempWorkModes.clear();
    tempLogoBytes = null;
    tempLogoFilename = null;
    notifyListeners();
  }

  Future<bool> _validateRecruiterRole() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _firestore.collection('Recruiter').doc(user.uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    return data != null && data['role'] == 'Recruiter';
  }

  String? _validateRequiredFields() {
    if (tempTitle.isEmpty) return 'Job title is required';
    if (tempDepartment.isEmpty) return 'Department is required';
    if (tempDescription.isEmpty) return 'Job description is required';
    if (tempPay.isEmpty) return 'Salary range is required';
    if (tempExperience.isEmpty) return 'Experience requirement is required';
    if ((tempCompany ?? '').isEmpty) return 'Company name is required';
    if ((tempLocation ?? '').isEmpty) return 'Location is required';
    if ((tempResponsibilities ?? '').isEmpty) return 'Key responsibilities are required';
    if ((tempQualifications ?? '').isEmpty) return 'Minimum qualifications are required';
    if ((tempDeadline ?? '').isEmpty) return 'Application deadline is required';
    if ((tempContactEmail ?? '').isEmpty) return 'Contact email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (tempContactEmail != null && !emailRegex.hasMatch(tempContactEmail!)) {
      return 'Please enter a valid email address';
    }
    if (tempWorkModes.isEmpty) return 'Please select at least one work mode';
    return null;
  }

  Future<String?> addJob() async {
    if (isPosting) return 'Already posting...';
    final validationError = _validateRequiredFields();
    if (validationError != null) return validationError;
    isPosting = true;
    notifyListeners();
    final user = _auth.currentUser;
    if (user == null) {
      isPosting = false;
      notifyListeners();
      return 'Not authenticated.';
    }
    if (!await _validateRecruiterRole()) {
      isPosting = false;
      notifyListeners();
      return 'You do not have permission to post a job.';
    }
    final postedJobsRef = _firestore
        .collection('Recruiter')
        .doc(user.uid)
        .collection('Posted_jobs')
        .doc();
    String? logoUrl;
    if (tempLogoBytes != null && tempLogoFilename != null) {
      final storagePath = 'recruiter_logos/${user.uid}/${postedJobsRef.id}_${tempLogoFilename!}';
      final storageRef = _storage.ref().child(storagePath);
      try {
        final uploadTask = await storageRef.putData(tempLogoBytes!, SettableMetadata(contentType: 'image/png'));
        logoUrl = await uploadTask.ref.getDownloadURL();
      } catch (e) {
        isPosting = false;
        notifyListeners();
        return 'Logo upload failed: $e';
      }
    }
    final jobData = <String, dynamic>{
      'title': tempTitle,
      'department': tempDepartment,
      'description': tempDescription,
      'pay': tempPay,
      'experience': tempExperience,
      'nature': tempNature,
      'logoUrl': logoUrl ?? '',
      'recruiterUid': user.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'company': tempCompany ?? '',
      'location': tempLocation ?? '',
      'responsibilities': tempResponsibilities ?? '',
      'qualifications': tempQualifications ?? '',
      'deadline': tempDeadline ?? '',
      'contactEmail': tempContactEmail ?? '',
      'instructions': tempInstructions ?? '',
      'skills': tempSkills,
      'benefits': tempBenefits,
      'workModes': tempWorkModes,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'status': 'active',
      'applicationCount': 0,
      'viewCount': 0,
    };
    try {
      await postedJobsRef.set(jobData);
      _clearTempFields();
      isPosting = false;
      notifyListeners();
      return null;
    } catch (e) {
      isPosting = false;
      notifyListeners();
      return 'Failed to post job: $e';
    }
  }

  Future<String?> updateJob(String jobId, Map<String, dynamic> updates) async {
    final user = _auth.currentUser;
    if (user == null) return 'Not authenticated.';
    try {
      final jobRef = _firestore.collection('Recruiter').doc(user.uid).collection('Posted_jobs').doc(jobId);
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await jobRef.update(updates);
      return null;
    } catch (e) {
      return 'Failed to update job: $e';
    }
  }

  Future<String?> deleteJob(String jobId) async {
    final user = _auth.currentUser;
    if (user == null) return 'Not authenticated.';
    try {
      await _firestore.collection('Recruiter').doc(user.uid).collection('Posted_jobs').doc(jobId).delete();
      return null;
    } catch (e) {
      return 'Failed to delete job: $e';
    }
  }

  Future<String?> toggleJobStatus(String jobId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'paused' : 'active';
    return await updateJob(jobId, {'status': newStatus});
  }

  Map<String, int> getJobStatistics() {
    int activeJobs = 0;
    int pausedJobs = 0;
    int totalApplications = 0;
    int totalViews = 0;
    for (final job in _jobList) {
      final status = job['status'] as String? ?? 'active';
      if (status == 'active') activeJobs++;
      else if (status == 'paused') pausedJobs++;
      totalApplications += (job['applicationCount'] as int? ?? 0);
      totalViews += (job['viewCount'] as int? ?? 0);
    }
    return {
      'activeJobs': activeJobs,
      'pausedJobs': pausedJobs,
      'totalJobs': _jobList.length,
      'totalApplications': totalApplications,
      'totalViews': totalViews,
    };
  }

  void loadJobForEditing(Map<String, dynamic> job) {
    tempTitle = job['title'] ?? '';
    tempDepartment = job['department'] ?? '';
    tempDescription = job['description'] ?? '';
    tempPay = job['pay'] ?? '';
    tempExperience = job['experience'] ?? '';
    tempNature = job['nature'] ?? 'Full Time';
    tempCompany = job['company'] ?? '';
    tempLocation = job['location'] ?? '';
    tempResponsibilities = job['responsibilities'] ?? '';
    tempQualifications = job['qualifications'] ?? '';
    tempDeadline = job['deadline'] ?? '';
    tempContactEmail = job['contactEmail'] ?? '';
    tempInstructions = job['instructions'] ?? '';
    tempSkills = List<String>.from(job['skills'] ?? []);
    tempBenefits = List<String>.from(job['benefits'] ?? []);
    tempWorkModes = List<String>.from(job['workModes'] ?? []);
    tempLogoBytes = null;
    tempLogoFilename = null;
    notifyListeners();
  }
}
