import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:IntelliMed/common_code/custom_text_style.dart';
import 'package:IntelliMed/route_constants.dart';
import 'package:IntelliMed/screen/ambulance/AmbulanceBookingModel.dart';
import 'package:IntelliMed/screen/ambulance/bookingCard.dart';
import 'package:provider/provider.dart';
import '../../common_code/custome_floating_action_button.dart';
import '../../provider/AmbulanceProvider.dart';

class AmbulanceBookingList extends StatefulWidget {
  @override
  _AmbulanceBookingListState createState() => _AmbulanceBookingListState();
}

class _AmbulanceBookingListState extends State<AmbulanceBookingList> {

  @override
  void initState() {

    // Fetch bookings when widget is initialized
    Provider.of<AmbulanceBookingProvider>(context, listen: false)
        .fetchBookings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final  ambulanceBookingProvider= Provider.of<AmbulanceBookingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambulance Booking:-"),
      ),
      body: ambulanceBookingProvider.isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).appBarTheme.backgroundColor))
          : ambulanceBookingProvider.bookings.isEmpty
              ? Center(
                  child: Text(
                  "No bookings available",
                  style: CustomTextStyles.titleLarge,
                )) // Show this text when list is empty
              : ListView.separated(
                  itemCount: ambulanceBookingProvider.bookings.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final booking = ambulanceBookingProvider.bookings[index];
                    return BookingCard(
                        booking: booking,
                        onMoreDetail: (){
                          _showDriverDetailsBottomSheet(context,booking);
                        },

                    );
                  },

                ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, bookAmbulanceScreenRoute);
        },
        icon: Icons.add,
      ),
    );
  }
  void _showDriverDetailsBottomSheet(BuildContext context, AmbulanceModel booking) async {
    try {
      // Get provider
      final ambulanceProvider = Provider.of<AmbulanceBookingProvider>(context, listen: false);

      // Validate driver ID
      if (booking.driverId.isEmpty) {
        throw Exception("Invalid driver ID");
      }

      // Fetch driver details
      final driverDetails = await ambulanceProvider.fetchDriverDetails(booking.driverId);

      // Validate fetched data
      if (driverDetails.isEmpty) {
        throw Exception("Driver details not found");
      }

      // Close the loading bottom sheet
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show the bottom sheet with driver details
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20,),
                Text(
                  'Ambulance Has Been Booked!',
                  style: CustomTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                  ),
                ),
                Image.asset('assets/images/ambulance.png',height: 150,width: 150,),
                Text(
                  'Arriving in 15 mins',
                  style: CustomTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver Details:',
                      style: CustomTextStyles.titleLarge.copyWith(
                          color: Colors.red
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage('assets/images/driver_img.jpg'),
                        ),

                        SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${driverDetails['name']}',
                              style: CustomTextStyles.titleMedium.copyWith(
                                  color: Colors.black
                              ),
                            ),
                            Text(
                              'Driver',
                              style: CustomTextStyles.titleSmall.copyWith(
                                  color: Colors.grey
                              ),
                            ),
                            Text(
                              '${driverDetails['mobileNo']}',
                              style: CustomTextStyles.titleSmall.copyWith(
                                  color: Colors.black
                              ),
                            ),
                            RatingBar.builder(
                              initialRating: 0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.red),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  // userRating = rating;
                                });
                              },
                            ),

                          ],
                        )
                      ],
                    ),

                  ],
                ),
                Divider(),
                const SizedBox(height: 20),

              ],
            ),
          );
        },
      );
    } catch (e) {
      // Close the loading bottom sheet if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }

  }



}
