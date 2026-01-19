import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/appoinment_viewmodel.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String patientPhone; // REQUIRED

  const BookAppointmentScreen({super.key, required this.patientPhone});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AppointmentViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _label('Patient Name'),
              _field(_nameController, 'Enter name'),
              const SizedBox(height: 16),
              _label('Age'),
              _field(_ageController, 'Enter age', keyboard: TextInputType.number),
              const SizedBox(height: 16),
              _label('Gender'),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (v) => setState(() => _gender = v!),
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final appointment = vm.bookAppointment(
                        patientName: _nameController.text.trim(),
                        age: int.parse(_ageController.text.trim()),
                        gender: _gender,
                        phone: widget.patientPhone,
                      );

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Appointment Confirmed'),
                          content: Text(
                            'Your appointment number is\n\nA${appointment.appointmentNumber}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // close dialog
                                Navigator.pop(context); // go back to home
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm Booking'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.w600));

  Widget _field(TextEditingController controller, String hint,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration([String? hint]) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
