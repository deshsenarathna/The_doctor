import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'views/login_screen.dart';
import 'views/signup_screen.dart';
import 'views/patient_homescreen.dart';
import 'viewmodel/login_viewmodel.dart';
import 'viewmodel/signup_viewmodel.dart';
import 'viewmodel/patient_home_viewmodel.dart';

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
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => PatientHomeViewModel()),
      ],
      child: MaterialApp(
        title: 'HealthCare',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/patientHome': (_) => const PatientHomeScreen(),
          
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}