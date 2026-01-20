import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';

class PatientAccountViewModel extends ChangeNotifier {
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

  Future<void> deleteAccount({bool deleteAppointments = true}) async {
    isLoading = true;
    notifyListeners();
    try {
      // delete appointments made by this phone before deleting user
      final user = _fa.currentUser;
      if (deleteAppointments && user != null) {
        final profile = await _db.collection('users').doc(user.uid).get();
        final p = profile.data()?['phone'] as String?;
        if (p != null && p.isNotEmpty) {
          final apps = await _db.collection('appointments').where('phone', isEqualTo: p).get();
          for (final d in apps.docs) {
            await d.reference.delete();
          }
        }
      }
      await _auth.deleteAccount();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
