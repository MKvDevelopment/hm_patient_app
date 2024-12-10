import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../route_constants.dart';
import '../screen/auth/StudentModel.dart';

class AuthProviderr with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  User? _user;
  bool isLoading = false;

  bool get isLoadingValue => isLoading;

  set isLoadingValue(bool value) {
    isLoading = value;
    notifyListeners();
  }

  bool get isAuthenticated => _user != null;

  User? get user => _user;

  AuthProviderr() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    FocusScope.of(context).unfocus();
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async => {
                if (value.user != null)
                  {
                    isLoadingValue = false,
                    flushBarSuccessMsg(context, "Success", "Login Successful"),
                    fetchStudent(context),
                  }
                else
                  {
                    flushBarErrorMsg(context, "Error", "Login Failed"),
                    isLoadingValue = false
                  }
              });
    } catch (e) {
      isLoadingValue = false;
      flushBarErrorMsg(context, "Error", "Login Failed");
      throw e.toString();
    }
  }

  // Method to fetch students from Firestore
  Future<void> fetchStudent(BuildContext context) async {
    final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      DocumentSnapshot snapshot = await _firebaseFirestore
          .collection('students')
          .doc(auth.currentUser?.uid)
          .get();
      if (snapshot.exists) {
        // Convert the document data to a StudentModel object
        StudentModel student =
            StudentModel.fromFirestore(snapshot.data() as Map<String, dynamic>);
        saveUserDataToPreferences(student);
        notifyListeners(); // Notify listeners so that the UI updates
      } else {
        // If the document does not exist
        print("No student data found for the current user.");
      }
    } catch (error) {
      print("Error fetching students: $error");
    } finally {
      Navigator.pushNamedAndRemoveUntil(context, homeScreenRoute,(route)=>false);
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
    await prefs.setString('branch', student.branch);
    await prefs.setString('year', student.year);
    await prefs.setString('bloodGroup', student.bloodGroup);
    await prefs.setString('gender', student.gender);
    await prefs.setString('address', student.address);
  }

  Future<StudentModel?> getUserDataFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve saved data
    String? studentId = prefs.getString('studentId');
    String? email = prefs.getString('email');
    String? name = prefs.getString('name');
    String? mobileNo = prefs.getString('mobileNo');
    String? imgUrl = prefs.getString('imgUrl');
    String? rollNo = prefs.getString('rollNo');
    String? branch = prefs.getString('branch');
    String? year = prefs.getString('year');
    String? bloodGroup = prefs.getString('bloodGroup');
    String? gender = prefs.getString('gender');
    String? address = prefs.getString('address');

    // Check if the studentId exists (indicating that data is saved)
    if (studentId != null && email != null) {
      // Return a StudentModel object with the retrieved values
      return StudentModel(
        email: email,
        studentId: studentId,
        name: name ?? '',
        mobileNo: mobileNo ?? '',
        rollNo: rollNo ?? '',
        imgUrl: imgUrl ?? '',
        branch: branch ?? '',
        year: year ?? '',
        bloodGroup: bloodGroup ?? '',
        gender: gender ?? '',
        address: address ?? '',
      );
    } else {
      // If no data is found, return null
      return null;
    }
  }

  // Modify createUserWithEmailAndPassword method
  Future<void> createUserWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    FocusScope.of(context).unfocus();
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        if (value.user != null) {
          isLoadingValue = false;

          // Create the student object
          StudentModel student = StudentModel(
            email: email,
            studentId: value.user!.uid,
            name: '',
            mobileNo: '',
            rollNo: '',
            imgUrl: '',
            branch: '',
            year: '',
            bloodGroup: '',
            gender: '',
            address: '',
          );

          // Add student to Firestore
          addStudent(student, context);

          // Save data in SharedPreferences
          await saveUserDataToPreferences(student);

          // Show success message
          flushBarSuccessMsg(context, "Success", "Registration Successful");

          // Navigate to home screen
          Navigator.pushNamedAndRemoveUntil(context, homeScreenRoute,(route)=>false);
        } else {
          flushBarErrorMsg(context, "Error", "Registration Failed");
          isLoadingValue = false;
        }
      });
    } catch (e) {
      isLoadingValue = false;
      flushBarErrorMsg(context, "Error", "Registration Failed");
      throw e.toString();
    }
  }

  Future<void> signOut(BuildContext context, String logInScreenRoute) async {
    await _auth.signOut();
    _user = null;
    notifyListeners();

    Navigator.pushReplacementNamed(context, logInScreenRoute);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _user = firebaseUser;
    notifyListeners();
  }

  // Method to add a student to Firestore
  Future<void> addStudent(StudentModel student, BuildContext context) async {
    try {
      isLoadingValue = true;

      // Add the student to the 'students' collection in Firestore
      await firebaseFirestore
          .collection('students')
          .doc(student.studentId)
          .set(student.toMap())
          .then((onValue) {
        flushBarSuccessMsg(context, "Success", "Student added successfully");
      }).onError((error, stackTrace) {
        flushBarErrorMsg(context, "Error", "Failed to add student");
      });
    } catch (error) {
      print("Error adding student: $error");
      flushBarErrorMsg(context, "Error", "$error");
    } finally {
      isLoadingValue = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    isLoadingValue = true;
    notifyListeners();

    final user = _auth.currentUser;

    if (user == null) {
      isLoadingValue = false;
      notifyListeners();
      throw FirebaseAuthException(
          code: 'no-user', message: 'No user is signed in.');
    }

    // Re-authenticate the user
    final email = user.email!;
    final credential =
        EmailAuthProvider.credential(email: email, password: oldPassword);

    try {
      // Re-authenticate
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } finally {
      isLoadingValue = false;
      notifyListeners();
    }
  }
}
