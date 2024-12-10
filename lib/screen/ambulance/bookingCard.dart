import 'package:flutter/material.dart';

import '../../common_code/custom_text_style.dart';

class BookingCard extends StatelessWidget {
  final dynamic booking;
  final VoidCallback onMoreDetail;

  const BookingCard({
    Key? key,
    required this.booking,
    required this.onMoreDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: Card(
        elevation: 6,
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Text(
                      booking.name,
                      style: CustomTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      'Time: ${booking.bookingTime}',
                      style: CustomTextStyles.titleSmall
                          .copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Image.asset(
                    'assets/images/tracking.png',
                    width: 50,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PickUp: ${booking.pickupLocation}",
                          style: CustomTextStyles.titleSmall,
                        ),
                        Text(
                          "Destination: ${booking.destination}",
                          style: CustomTextStyles.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(booking.confirmStatus=='pending')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: (){},
                        child: const Text('Booking Status:- Pending...'),
                      ),
                    ),
                  // Accept Button

                  // Complete Button
                  if (booking.confirmStatus == 'Accepted') ...[
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text('Status :- Accepted',style: CustomTextStyles.titleSmall.copyWith(color: Colors.green),)
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onMoreDetail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Get Detail's"),
                      ),
                    ),
                  ],
                  // Cancelled (Non-clickable) Button
                  if (booking.confirmStatus == 'Canceled') ...[
                    Text('Cancelled By Driver',style: CustomTextStyles.titleMedium.copyWith(color: Colors.red),),
                  ],
                  // Completed (Non-clickable) Button
                  if (booking.confirmStatus == 'Completed') ...[
                    Text('Booking Completed',style: CustomTextStyles.titleMedium.copyWith(color: Colors.green),),
                  ],

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}