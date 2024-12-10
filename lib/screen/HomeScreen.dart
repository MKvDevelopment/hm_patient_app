import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:IntelliMed/screen/profile/myProfile.dart';
import 'ambulance/AmbulanceBookingListPage.dart';
import 'appoitment/myAppoitment.dart';
import 'home/HomePage.dart';
import 'prescription/myprescription.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {

  int _currentIndex = 0; // Current selected index (abhi kaun sa selected h)

  // Pages to display for each tab (har item ke liye alag page)
  final List<Widget> _pages = [
    HomePage(),
    MyPrescription(),
    AmbulanceBookingList(),
    AppointmentScheduleScreen(),
    MyProfile()
  ];
  late NotchBottomBarController _notchBottomBarController;

  @override
  void initState() {
    super.initState();

    _notchBottomBarController = NotchBottomBarController();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // For mobile, add Drawer
      body: _pages[_currentIndex], // Display selected page
      bottomNavigationBar:  _buildNotchBottomBar(),
      // Show BottomNavigationBar for mobile
    );
  }

  // Build the Animated Notch Bottom Bar
  AnimatedNotchBottomBar _buildNotchBottomBar() {
    return AnimatedNotchBottomBar(
      notchColor: Colors.red,
      bottomBarItems: [
        BottomBarItem(
          inActiveItem: Icon(Icons.home_outlined, color: Colors.grey),
          activeItem: Icon(Icons.home, color: Colors.white),
          itemLabel: 'Home',
        ),
        BottomBarItem(
          inActiveItem: Icon(Icons.favorite_border, color: Colors.grey),
          activeItem: Icon(Icons.favorite, color: Colors.white),
          itemLabel: 'Prescriptions',
        ),
        BottomBarItem(
          inActiveItem: Image.asset('assets/images/ambulance.png'),
          activeItem: Image.asset('assets/images/ambulance.png'),
          itemLabel: 'Ambulance',
        ),
        BottomBarItem(
          inActiveItem: Icon(Icons.calendar_month, color: Colors.grey),
          activeItem: Icon(Icons.calendar_month, color: Colors.white),
          itemLabel: 'Appointments',
        ),
        BottomBarItem(
          inActiveItem: Icon(Icons.person, color: Colors.grey),
          activeItem: Icon(Icons.person, color: Colors.white),
          itemLabel: 'Profile',
        ),
      ],
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      // Optional: Set the current index
      // currentIndex: _selectedIndex,
      notchBottomBarController: _notchBottomBarController,
      kIconSize: 25.0,
      kBottomRadius: 25.0,
      showBottomRadius: true,
      showBlurBottomBar: true,
      showLabel: false,
    );
  }


  @override
  void dispose() {
    _notchBottomBarController.dispose();
    super.dispose();
  }

}
