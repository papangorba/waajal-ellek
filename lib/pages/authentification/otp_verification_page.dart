import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pndtech_client/mainScreen/main_screen.dart';
import 'package:pndtech_client/pages/home_page.dart';
import 'package:pndtech_client/theme/theme.dart';
import 'package:pndtech_client/global/global.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String receptionMethod;
  //final String verificationId;

  const OtpVerificationPage({
    Key? key,
    required this.phoneNumber,
    required this.receptionMethod,
  //  required this.verificationId,
  }) : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  Future<void> verifyOtp() async {
    /////code otp fixe a 000000/////////////////
    String smsCode = otpController.text.trim();
    if (smsCode != "000000") {
      Fluttertoast.showToast(msg: "Code incorrect !");
      return;
    }
    try {
      // Connexion Firebase anonyme dans tous les cas
      UserCredential cred = await FirebaseAuth.instance.signInAnonymously();
      User? user = cred.user;

      if (user == null) {
        Fluttertoast.showToast(msg: "Erreur de connexion anonyme.");
        return;
      }

      currentFirebaseUser = user;
      final userRef = FirebaseDatabase.instance.ref("clients");
      final snapshot = await userRef.orderByChild("phone").equalTo(widget.phoneNumber).get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map;
        String oldKey = data.keys.first;
        Map<dynamic, dynamic> clientData = data[oldKey];

        await userRef.child(user.uid).set({
          ...clientData,
          "uid": user.uid,
        });

        await userRef.child(oldKey).remove();

        String prenom =clientData["prenom"] ?? "Client";
        Fluttertoast.showToast(msg: "Bienvenue $prenom !");
      } else {
        // 🆕 Nouvel utilisateur → pas d'enregistrement maintenant
        Fluttertoast.showToast(msg: "Bienvenue nouveau client !");
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur: $e");
    }

  /////////////Methode a utiliser si le code otp est verifier par firebase/////////
  //  String smsCode = otpController.text.trim();
  //  try {
  //    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
  //      verificationId: widget.verificationId,
  //      smsCode: smsCode,
   //   );

  //    UserCredential userCredential =
  //    await fAuth.signInWithCredential(phoneAuthCredential);
   //   User? user = userCredential.user;

  //    if (user != null) {
   //     currentFirebaseUser = user;
   //     Fluttertoast.showToast(msg: "✅ Vérification réussie !");

   //     Navigator.pushReplacement(
   //       context,
   //       MaterialPageRoute(builder: (context) => HomePage()),
   //     );
  //    }
   // } on FirebaseAuthException catch (e) {
   //   Fluttertoast.showToast(
   //     msg: "❌ Échec de vérification : ${e.message}",
   //     toastLength: Toast.LENGTH_LONG,
  //    );
  //  } catch (e) {
   //   Fluttertoast.showToast(
   //     msg: "❌ Erreur inattendue : $e",
   //     toastLength: Toast.LENGTH_LONG,
   //   );
   // }


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Vérification OTP",
          style: TextStyle(color: AppColors.white),

        ),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              "Un code vous a été envoyé",
              style:  TextStyle(color: AppColors.primary,fontSize: 18,fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "sur ${widget.phoneNumber} via ${widget.receptionMethod}",
              style: const TextStyle(fontSize: 16,color: AppColors.secondary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: "Entrer le code OTP",
                hintStyle: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
                labelStyle: AppTextStyles.formLabel,
                prefixStyle: AppTextStyles.inputText,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
             // width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: verifyOtp,
                child: const Text(
                  "Vérifier",
                  style: TextStyle(color: AppColors.white,fontSize: 22,fontWeight: FontWeight.bold)
                  ,
                ),
              ),
            ),
            const Spacer(),
            const Text("100% Sénégalais - Ñu Demm by PndTech", style: TextStyle(color:AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
