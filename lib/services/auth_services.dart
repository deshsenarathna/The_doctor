import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Signup
  Future<UserModel?> signup({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      await _db.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'phone': '',
      });

      return UserModel(
        email: email,
        phone: '',
        role: role,
        uid: uid,
      );
    } catch (_) {
      return null;
    }
  }

  // Login
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;

      return UserModel(
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        role: data['role'] ?? '',
        uid: uid,
      );
    } catch (_) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
