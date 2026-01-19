import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/appoinment_viewmodel.dart';
import 'patient/book_appoinment.dart';
import '../widgets/appoinment_card.dart';

class PatientHomeScreen extends StatelessWidget {
  final String patientPhone; // REQUIRED

  const PatientHomeScreen({super.key, required this.patientPhone});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AppointmentViewModel>(context);

    // Get today's appointment for this patient
    final appointment = vm.getTodayAppointment(patientPhone);

    final int? currentOngoingNumber =
        appointment != null ? appointment.appointmentNumber : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Home'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _doctorCard(),
            const SizedBox(height: 16),

            if (currentOngoingNumber != null)
              _nowServingCard(currentOngoingNumber),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookAppointmentScreen(
                        patientPhone: patientPhone,
                      ),
                    ),
                  );
                },
                child: const Text('Book Appointment'),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'My Appointment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            appointment == null
                ? const Text('No appointment yet')
                : AppointmentCard(appointment: appointment),
          ],
        ),
      ),
    );
  }

  Widget _doctorCard() {
    return Card(
      child: const ListTile(
        leading: Icon(Icons.local_hospital, size: 40, color: Colors.blue),
        title: Text('Dr. Silva', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('General Physician • Dispensary'),
      ),
    );
  }

  Widget _nowServingCard(int number) {
    return Card(
      color: Colors.orange.shade50,
      child: ListTile(
        leading: const Icon(Icons.record_voice_over, color: Colors.orange),
        title: const Text(
          'Now Serving',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Appointment No $number',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
