import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/ui/register/register_success_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    setState(() => isOtpComplete = false);

    try {
      final api = ApiServices();
      final response = await api.emailOTPVerification(otp);

      if (!mounted) return;

      if (response.retCode == '200') {
        Navigator.pushReplacementNamed(context, '/register');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to verify OTP: $e')));
    } finally {
      setState(() {
        isOtpComplete = _otpControllers.every((c) => c.text.isNotEmpty);
      });
    }
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
