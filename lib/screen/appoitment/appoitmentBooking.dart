import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../common_code/custom_text_style.dart';
import '../../constants.dart';
import '../../provider/AppoitmentProvider.dart';
import 'AppointmentModel.dart';

class AppointmentBookingPage extends StatefulWidget {
  const AppointmentBookingPage({super.key});

  @override
  _AppointmentBookingPageState createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final _formKey = GlobalKey<FormState>();
  String? userId=FirebaseAuth.instance.currentUser?.uid;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  late String seletctedDoctor;
  late String selectedCategory;

  // Method to select date
  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // Method to select time
  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    return Scaffold(
      appBar: AppBar(title:const  Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCategoryDropdownField('Select Category', doctorCategory),
              const SizedBox(height: 10,),
              _buildDoctorDropdownField('Select Doctor', doctorList),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedDate != null
                        ? '${selectedDate!.toLocal()}'.split(' ')[0]
                        : 'Select Date',
                    style: CustomTextStyles.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedTime != null
                        ? 'Time: ${selectedTime!.format(context)}'
                        : 'Select Time',
                    style: CustomTextStyles.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              appointmentProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      selectedDate != null &&
                      selectedTime != null) {
                    var uuid = const Uuid().v4();
                    final appointment = AppointmenModel(
                      id: uuid.replaceAll('-', ''),
                      doctorName: seletctedDoctor,
                      verification: 'pending',
                      category: selectedCategory,
                      prescriptionDrUrl: '',
                      date: "${selectedDate!.toLocal()}".split(' ')[0],
                      time: selectedTime!.format(context),
                      status: 'pending',
                      userId: userId,
                    );
                    appointmentProvider.addAppointment(appointment);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Appointment booked successfully!'),
                    ));
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please fill in all fields'),
                    ));
                  }
                },
                child: const Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCategoryDropdownField(String label, List<String> options) {
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
          selectedCategory = newValue!;
        },
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }
  Widget _buildDoctorDropdownField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: CustomTextStyles.titleSmall,
          border:const OutlineInputBorder(),
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
          seletctedDoctor = newValue!;
        },
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }
}
