// views/doctor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../models/appoinment_model.dart';
import '../viewmodel/appoinment_viewmodel.dart';
import 'package:provider/provider.dart';

class DoctorHomeScreen extends StatefulWidget {
  final String doctorEmail;
  const DoctorHomeScreen({super.key, required this.doctorEmail});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final List<Session> _sessions = [];

  @override
  Widget build(BuildContext context) {
    final appointmentVM = Provider.of<AppointmentViewModel>(context);

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
              child: _sessions.isEmpty
                  ? const Center(child: Text('No sessions yet'))
                  : ListView.builder(
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        // Filter appointments for this session
                        final sessionAppointments = appointmentVM.appointments
                            .where((a) => a.sessionId == session.id)
                            .toList();

                        return Card(
                          child: ExpansionTile(
                            title: Text(session.name),
                            subtitle: Text(
                                'Date: ${session.date.toLocal().toString().split(' ')[0]} | Max Appointments: ${session.maxAppointments}'),
                            children: [
                              sessionAppointments.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text('No appointments yet'),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: sessionAppointments.length,
                                      itemBuilder: (context, i) {
                                        final app = sessionAppointments[i];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: app.status == AppointmentStatus.completed
                                                ? Colors.green
                                                : Colors.orange,
                                            child: Text(app.appointmentNumber.toString(),
                                                style: const TextStyle(color: Colors.white)),
                                          ),
                                          title: Text(app.patientName),
                                          subtitle: Text(
                                              '${app.date.hour}:${app.date.minute.toString().padLeft(2, '0')} | ${app.phone}'),
                                          trailing: app.status == AppointmentStatus.completed
                                              ? const Text('Completed', style: TextStyle(color: Colors.green))
                                              : ElevatedButton(
                                                  onPressed: () {
                                                    appointmentVM.markCompleted(app.appointmentNumber);
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
                  date: _selectedDate,
                  doctorEmail: widget.doctorEmail,
                  startTime: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _startTime.hour, _startTime.minute),
                  maxAppointments: int.tryParse(_maxController.text.trim()) ?? 10,
                );
                setState(() {
                  _sessions.add(session);
                });
                Navigator.pop(ctx);
              },
              child: const Text('Start')),
        ],
      ),
    );
  }
}
