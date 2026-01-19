// models/session_model.dart
class Session {
  final String id;
  final String name;
  final DateTime date;
  final DateTime startTime;
  final DateTime? endTime;
  final int maxAppointments;

  Session({
    required this.id,
    required this.name,
    required this.date,
    required this.startTime,
    this.endTime,
    required this.maxAppointments,
  });
}
