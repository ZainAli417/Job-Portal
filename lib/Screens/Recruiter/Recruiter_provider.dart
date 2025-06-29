import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Main provider class for managing job postings, filtering, and search functionality
class JobPostingProvider extends ChangeNotifier {
  // =============================================================================
  // STATIC INSTANCES & CONSTANTS
  // =============================================================================

  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  // =============================================================================
  // CORE STATE VARIABLES
  // =============================================================================

  final _formData = _JobFormData();
  final _jobList = <Map<String, dynamic>>[];
  final _filteredJobList = <Map<String, dynamic>>[];
  StreamSubscription? _jobsSubscription;

  bool _isPosting = false;
  bool _isInitialized = false;
  String? _cachedUserId;
  bool? _isRecruiterCached;

  // =============================================================================
  // SEARCH & FILTER STATE
  // =============================================================================

  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  String _sortBy = 'newest';
  List<String> _searchKeywords = [];

  // Range filters
  RangeValues _salaryRange = const RangeValues(0, 500000);
  RangeValues _experienceRange = const RangeValues(0, 20);

  // Dropdown filters
  String? selectedJobType;
  String? selectedWorkMode;
  String? selectedEducation;
  String? selectedLocation;

  // Multi-select filters
  List<String> selectedSkills = [];
  List<String> selectedIndustries = [];
  List<String> selectedBenefits = [];

  // Date filter
  DateTime? postedAfter;

  // Boolean filters
  bool isRemoteOnly = false;
  bool isUrgentOnly = false;
  bool hasHealthInsurance = false;
  bool hasRetirement = false;
  bool hasFlexibleHours = false;
  bool hasRetirementPlan = false;

  // =============================================================================
  // FILTER OPTIONS (CONSTANTS)
  // =============================================================================

  final List<String> locationOptions = [
    'Karachi', 'Lahore', 'Islamabad', 'Peshawar', 'Quetta'
  ];

  final List<String> skillOptions = [
    'Aircraft Maintenance', 'Avionics Systems', 'Flight Operations', 'Radar Systems',
    'Navigation Systems', 'Aircraft Engines', 'Hydraulic Systems', 'Electrical Systems',
    'Flight Planning', 'Air Traffic Control', 'Weather Analysis', 'Mission Planning',
    'Safety Protocols', 'Emergency Procedures', 'Quality Assurance', 'Technical Documentation',
    'Pilot Training', 'Crew Resource Management', 'Aircraft Inspection', 'Ground Support'
  ];

  final List<String> industryOptions = [
    'Aviation', 'Defense', 'Engineering', 'Logistics'
  ];

  final List<String> benefitOptions = [
    'Health Insurance', 'Retirement Plan', 'Flexible Hours'
  ];

  final List<String> jobTypeOptions = [
    'Full Time', 'Part Time', 'Contract', 'Internship'
  ];

  final List<String> workModeOptions = [
    'On-site', 'Remote', 'Hybrid'
  ];

  final List<String> educationOptions = [
    'Matric', 'Intermediate', 'Bachelors', 'Masters', 'PhD'
  ];

  // =============================================================================
  // CONSTRUCTOR & INITIALIZATION
  // =============================================================================

  JobPostingProvider() {
    _initializeProvider();
  }

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeProvider() async {
    final user = _auth.currentUser;
    _cachedUserId = user?.uid;
    if (user != null) await _initRealtimeListener();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _initRealtimeListener() async {
    if (_cachedUserId == null) return;
    await _jobsSubscription?.cancel();
    _jobsSubscription = _firestore
        .collection('Recruiter')
        .doc(_cachedUserId)
        .collection('Posted_jobs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(_updateJobList);
  }

  void _updateJobList(QuerySnapshot snapshot) {
    _jobList
      ..clear()
      ..addAll(snapshot.docs.map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }));
    _applySearchAndFilters();
  }

