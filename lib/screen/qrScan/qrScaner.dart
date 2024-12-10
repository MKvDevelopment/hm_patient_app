import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:IntelliMed/common_code/custom_text_style.dart';
import 'package:IntelliMed/constants.dart';
import 'package:IntelliMed/provider/StudentProvider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QrScannerClass extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QrScannerClass> {
  String? qrCodeResult;
  bool isScanned = false; // Flag to check if QR code has been scanned

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Scanner"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: scanCode(context),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  side: const BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    qrCodeResult = null;
                  });
                },
                child: Text(
                  "Scan a QR Code",
                  style: CustomTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRCodeResultDialog(BuildContext context, String resultt) {
    FirebaseAuth auth = FirebaseAuth.instance;
    List<String> result = resultt.split(',');

    if (auth.currentUser!.uid == result[0]) {
      flushBarSuccessMsg(context, "Success!", "Verified Successfully.");

      final studentProvider = Provider.of<StudentProvider>(context, listen: false);

      studentProvider.updateAppoitmentDetails(context,result[1]);

      // Fetch student data before showing the dialog
      studentProvider.fetchStudent(context).then((_) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: studentProvider.isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: studentProvider.student!.imgUrl.isNotEmpty
                        ? NetworkImage(studentProvider.student!.imgUrl)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: studentProvider.student!.imgUrl.isEmpty
                        ? Icon(Icons.person, size: 70, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Student Info
                  Text(
                    studentProvider.student!.name,
                    style: CustomTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text("Roll No: ${studentProvider.student!.rollNo}",
                      style: CustomTextStyles.titleMedium,),
                  Text("Mobile: ${studentProvider.student!.mobileNo}",
                      style: CustomTextStyles.titleMedium),
                  Text("Branch: ${studentProvider.student!.branch}",
                      style: CustomTextStyles.titleMedium),

                  const SizedBox(height: 16),

                  // Close Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Close",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    } else {
      // Show failure dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Failed!',
            style: CustomTextStyles.titleLarge,
          ),
          content: Text(
            'You are Not Verified',
            style: CustomTextStyles.titleMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                isScanned = false; // Reset scanning flag
              },
              child: Text(
                "Go Back!",
                style: CustomTextStyles.titleMedium,
              ),
            ),
          ],
        ),
      );
    }
  }


  Widget scanCode(BuildContext context) {
    return MobileScanner(
      onDetect: (barcodeCapture) {
        if (isScanned) return; // Skip if QR has already been scanned

        final barcode = barcodeCapture.barcodes.first;
        if (barcode.rawValue != null) {
          final String code = barcode.rawValue!;
          setState(() {
            qrCodeResult = code;
            isScanned = true; // Mark as scanned to avoid multiple scans
          });
          _showQRCodeResultDialog(context, code);
        } else {
          debugPrint("Failed to scan QR Code");
        }
      },
    );
  }
}
