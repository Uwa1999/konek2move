import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
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
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(top), // ⭐ pass top padding to header
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ), // ⭐ clean page padding
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
                  ), // ⭐ consistent bottom spacing before button
                ],
              ),
            ),
          ),

          // ⭐ Dynamic + consistent footer spacing
          Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: bottom + 16, // ⭐ dynamic safe-area + consistent spacing
            ),
            child: CustomButton(
              text: isLoading ? "Sending..." : "Continue",
              horizontalPadding: 0,
              color: isEmailValid ? kPrimaryColor : Colors.grey.shade400,
              textColor: Colors.white,
              onTap: isEmailValid && !isLoading ? _onSendCode : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double top) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: top + 12, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // ⭐ softer & cleaner
            blurRadius: 16, // ⭐ smooth shadow
            offset: const Offset(0, 4), // ⭐ subtle elevation
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            "Forgot Password",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          Positioned(
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.arrow_back, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
