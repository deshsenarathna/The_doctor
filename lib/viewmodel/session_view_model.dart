import 'package:flutter/material.dart';
import '../models/session_model.dart';

class SessionViewModel extends ChangeNotifier {
  final List<Session> _sessions = [];

  List<Session> get activeSessions =>
      _sessions.where((s) => s.isActive).toList();

  List<Session> doctorSessions(String doctorEmail) =>
      _sessions.where((s) => s.doctorEmail == doctorEmail).toList();

  void startSession(Session session) {
    _sessions.add(session);
    notifyListeners();
  }

  void endSession(String sessionId) {
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    session.isActive = false;
    notifyListeners();
  }
}
