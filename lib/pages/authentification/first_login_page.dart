import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:waajal_elek/config/theme.dart';
import 'package:waajal_elek/pages/authentification/otp_verif_et_change_password_page.dart';

import '../../config/apiconfig.dart';

class FirstLoginPage extends StatefulWidget {
  const FirstLoginPage({super.key});

  @override
  State<FirstLoginPage> createState() => _FirstLoginPageState();
}

class _FirstLoginPageState extends State<FirstLoginPage> {
  final TextEditingController phoneController     = TextEditingController();
  final TextEditingController matriculeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    matriculeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username   = matriculeController.text.trim();
    final phone      = phoneController.text.trim();

    if (username.isEmpty) {
      _showSnack("Veuillez entrer votre matricule");
      return;
    }

    if (phone.isEmpty) {
      _showSnack("Veuillez entrer votre numéro de téléphone");
      return;
    }

    // Retirer +221 si présent, garder uniquement les chiffres
    final cleanPhone = phone
        .replaceAll(RegExp(r'^\+221'), '')
        .replaceAll(' ', '');

    if (!RegExp(r'^\d{9}$').hasMatch(cleanPhone)) {
      _showSnack("Numéro invalide. Format attendu : 77XXXXXXX");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiConfig.post(
        ApiConfig.passwordResetRequest,
        {
          'username': username,
          'phone': cleanPhone,
        },
      );

      if (!mounted) return;

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Compte trouvé → navigation vers la page OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationPage(
              phoneNumber: '+221$cleanPhone',
              username: username,
            ),
          ),
        );
      } else {
        _showSnack(body['message'] ?? "Une erreur est survenue");
      }
    } on Exception catch (_) {
      _showSnack("Erreur de connexion au serveur");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
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
                  'assets/images/wajal euleuk-02.png',
                  width: 140,
                  height: 140,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Entrez votre matricule et votre numéro de téléphone "
                    "pour recevoir le code d'activation par SMS",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // ── Matricule
              TextField(
                controller: matriculeController,
                decoration: InputDecoration(
                  labelText: 'Matricule',
                  hintText: 'Ex: papa_pnd',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),

              const SizedBox(height: 20),

              // ── Numéro de téléphone
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: '77XXXXXXX',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),

              const SizedBox(height: 30),

              // ── Bouton
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                    FocusScope.of(context).unfocus();
                    _submit();
                  },
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    "Recevoir le code par SMS",
                    style: TextStyle(
                      color: AppTheme.backgroundColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 160),

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