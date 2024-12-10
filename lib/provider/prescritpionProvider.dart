import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:IntelliMed/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../screen/appoitment/AppointmentModel.dart';
import '../screen/prescription/prescriptionModel.dart';

class PrescriptionProvider with ChangeNotifier {
  bool isLoading = false;
  List<DoctorPrescriptionModel> prescriptions = [];
  List<AppointmenModel> drPrescriptions = [];
  String? selectedFilePath;
  String? fileUrl;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> fetchPrescriptions() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    try {
      isLoading = true;
      notifyListeners();


      final snapshot = await _firestore
          .collection('prescriptions')
          .where('userId', isEqualTo: userId)
          .get();

      prescriptions = snapshot.docs
          .map((doc) => DoctorPrescriptionModel.fromJson(doc.data()))
          .toList();
    } catch (error) {
      print("Error fetching prescriptions: $error");
    } finally {
      isLoading = false; // Hide loading indicator
      notifyListeners();
    }
  }

  Future<void> fetchDrPrescriptions() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("User is not logged in.");
      return;
    }

    try {
      // Show loading indicator
      isLoading = true;
      notifyListeners();

      // Define a time filter (e.g., appointments from the last 30 days)
      DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      // Fetch data from Firestore
      final snapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      // Map Firestore documents to the AppointmenModel
      drPrescriptions = snapshot.docs
          .map((doc) => AppointmenModel.fromFirestore(doc))
          .toList();
    } catch (error) {
      print("Error fetching prescriptions: $error");
      // Optionally, handle the error (e.g., show a snackbar or dialog)
    } finally {
      // Hide loading indicator
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null && result.files.single.path != null) {
        selectedFilePath = result.files.single.path!;
      } else {
        print("No file selected.");
      }
    } catch (error) {
      print("Error picking file: $error");
      flushBarErrorMsg(context, 'Error!', 'Failed to pick file.');
    }
  }

  /// Upload PDF to Firebase Storage and save metadata to Firestore
  Future<void> uploadPrescriptionWithFile(
      BuildContext context,
      String doctorName,
      String date,
      ) async {
    if (selectedFilePath == null) {
      flushBarErrorMsg(context, 'Error!', 'Please select a file to upload.');
      return;
    }

    isLoading = true; // Set loading state
    notifyListeners();

    try {
      // Upload the file to Firebase Storage
      final file = File(selectedFilePath!);
      final ref = _storage
          .ref()
          .child('prescriptions/${DateTime.now().millisecondsSinceEpoch}.pdf');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});

      // Get the file download URL
      final fileUrl = await snapshot.ref.getDownloadURL();
      print("File uploaded successfully. Download URL: $fileUrl");

      // Save the prescription details to Firestore
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      var uuid = Uuid().v4().replaceAll('-', '');
      final newPrescription = DoctorPrescriptionModel(
        doctorName: doctorName,
        date: date,
        fileLink: fileUrl,
        timestamp: Timestamp.now(),
        id: uuid,
        userId: userId,
      );

      await _firestore
          .collection('prescriptions')
          .doc(uuid)
          .set(newPrescription.toJson());

      prescriptions.add(newPrescription);

      // Show success message
      flushBarSuccessMsg(context, 'Success!', 'Prescription uploaded successfully.');
    } catch (error) {
      print("Error uploading prescription or file: $error");
      flushBarErrorMsg(context, 'Error!', 'Failed to upload prescription.');
    } finally {
      isLoading = false; // Reset loading state
      notifyListeners();
    }
  }
 /* Future<void> downloadFile(BuildContext context, String fileLink) async {
    isLoading = true;
    notifyListeners();

    try {
      // Notify user that download has started
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading...')),
      );

      // Get a reference to the file on Firebase Storage
      final ref = FirebaseStorage.instance.refFromURL(fileLink);
      final downloadUrl = await ref.getDownloadURL();

      // Get the application-specific directory for saving the file
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/Downloads/${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);

      // Use Dio to download the file
      final dio = Dio();
      await dio.download(downloadUrl, file.path);

      // Notify user of success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File downloaded to ${file.path}')),
      );
    } catch (e) {
      // Log and notify user of the error
      print("Error during file download: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    } finally {
      isLoading = false; // Reset loading state
      notifyListeners();
    }
  }
*/

  Future<void> downloadFile(BuildContext context, String fileLink) async {
    isLoading = true;
    notifyListeners();

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading...')),
      );

      final ref = FirebaseStorage.instance.refFromURL(fileLink);
      final downloadUrl = await ref.getDownloadURL();

      // Save the file in the public Downloads directory
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);

      final dio = Dio();
      await dio.download(
        downloadUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('Download Progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      if (await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to $filePath')),
        );
      } else {
        throw Exception("File download failed.");
      }
    } catch (e) {
      print("Error during file download: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
/*
  Future<void> downloadFile(BuildContext context, String fileLink) async {
    isLoading = true;
    notifyListeners();

    try {
      // Notify user that download has started
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading...')),
      );

      // Get a reference to the file on Firebase Storage
      final ref = FirebaseStorage.instance.refFromURL(fileLink);
      final downloadUrl = await ref.getDownloadURL();

      // Get the application-specific directory for saving the file
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Could not access external storage directory.");
      }

      // Create the Downloads folder if it doesn't exist
      final downloadDir = Directory('${directory.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final filePath = '${downloadDir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);

      // Use Dio to download the file
      final dio = Dio();
      await dio.download(
        downloadUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('Download Progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // Check if the file exists
      if (await file.exists()) {
        // Notify user of success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to ${file.path}')),
        );
      } else {
        throw Exception("File download failed.");
      }
    } catch (e) {
      // Log and notify user of the error
      print("Error during file download: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    } finally {
      isLoading = false; // Reset loading state
      notifyListeners();
    }
  }
*/


}
