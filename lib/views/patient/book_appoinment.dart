import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/appoinment_viewmodel.dart';
import '../../viewmodel/session_view_model.dart';
import '../../models/session_model.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String patientPhone;

  const BookAppointmentScreen({super.key, required this.patientPhone});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  Session? _selectedSession;

  String _dateStr(DateTime d) => d.toLocal().toString().split(' ').first;
  String _timeStr(DateTime d, BuildContext context) =>
      TimeOfDay.fromDateTime(d).format(context);

  Widget _sessionSummary(Session? s) {
    if (s == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: const [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text('Select a session to see details'),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event_available, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      _chip(Icons.calendar_today, _dateStr(s.date)),
                      _chip(Icons.access_time, _timeStr(s.startTime, context)),
                      _chip(Icons.people, 'Max ${s.maxAppointments}'),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentVM = Provider.of<AppointmentViewModel>(context, listen: false);
    final sessionVM = Provider.of<SessionViewModel>(context);

    final activeSessions = sessionVM.activeSessions();

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title
              Row(
                children: const [
                  Icon(Icons.medical_services, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Book Appointment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Session>(
                value: _selectedSession,
                isExpanded: true,
                items: activeSessions.map((s) {
                  final dateStr = s.date.toLocal().toString().split(' ')[0];
                  final timeStr = TimeOfDay.fromDateTime(s.startTime).format(context);
                  final label = '${s.name} • $dateStr • $timeStr • Max: ${s.maxAppointments}';
                  return DropdownMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (s) => setState(() => _selectedSession = s),
                decoration: InputDecoration(
                  labelText: 'Select Session',
                  prefixIcon: const Icon(Icons.event_note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (s) => s == null ? 'Select a session' : null,
              ),
              const SizedBox(height: 12),
              _sessionSummary(_selectedSession),
              const SizedBox(height: 16),
              // Patient details card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.person_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Patient Details', style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Patient Name',
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          labelText: 'Age',
                          prefixIcon: const Icon(Icons.numbers),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter age';
                          final n = int.tryParse(v);
                          if (n == null || n <= 0) return 'Enter valid age';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                        ],
                        onChanged: (v) => setState(() => _gender = v!),
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: const Icon(Icons.wc),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _selectedSession != null) {
                      try {
                        final appointment = await appointmentVM.bookAppointment(
                          patientName: _nameController.text.trim(),
                          age: int.parse(_ageController.text.trim()),
                          gender: _gender,
                          phone: widget.patientPhone,
                          sessionId: _selectedSession!.id,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Booked appointment No ${appointment.appointmentNumber}')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                        );
                      }
                    }
                  },
                  label: const Text('Confirm Booking'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
