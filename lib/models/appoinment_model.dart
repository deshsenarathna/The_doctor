enum AppointmentStatus { pending, completed }

class Appointment {
  final int appointmentNumber;
  final String patientName;
  final int age;
  final String gender;
  final String phone;
  final DateTime date;
  final String sessionId; // 🔥 LINK TO SESSION
  AppointmentStatus status;

  Appointment({
    required this.appointmentNumber,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.phone,
    required this.date,
    required this.sessionId,
    this.status = AppointmentStatus.pending,
  });
}
