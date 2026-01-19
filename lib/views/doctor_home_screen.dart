import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/session_model.dart';
import '../models/appoinment_model.dart';
import '../viewmodel/session_view_model.dart';
import '../viewmodel/appoinment_viewmodel.dart';
import '../viewmodel/login_viewmodel.dart';

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
      appBar: AppBar(
        title: const Text('Doctor Home'),
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Edit session',
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                  onPressed: () => _showEditSessionDialog(context, sessionVM, session),
                                ),
                                IconButton(
                                  tooltip: 'Delete session',
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(context, sessionVM, session),
                                ),
                              ],
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
                                                      session.id,
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

  /// ✏️ Edit Session Dialog
  void _showEditSessionDialog(
    BuildContext context,
    SessionViewModel sessionVM,
    Session session,
  ) {
    final nameController = TextEditingController(text: session.name);
    final maxController = TextEditingController(text: session.maxAppointments.toString());
    DateTime selectedDate = DateTime(session.date.year, session.date.month, session.date.day);
    TimeOfDay startTime = TimeOfDay(hour: session.startTime.hour, minute: session.startTime.minute);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Session'),
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
                  decoration: const InputDecoration(labelText: 'Max Appointments'),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text('Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                ),
                ListTile(
                  title: Text('Start Time: ${startTime.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: startTime);
                    if (picked != null) setState(() => startTime = picked);
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
              onPressed: () async {
                final updated = Session(
                  id: session.id,
                  doctorEmail: session.doctorEmail,
                  name: nameController.text.trim(),
                  date: selectedDate,
                  startTime: DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    startTime.hour,
                    startTime.minute,
                  ),
                  maxAppointments: int.tryParse(maxController.text.trim()) ?? session.maxAppointments,
                  isActive: session.isActive,
                );
                await sessionVM.updateSession(updated);
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  /// 🗑️ Confirm Delete
  void _confirmDelete(
    BuildContext context,
    SessionViewModel sessionVM,
    Session session,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure you want to delete this session? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await sessionVM.deleteSession(session.id);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
