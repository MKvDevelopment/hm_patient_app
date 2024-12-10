import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../common_code/custom_text_style.dart';
import '../../constants.dart';
import '../../provider/AmbulanceProvider.dart';
import 'AmbulanceBookingModel.dart';

class BookAmbulance extends StatefulWidget {
  const BookAmbulance({super.key});

  @override
  State<BookAmbulance> createState() => _BookAmbulanceState();
}

class _BookAmbulanceState extends State<BookAmbulance> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final hostalController = TextEditingController();
  final roomNoController = TextEditingController();
  final descriptionController = TextEditingController();
  final destinationController = TextEditingController();

  TimeOfDay? selectedTime;
  String? selectedHostal;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), // Forces 12-hour format
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }
  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    nameController.dispose();
    contactController.dispose();
    hostalController.dispose();
    roomNoController.dispose();
    descriptionController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ambulanceBookingProvider = Provider.of<AmbulanceBookingProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Book an Ambulance"),
        ),
        body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),
                  _buildTextField('Name', 'Enter name', controller: nameController),
                  const SizedBox(height: 5),
                  _buildTextField('Contact Number', 'Enter contact number',controller: contactController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 5),
                  _buildTextField('Hostel', 'Enter Hostel name', controller: hostalController),
                  const SizedBox(height: 5),
                  _buildTextField('Room No', 'Enter Room No', controller: roomNoController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 2),
                  _buildDropdownField('PickUp Location', hostalList),
                  const SizedBox(height: 2),
                  _buildTextField('Destination', 'Enter Destination', controller: destinationController),
                  const SizedBox(height: 5),
                  _buildTextField('Description', 'Enter Description', controller: descriptionController),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      _selectTime(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.3),
                        borderRadius: BorderRadius.circular(8.0), // Use 0 for sharp corners
                      ),
                      child: Text(selectedTime != null
                          ? "Booking Time: ${selectedTime!.format(context)}"
                          : 'Select Booking Time',style: CustomTextStyles.titleMedium),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ambulanceBookingProvider.isLoading?
                  CircularProgressIndicator(color: Theme.of(context).appBarTheme.backgroundColor):
                  ElevatedButton(
                    onPressed: () {
                      String? userId=FirebaseAuth.instance.currentUser?.uid;
                      if (_formKey.currentState!.validate() && selectedTime != null) {
                        var uuid = Uuid().v4();
                        AmbulanceModel booking = AmbulanceModel(
                          name: nameController.text.trim(),
                          userId: userId,
                          contactNumber: contactController.text.trim(),
                          hostal: hostalController.text.trim(),
                          roomNo: roomNoController.text.trim(),
                          pickupLocation: selectedHostal ?? 'Not selected',
                          description: descriptionController.text.trim(),
                          destination: destinationController.text.trim(),
                          bookingTime: selectedTime!.format(context),
                          bookingId: uuid,
                          confirmStatus: 'pending',
                          driverId: '',
                        );
                        ambulanceBookingProvider.submitBooking(booking,context);

                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select booking time')),
                        );
                      }
                    },
                    child: Text(
                      'Book Ambulance',
                      style: CustomTextStyles.titleSmall
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              )),
        ));
  }

  // Helper function to build text fields with controllers
  Widget _buildTextField(String label, String hint, {TextInputType keyboardType = TextInputType.text, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: CustomTextStyles.titleSmall,
          hintText: hint,
          hintStyle: CustomTextStyles.titleSmall,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  // Helper function to build a dropdown field
  Widget _buildDropdownField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: CustomTextStyles.titleSmall,
          border: const OutlineInputBorder(),
        ),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: CustomTextStyles.titleSmall,
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          selectedHostal = newValue;
        },
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }
}
