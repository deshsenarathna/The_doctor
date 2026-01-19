import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appoinment_model.dart';
import '../viewmodel/appoinment_viewmodel.dart';
import '../viewmodel/session_view_model.dart';
import '../viewmodel/login_viewmodel.dart';
import 'patient/book_appoinment.dart';
// import '../widgets/appoinment_card.dart';

class PatientHomeScreen extends StatelessWidget {
  final String patientPhone; // REQUIRED

  const PatientHomeScreen({super.key, required this.patientPhone});

  @override
  Widget build(BuildContext context) {
    final sessionVM = Provider.of<SessionViewModel>(context);
    final appointmentVM = Provider.of<AppointmentViewModel>(context);

    // Get active sessions
    final activeSessions = sessionVM.activeSessions();
    final currentSession = activeSessions.isNotEmpty ? activeSessions.first : null;

    // Get patient's appointment(s)
    Appointment? myTodayAppointment;
    Appointment? myNextAppointment; // today or upcoming across sessions
    int? currentServingNumber; // derived from session progress
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (currentSession != null) {
      // Patient's own appointment today in this active session
      final myMatches = appointmentVM.appointments.where((a) =>
          a.phone == patientPhone &&
          a.sessionId == currentSession.id &&
          sameDay(a.date, today));
      myTodayAppointment = myMatches.isNotEmpty ? myMatches.first : null;

          // Compute current "Now Serving" via ViewModel helper (today only)
          currentServingNumber = appointmentVM.nowServingForSession(currentSession.id, day: today);
    }

    // Determine next appointment for the patient (today or upcoming, pending first)
    final myAll = appointmentVM.appointments
        .where((a) => a.phone == patientPhone)
        .toList();
    myAll.sort((a, b) {
      final ad = DateTime(a.date.year, a.date.month, a.date.day);
      final bd = DateTime(b.date.year, b.date.month, b.date.day);
      return ad.compareTo(bd);
    });
    Appointment? upcoming;
    for (final a in myAll) {
      final ad = DateTime(a.date.year, a.date.month, a.date.day);
      if (!ad.isBefore(today)) {
        upcoming = a;
        break;
      }
    }
    myNextAppointment = upcoming ?? (myAll.isNotEmpty ? myAll.first : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Home'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final loginVM = Provider.of<LoginViewModel>(context, listen: false);
              await loginVM.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _doctorCard(),
            const SizedBox(height: 16),

            if (currentServingNumber != null)
              _nowServingCard(currentServingNumber, myTodayAppointment),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (currentSession == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No active session to book')),
                    );
                    return;
                  }

                  // Block booking if patient already has a pending appointment today in this session
                  if (myTodayAppointment != null && myTodayAppointment.status == AppointmentStatus.pending) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You already have an appointment for today.')),
                    );
                    return;
                  }

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
            const Text('My Appointment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            myNextAppointment == null
              ? const Text('No appointment yet')
              : _attractiveMyAppointmentCard(myNextAppointment as Appointment, sessionVM),
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

  Widget _nowServingCard(int number, Appointment? myTodayAppointment) {
    return Card(
      color: Colors.orange.shade50,
      child: ListTile(
        leading: const Icon(Icons.record_voice_over, color: Colors.orange),
        title: const Text(
          'Now Serving',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          myTodayAppointment == null
              ? 'Appointment No $number'
              : 'Appointment No $number\nYour Number: ${myTodayAppointment.appointmentNumber}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // Old simple card removed; using attractive gradient card below

  Widget _attractiveMyAppointmentCard(Appointment app, dynamic sessionVM) {
    final matching = sessionVM.sessions.where((s) => s.id == app.sessionId);
    final sessionName = matching.isNotEmpty ? matching.first.name : 'Session';
    final dateStr = app.date.toLocal().toString().split(' ').first;
    final isCompleted = app.status == AppointmentStatus.completed;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCompleted
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Text(
              app.appointmentNumber.toString(),
              style: TextStyle(
                color: isCompleted ? Colors.green.shade700 : Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sessionName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isCompleted ? 'Completed' : 'Pending',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Date: $dateStr',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 2),
                Text(
                  'Patient: ${app.patientName} • ${app.age} • ${app.gender}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
