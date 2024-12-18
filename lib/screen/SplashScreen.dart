import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

import '../route_constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    await Future.delayed(Duration(seconds: 3)); // Show splash for 2 seconds

    User? user = _auth.currentUser;
    if (user != null) {
      // If user is logged in, navigate to home
      Navigator.pushReplacementNamed(context, homeScreenRoute);
    } else {
      // If user is not logged in, navigate to login
      Navigator.pushReplacementNamed(context, logInScreenRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/anim/splash_animation.json', // Path to your Lottie animation
          fit: BoxFit.cover,
          repeat: false,
        ),
      ),
    );
  }
}