  // =============================================================================
  // PUBLIC GETTERS - CORE STATE
  // =============================================================================

  List<Map<String, dynamic>> get jobList => _jobList;
  List<Map<String, dynamic>> get filteredJobList => _filteredJobList;
  bool get isPosting => _isPosting;
  bool get isInitialized => _isInitialized;
  String get searchQuery => _searchQuery;
  Map<String, dynamic> get activeFilters => Map.from(_activeFilters);
  String get sortBy => _sortBy;
  List<String> get searchKeywords => List.from(_searchKeywords);

  // =============================================================================
  // PUBLIC GETTERS - FORM DATA
  // =============================================================================

  String? get tempSalaryType => _formData.salaryType;
  String? get tempSalary => _formData.salary;
  String? get tempPayDetails => _formData.payDetails;
  String get tempTitle => _formData.title;
  String get tempDepartment => _formData.department;
  String get tempDescription => _formData.description;
  String get tempPay => _formData.pay;
  String get tempExperience => _formData.experience;
  String get tempNature => _formData.nature;
  String get tempCompany => _formData.company;
  String get tempLocation => _formData.location;
  String get tempResponsibilities => _formData.responsibilities;
  String get tempQualifications => _formData.qualifications;
  String get tempDeadline => _formData.deadline;
  String get tempContactEmail => _formData.contactEmail;
  String get tempInstructions => _formData.instructions;
  List<String> get tempSkills => _formData.skills;
  List<String> get tempBenefits => _formData.benefits;
  List<String> get tempWorkModes => _formData.workModes;
  Uint8List? get tempLogoBytes => _formData.logoBytes;
  String? get tempLogoFilename => _formData.logoFilename;

  // =============================================================================
  // PUBLIC GETTERS - FILTERS
  // =============================================================================

  RangeValues get salaryRange => _salaryRange;
  RangeValues get experienceRange => _experienceRange;
  String? get jobType => selectedJobType;
  String? get workMode => selectedWorkMode;
  String? get education => selectedEducation;
  String? get location => selectedLocation;
  List<String> get skills => selectedSkills;
  List<String> get industries => selectedIndustries;
  List<String> get benefits => selectedBenefits;
  DateTime? get getPostedAfter => postedAfter;
  bool get remoteOnly => isRemoteOnly;
  bool get urgentOnly => isUrgentOnly;
  bool get healthInsurance => hasHealthInsurance;
  bool get retirementPlan => hasRetirementPlan;
  bool get flexibleHours => hasFlexibleHours;

  // =============================================================================
  // PUBLIC METHODS - FORM DATA UPDATES
  // =============================================================================

  void updateTempTitle(String v) => _updateField(() => _formData.title = v.trim());
  void updateTempDepartment(String v) => _updateField(() => _formData.department = v.trim());
  void updateTempDescription(String v) => _updateField(() => _formData.description = v.trim());
  void updateTempPay(String v) => _updateField(() => _formData.pay = v.trim());
  void updateTempExperience(String v) => _updateField(() => _formData.experience = v.trim());
  void updateTempNature(String v) => _updateField(() => _formData.nature = v);
  void updateTempCompany(String v) => _updateField(() => _formData.company = v.trim());
  void updateTempLocation(String v) => _updateField(() => _formData.location = v.trim());
  void updateTempResponsibilities(String v) => _updateField(() => _formData.responsibilities = v.trim());
  void updateTempQualifications(String v) => _updateField(() => _formData.qualifications = v.trim());
  void updateTempDeadline(String v) => _updateField(() => _formData.deadline = v.trim());
  void updateTempContactEmail(String v) => _updateField(() => _formData.contactEmail = v.trim());
  void updateTempInstructions(String v) => _updateField(() => _formData.instructions = v.trim());
  void updateTempSalaryType(String v) => _updateField(() => _formData.salaryType = v);
  void updateTempSalary(String v) => _updateField(() => _formData.salary = v.trim());
  void updateTempPayDetails(String v) => _updateField(() => _formData.payDetails = v.trim());

