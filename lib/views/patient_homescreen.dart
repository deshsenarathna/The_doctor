import 'package:flutter/material.dart';
import '../../models/appoinment_model.dart';
import '../../widgets/appoinment_card.dart';
import 'patient/book_appoinment.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMP data
    final List<Appointment> myAppointments = [
      Appointment(
        appointmentNumber: 1,
        patientName: 'John Doe',
        age: 30,
        gender: 'Male',
        phone: '0712345678',
        date: DateTime.now().subtract(const Duration(minutes: 30)),
        status: AppointmentStatus.completed,
      ),
      Appointment(
        appointmentNumber: 2,
        patientName: 'Jane Perera',
        age: 25,
        gender: 'Female',
        phone: '0771234567',
        date: DateTime.now().add(const Duration(minutes: 10)),
        status: AppointmentStatus.pending,
      ),
      Appointment(
        appointmentNumber: 3,
        patientName: 'Kamal Silva',
        age: 40,
        gender: 'Male',
        phone: '0719876543',
        date: DateTime.now().add(const Duration(minutes: 20)),
        status: AppointmentStatus.pending,
      ),
    ];

    // Current ongoing number
    final pendingAppointments =
        myAppointments.where((a) => a.status == AppointmentStatus.pending).toList();

    final int? currentOngoingNumber =
        pendingAppointments.isNotEmpty ? pendingAppointments.first.appointmentNumber : null;

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
                      builder: (_) => const BookAppointmentScreen(),
                    ),
                  );
                },
                child: const Text('Book Appointment'),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'My Appointments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: myAppointments.isEmpty
                  ? const Center(child: Text('No appointments yet'))
                  : ListView.builder(
                      itemCount: myAppointments.length,
                      itemBuilder: (context, index) {
                        return AppointmentCard(
                          appointment: myAppointments[index],
                        );
                      },
                    ),
            ),
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
