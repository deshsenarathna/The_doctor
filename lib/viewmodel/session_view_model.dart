import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';

class SessionViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  // Fetch sessions from Firestore
  Future<void> fetchSessions() async {
    final snapshot = await _db.collection('sessions').get();
    _sessions = snapshot.docs.map((doc) => Session(
      id: doc['id'],
      doctorEmail: doc['doctorEmail'],
      name: doc['name'],
      date: (doc['date'] as Timestamp).toDate(),
      startTime: (doc['startTime'] as Timestamp).toDate(),
      maxAppointments: doc['maxAppointments'],
      isActive: doc['isActive'],
    )).toList();
    notifyListeners();
  }

  List<Session> activeSessions() => _sessions.where((s) => s.isActive).toList();

  List<Session> doctorSessions(String doctorEmail) =>
      _sessions.where((s) => s.doctorEmail == doctorEmail).toList();

  // Start session and save to Firestore
  Future<void> startSession(Session session) async {
    await _db.collection('sessions').doc(session.id).set({
      'id': session.id,
      'doctorEmail': session.doctorEmail,
      'name': session.name,
      'date': session.date,
      'startTime': session.startTime,
      'maxAppointments': session.maxAppointments,
      'isActive': session.isActive,
    });
    _sessions.add(session);
    notifyListeners();
  }

  // End session
  Future<void> endSession(String sessionId) async {
    await _db.collection('sessions').doc(sessionId).update({'isActive': false});
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    session.isActive = false;
    notifyListeners();
  }

  // Update an existing session
  Future<void> updateSession(Session updated) async {
    await _db.collection('sessions').doc(updated.id).update({
      'doctorEmail': updated.doctorEmail,
      'name': updated.name,
      'date': updated.date,
      'startTime': updated.startTime,
      'maxAppointments': updated.maxAppointments,
      'isActive': updated.isActive,
    });

    final index = _sessions.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _sessions[index] = updated;
      notifyListeners();
    }
  }

  // Delete a session
  Future<void> deleteSession(String sessionId) async {
    await _db.collection('sessions').doc(sessionId).delete();
    _sessions.removeWhere((s) => s.id == sessionId);
    notifyListeners();
  }
}
