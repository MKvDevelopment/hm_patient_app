import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../screen/ambulance/AmbulanceBookingModel.dart';

class AmbulanceBookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
   List<AmbulanceModel> bookings=[];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> submitBooking(AmbulanceModel booking,BuildContext context) async {
    try {
      isLoading = true;
      // Add the ambulance booking to Firestore
      await _firestore
          .collection('ambulanceBookings')
          .doc(booking.bookingId)
          .set(booking.toMap())
          .then((v){
            bookings.insert(0,booking);
        flushBarSuccessMsg(context, "Success", "Booking Successful");
        isLoading = false;
      }).onError((error, stackTrace) {
        flushBarErrorMsg(context, "Error", "Booking Failed");
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      // Handle errors
      flushBarErrorMsg(context, "Error", "$e");

    }
  }

  // Method to delete a booking
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('ambulanceBookings').doc(bookingId).delete();
      // Remove the item locally as well
      bookings.removeWhere((booking) => booking.bookingId == bookingId);
      notifyListeners();
    } catch (error) {
      print("Failed to delete booking: $error");
    }
  }

  Future<void> fetchBookings() async {
    isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ambulanceBookings')
          .where('userId', isEqualTo: auth.currentUser?.uid)
          //.orderBy('bookingTime',descending: false)
          .get();
      bookings = snapshot.docs.map((doc) {
        return AmbulanceModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

    } catch (e) {
      print("Error fetching bookings: $e");
      bookings=[];
    }finally{
      isLoading = false;
      notifyListeners();
    }
  }
  Future<Map<String, dynamic>> fetchDriverDetails(String driverId) async {
    try {
      // Fetch the document snapshot from Firestore
      DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('driverList').doc(driverId).get();

      // Check if the document exists
      if (!snapshot.exists) {
        throw Exception('Driver not found');
      }

      // Extract data from the document snapshot
      final data = snapshot.data() as Map<String, dynamic>;

      // Return the data
      return {
        'email': data['email'] ?? 'N/A', // Replace with the actual field name
        'experience': data['experience'] ?? 'N/A', // Replace with the actual field name
        'mobileNo': data['mobileNo'] ?? 'N/A', // Replace with the actual field name
        'name': data['name'] ?? 'N/A', // Replace with the actual field name
        'vehicleNo': data['vehicleNo'] ?? 'N/A', // Replace with the actual field name
      };
    } catch (e) {
      // Handle errors and rethrow them to notify the caller
      throw Exception('Failed to fetch driver details: $e');
    }
  }

}
