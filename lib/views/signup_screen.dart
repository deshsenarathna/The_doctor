import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/signup_viewmodel.dart';

enum UserType { patient, doctor }

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserType selectedRole = UserType.patient;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SignupViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email';
                    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!regex.hasMatch(v)) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    if (v.length < 6) return 'Password must be at least 6 chars';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Role selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Patient'),
                      selected: selectedRole == UserType.patient,
                      onSelected: (_) => setState(() => selectedRole = UserType.patient),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Doctor'),
                      selected: selectedRole == UserType.doctor,
                      onSelected: (_) => setState(() => selectedRole = UserType.doctor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Signup button
                vm.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final user = await vm.signup(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              role: selectedRole == UserType.patient ? 'patient' : 'doctor',
                            );

                            if (user != null) {
                              // Navigate based on role
                              if (user.role == 'patient') {
                                Navigator.pushReplacementNamed(context, '/patientHome');
                              } else {
                                Navigator.pushReplacementNamed(context, '/doctorHome');
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Signup failed')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Sign Up'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
