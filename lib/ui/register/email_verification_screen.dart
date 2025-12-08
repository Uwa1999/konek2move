import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_appbar.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/ui/register/register_screen.dart';

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterScreen(email: widget.email),
          ),
        );
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
    return SizedBox(
      width: 48,
      height: 55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: currentIndex == index ? kPrimaryColor : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
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
            // textAlignVertical:
            //     TextAlignVertical.center, // ⭐ Force vertical centering
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              // height: 1.0, // ⭐ Prevents shifting on some AMOLED screens
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero, // ⭐ Prevents top/bottom shifting
            ),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: CustomAppBar(
        title: "Email Verification Code",
        leadingIcon: Icons.arrow_back,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Enter the code we just sent to email",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 6),

            Text(
              maskEmailAddress(widget.email),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),

            const SizedBox(height: 24),

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

      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    // Detect 3-button navigation
    final bool isThreeButtonNav = safeBottom == 0;

    return SafeArea(
      bottom: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            isThreeButtonNav
                ? 16 // 3-button nav phones
                : safeBottom + 24, // gesture nav phones
          ),
          child: CustomButton(
            radius: 30,
            text: isLoading ? "Sending..." : "Continue",
            horizontalPadding: 0,
            textColor: Colors.white,
            color: isOtpComplete ? kPrimaryColor : Colors.grey.shade300,
            onTap: isOtpComplete && !isLoading ? _verifyOtp : null,
          ),
        ),
      ),
    );
  }
}
