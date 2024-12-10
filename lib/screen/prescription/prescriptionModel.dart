// doctor_appointment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorPrescriptionModel {
  final String doctorName;
  final String id;
  final String? userId;
  final String date;
  final String fileLink;
  final Timestamp timestamp;

  DoctorPrescriptionModel({
    required this.doctorName,
    required this.id,
    required this.userId,
    required this.date,
    required this.fileLink,
    required this.timestamp,
  });

  // Factory method to create an instance from a JSON object
  factory DoctorPrescriptionModel.fromJson(Map<String, dynamic> json) {
    return DoctorPrescriptionModel(
      doctorName: json['doctorName'],
      id: json['id'],
      date: json['date'],
      userId: json['userId'],
      fileLink: json['fileLink'],
      timestamp: json['timestamp'] ?? Timestamp.now(),
    );
  }

  // Method to convert the object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'doctorName': doctorName,
      'date': date,
      'id': id,
      'userId': userId,
      'fileLink': fileLink,
      'timestamp': timestamp,
    };
  }
}
