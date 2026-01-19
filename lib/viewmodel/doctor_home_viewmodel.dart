// views/doctor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../models/appoinment_model.dart';
import '../viewmodel/appoinment_viewmodel.dart';
import '../viewmodel/session_view_model.dart';
import 'package:provider/provider.dart';

class DoctorHomeScreen extends StatefulWidget {
  final String doctorEmail;
  const DoctorHomeScreen({super.key, required this.doctorEmail});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {

  @override
  Widget build(BuildContext context) {
    final appointmentVM = Provider.of<AppointmentViewModel>(context);
    final sessionVM = Provider.of<SessionViewModel>(context);
    final doctorSessions = sessionVM.doctorSessions(widget.doctorEmail);

    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Home'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor info
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_hospital, size: 40, color: Colors.blue),
                title: Text(widget.doctorEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('General Physician • Dispensary'),
              ),
            ),
            const SizedBox(height: 16),

            // Start new session button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showStartSessionDialog(context),
                child: const Text('Start New Session'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: doctorSessions.isEmpty
                  ? const Center(child: Text('No sessions yet'))
                  : ListView.builder(
                      itemCount: doctorSessions.length,
                      itemBuilder: (context, index) {
                        final session = doctorSessions[index];

                        // Filter today's appointments for this session
                        final today = DateTime.now();
                        final sessionApps = appointmentVM.appointments
                            .where((a) => a.sessionId == session.id && sameDay(a.date, today))
                            .toList()
                          ..sort((a, b) => a.appointmentNumber.compareTo(b.appointmentNumber));

                        final nowServing = appointmentVM.nowServingForSession(session.id, day: today);

                        final hasNext = sessionApps.any((a) =>
                          a.appointmentNumber == nowServing && a.status != AppointmentStatus.completed);

                        return Card(
                          child: ExpansionTile(
                            title: Text(session.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Date: ${session.date.toLocal().toString().split(' ')[0]} | Max Appointments: ${session.maxAppointments}'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.record_voice_over, size: 16, color: Colors.orange),
                                    const SizedBox(width: 6),
                                    Text('Now Serving: $nowServing',
                                        style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: hasNext
                                          ? () {
                                              appointmentVM.markCompleted(session.id, nowServing);
                                            }
                                          : null,
                                      child: const Text('Complete Next'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            children: [
                              sessionApps.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text('No appointments yet'),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: sessionApps.length,
                                      itemBuilder: (context, i) {
                                        final app = sessionApps[i];
                                        final isCompleted = app.status == AppointmentStatus.completed;
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                isCompleted ? Colors.green : (app.appointmentNumber == nowServing ? Colors.blue : Colors.orange),
                                            child: Text(app.appointmentNumber.toString(),
                                                style: const TextStyle(color: Colors.white)),
                                          ),
                                          title: Text(app.patientName),
                                          subtitle: Text('${app.phone}'),
                                          trailing: isCompleted
                                              ? const Text('Completed', style: TextStyle(color: Colors.green))
                                              : ElevatedButton(
                                                  onPressed: () {
                                                    appointmentVM.markCompleted(
                                                      session.id,
                                                      app.appointmentNumber,
                                                    );
                                                  },
                                                  child: const Text('Mark Completed'),
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

  void _showStartSessionDialog(BuildContext context) {
    final sessionVM = Provider.of<SessionViewModel>(context, listen: false);
    final _nameController = TextEditingController();
    final _maxController = TextEditingController();
    DateTime _selectedDate = DateTime.now();
    TimeOfDay _startTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start New Session'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Session Name'),
              ),
              TextField(
                controller: _maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max Appointments'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100));
                  if (picked != null) {
                    _selectedDate = picked;
                  }
                },
                child: const Text('Pick Date'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showTimePicker(context: context, initialTime: _startTime);
                  if (picked != null) {
                    _startTime = picked;
                  }
                },
                child: const Text('Pick Start Time'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                final id = const Uuid().v4();
                final session = Session(
                  id: id,
                  name: _nameController.text.trim(),
                  date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
                  doctorEmail: widget.doctorEmail,
                  startTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _startTime.hour, _startTime.minute),
                  maxAppointments: int.tryParse(_maxController.text.trim()) ?? 10,
                  isActive: true,
                );
                sessionVM.startSession(session);
                Navigator.pop(ctx);
              },
              child: const Text('Start')),
        ],
      ),
    );
  }
}
