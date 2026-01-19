import 'package:flutter/material.dart';
import '../models/appoinment_model.dart';
import '../services/appoinment_services.dart';

class PatientHomeViewModel extends ChangeNotifier {
  final AppointmentService _service = AppointmentService();

  bool isLoading = true;
  List<Appointment> appointments = [];

  Future<void> loadAppointments() async {
    isLoading = true;
    notifyListeners();

    appointments = await _service.fetchAppointments();
    isLoading = false;
    notifyListeners();
  }
}
