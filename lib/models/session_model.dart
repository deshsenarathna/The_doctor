class Session {
  final String id;
  final String doctorEmail;
  final String name;
  final DateTime date;
  final DateTime startTime;
  final int maxAppointments;
  bool isActive;

  Session({
    required this.id,
    required this.doctorEmail,
    required this.name,
    required this.date,
    required this.startTime,
    required this.maxAppointments,
    this.isActive = true,
  });
}
