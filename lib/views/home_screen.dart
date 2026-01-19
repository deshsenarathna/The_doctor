import 'package:flutter/material.dart';
import 'package:doctor_app/views/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: const Icon(Icons.nightlight_round, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.favorite, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                const Text(
                  'HealthCare',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your health, our priority',
                  style: TextStyle(color: Colors.grey[700], fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const _FeatureCard(
                  icon: Icons.event_available,
                  title: 'Easy Booking',
                  description: 'Book appointments with top doctors in seconds',
                ),
                const _FeatureCard(
                  icon: Icons.location_on,
                  title: 'Live Tracking',
                  description: 'Track your doctor in real-time like Uber',
                ),
                const _FeatureCard(
                  icon: Icons.verified_user,
                  title: 'Trusted Care',
                  description: 'Verified doctors with ratings and reviews',
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Get Started",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 7),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: Icon(icon, color: Colors.blue, size: 32),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(description),
        ),
      ),
    );
  }
}