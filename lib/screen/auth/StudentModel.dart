class StudentModel {
  String name;
  String rollNo;
  String branch;
  String year;
  String? email;
  String mobileNo;
  String bloodGroup;
  String gender;
  String address;
  String imgUrl;
  String studentId;

  // Constructor
  StudentModel({
    required this.studentId,
    required this.name,
    required this.rollNo,
    required this.branch,
    required this.imgUrl,
    required this.year,
    required this.email,
    required this.mobileNo,
    required this.bloodGroup,
    required this.gender,
    required this.address,
  });

  // Convert Firestore document into a Student object
  factory StudentModel.fromFirestore(Map<String, dynamic> firestoreDoc) {
    return StudentModel(
      name: firestoreDoc['name'] ?? '',
      studentId: firestoreDoc['studentId'] ?? '',
      rollNo: firestoreDoc['rollNo'] ?? '',
      branch: firestoreDoc['branch'] ?? '',
      year: firestoreDoc['year'] ?? '',
      email: firestoreDoc['email'] ?? '',
      imgUrl: firestoreDoc['imgUrl'] ?? '',
      mobileNo: firestoreDoc['mobileNo'] ?? '',
      bloodGroup: firestoreDoc['bloodGroup'] ?? '',
      gender: firestoreDoc['gender'] ?? '',
      address: firestoreDoc['address'] ?? '',
    );
  }

  // Convert Student object to a map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'rollNo': rollNo,
      'branch': branch,
      'year': year,
      'imgUrl': imgUrl,
      'email': email,
      'mobileNo': mobileNo,
      'bloodGroup': bloodGroup,
      'gender': gender,
      'address': address,
    };
  }
}
