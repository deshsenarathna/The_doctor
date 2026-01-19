import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/appoinment_model.dart';

class AppointmentViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;

  StreamSubscription<QuerySnapshot>? _subscription;

  AppointmentStatus _parseStatus(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.endsWith('.completed') || s == 'completed') return AppointmentStatus.completed;
    return AppointmentStatus.pending;
  }

  Future<void> fetchAppointments() async {
    final snapshot = await _db.collection('appointments').get();
    _appointments = snapshot.docs.map((doc) => Appointment(
      appointmentNumber: doc['appointmentNumber'],
      patientName: doc['patientName'],
      age: doc['age'],
      gender: doc['gender'],
      phone: doc['phone'],
      sessionId: doc['sessionId'],
      status: _parseStatus(doc['status']),
      date: (doc['date'] as Timestamp).toDate(),
    )).toList();
    notifyListeners();
  }

  int nowServingForSession(String sessionId, {DateTime? day}) {
    final refDay = day ?? DateTime.now();
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final sessionApps = _appointments
        .where((a) => a.sessionId == sessionId && sameDay(a.date, refDay))
        .toList();
    if (sessionApps.isEmpty) return 1;

    final pendingNums = sessionApps
        .where((a) => a.status != AppointmentStatus.completed)
        .map((a) => a.appointmentNumber)
        .toList();
    if (pendingNums.isNotEmpty) {
      return pendingNums.reduce((a, b) => a < b ? a : b);
    }

    final maxNum = sessionApps
        .map((a) => a.appointmentNumber)
        .reduce((a, b) => a > b ? a : b);
    return maxNum + 1;
  }

  void listenToAppointments() {
    _subscription?.cancel();
    _subscription = _db
        .collection('appointments')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _appointments = snapshot.docs.map((doc) => Appointment(
            appointmentNumber: doc['appointmentNumber'],
            patientName: doc['patientName'],
            age: doc['age'],
            gender: doc['gender'],
            phone: doc['phone'],
            sessionId: doc['sessionId'],
            status: _parseStatus(doc['status']),
            date: (doc['date'] as Timestamp).toDate(),
          ))
          .toList();
      notifyListeners();
    });
  }

  Future<Appointment> bookAppointment({
    required String patientName,
    required int age,
    required String gender,
    required String phone,
    required String sessionId,
  }) async {
    final today = DateTime.now();

    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    // Prevent duplicate booking for same session + day + phone if pending
    final existing = _appointments.where((a) =>
        a.sessionId == sessionId && a.phone == phone && sameDay(a.date, today) && a.status == AppointmentStatus.pending);
    if (existing.isNotEmpty) {
      throw Exception('You already have a pending appointment for this session today.');
    }

    // Compute next number within this session for today
    final sessionToday = _appointments
        .where((a) => a.sessionId == sessionId && sameDay(a.date, today))
        .toList();
    final nextNumber = sessionToday.isEmpty
        ? 1
        : (sessionToday.map((a) => a.appointmentNumber).reduce((a, b) => a > b ? a : b) + 1);

    final appointment = Appointment(
      appointmentNumber: nextNumber,
      patientName: patientName,
      age: age,
      gender: gender,
      phone: phone,
      sessionId: sessionId,
      date: DateTime(today.year, today.month, today.day),
      status: AppointmentStatus.pending,
    );

    await _db.collection('appointments').add({
      'appointmentNumber': appointment.appointmentNumber,
      'patientName': appointment.patientName,
      'age': appointment.age,
      'gender': appointment.gender,
      'phone': appointment.phone,
      'sessionId': appointment.sessionId,
      'status': appointment.status.toString(),
      'date': appointment.date,
    });

    _appointments.add(appointment);
    notifyListeners();
    return appointment;
  }

  Future<void> markCompleted(String sessionId, int appointmentNumber) async {
    // Prefer today's appointment, but avoid composite index by filtering in memory
    try {
      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final snap = await _db
          .collection('appointments')
          .where('sessionId', isEqualTo: sessionId)
          .where('appointmentNumber', isEqualTo: appointmentNumber)
          .get();

      if (snap.docs.isEmpty) return;

      String? targetId;
      DateTime? latestDate;
      for (final d in snap.docs) {
        final ts = d['date'] as Timestamp;
        final dt = ts.toDate();
        if (dt.isAfter(dayStart.subtract(const Duration(milliseconds: 1))) && dt.isBefore(dayEnd)) {
          targetId = d.id; // exact today match
          break;
        }
        if (latestDate == null || dt.isAfter(latestDate)) {
          latestDate = dt;
          targetId = d.id; // fallback to latest
        }
      }

      if (targetId != null) {
        await _db.collection('appointments').doc(targetId)
            .update({'status': AppointmentStatus.completed.toString()});
      }
    } catch (_) {
      // Swallow to keep UI responsive; listener will reflect actual state
    }
    // Update local list to keep UI responsive
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    final today = DateTime.now();
    final idx = _appointments.indexWhere((a) =>
        a.sessionId == sessionId &&
        a.appointmentNumber == appointmentNumber &&
        sameDay(a.date, today));
    if (idx != -1) {
      _appointments[idx].status = AppointmentStatus.completed;
    } else {
      // Fallback: update first matching regardless of day
      final anyIdx = _appointments.indexWhere((a) =>
          a.sessionId == sessionId && a.appointmentNumber == appointmentNumber);
      if (anyIdx != -1) {
        _appointments[anyIdx].status = AppointmentStatus.completed;
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
