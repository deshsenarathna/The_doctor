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
              DropdownButtonFormField<Session>(
                value: _selectedSession,
                items: activeSessions.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text('${s.name} • ${s.date.toLocal().toString().split(' ')[0]}'),
                )).toList(),
                onChanged: (s) => setState(() => _selectedSession = s),
                decoration: InputDecoration(
                  labelText: 'Select Session',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (s) => s == null ? 'Select a session' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter age' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (v) => setState(() => _gender = v!),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                  child: const Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
