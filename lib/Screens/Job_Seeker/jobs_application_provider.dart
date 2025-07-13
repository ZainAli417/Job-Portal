// lib/providers/job_applications_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class JobApplicationsProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isApplying = false;
  String? _errorMessage;
  final Set<String> _appliedJobs = {};

  bool get isApplying => _isApplying;
  String? get errorMessage => _errorMessage;

  /// Load all jobs that the current user has already applied to.
  Future<void> loadAppliedJobs() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userApps = await _firestore
        .collection('applications')
        .doc(user.uid)
        .collection('applied_jobs')
        .get();

    _appliedJobs
      ..clear()
      ..addAll(userApps.docs.map((doc) => doc.data()['jobId'] as String));

    notifyListeners();
  }

  /// Check if current user already applied to [jobId]
  bool hasApplied(String jobId) => _appliedJobs.contains(jobId);

  /// Apply to [jobId]
  Future<void> applyForJob(String jobId) async {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'You must be logged in to apply.';
      notifyListeners();
      return;
    }

    if (hasApplied(jobId)) {
      // Already applied
      return;
    }

    _isApplying = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final seekerRef = _firestore.collection('Job_Seeker').doc(user.uid);
      final seekerSnap = await seekerRef.get();
      if (!seekerSnap.exists) throw Exception('Seeker profile not found.');
      final mainData = seekerSnap.data()!;

      final sectionsDoc = await seekerRef
          .collection('user_profile')
          .doc('sections')
          .get();
      final Map<String, dynamic> subProfiles =
      sectionsDoc.exists ? sectionsDoc.data()! : {};

      final applicationData = {
        'userId': user.uid,
        'jobId': jobId,
        'appliedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'profileSnapshot': {
          'user_Account_Data': mainData,
          'user_Profile_Sections': subProfiles,
        },
      };

      // ✅ Write under applications/{user.uid}/applied_jobs/
      await _firestore
          .collection('applications')
          .doc(user.uid)
          .collection('applied_jobs')
          .add(applicationData);

      // ✅ Locally record
      _appliedJobs.add(jobId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isApplying = false;
      notifyListeners();
    }
  }
}
