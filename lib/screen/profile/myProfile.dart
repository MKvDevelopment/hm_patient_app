import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common_code/custom_text_style.dart';
import '../../provider/StudentProvider.dart';
import '../../route_constants.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
@override
  void didChangeDependencies() {
    super.didChangeDependencies();
   Provider.of<StudentProvider>(context).fetchStudent(context);

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        return Scaffold(
            backgroundColor: Colors.red,
            body:  Column(
                    children: [
                      Container(
                        color: Colors.red,
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 60),
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child:  studentProvider.student?.imgUrl != null &&
                                    studentProvider.student!.imgUrl.isNotEmpty
                                    ? Image.network(
                                  studentProvider.student!.imgUrl,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                )
                                    : Icon(Icons.person,
                                    size: 80, color: Colors.grey),
                              )
                            ),
                            SizedBox(height: 10),
                            Text(
                              studentProvider.student?.name.isNotEmpty == true
                                  ? studentProvider.student!.name
                                  : 'Student Name',
                              style: CustomTextStyles.titleLarge
                                  .copyWith(color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Batch ${studentProvider.student?.year.isNotEmpty == true ? studentProvider.student!.year : '23'} '
                              '| Branch ${(studentProvider.student?.branch.isNotEmpty == true ? studentProvider.student!.branch : ' CSE')} '
                              '| ${studentProvider.student?.gender.isNotEmpty == true ? studentProvider.student!.gender : ' Male'}',
                              style: CustomTextStyles.titleSmall
                                  .copyWith(color: Colors.white),
                            ),
                            Text(
                              'Blood Group - ${studentProvider.student?.bloodGroup ?? 'A+'}',
                              style: CustomTextStyles.titleSmall
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      studentProvider.isLoading
                          ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ))
                          :

                      Expanded(
                          child: Container(
                        color: Colors.grey[200],
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading:
                                      Icon(Icons.person, color: Colors.red),
                                  title: Text(
                                    'Profile',
                                    style: CustomTextStyles.titleMedium,
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, studentDetailScreenRoute);
                                  },
                                ),
                                Divider(),
                                ListTile(
                                  leading:
                                      Icon(Icons.refresh, color: Colors.green),
                                  title: Text(
                                    'Reset Password',
                                    style: CustomTextStyles.titleMedium,
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, changePasswordScreenRoute);
                                  },
                                ),
                                Divider(),
                                ListTile(
                                  leading:
                                      Icon(Icons.logout, color: Colors.red),
                                  title: Text(
                                    'Logout',
                                    style: CustomTextStyles.titleMedium,
                                  ),
                                  onTap: () {
                                    _showLogoutDialog(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ))
                    ],
                  ));
      },
    );
  }

  // Function to show the logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: CustomTextStyles.titleLarge,
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: CustomTextStyles.titleMedium,
          ),
          actions: <Widget>[
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            // Confirm button
            TextButton(
              onPressed: () {
                // Perform the logout action here
                _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Logout logic (you can modify this as per your application needs)
  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    // You can handle the actual logout here (clear session, tokens, etc.)
    Navigator.of(context).pop(); // Close the dialog
    Navigator.pushReplacementNamed(context, logInScreenRoute);
  }
}
