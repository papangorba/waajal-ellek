import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:waajal_elek/config/theme.dart';
import '../../config/apiconfig.dart';
// import 'package:waajal_elek/pages/authentification/login_screen.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String username;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.username,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();

  // ── OTP
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
  List.generate(6, (_) => FocusNode());

  // ── Mot de passe
  final _newPasswordController     = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  bool _isResending    = false;

  String get _otp => _otpControllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (var c in _otpControllers) c.dispose();
    for (var f in _otpFocusNodes)  f.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Gestion cases OTP ────────────────────────────────────────────────────

  void _onDigitChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  // ─── Soumission ───────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_otp.length != 6) {
      _showSnack("Veuillez entrer les 6 chiffres du code OTP");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiConfig.post(
        ApiConfig.passwordResetConfirm,
        {
          'username'               : widget.username,
          'otp'                    : _otp,
          'newPassword'            : _newPasswordController.text,
          'newPasswordConfirmation': _confirmPasswordController.text,
        },
      );

      if (!mounted) return;

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ Succès
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text(
              "Succès",
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              body['message'] ?? "Mot de passe réinitialisé avec succès",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(builder: (_) => const LoginScreen()),
                  //   (route) => false,
                  // );
                },
                child: const Text("Se connecter"),
              ),
            ],
          ),
        );
      } else {
        // ❌ Erreur → snackbar + vider les cases OTP
        _showSnack(body['message'] ?? "Une erreur est survenue");
        for (var c in _otpControllers) c.clear();
        _otpFocusNodes[0].requestFocus();
      }
    } on Exception catch (_) {
      _showSnack("Erreur de connexion au serveur");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Renvoi du code ───────────────────────────────────────────────────────

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      final cleanPhone = widget.phoneNumber.replaceAll('+221', '');

      final response = await ApiConfig.post(
        ApiConfig.passwordResetRequest,
        {
          'username': widget.username,
          'phone'   : cleanPhone,
        },
      );

      if (!mounted) return;

      final body = jsonDecode(response.body);
      _showSnack(body['message'] ?? "Code renvoyé");
    } on Exception catch (_) {
      _showSnack("Erreur lors du renvoi du code");
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final otpBoxSize = (screenWidth - 48 - 60) / 6;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      appBar: AppBar(
        title: const Text(
          "Réinitialisation du mot de passe",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06, // 6% de l'écran
            vertical: 20,
          ),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── Icône + titre
                Icon(
                  Icons.sms_outlined,
                  size: screenHeight * 0.07,
                  color: AppTheme.primaryColor,
                ),

                SizedBox(height: screenHeight * 0.015),

                const Text(
                  "Code envoyé par SMS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "sur le numéro ${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),

                SizedBox(height: screenHeight * 0.03),

                // ── Label OTP
                const Text(
                  "Code OTP",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // ── 6 cases OTP responsive
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: otpBoxSize,
                      height: otpBoxSize * 1.2,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        // ✅ CORRECTION : style explicite pour rendre le texte visible
                        style: TextStyle(
                          fontSize: otpBoxSize * 0.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppTheme.primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppTheme.primaryColor.withOpacity(0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppTheme.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) => _onDigitChanged(value, index),
                      ),
                    );
                  }),
                ),

                // ── Renvoyer le code
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isResending ? null : _resendCode,
                    child: _isResending
                        ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text("Renvoyer le code"),
                  ),
                ),

                const Divider(height: 8),

                SizedBox(height: screenHeight * 0.02),

                // ── Section nouveau mot de passe
                const Text(
                  "Nouveau mot de passe",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                //username affiché séparément au-dessus du champ
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        "Compte : ${widget.username}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                //Champ nouveau mot de passe
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                //Confirmation mdp
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // Indicateur règle
                _PasswordRule(
                  label: "Au moins 8 caractères",
                  met: _newPasswordController.text.length >= 8,
                ),

                SizedBox(height: screenHeight * 0.04),

                // ── Bouton confirmer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.018,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submit,
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
                      "Confirmer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

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
      ),
    );
  }
}

// ── Widget indicateur règle mot de passe ─────────────────────────────────────

class _PasswordRule extends StatelessWidget {
  final String label;
  final bool met;

  const _PasswordRule({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: met ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: met ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}