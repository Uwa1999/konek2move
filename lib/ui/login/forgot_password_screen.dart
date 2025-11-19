import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/ui/login/verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_validatePhone);
  }

  void _validatePhone() {
    final text = phoneController.text;
    final valid = text.length == 11 && text.startsWith('09');

    if (valid != isPhoneValid) {
      setState(() {
        isPhoneValid = valid;
      });
    }
  }

  void _onSendCode() {
    if (!isPhoneValid) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationScreen(phoneNumber: phoneController.text),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.removeListener(_validatePhone);
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/'),
                  ),
                ),
                const Center(
                  child: Text(
                    "Forgot Password",
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Forgot Password",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Please enter the registered mobile number to reset your password",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 40),
                  _buildLabel("Mobile Number"),
                  const SizedBox(height: 5),
                  _buildPhoneField(),
                  const SizedBox(height: 20), // Space before bottom button
                ],
              ),
            ),
          ),
          Spacer(),
          // Bottom button
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: CustomButton(
              text: "Continue",
              horizontalPadding: 0,
              color: isPhoneValid ? kPrimaryColor : Colors.grey,
              textColor: Colors.white,
              onTap: isPhoneValid ? _onSendCode : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      decoration: InputDecoration(
        hintText: "e.g. 09XXXXXXXXX",
        hintStyle: TextStyle(color: Colors.grey.shade600),
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
