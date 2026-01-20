import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';

class DoctorAccountViewModel extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _fa = FirebaseAuth.instance;

  bool isLoading = false;
  String? email;
  String? phone;
  String? role;

  Future<void> load() async {
    final user = _fa.currentUser;
    if (user == null) return;
    email = user.email;
    isLoading = true;
    notifyListeners();
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        phone = data?['phone'] as String?;
        role = data?['role'] as String?;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePhone(String newPhone) async {
    isLoading = true;
    notifyListeners();
    try {
      await _auth.updatePhone(newPhone);
      phone = newPhone;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePassword(String newPassword) async {
    isLoading = true;
    notifyListeners();
    try {
      await _auth.updatePassword(newPassword);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Delete doctor's account and cascade: remove sessions and their appointments
  Future<void> deleteAccountCascade() async {
    isLoading = true;
    notifyListeners();
    try {
      final user = _fa.currentUser;
      if (user != null) {
        final emailAddr = user.email ?? '';
        // Find sessions by this doctor
        final sessionsSnap = await _db.collection('sessions').where('doctorEmail', isEqualTo: emailAddr).get();
        final sessionIds = <String>[];
        for (final d in sessionsSnap.docs) {
          sessionIds.add(d.id);
        }
        // Delete appointments for each session
        for (final sid in sessionIds) {
          final appsSnap = await _db.collection('appointments').where('sessionId', isEqualTo: sid).get();
          for (final a in appsSnap.docs) {
            await a.reference.delete();
          }
          // delete session itself
          await _db.collection('sessions').doc(sid).delete();
        }
      }
      await _auth.deleteAccount();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
