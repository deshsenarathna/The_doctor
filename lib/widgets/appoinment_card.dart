import 'package:flutter/material.dart';
import '../models/appoinment_model.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = appointment.status == AppointmentStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green : Colors.blue,
          child: Text(
            appointment.appointmentNumber.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          'Appointment No ${appointment.appointmentNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          appointment.date.toString(),
        ),
        trailing: Text(
          isCompleted ? 'Completed' : 'Pending',
          style: TextStyle(
            color: isCompleted ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
