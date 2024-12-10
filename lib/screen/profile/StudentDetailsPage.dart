import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common_code/custom_elevated_button.dart';
import '../../common_code/custom_row.dart';
import '../../provider/StudentProvider.dart';
import '../auth/StudentModel.dart';

class StudentDetailsPage extends StatefulWidget {
  const StudentDetailsPage({super.key});

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var rollNoController = TextEditingController();
  var branchController = TextEditingController();
  var yearController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  var bloodController = TextEditingController();
  var genderController = TextEditingController();
  var addressController = TextEditingController();

  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      final studentProvider =
          Provider.of<StudentProvider>(context, listen: false);
      final student = studentProvider.student;

      if (student != null) {
        nameController.text = student.name;
        rollNoController.text = student.rollNo;
        branchController.text = student.branch;
        yearController.text = student.year;
        emailController.text = student.email ?? '';
        mobileController.text = student.mobileNo;
        bloodController.text = student.bloodGroup;
        genderController.text = student.gender;
        addressController.text = student.address;
      }

      isInitialized = true; // Mark as initialized
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(builder: (context, provider, child) {
      return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Student Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.red,
                ))
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.red,
                                child: ClipOval(
                                  child: provider.student?.imgUrl != null &&
                                          provider.student!.imgUrl.isNotEmpty
                                      ? Image.network(
                                          provider.student!.imgUrl,
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                        )
                                      : provider.imageUrl != null &&
                                              provider.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              provider.imageUrl!,
                                              fit: BoxFit.cover,
                                              width: 120,
                                              height: 120,
                                            )
                                          : Icon(Icons.person,
                                              size: 100, color: Colors.white),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                  // Background color of the button
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.6),
                                      // Glow effect color
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    provider.pickImage(context);
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white, // Icon color
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        EditableRow(
                          labelText: 'Name',
                          hintText: 'Enter Name',
                          enabled: true,
                          inputType: TextInputType.name,
                          controller: nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        EditableRow(
                          controller: rollNoController,
                          labelText: 'Roll No',
                          enabled: true,
                          hintText: 'Enter Roll No',
                          inputType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your roll no';
                            }
                            return null;
                          },
                        ),
                        EditableRow(
                          controller: branchController,
                          labelText: 'Branch',
                          hintText: 'Enter Branch',
                          enabled: true,
                          inputType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your branch';
                            }
                            return null;
                          },
                        ),
                        EditableRow(
                          controller: yearController,
                          labelText: 'Year',
                          hintText: 'Enter Year',
                          enabled: true,
                          inputType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your year';
                            }
                            return null;
                          },
                        ),
                        EditableRow(
                          controller: emailController,
                          labelText: 'Email ID',
                          enabled: false,
                          hintText: 'Enter Email ID',
                          inputType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        EditableRow(
                          controller: mobileController,
                          labelText: 'Mobile No',
                          enabled: true,
                          hintText: 'Enter Mobile No',
                          inputType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your mobile no';
                            }
                            return null;
                          },
                        ),
                        EditableRow(
                          controller: bloodController,
                          labelText: 'Blood Group',
                          enabled: true,
                          hintText: 'Enter Blood Group',
                          inputType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your blood group';
                            }
                            return null;
                          },
                        ),
                        EditableRow(
                          controller: genderController,
                          labelText: 'Gender',
                          enabled: true,
                          hintText: 'Enter Gender',
                          inputType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your gender';
                            }
                            return null;
                          },
                        ),
                        EditableRow(
                          controller: addressController,
                          labelText: 'Permanent Address',
                          enabled: true,
                          hintText: 'Enter Permanent Address',
                          inputType: TextInputType.streetAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your permanent address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        provider.isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor,
                                ),
                              )
                            : CustomElevatedButton(
                                labelText: Text('Update'),
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    final updatedStudent = StudentModel(
                                      studentId: provider.student!.studentId,
                                      // Ensure you pass the student ID
                                      name: nameController.text.trim(),
                                      rollNo: rollNoController.text.trim(),
                                      branch: branchController.text.trim(),
                                      year: yearController.text.trim(),
                                      imgUrl: provider.imageUrl ??
                                          provider.student!.imgUrl,
                                      email: emailController.text.trim(),
                                      mobileNo: mobileController.text.trim(),
                                      bloodGroup: bloodController.text.trim(),
                                      gender: genderController.text.trim(),
                                      address: addressController.text.trim(),
                                    );

                                    // Call the provider's updateStudent method
                                    provider
                                        .updateStudent(updatedStudent)
                                        .then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Student information updated successfully')),
                                      );
                                    }).catchError((error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to update student information')),
                                      );
                                    });
                                  }
                                })
                      ],
                    ),
                  ),
                ));
    });
  }
}
