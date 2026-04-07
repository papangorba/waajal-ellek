import 'package:flutter/material.dart';
import 'package:waajal_elek/config/theme.dart';
import 'package:waajal_elek/pages/authentification/otp_verification_page.dart';

class FirstLoginPage extends StatefulWidget {
  const FirstLoginPage({super.key});

  @override
  State<FirstLoginPage> createState() => _FirstLoginPageState();
}

class _FirstLoginPageState extends State<FirstLoginPage> {

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController matriculeController = TextEditingController();

  void validatePhoneNumber() {

    String phone = phoneController.text.trim();

    if (!phone.startsWith('+')) {
      phone = '+221$phone';
    }

    if (phone.length < 12 || !RegExp(r'^\+221\d{9}$').hasMatch(phone)) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Numéro invalide. Format attendu : 77XXXXXXX"),
        ),
      );

    } else {

      showOtpChoiceDialog(phone);

    }
  }

  void showOtpChoiceDialog(String phoneNumber) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(

        title: const Text(
          "Choisir la méthode de réception",
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        content: const Text(
          "Comment souhaitez-vous recevoir le code OTP ?",
          style: TextStyle(fontSize: 16),
        ),

        actions: [

          TextButton(
            onPressed: () {

              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OtpVerificationPage(
                    phoneNumber: phoneNumber,
                    receptionMethod: "SMS",
                  ),
                ),
              );
            },
            child: const Text("Par SMS"),
          ),

          TextButton(
            onPressed: () {

              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OtpVerificationPage(
                    phoneNumber: phoneNumber,
                    receptionMethod: "WhatsApp",
                  ),
                ),
              );
            },
            child: const Text("Par WhatsApp"),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(
        title: const Text(
          "Waajal Ëlëk - Activation",
          style: TextStyle(color: AppTheme.backgroundColor),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: AppTheme.backgroundColor),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 30),

              Center(
                child: Image.asset(
                  'assets/images/wadjal elek.png',
                  width: 140,
                  height: 140,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Entrez votre numéro de téléphone et votre matricule pour recevoir le code d'activation",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: matriculeController,
                decoration: InputDecoration(
                  labelText: 'Matricule',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),

                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    validatePhoneNumber();
                  },

                  child: const Text(
                    "Recevoir le code",
                    style: TextStyle(
                      color: AppTheme.backgroundColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ),
              ),

              const SizedBox(height: 40),

              const Center(
                child: Text(
                  "Waajal Ëlëk",
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}