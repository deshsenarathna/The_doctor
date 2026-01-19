import 'package:flutter/material.dart';
import '../models/appoinment_model.dart';

class AppointmentViewModel extends ChangeNotifier {
  final List<Appointment> _appointments = [];

  List<Appointment> get appointments => _appointments;

  int get currentOngoingNumber {
    final completedCount =
        _appointments.where((a) => a.status == AppointmentStatus.completed).length;
    return completedCount + 1;
  }

  Appointment? getTodayAppointment(String phone) {
    final today = DateTime.now();
    try {
      return _appointments.firstWhere(
        (a) =>
            a.phone == phone &&
            a.date.year == today.year &&
            a.date.month == today.month &&
            a.date.day == today.day,
      );
    } catch (_) {
      return null;
    }
  }

  Appointment bookAppointment({
    required String patientName,
    required int age,
    required String gender,
    required String phone,
  }) {
    final today = DateTime.now();

    final existing = getTodayAppointment(phone);
    if (existing != null) return existing;

    final todayAppointments = _appointments.where(
      (a) =>
          a.date.year == today.year &&
          a.date.month == today.month &&
          a.date.day == today.day,
    );

    final nextNumber = todayAppointments.length + 1;

    final appointment = Appointment(
      appointmentNumber: nextNumber,
      patientName: patientName,
      age: age,
      gender: gender,
      phone: phone,
      date: today,
    );

    _appointments.add(appointment);
    notifyListeners();
    return appointment;
  }

  void markCompleted(int appointmentNumber) {
    final appointment = _appointments.firstWhere(
      (a) => a.appointmentNumber == appointmentNumber,
    );
    appointment.status = AppointmentStatus.completed;
    notifyListeners();
  }
}
