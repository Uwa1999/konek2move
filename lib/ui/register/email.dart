import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/ui/register/email_verification_screen.dart';
import 'package:konek2move/ui/splash/splash_screen.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isEmailValid = false;
  bool isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateInputs);
  }

  void _validateInputs() {
    final emailText = emailController.text.trim();

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
      final response = await api.emailVerification(emailController.text.trim());

      if (!mounted) return;

      if (response.retCode == '200') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EmailVerificationScreen(email: emailController.text.trim()),
          ),
        );
      } else {
        _showTopMessage(context, message: response.message, isError: true);
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
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Email Verification",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Please enter an email address that is not yet registered to continue.",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                  _buildLabel("Email"),
                  const SizedBox(height: 10),
                  _buildEmailField(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
            child: CustomButton(
              text: isLoading ? "Sending..." : "Continue",
              horizontalPadding: 0,
              color: isEmailValid ? kPrimaryColor : Colors.grey,
              textColor: Colors.white,
              onTap: isEmailValid && !isLoading ? _onSendCode : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const Text(
              "Verification",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Positioned(
              left: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SplashScreen()),
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.grey.shade600),
        hintText: "Enter your email",
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
