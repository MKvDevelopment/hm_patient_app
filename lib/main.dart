import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:IntelliMed/provider/AmbulanceProvider.dart';
import 'package:IntelliMed/provider/AppoitmentProvider.dart';
import 'package:IntelliMed/provider/AuthProvider.dart';
import 'package:IntelliMed/provider/StudentProvider.dart';
import 'package:IntelliMed/provider/doctorAvailablityProvider.dart';
import 'package:IntelliMed/provider/prescritpionProvider.dart';
import 'package:IntelliMed/route_constants.dart';
import 'package:IntelliMed/screen/HomeScreen.dart';
import 'package:IntelliMed/screen/SplashScreen.dart';
import 'package:IntelliMed/screen/ambulance/AmbulanceBookingListPage.dart';
import 'package:IntelliMed/screen/ambulance/bookAmobulance.dart';
import 'package:IntelliMed/screen/appoitment/appoitmentBooking.dart';
import 'package:IntelliMed/screen/appoitment/myAppoitment.dart';
import 'package:IntelliMed/screen/auth/ChangePasswordPage.dart';
import 'package:IntelliMed/screen/auth/LoginPage.dart';
import 'package:IntelliMed/screen/auth/RegisterPage.dart';
import 'package:IntelliMed/screen/home/HomePage.dart';
import 'package:IntelliMed/screen/prescription/myprescription.dart';
import 'package:IntelliMed/screen/profile/StudentDetailsPage.dart';
import 'package:IntelliMed/screen/profile/myProfile.dart';
import 'package:IntelliMed/screen/qrScan/qrScaner.dart';
import 'package:provider/provider.dart';

import 'common_code/custom_text_style.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthProviderr()),
    ChangeNotifierProvider(create: (_) => AmbulanceBookingProvider()),
    ChangeNotifierProvider(create: (_) => StudentProvider()),
    ChangeNotifierProvider(create: (_) => AppointmentProvider()),
    ChangeNotifierProvider(create: (_) => PrescriptionProvider()),
    ChangeNotifierProvider(create: (_) => DoctorProvider()),

  ],
    child: const MyApp(),));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 24.0,),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          labelStyle: const TextStyle(
            color: Colors.grey,
          ),
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          // Add more customization as needed
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding:  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textTheme:  const TextTheme(

          bodyLarge: TextStyle(color: Colors.white,fontSize: 20,fontFamily: 'Poppins'),
          bodyMedium: TextStyle(color: Colors.white,fontSize: 14),
          bodySmall: TextStyle(color: Colors.white,fontSize: 12),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),

            ),
          ),
          elevation:5,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: CustomTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 10,

        ),
        listTileTheme: const ListTileThemeData(
            titleTextStyle: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w500),
            subtitleTextStyle: TextStyle(color: Colors.white,fontSize: 14),
            iconColor: Colors.white,
            visualDensity: VisualDensity(
                horizontal: 0,
                vertical: -4
            ),

            textColor: Colors.white
        ),
        dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.w500),
          contentTextStyle: TextStyle(color: Colors.white,fontSize: 16),
        ),
      ),
      // Dark theme is inclided in the Full template
      themeMode: ThemeMode.light,
      initialRoute: splashScreenRoute,
      routes: {
        splashScreenRoute: (context) => SplashScreen(),
        logInScreenRoute: (context) => const LoginScreen(),
        homeScreenRoute: (context) => const HomeScreen(),
        homePageRoute: (context) => HomePage(),
        profileScreenRoute: (context) => const MyProfile(),
        sheduleScreenRoute: (context) => MyPrescription(),
        appoitmentScreenRoute: (context) => AppointmentScheduleScreen(),
        signUpScreenRoute: (context) => RegisterPage(),
        studentDetailScreenRoute: (context) => const StudentDetailsPage(),
        bookAmbulanceScreenRoute: (context) => const BookAmbulance(),
        ambulanceListScreenRoute: (context) => AmbulanceBookingList(),
        changePasswordScreenRoute: (context) => const ChangePasswordPage(),
        appoitmentBookingPage: (context) => AppointmentBookingPage(),
        qrScannerPage: (context) => QrScannerClass(),
      },
    );
  }
}