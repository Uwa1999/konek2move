import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/ui/register/register_screen.dart';
import 'package:konek2move/ui/register/register_success_screen.dart';

class ForgotEmailVerificationScreen extends StatefulWidget {
  final String email;

  const ForgotEmailVerificationScreen({super.key, required this.email});

  @override
  State<ForgotEmailVerificationScreen> createState() =>
      _ForgotEmailVerificationScreenState();
}

class _ForgotEmailVerificationScreenState
    extends State<ForgotEmailVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool isOtpComplete = false;
  bool isLoading = false;
  int currentIndex = 0;
  int _secondsRemaining = 300;
  Timer? _timer;

  String maskEmailAddress(String email) {
    if (!email.contains('@')) return email;

    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) return '$username@$domain';

    final prefix = username.substring(0, 2);
    final middleMasked = '*' * (username.length - 2);

    return '$prefix$middleMasked@$domain';
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length < 6) {
      _showTopMessage(
        context,
        message: 'Please enter complete OTP',
        isError: true,
      );
      return;
    }

    setState(() => isOtpComplete = false);

    try {
      final api = ApiServices();
      final response = await api.emailOTPVerification(otp);

      if (!mounted) return;

      if (response.retCode == '200') {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showTopMessage(context, message: response.error, isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      _showTopMessage(
        context,
        message: 'Failed to verify OTP: $e',
        isError: true,
      );
    } finally {
      setState(() {
        isOtpComplete = _otpControllers.every((c) => c.text.isNotEmpty);
      });
    }
  }

  // Reusable Top Flushbar function
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
  void initState() {
    super.initState();
    _startTimer();

    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() => currentIndex = i);
        }
      });
    }
  }

  void _startTimer() {
    _secondsRemaining = 300;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _resendOTP() async {
    try {
      final ApiServices api = ApiServices();
      final response = await api.emailVerification(widget.email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}${response.message}')),
      );
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _otpBox(int index) {
    return Container(
      width: 48,
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: currentIndex == index ? kPrimaryColor : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        autofocus: index == 0,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }

          setState(() {
            isOtpComplete = _otpControllers.every((c) => c.text.isNotEmpty);
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _otpControllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom AppBar
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Center(
                  child: Text(
                    "Verification",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    "Verification Email",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Enter the code we just sent to email",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    maskEmailAddress(widget.email),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      6,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _otpBox(i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _secondsRemaining == 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive code?",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            TextButton(
                              onPressed: () => _resendOTP(),
                              child: const Text(
                                "Resend",
                                style: TextStyle(color: kPrimaryColor),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "Resend available in $_secondsRemaining seconds",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Continue button
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
            child: CustomButton(
              text: isLoading ? "Sending..." : "Continue",
              horizontalPadding: 0,
              color: isOtpComplete ? kPrimaryColor : Colors.grey,
              textColor: isOtpComplete ? Colors.white : Colors.grey.shade600,
              onTap: isOtpComplete && !isLoading ? _verifyOtp : null,
            ),
          ),
        ],
      ),
    );
  }
}
