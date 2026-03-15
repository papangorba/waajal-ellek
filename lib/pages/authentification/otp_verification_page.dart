import 'package:flutter/material.dart';
import 'package:waajal_elek/config/theme.dart';

class OtpVerificationPage extends StatefulWidget {

  final String phoneNumber;
  final String receptionMethod;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.receptionMethod,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {

  final TextEditingController otpController = TextEditingController();

  void verifyOtp() {

    String otp = otpController.text.trim();

    if (otp.length != 6) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Code OTP invalide"),
        ),
      );

      return;
    }

    // ici tu pourras appeler ton API

    print("OTP saisi : $otp");
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(
        title: const Text(
          "Vérification OTP",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const Spacer(),

            const Text(
              "Un code vous a été envoyé",
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "sur ${widget.phoneNumber} via ${widget.receptionMethod}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,

              decoration: InputDecoration(
                hintText: "Entrer le code OTP",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),

                onPressed: verifyOtp,

                child: const Text(
                  "Vérifier",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextButton(
              onPressed: (){},
              child: const Text(
                "Renvoyer le code",
                style: TextStyle(fontSize: 16),
              ),
            ),


            const Spacer(),

            const Text(
              "Application Waajal Ëlëk",
              style: TextStyle(color: AppTheme.primaryColor),
            ),

          ],
        ),
      ),
    );
  }
}