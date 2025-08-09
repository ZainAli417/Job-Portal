import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class job_seeker_provider extends ChangeNotifier {

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Stream<List<Map<String, dynamic>>> publicJobsStream() {
  return _firestore
      .collection('Posted_jobs_public')
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final rawData = doc.data() as Map? ?? {};
      final data = rawData.map((key, value) => MapEntry(key.toString(), value));
      data['id'] = doc.id;
      return data;
    }).toList();
  });
}


/// Streams *all* public jobs, regardless of status
Stream<List<Map<String, dynamic>>> allJobsStream() {
  return _firestore
      .collection('Posted_jobs_public')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return data;
    }).toList();
  });
}

}