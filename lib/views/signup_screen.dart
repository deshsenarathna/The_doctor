import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'patient_homescreen.dart';
import 'doctor_home_screen.dart';
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
  final _phoneController = TextEditingController();
  UserType selectedRole = UserType.patient;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SignupViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.app_registration, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Create Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter email';
                            final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!regex.hasMatch(v)) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter password';
                            if (v.length < 6) return 'Password must be at least 6 chars';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter phone number';
                            if (v.length < 9) return 'Enter a valid phone number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        vm.isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: CircularProgressIndicator(),
                              )
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle_outline),
                                  onPressed: () async {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      final user = await vm.signup(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text.trim(),
                                        role: selectedRole == UserType.patient ? 'patient' : 'doctor',
                                        phone: _phoneController.text.trim(),
                                      );

                                      if (user != null) {
                                        if (user.role == 'patient') {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PatientHomeScreen(
                                                patientPhone: user.phone,
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => DoctorHomeScreen(
                                                doctorEmail: user.email,
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Signup failed')),
                                        );
                                      }
                                    }
                                  },
                                  label: const Text('Sign Up'),
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
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
