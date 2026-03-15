import 'package:flutter/material.dart';
import 'package:waajal_elek/config/theme.dart';

class FirstLoginPage extends StatelessWidget {
  const FirstLoginPage({super.key});

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
                  'assets/images/forces_arm__e.jpg',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Entrez votre numéro de téléphone et matricule pour recevoir vos informations d'activation",
               // style: TextStyles.,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              TextField(
                //controller: phoneController,
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
                //controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Matricule',
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
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
                  " Waajal Ëlëk",
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
