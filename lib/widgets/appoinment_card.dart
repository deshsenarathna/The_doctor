import 'package:flutter/material.dart';
import '../models/appoinment_model.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onMarkCompleted;

  const AppointmentCard({super.key, required this.appointment, this.onMarkCompleted});

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
          'Appointment No ${appointment.appointmentNumber} - ${appointment.patientName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Age: ${appointment.age}, Gender: ${appointment.gender}\nPhone: ${appointment.phone}'),
        trailing: isCompleted
            ? const Text('Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
            : (onMarkCompleted != null
                ? ElevatedButton(
                    onPressed: onMarkCompleted,
                    child: const Text('Mark Completed'),
                  )
                : const Text('Pending',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
