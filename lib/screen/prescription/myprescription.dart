import 'package:flutter/material.dart';
import 'package:IntelliMed/common_code/custom_text_style.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../provider/prescritpionProvider.dart';

class MyPrescription extends StatefulWidget {
  const MyPrescription({super.key});

  @override
  State<MyPrescription> createState() => _MyPrescriptionState();
}

class _MyPrescriptionState extends State<MyPrescription> {
  @override
  void initState() {
    super.initState();
    // Fetch prescriptions only once when the widget is first created
    Provider.of<PrescriptionProvider>(context, listen: false)
        .fetchPrescriptions();

    Provider.of<PrescriptionProvider>(context, listen: false)
        .fetchDrPrescriptions();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.red,
              title: const Text('Prescription Records'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(30),
                child: Container(
                  // Change to your desired color
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    labelStyle: CustomTextStyles.titleSmall,
                    indicatorColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    isScrollable: false,
                    // Disable scrollable to ensure both tabs take equal space
                    tabs: [
                      Expanded(
                        child: Tab(
                          text: 'Docter Side',
                        ),
                      ),
                      Expanded(
                        child: Tab(
                          text: 'My Side',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: const TabBarView(
              children: [
                DoctorPrescription(),
                MySidePrescription(),
              ],
            )));
  }
}

class MySidePrescription extends StatelessWidget {
  const MySidePrescription();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: provider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.red,
                ))
              : provider.prescriptions.isEmpty
                  ? Center(
                      child: Text(
                      "No Prescription available",
                      style: CustomTextStyles.titleLarge,
                    ))
                  : RefreshIndicator(
                      onRefresh: () {
                        return provider.fetchPrescriptions();
                      },
                      child: ListView.builder(
                          itemCount: provider.prescriptions.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 12.0),
                              child: Card(
                                elevation: 6, // Adds depth to the card
                                color: Colors.red.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),

                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 15.0, horizontal: 15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Doctor:- ${provider.prescriptions[index].doctorName}',
                                        style: CustomTextStyles.titleMedium
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Date:- ${provider.prescriptions[index].date}',
                                        style: CustomTextStyles.titleSmall
                                            .copyWith(color: Colors.grey),
                                      ),
                                      Row(
                                        children: [
                                          Spacer(),
                                          ElevatedButton(
                                            onPressed: () {
                                              // provider.downloadFile(
                                              //   context,
                                              //   provider
                                              //       .prescriptions[index].fileLink,
                                              // );
                                              provider.downloadFile(
                                                context,
                                                provider
                                                    .prescriptions[index].fileLink
                                              );
                                            },
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0), // Adjust the radius as needed
                                                ),
                                              ),
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.white),
                                              // Sets the background color to white
                                              foregroundColor:
                                                  MaterialStateProperty.all(Colors
                                                      .black), // Sets the text and icon color
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.file_download),
                                                SizedBox(width: 8),
                                                Text('Download'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddDialog(context, provider);
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _showAddDialog(
      BuildContext context, PrescriptionProvider provider) async {
    String selectedDate = ''; // Initialized as an empty string
    var dateController = TextEditingController();
    var doctorController = TextEditingController();
    BuildContext contextt;

    showDialog(
        context: context,
        builder: (context) {
          contextt = context;
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text(
              'Add Prescription',
              style: CustomTextStyles.titleMedium,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: doctorController,
                  style:
                      CustomTextStyles.titleSmall.copyWith(color: Colors.black),
                  decoration: InputDecoration(
                    labelStyle: CustomTextStyles.titleSmall
                        .copyWith(color: Colors.black),
                    labelText: "Enter Doctor Name",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 1.0, horizontal: 5.0),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: dateController,
                  style:
                      CustomTextStyles.titleSmall.copyWith(color: Colors.black),
                  decoration: InputDecoration(
                    labelStyle: CustomTextStyles.titleSmall
                        .copyWith(color: Colors.black),
                    labelText: "Select Date",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 1.0, horizontal: 5.0),
                  ),
                  readOnly: true,
                  onTap: () async {
                    // Show date picker when tapped
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      // Format the date and set it directly to the text field controller
                      dateController.text =
                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      selectedDate =
                          dateController.text; // Set the selected date
                    }
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () => provider.pickFile(context),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    // Sets the background color to white
                    foregroundColor: MaterialStateProperty.all(
                        Colors.black), // Sets the text and icon color
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_file_outlined),
                      SizedBox(width: 8),
                      Text('Upload File'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(contextt),
                child: Text('Cancel', style: CustomTextStyles.titleSmall),
              ),
              OutlinedButton(
                onPressed: () async {
                  if (doctorController.text.isEmpty) {
                    ScaffoldMessenger.of(contextt).showSnackBar(
                      SnackBar(content: Text('Please Enter Doctor Name')),
                    );
                    return;
                  } else if (selectedDate.isEmpty) {
                    ScaffoldMessenger.of(contextt).showSnackBar(
                      SnackBar(content: Text('Please select a date')),
                    );
                    return;
                  } else if (provider.selectedFilePath == null) {
                    ScaffoldMessenger.of(contextt).showSnackBar(
                      SnackBar(
                          content: Text('Please select a prescription file')),
                    );
                    return;
                  } else {
                    Navigator.pop(context);
                    await provider.uploadPrescriptionWithFile(
                      context,
                      doctorController.text.trim(),
                      selectedDate,
                    );
                  }
                },
                child: Text('Save', style: CustomTextStyles.titleSmall),
              ),
            ],
          );
        });
  }
}

class DoctorPrescription extends StatelessWidget {
  const DoctorPrescription();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrescriptionProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            Scaffold(
              body: provider.drPrescriptions.isEmpty
                  ? Center(
                      child: Text(
                        "No Prescription available",
                        style: CustomTextStyles.titleLarge,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () {
                        return provider.fetchDrPrescriptions();
                      },
                      child: ListView.builder(
                        itemCount: provider.drPrescriptions.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 12.0,
                            ),
                            child: Card(
                              elevation: 6, // Adds depth to the card
                              color: Colors.red.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                  horizontal: 15.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Doctor:- ${provider.drPrescriptions[index].doctorName}',
                                      style: CustomTextStyles.titleMedium
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Date:- ${provider.drPrescriptions[index].date}',
                                      style: CustomTextStyles.titleSmall
                                          .copyWith(color: Colors.grey),
                                    ),
                                    Row(
                                      children: [
                                        const Spacer(),
                                        ElevatedButton(
                                          onPressed: () {
                                            provider.downloadFile(
                                              context,
                                              provider
                                                  .drPrescriptions[index].prescriptionDrUrl,
                                            );
                                          },
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  50.0,
                                                ), // Adjust the radius as needed
                                              ),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.white),
                                            // Sets the background color to white
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.black),
                                            // Sets the text and icon color
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.file_download),
                                              SizedBox(width: 8),
                                              Text('Download'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            if (provider.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  // Semi-transparent overlay
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
