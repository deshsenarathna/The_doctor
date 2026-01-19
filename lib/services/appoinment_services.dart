import '../models/appoinment_model.dart';

class AppointmentService {
  /// Simulate fetching appointments from a server / database
  Future<List<Appointment>> fetchAppointments() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Appointment(
        appointmentNumber: 1,
        patientName: 'John Doe',
        age: 30,
        gender: 'Male',
        phone: '0712345678',
        date: DateTime.now().add(const Duration(days: 1)),
        status: AppointmentStatus.pending,
      ),
      Appointment(
        appointmentNumber: 2,
        patientName: 'Jane Perera',
        age: 25,
        gender: 'Female',
        phone: '0771234567',
        date: DateTime.now().add(const Duration(days: 3)),
        status: AppointmentStatus.pending,
      ),
    ];
  }
}
