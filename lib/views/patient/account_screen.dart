import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/patient_account_viewmodel.dart';

class PatientAccountScreen extends StatefulWidget {
  const PatientAccountScreen({super.key});

  @override
  State<PatientAccountScreen> createState() => _PatientAccountScreenState();
}

class _PatientAccountScreenState extends State<PatientAccountScreen> {
  final _phoneController = TextEditingController();
  final _pwdController = TextEditingController();
  final _pwdConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientAccountViewModel>().load().then((_) {
        final vm = context.read<PatientAccountViewModel>();
        _phoneController.text = vm.phone ?? '';
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pwdController.dispose();
    _pwdConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientAccountViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.person, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: vm.email ?? '',
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            prefixIcon: const Icon(Icons.phone),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        vm.isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.save_outlined),
                                onPressed: () async {
                                  final newPhone = _phoneController.text.trim();
                                  if (newPhone.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Phone cannot be empty')),
                                    );
                                    return;
                                  }
                                  await vm.updatePhone(newPhone);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Profile updated')),
                                    );
                                  }
                                },
                                label: const Text('Update Profile'),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.lock_reset, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Change Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pwdController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pwdConfirmController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        vm.isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final p1 = _pwdController.text.trim();
                                  final p2 = _pwdConfirmController.text.trim();
                                  if (p1.isEmpty || p2.isEmpty || p1 != p2 || p1.length < 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Passwords must match and be at least 6 characters')),
                                    );
                                    return;
                                  }
                                  try {
                                    await vm.updatePassword(p1);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Password updated')),
                                      );
                                    }
                                    _pwdController.clear();
                                    _pwdConfirmController.clear();
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to update password: $e')),
                                      );
                                    }
                                  }
                                },
                                label: const Text('Update Password'),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.red.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.delete_forever, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text('Danger Zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.redAccent)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        vm.isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Account'),
                                      content: const Text('This will permanently delete your account and appointments. Continue?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await vm.deleteAccount(deleteAppointments: true);
                                      if (mounted) {
                                        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to delete account: $e')),
                                        );
                                      }
                                    }
                                  }
                                },
                                label: const Text('Delete Account'),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
