import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_appbar.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/core/widgets/custom_fields.dart';
import 'package:konek2move/ui/login/forgot_password_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController forgotEmailController = TextEditingController();
  bool isEmailValid = false;
  bool isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    forgotEmailController.addListener(_validateInputs);
  }

  void _validateInputs() {
    final emailText = forgotEmailController.text.trim();

    final emailValid =
        emailText.isNotEmpty && emailText.toLowerCase().endsWith('@gmail.com');

    setState(() {
      isEmailValid = emailValid;
    });
  }

  Future<void> _onSendCode() async {
    if (!isEmailValid) return;

    setState(() {
      isLoading = true;
    });

    try {
      final ApiServices api = ApiServices();
      final response = await api.emailVerification(
        forgotEmailController.text.trim(),
      );

      if (!mounted) return;

      if (response.retCode == '200') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ForgotEmailVerificationScreen(
              email: forgotEmailController.text.trim(),
            ),
          ),
        );
      } else {
        _showTopMessage(context, message: response.error, isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      _showTopMessage(
        context,
        message: 'Failed to send OTP: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showTopMessage(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final color = isError ? Colors.redAccent : Colors.green;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: color,
      icon: Icon(icon, color: Colors.white, size: 28),
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 500),
    ).show(context);
  }

  @override
  void dispose() {
    forgotEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------- APP BAR ----------
      appBar: const CustomAppBar(
        title: "Forgot Password",
        leadingIcon: Icons.arrow_back,
      ),

      // ---------- BODY ----------
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Forgot Password",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Please enter the registered mobile number to reset your password",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),

            const SizedBox(height: 32),

            CustomInputField(
              label: "Email",
              hint: "Enter your email",
              controller: forgotEmailController,
              prefixSvg: "assets/icons/email.svg",
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),

      // ---------- BOTTOM BUTTON ----------
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    // Detect 3-button navigation (no safe inset)
    final bool isThreeButtonNav = safeBottom == 0;

    return SafeArea(
      bottom: false, // ← REQUIRED so 3-button nav does NOT cover the UI
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,

            // ⬇️ FINAL BOTTOM PADDING FIX
            isThreeButtonNav
                ? 16 // 3-button navigation → add 16 so button is visible
                : safeBottom + 24, // gesture navbar → add small buffer
          ),
          child: CustomButton(
            text: isLoading ? "Sending..." : "Continue",
            horizontalPadding: 0,
            color: isEmailValid ? kPrimaryColor : Colors.grey.shade400,
            textColor: Colors.white,
            onTap: isEmailValid && !isLoading ? _onSendCode : null,
          ),
        ),
      ),
    );
  }
}
