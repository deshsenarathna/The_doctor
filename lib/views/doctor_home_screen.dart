import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/session_model.dart';
import '../models/appoinment_model.dart';
import '../viewmodel/session_view_model.dart';
import '../viewmodel/appoinment_viewmodel.dart';

class DoctorHomeScreen extends StatelessWidget {
  final String doctorEmail;
  const DoctorHomeScreen({super.key, required this.doctorEmail});

  @override
  Widget build(BuildContext context) {
    final sessionVM = Provider.of<SessionViewModel>(context);
    final appointmentVM = Provider.of<AppointmentViewModel>(context);

    // ✅ sessions from provider (NOT local list)
    final sessions = sessionVM.doctorSessions(doctorEmail);

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Home'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Doctor info card
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.local_hospital,
                  size: 40,
                  color: Colors.blue,
                ),
                title: Text(
                  doctorEmail,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('General Physician • Dispensary'),
              ),
            ),

            const SizedBox(height: 16),

            /// Start session button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showStartSessionDialog(context, sessionVM),
                child: const Text('Start New Session'),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// Sessions list
            Expanded(
              child: sessions.isEmpty
                  ? const Center(child: Text('No sessions yet'))
                  : ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];

                        final sessionAppointments = appointmentVM.appointments
                            .where((a) => a.sessionId == session.id)
                            .toList();

                        return Card(
                          child: ExpansionTile(
                            title: Text(session.name),
                            subtitle: Text(
                              'Date: ${session.date.toLocal().toString().split(' ')[0]} '
                              '| Max: ${session.maxAppointments}',
                            ),
                            children: [
                              sessionAppointments.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text('No appointments yet'),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: sessionAppointments.length,
                                      itemBuilder: (context, i) {
                                        final app = sessionAppointments[i];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                app.status ==
                                                    AppointmentStatus.completed
                                                ? Colors.green
                                                : Colors.orange,
                                            child: Text(
                                              app.appointmentNumber.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          title: Text(app.patientName),
                                          subtitle: Text(app.phone),
                                          trailing:
                                              app.status ==
                                                  AppointmentStatus.completed
                                              ? const Text(
                                                  'Completed',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                  ),
                                                )
                                              : ElevatedButton(
                                                  onPressed: () {
                                                    appointmentVM.markCompleted(
                                                      app.appointmentNumber,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Mark Done',
                                                  ),
                                                ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔵 Start Session Dialog (PROVIDER-BASED)
  void _showStartSessionDialog(
    BuildContext context,
    SessionViewModel sessionVM,
  ) {
    final nameController = TextEditingController();
    final maxController = TextEditingController(text: '10');
    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Start New Session'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Session Name'),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: maxController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max Appointments',
                  ),
                ),
                const SizedBox(height: 8),

                ListTile(
                  title: Text(
                    'Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),

                ListTile(
                  title: Text('Start Time: ${startTime.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (picked != null) {
                      setState(() => startTime = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                sessionVM.startSession(
                  Session(
                    id: const Uuid().v4(),
                    doctorEmail: doctorEmail,
                    name: nameController.text.trim(),
                    date: selectedDate,
                    startTime: DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      startTime.hour,
                      startTime.minute,
                    ),
                    maxAppointments: int.tryParse(maxController.text) ?? 10,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
