import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/login_viewmodel.dart';
import 'patient_homescreen.dart';
import 'doctor_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LoginViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 30),
              vm.isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final user = await vm.login(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            );

                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Login failed')),
                              );
                              return;
                            }

                            // Navigate based on email (doctor or patient)
                            if (user.isDoctor) {
                              // For now, simple placeholder screen
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DoctorHomeScreen(doctorEmail: user.email!),
                                ),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientHomeScreen(
                                    patientPhone: user.phone!,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Login'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple placeholder for doctors until real DoctorHomeScreen is implemented
class DoctorPlaceholderScreen extends StatelessWidget {
  const DoctorPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Home')),
      body: const Center(
        child: Text(
          'Welcome Doctor!\nYour home screen will be implemented later.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