  void updateTempLogo(Uint8List bytes, String name) => _updateField(() {
    _formData.logoBytes = bytes;
    _formData.logoFilename = name;
  });

  void toggleWorkMode(String w) => _toggleListItem(_formData.workModes, w);

  void clearTempFields() {
    _formData.clear();
    notifyListeners();
  }

  void loadJobForEditing(Map<String, dynamic> job) {
    _formData.loadFromJob(job);
    notifyListeners();
  }

  // =============================================================================
  // PUBLIC METHODS - FILTER SETTERS
  // =============================================================================

  void setSalaryRange(RangeValues values) {
    _salaryRange = values;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setExperienceRange(RangeValues values) {
    _experienceRange = values;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setJobType(String? value) {
    selectedJobType = value;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setWorkMode(String? value) {
    selectedWorkMode = value;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setEducation(String? value) {
    selectedEducation = value;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setLocation(String? value) {
    selectedLocation = value;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setRemoteOnly(bool value) {
    isRemoteOnly = value;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setUrgentOnly(bool value) {
    isUrgentOnly = value;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setHealthInsurance(bool value) {
    hasHealthInsurance = value;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setRetirementPlan(bool value) {
    hasRetirementPlan = value;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setFlexibleHours(bool value) {
    hasFlexibleHours = value;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setHasHealthInsurance(bool v) {
    hasHealthInsurance = v;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setHasRetirement(bool v) {
    hasRetirement = v;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setHasFlexibleHours(bool v) {
    hasFlexibleHours = v;
    _applySearchAndFilters();
    notifyListeners();
  }

  void setPostedAfter(DateTime? date) {
    postedAfter = date;
    _applySearchAndFilters();
    notifyListeners();
  }

  // =============================================================================
  // PUBLIC METHODS - MULTI-SELECT TOGGLES
  // =============================================================================

  void toggleSkill(String skill) {
    if (selectedSkills.contains(skill)) {
      selectedSkills.remove(skill);
    } else {
      selectedSkills.add(skill);
    }
    _applySearchAndFilters();
    notifyListeners();
  }

  void toggleIndustry(String industry) {
    if (selectedIndustries.contains(industry)) {
      selectedIndustries.remove(industry);
    } else {
      selectedIndustries.add(industry);
    }
    _applySearchAndFilters();
    notifyListeners();
  }

  void toggleBenefit(String benefit) {
    if (selectedBenefits.contains(benefit)) {
      selectedBenefits.remove(benefit);
    } else {
      selectedBenefits.add(benefit);
    }
    _applySearchAndFilters();
    notifyListeners();
  }

  // =============================================================================
  // PUBLIC METHODS - SEARCH & FILTERING
  // =============================================================================

  void searchJobs(String query) {
    _searchQuery = query.trim().toLowerCase();
    _searchKeywords = _searchQuery.split(' ').where((w) => w.isNotEmpty).toList();
    _applySearchAndFilters();
  }

  void applyFilters(Map<String, dynamic> filters) {
    _activeFilters = Map.from(filters);
    _applySearchAndFilters();
  }

  void clearAllFilters() {
    _searchQuery = '';
    _searchKeywords.clear();
    _activeFilters.clear();
    _sortBy = 'newest';
    _applySearchAndFilters();
  }

  void setSortBy(String value) {
    _sortBy = value;
    _applySearchAndFilters();
  }

  // =============================================================================
  // PUBLIC METHODS - JOB OPERATIONS
  // =============================================================================

  Future<String?> addJob() async {
    if (_isPosting) return 'Already posting...';

    final validationError = _validateRequiredFields();
    if (validationError != null) return validationError;

    _setPostingState(true);
    try {
      if (_cachedUserId == null) return 'Not authenticated.';
      if (!await _validateRecruiterRole()) {
        return 'You do not have permission to post a job.';
      }

      final jobId = _firestore.collection('Recruiter').doc().id;

      // Parallel logo upload if needed
      final logoUploadFuture = _formData.logoBytes != null && _formData.logoFilename != null
          ? _uploadLogo(_cachedUserId!, jobId)
          : Future<String?>.value(null);

      final logoUrl = await logoUploadFuture;
      if (_formData.logoBytes != null && logoUrl == null) {
        return 'Logo upload failed';
      }

      final jobData = _buildJobData(jobId, _cachedUserId!, logoUrl);

      final batch = _firestore.batch();
      batch.set(
          _firestore
              .collection('Recruiter')
              .doc(_cachedUserId)
              .collection('Posted_jobs')
              .doc(jobId),
          jobData);
      batch.set(_firestore.collection('Posted_jobs_public').doc(jobId), jobData);

      await batch.commit();
      clearTempFields();
      return null;
    } catch (e) {
      debugPrint('Error adding job: $e');
      return 'Failed to post job: $e';
    } finally {
      _setPostingState(false);
    }
  }

  Future<String?> updateJob(String jobId, Map<String, dynamic> updates) async {
    if (_cachedUserId == null) return 'Not authenticated.';
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      final batch = _firestore.batch();
      batch.update(
          _firestore
              .collection('Recruiter')
              .doc(_cachedUserId)
              .collection('Posted_jobs')
              .doc(jobId),
          updates);
      batch.update(_firestore.collection('Posted_jobs_public').doc(jobId), updates);
      await batch.commit();
      return null;
    } catch (e) {
      debugPrint('Error updating job: $e');
      return 'Failed to update job: $e';
    }
  }

  Future<String?> deleteJob(String jobId) async {
    if (_cachedUserId == null) return 'Not authenticated.';
    try {
      final batch = _firestore.batch();
      batch.delete(_firestore
          .collection('Recruiter')
          .doc(_cachedUserId)
          .collection('Posted_jobs')
          .doc(jobId));
      batch.delete(_firestore.collection('Posted_jobs_public').doc(jobId));
      await batch.commit();
      return null;
    } catch (e) {
      debugPrint('Error deleting job: $e');
      return 'Failed to delete job: $e';
    }
  }

  Future<String?> toggleJobStatus(String jobId, String currentStatus) async {
    if (_cachedUserId == null) return 'Not authenticated';
    try {
      final updates = {
        'status': currentStatus == 'active' ? 'paused' : 'active',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final batch = _firestore.batch();
      batch.update(
        _firestore.collection('Recruiter').doc(_cachedUserId).collection('Posted_jobs').doc(jobId),
        updates,
      );
      batch.set(
        _firestore.collection('Posted_jobs_public').doc(jobId),
        updates,
        SetOptions(merge: true),
      );
      await batch.commit();
      return null;
    } catch (e) {
      debugPrint('Toggle error: $e');
      return 'Failed to toggle status';
    }
  }

  Map<String, int> getJobStatistics() {
    var activeJobs = 0, pausedJobs = 0, totalApplications = 0, totalViews = 0;
    for (final job in _jobList) {
      if (job['status'] == 'paused') {
        pausedJobs++;
      } else {
        activeJobs++;
      }
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

  // =============================================================================
  // PRIVATE HELPER METHODS
  // =============================================================================

  void _updateField(VoidCallback action) {
    action();
    notifyListeners();
  }

  void _toggleListItem(List<String> list, String item) {
    if (list.contains(item)) {
      list.remove(item);
    } else {
      list.add(item);
    }
    notifyListeners();
  }

  void _setPostingState(bool value) {
    _isPosting = value;
    notifyListeners();
  }

  void _applySearchAndFilters() {
    var results = List<Map<String, dynamic>>.from(_jobList);
    if (_searchQuery.isNotEmpty) {
      results = results.where(_matchesSearch).toList();
    }
    results = _applyAdvancedFilters(results);
    results = _applySorting(results);
    _filteredJobList
      ..clear()
      ..addAll(results);
    notifyListeners();
  }

  bool _matchesSearch(Map<String, dynamic> job) {
    if (_searchKeywords.isEmpty) return true;
    final fields = [
      job['title'] ?? '',
      job['company'] ?? '',
      job['department'] ?? '',
      job['description'] ?? '',
      job['location'] ?? '',
      job['responsibilities'] ?? '',
      job['qualifications'] ?? '',
      ...(job['skills'] ?? []),
    ].map((e) => e.toString().toLowerCase()).join(' ');
    return _searchKeywords.every(fields.contains);
  }

  List<Map<String, dynamic>> _applyAdvancedFilters(List<Map<String, dynamic>> jobs) {
    return jobs.where((job) {
      if (isRemoteOnly && !(job['workModes']?.contains('Remote') ?? false)) return false;
      if (isUrgentOnly && !(job['tags']?.contains('Urgent') ?? false)) return false;
      if (hasHealthInsurance && !(job['benefits']?.contains('Health Insurance') ?? false)) return false;
      if (hasRetirement && !(job['benefits']?.contains('Retirement Plan') ?? false)) return false;
      if (hasFlexibleHours && !(job['benefits']?.contains('Flexible Hours') ?? false)) return false;
      if (postedAfter != null && _parseJobDate(job)?.isBefore(postedAfter!) == true) return false;

      if (selectedSkills.isNotEmpty &&
          !(job['skills'] as List?)!.any((s) => selectedSkills.contains(s)) == true) {
        return false;
      }

      if (selectedIndustries.isNotEmpty &&
          !(job['industry'] != null && selectedIndustries.contains(job['industry']))) {
        return false;
      }

      if (selectedBenefits.isNotEmpty &&
          !(job['benefits'] as List?)!.any((b) => selectedBenefits.contains(b)) == true) {
        return false;
      }

      return true;
    }).toList();
  }

  DateTime? _parseJobDate(Map<String, dynamic> job) {
    // First try parsing ISO string if available
    if (job['createdAt'] != null) {
      try {
        return DateTime.parse(job['createdAt'].toString());
      } catch (_) {
        // Fallback silently
      }
    }

    // Otherwise, check for Firestore Timestamp
    if (job['timestamp'] != null && job['timestamp'] is Timestamp) {
      return (job['timestamp'] as Timestamp).toDate();
    }

    return null; // Nothing valid found
  }

  List<Map<String, dynamic>> _applySorting(List<Map<String, dynamic>> jobs) {
    return jobs; // Replace with actual sorting logic if needed
  }

  Future<bool> _validateRecruiterRole() async {
    if (_isRecruiterCached != null) return _isRecruiterCached!;
    if (_cachedUserId == null) return false;
    final doc = await _firestore.collection('Recruiter').doc(_cachedUserId).get();
    _isRecruiterCached = doc.exists && doc.data()?['role'] == 'Recruiter';
    return _isRecruiterCached!;
  }

  String? _validateRequiredFields() {
    final checks = [
      (_formData.title.isEmpty, 'Job title is required'),
      (_formData.department.isEmpty, 'Department is required'),
      (_formData.description.isEmpty, 'Job description is required'),
      (_formData.salaryType?.isEmpty ?? true, 'Compensation type is required'),
      (_formData.salary?.isEmpty ?? true, 'Salary range is required'),
      (_formData.company.isEmpty, 'Company name is required'),
      (_formData.location.isEmpty, 'Location is required'),
      (_formData.responsibilities.isEmpty, 'Responsibilities required'),
      (_formData.qualifications.isEmpty, 'Qualifications required'),
      (_formData.deadline.isEmpty, 'Deadline is required'),
      (_formData.contactEmail.isEmpty, 'Email required'),
      (_formData.workModes.isEmpty, 'At least one work mode is required'),
    ];
    for (final (cond, msg) in checks) {
      if (cond) return msg;
    }
    if (!_emailRegex.hasMatch(_formData.contactEmail)) {
      return 'Invalid email format';
    }
    return null;
  }

  Map<String, dynamic> _buildJobData(String jobId, String userId, String? logoUrl) {
    final now = DateTime.now();
    return {
      'id': jobId,
      'title': _formData.title,
      'department': _formData.department,
      'description': _formData.description,
      'salaryType': _formData.salaryType,
      'salary': _formData.salary,
      'additionalPayDetails': _formData.payDetails,
      'experience': _formData.experience,
      'nature': _formData.nature,
      'logoUrl': logoUrl ?? '',
      'recruiterUid': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'company': _formData.company,
      'location': _formData.location,
      'responsibilities': _formData.responsibilities,
      'qualifications': _formData.qualifications,
      'deadline': _formData.deadline,
      'contactEmail': _formData.contactEmail,
      'instructions': _formData.instructions,
      'skills': List.from(_formData.skills),
      'benefits': List.from(_formData.benefits),
      'workModes': List.from(_formData.workModes),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'status': 'active',
      'applicationCount': 0,
      'viewCount': 0,
    };
  }

  Future<String?> _uploadLogo(String userId, String jobId) async {
    try {
      final ref = _storage.ref('recruiter_logos/$userId/${jobId}_${_formData.logoFilename}');
      final task = await ref.putData(
          _formData.logoBytes!, SettableMetadata(contentType: 'image/png'));
      return await task.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Logo upload error: $e');
      return null;
    }
  }
}

// =============================================================================
// FORM DATA CLASS
// =============================================================================

/// Compact form data container for job posting information
class _JobFormData {
  // Basic job information
  String title = '';
  String department = '';
  String description = '';
  String pay = '';
  String experience = '';
  String nature = 'Full Time';
  String company = '';
  String location = '';
  String responsibilities = '';
  String qualifications = '';
  String deadline = '';
  String contactEmail = '';
  String instructions = '';

  // Collections
  final skills = <String>[];
  final benefits = <String>[];
  final workModes = <String>[];

  // Salary fields
  String? salaryType;
  String? salary;
  String? payDetails;

  // Logo data
  Uint8List? logoBytes;
  String? logoFilename;

  /// Clear all form data
  void clear() {
    title = department = description = '';
    pay = experience = '';
    nature = 'Full Time';
    company = location = responsibilities = qualifications = '';
    deadline = contactEmail = instructions = '';
    skills.clear();
    benefits.clear();
    workModes.clear();
    salaryType = null;
    salary = null;
    payDetails = null;
    logoBytes = null;
    logoFilename = null;
  }

  /// Load form data from existing job
  void loadFromJob(Map<String, dynamic> job) {
    title = job['title'] ?? '';
    department = job['department'] ?? '';
    description = job['description'] ?? '';
    pay = job['pay'] ?? '';
    experience = job['experience'] ?? '';
    nature = job['nature'] ?? 'Full Time';
    company = job['company'] ?? '';
    location = job['location'] ?? '';
    responsibilities = job['responsibilities'] ?? '';
    qualifications = job['qualifications'] ?? '';
    deadline = job['deadline'] ?? '';
    contactEmail = job['contactEmail'] ?? '';
    instructions = job['instructions'] ?? '';

    skills
      ..clear()
      ..addAll(List<String>.from(job['skills'] ?? []));
    benefits
      ..clear()
      ..addAll(List<String>.from(job['benefits'] ?? []));
    workModes
      ..clear()
      ..addAll(List<String>.from(job['workModes'] ?? []));

    salaryType = job['salaryType']?.toString();
    salary = job['salary']?.toString();
    payDetails = job['additionalPayDetails']?.toString();

    logoBytes = null;
    logoFilename = null;
  }
}