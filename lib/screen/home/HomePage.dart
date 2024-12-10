import 'package:flutter/material.dart';
import 'package:IntelliMed/common_code/custom_text_style.dart';
import 'package:IntelliMed/screen/appoitment/AppointmentModel.dart';
import 'package:IntelliMed/screen/home/doctorModel.dart';
import 'package:IntelliMed/screen/home/sheduleTimeChip.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_code/custome_floating_action_button.dart';
import '../../provider/AppoitmentProvider.dart';
import '../../provider/doctorAvailablityProvider.dart';
import '../../route_constants.dart';
import 'nightSheduleTimeChip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? email,name,rollNo,imgUrl;

  @override
  void initState() {
    super.initState();
    Provider.of<DoctorProvider>(context, listen: false).fetchDoctors();
    // Fetch bookings when widget is initialized
    Provider.of<AppointmentProvider>(context, listen: false)
        .fetchAppointments();
    getUserDataFromPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.red, // Customize your AppBar background color
        title: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: imgUrl != null && imgUrl!.isNotEmpty
                    ? Image.network(
                  imgUrl!,
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // Image loaded successfully
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.red,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red),
                )
                    : Image.asset(
                  'assets/icons/doctorIcon.png',
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),

            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              // Align text vertically
              children: [
                Text(
                  name ?? "Name",
                  style: CustomTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  email ?? "test@gmail.com",
                  style:
                      CustomTextStyles.titleSmall.copyWith(color: Colors.white),
                ),
                Text(
                  rollNo ?? "12345678",
                  style:
                  CustomTextStyles.titleSmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            iconSize: 40,
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {

              Navigator.pushNamed(context, qrScannerPage);
            },
          ),
          SizedBox(width: 10,)
        ],

      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selection
              Text(
                "Time Schedule:-",
                style: CustomTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5), // Add some space between text and dropdowns
              // First Dropdown
              Container(
                alignment: Alignment.topLeft,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red),
                  color: Colors.red.shade50,
                ),
                child: ScheduleDropdown(),
              ),
              Divider(color: Colors.grey),
              Text(
                "Night Time Schedule:-",
                style: CustomTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5), // Space between the dropdowns
              // Second Dropdown
              Container(
                alignment: Alignment.topLeft,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red),
                  color: Colors.red.shade50,
                ),
                child: NightScheduleDropdown(),
              ),
              Divider(color: Colors.grey),
              SizedBox(
                height: 240,
                child: Consumer<DoctorProvider>(
                  builder: (context, appoitmentProvider, child) {
                    final allDoctorsList = appoitmentProvider.doctors;

                    return allDoctorsList.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Current Availability (${allDoctorsList.length})",
                                style: CustomTextStyles.titleSmall
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 220,
                                width: double.infinity,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: allDoctorsList.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: _availabilityCard(
                                          allDoctorsList[index]),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              'No Doctors Available',
                              style: CustomTextStyles.titleMedium,
                            ),
                          );
                  },
                ),
              ),
              Divider(
                color: Colors.grey,
              ),
              Consumer<AppointmentProvider>(
                  builder: (context, appoitmentProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Upcoming Appointments
                    Text(
                      "Your Appointments",
                      style: CustomTextStyles.titleSmall
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    appoitmentProvider.pendingAppointments.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            // Disables internal scrolling

                            itemCount:
                                appoitmentProvider.pendingAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment =
                                  appoitmentProvider.pendingAppointments[index];
                              return _appointmentCard(appointment);
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Center(
                              child: Text('No Pending Appointments',
                                  style: CustomTextStyles.titleMedium),
                            ),
                          ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, appoitmentBookingPage);
        },
        icon: Icons.add,
      ),
    );
  }

  Widget _availabilityCard(DoctorModel appointment) {
    return Card(
      color: Colors.blue.shade50,
      elevation: 5,
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [


            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: appointment.imgUrl.isNotEmpty
                    ? Image.network(
                  appointment.imgUrl,
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child; // Image loaded successfully
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.red,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red),
                )
                    : Image.asset(
                  "assets/images/gents.png",
                  fit: BoxFit.contain,
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),


            Text(appointment.doctorName,
                style: CustomTextStyles.titleSmall.copyWith(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            Text(appointment.department,
                style:
                    CustomTextStyles.titleSmall.copyWith(color: Colors.grey)),
            Text("Experience: ${appointment.experience} years",
                style:
                    CustomTextStyles.titleSmall.copyWith(color: Colors.grey)),
            appointment.availabilityStatus.toString() == "true"
                ? Text("Available\n${appointment.availabilityTime}",
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.titleSmall
                        .copyWith(color: Colors.green))
                : Text("Not Available",
                    style: CustomTextStyles.titleSmall
                        .copyWith(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _appointmentCard(AppointmenModel appointment) {
    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blue.shade50,
              //  backgroundImage: AssetImage("assets/images/gents_doctor.png"),
              child: Image.asset(
                "assets/images/lady.png",
                width: 100, // Adjust width to match the radius
                height: 100, // Adjust height to match the radius
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment.doctorName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: CustomTextStyles.titleSmall.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  Text("Category: ${appointment.category}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: CustomTextStyles.titleSmall
                          .copyWith(color: Colors.grey)),
                  Text("Date: ${appointment.date}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: CustomTextStyles.titleSmall
                          .copyWith(color: Colors.grey)),
                  Text("Time: ${appointment.time}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: CustomTextStyles.titleSmall
                          .copyWith(color: Colors.grey)),
                  OutlinedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                          appointment.status == 'completed'
                              ? Colors.green
                              : Colors.orange),
                      // Sets the background color to white
                      foregroundColor: WidgetStateProperty.all(
                          Colors.white), // Sets the text and icon color
                    ),
                    onPressed: () {},
                    child: Text(appointment.status),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getUserDataFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      name = prefs.getString('name');
      rollNo = prefs.getString('rollNo');
      imgUrl = prefs.getString('imgUrl');
    });
  }
}
