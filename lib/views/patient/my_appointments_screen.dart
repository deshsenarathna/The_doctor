import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/appoinment_viewmodel.dart';
import '../../viewmodel/session_view_model.dart';
import '../../models/appoinment_model.dart';

class MyAppointmentsScreen extends StatelessWidget {
  final String patientPhone;
  const MyAppointmentsScreen({super.key, required this.patientPhone});

  @override
  Widget build(BuildContext context) {
    final appointmentVM = Provider.of<AppointmentViewModel>(context);
    final sessionVM = Provider.of<SessionViewModel>(context);

    final myAppointments = appointmentVM.appointments
        .where((a) => a.phone == patientPhone)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    String sessionNameFor(String sessionId) {
      final s = sessionVM.sessions.where((x) => x.id == sessionId);
      return s.isNotEmpty ? s.first.name : 'Session';
    }

    String statusText(AppointmentStatus s) =>
        s == AppointmentStatus.completed ? 'Completed' : 'Pending';

    Color statusColor(AppointmentStatus s) =>
        s == AppointmentStatus.completed ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: myAppointments.isEmpty
          ? const Center(child: Text('No appointments yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: myAppointments.length,
              itemBuilder: (context, i) {
                final app = myAppointments[i];
                final dateStr = app.date.toLocal().toString().split(' ').first;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor(app.status),
                      child: Text(
                        app.appointmentNumber.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('${sessionNameFor(app.sessionId)} • $dateStr',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Name: ${app.patientName}\nAge: ${app.age}, Gender: ${app.gender}\nPhone: ${app.phone}',
                    ),
                    trailing: Text(
                      statusText(app.status),
                      style: TextStyle(color: statusColor(app.status), fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
