import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class ListAppliedJobsProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _error;
  List<_AppRecord> _applications = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<_AppRecord> get applications => List.unmodifiable(_applications);

  Future<void> loadHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      _error = 'Not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final appsSnap = await _firestore
          .collection('applications')
          .doc(user.uid)
          .collection('applied_jobs')
          .orderBy('appliedAt', descending: true)
          .get();

      final jobIds = appsSnap.docs
          .map((d) => d.data()['jobId'] as String)
          .toSet()
          .toList();

      if (jobIds.isEmpty) {
        _applications = [];
        return;
      }

      // Increment view/application counts in bulk
      final batch = _firestore.batch();
      for (final jobId in jobIds) {
        final jobRef = _firestore.collection('Posted_jobs_public').doc(jobId);
        batch.update(jobRef, {
          'applicationCount': FieldValue.increment(1),
          'viewCount': FieldValue.increment(1),
        });
      }
      await batch.commit();

      final records = <_AppRecord>[];

      for (var chunk in _chunk(jobIds, 10)) {
        final jobsSnap = await _firestore
            .collection('Posted_jobs_public')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        final jobMap = { for (var d in jobsSnap.docs) d.id: d.data() };

        for (var doc in appsSnap.docs) {
          final data = doc.data();
          final jid = data['jobId'] as String;
          if (!chunk.contains(jid) || !jobMap.containsKey(jid)) continue;

          final jobData = jobMap[jid]!;

          DateTime parseDate(String s) {
            try {
              return DateTime.parse(s);
            } catch (_) {}
            try {
              return DateFormat('MM/dd/yy').parse(s);
            } catch (_) {}
            return DateFormat('MM/dd/yyyy').parse(s);
          }

          DateTime parseAppliedAt(dynamic v) {
            if (v is Timestamp) return v.toDate();
            if (v is String) return DateTime.parse(v);
            throw Exception('Invalid appliedAt type');
          }

          records.add(_AppRecord(
            jobId: jid,
            title: jobData['title'] ?? '—',
            company: jobData['company'] ?? '—',
            contactEmail: jobData['contactEmail'] ?? '—',
            createdAt: parseDate(jobData['createdAt'] ?? ''),
            deadline: parseDate(jobData['deadline'] ?? ''),
            appliedAt: parseAppliedAt(data['appliedAt']),
            status: data['status'] ?? 'pending',
          ));
        }
      }

      _applications = records;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<List<T>> _chunk<T>(List<T> list, int size) {
    final out = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      out.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return out;
  }
}

class _AppRecord {
  final String jobId;
  final String title;
  final String company;
  final String contactEmail;
  final DateTime createdAt;
  final DateTime deadline;
  final DateTime appliedAt;
  final String status;

  _AppRecord({
    required this.jobId,
    required this.title,
    required this.company,
    required this.contactEmail,
    required this.createdAt,
    required this.deadline,
    required this.appliedAt,
    required this.status,
  });
}
