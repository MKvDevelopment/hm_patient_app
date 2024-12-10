import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../screen/auth/StudentModel.dart';


class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth auth=FirebaseAuth.instance;
  bool _isLoading = false;
  StudentModel? _student;
  StudentModel? get student => _student; // Getter for accessing the student data


  bool get isLoading => _isLoading;


  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? imageUrl;

  // Function to pick an image from the gallery
  Future<void> pickImage(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
          _selectedImage = File(pickedFile.path);
        // Upload image to Firebase Storage
        await _uploadImageToFirebase(context);
      }
    } catch (e) {
      print("Error picking image: $e");
      flushBarErrorMsg(context, "Error!", "Failed to pick image.");
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  // Function to upload the image to Firebase Storage
  Future<void> _uploadImageToFirebase(BuildContext context) async {
    try {
      if (_selectedImage == null) return;

      final fileName = FirebaseAuth.instance.currentUser!.uid;
      final storageRef = FirebaseStorage.instance.ref().child("profile_images/$fileName");

      final uploadTask = storageRef.putFile(_selectedImage!);

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

        imageUrl = url; // Store the image URL
       await _firebaseFirestore
          .collection('students')
          .doc(auth.currentUser?.uid)
          .update({'imgUrl': imageUrl});


      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('imgUrl', imageUrl!);
        _isLoading = false;
        notifyListeners();

      flushBarSuccessMsg(context, "Success!", "Image uploaded successfully.");
    } catch (e) {
      print("Error uploading image: $e");
      flushBarErrorMsg(context, "Error!", "Failed to upload image.");
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchStudent(BuildContext context) async {
    if (auth.currentUser == null) {
      print("User not authenticated");
      isLoading == false;
      flushBarErrorMsg(context, "title", "user not authenticated");
      notifyListeners();
      return;
    }

    isLoading == true;
    notifyListeners();

    try {
      print("Fetching data for UID: ${auth.currentUser?.uid}");
      DocumentSnapshot snapshot = await _firebaseFirestore
          .collection('students')
          .doc(auth.currentUser?.uid)
          .get();
      if (snapshot.exists) {
        _student = StudentModel.fromFirestore(snapshot.data() as Map<String, dynamic>);
       await saveUserDataToPreferences(_student!);

        isLoading == false;
        notifyListeners();
        print("Data fetched successfully for UID: ${auth.currentUser?.uid}");
       // flushBarErrorMsg(context, "title", "Data fetched successfully");
      } else {
        print("No student data found for UID: ${auth.currentUser?.uid}");
        flushBarErrorMsg(context, "title", "No student data found for UID: ${auth.currentUser?.uid}");
      }
    } catch (error) {
      print("Error fetching student data: $error");
      flushBarErrorMsg(context, "title", "Error fetching student data: $error");
    } finally {
      isLoading == false;
      notifyListeners();
    }
  }


  // Method to update student data
  Future<void> updateStudent(StudentModel updatedStudent) async {
    isLoading == true;
    notifyListeners();
    try {
      await _firebaseFirestore.collection('students')
          .doc(updatedStudent.studentId)
          .update({
        'name': updatedStudent.name,
        'rollNo': updatedStudent.rollNo,
        'branch': updatedStudent.branch,
        'year': updatedStudent.year,
        'email': updatedStudent.email,
        'mobileNo': updatedStudent.mobileNo,
        'bloodGroup': updatedStudent.bloodGroup,
        'gender': updatedStudent.gender,
        'address': updatedStudent.address,
      });
      _student = updatedStudent; // Update local model
      saveUserDataToPreferences(updatedStudent);
      notifyListeners();
    } catch (error) {
      print("Error updating student: $error");
    }finally{
      isLoading == false;
      notifyListeners();
    }
  }

  // Method to save data in SharedPreferences
  Future<void> saveUserDataToPreferences(StudentModel student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studentId', student.studentId);
    await prefs.setString('email', student.email!);
    await prefs.setString('name', student.name);
    await prefs.setString('mobileNo', student.mobileNo);
    await prefs.setString('rollNo', student.rollNo);
    await prefs.setString('imgUrl', student.imgUrl);
    await prefs.setString('branch', student.branch);
    await prefs.setString('year', student.year);
    await prefs.setString('bloodGroup', student.bloodGroup);
    await prefs.setString('gender', student.gender);
    await prefs.setString('address', student.address);
  }

  Future<void> updateAppoitmentDetails(BuildContext context,String id) async {
    isLoading == true;
    notifyListeners();
    try {

      var map=Map<String, dynamic>();
      map['verification'] = 'approved';

      await _firebaseFirestore
          .collection('appointments')
          .doc(id)
          .update(map);
      notifyListeners();
    } catch (error) {
      print("Error updating student: $error");
    }finally{
      isLoading == false;
      notifyListeners();
    }
  }
// You can add more methods for updating or deleting students as needed
}
