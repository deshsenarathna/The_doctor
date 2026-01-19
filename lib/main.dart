import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodel/appoinment_viewmodel.dart';
import 'views/login_screen.dart';
import 'views/signup_screen.dart';
import 'viewmodel/login_viewmodel.dart';
import 'viewmodel/signup_viewmodel.dart';
import 'views/doctor_home_screen.dart';
import 'viewmodel/session_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DocApp());
}

class DocApp extends StatelessWidget {
  const DocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppointmentViewModel()..listenToAppointments()),
        ChangeNotifierProvider(create:  (_) => LoginViewModel()),
        ChangeNotifierProvider(create:  (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => SessionViewModel()..fetchSessions()),
      ],
      child: MaterialApp(
        title: 'HealthCare',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          scaffoldBackgroundColor: const Color(0xFFEAF6FF), // light blue background
          appBarTheme: const AppBarTheme(centerTitle: true),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/doctor_home': (_) => const DoctorHomeScreen(doctorEmail: ''),
          // PatientHomeScreen requires patientPhone, use Navigator.push instead
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
