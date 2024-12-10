import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screen/home/doctorModel.dart';
class DoctorProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DoctorModel> _doctors = [];
  bool _isLoading = false;

  List<DoctorModel> get doctors => _doctors;
  bool get isLoading => _isLoading;

  // Fetch doctors from Firestore
  Future<void> fetchDoctors() async {
    _isLoading = true;
    notifyListeners();

    try {
      _doctors.clear();
      final querySnapshot = await _firestore.collection('all_doctors').get();

    for(var doc in querySnapshot.docs) {

      final doctor = DoctorModel.fromMap(doc.data(), doc.id);
      _doctors.add(doctor);
    }

    } catch (e) {
      print('Error fetching doctor data: $e');

      _doctors = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
