class DoctorModel {
  final String id;
  final String doctorName;
  final String department;
  final String contactNumber;
  final String availabilityTime;
  final String experience;
  final bool availabilityStatus;
  final String imgUrl;

  DoctorModel({
    required this.id,
    required this.imgUrl,
    required this.doctorName,
    required this.department,
    required this.contactNumber,
    required this.availabilityTime,
    required this.experience,
    required this.availabilityStatus,
  });

  // Factory method to create an instance from a map (Firebase document snapshot)
  factory DoctorModel.fromMap(Map<String, dynamic> data, String documentId) {
    return DoctorModel(
      id: documentId,
      doctorName: data['doctorName'] ?? '',
      imgUrl: data['imgUrl'] ?? '',
      department: data['department'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      availabilityTime: data['availabilityTime'] ?? '',
      experience: data['experience'] ?? '',
      availabilityStatus: data['availabilityStatus'] == "true", // Convert string to bool
    );
  }
}
