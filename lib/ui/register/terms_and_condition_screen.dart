import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';

class TermsAndConditionScreen extends StatefulWidget {
  const TermsAndConditionScreen({super.key});

  @override
  State<TermsAndConditionScreen> createState() =>
      _TermsAndConditionScreenState();
}

class _TermsAndConditionScreenState extends State<TermsAndConditionScreen> {
  bool isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top AppBar
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
                    "Terms & Conditions",
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

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/images/terms.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _TermsSection(
                    title: "1. Introduction",
                    content:
                        "Welcome to Konek2Move Delivery App. By using our services, you agree to comply with our terms and conditions. Please read carefully before using the app.",
                  ),
                  _TermsSection(
                    title: "2. Account Registration",
                    content:
                        "You must provide accurate information when registering an account. You are responsible for maintaining the confidentiality of your account credentials.",
                  ),
                  _TermsSection(
                    title: "3. Use of Service",
                    content:
                        "The app provides delivery services. You agree not to misuse the app for illegal activities or violate any local laws.",
                  ),
                  _TermsSection(
                    title: "4. Payments",
                    content:
                        "All payments made through Konek2Move must be authorized and accurate. We are not responsible for unauthorized transactions.",
                  ),
                  _TermsSection(
                    title: "5. Privacy",
                    content:
                        "Your personal data is collected and used according to our Privacy Policy. By using the app, you consent to such data collection.",
                  ),
                  _TermsSection(
                    title: "6. Termination",
                    content:
                        "We may suspend or terminate your account if you violate these terms or engage in fraudulent activities.",
                  ),
                  _TermsSection(
                    title: "7. Changes to Terms",
                    content:
                        "Konek2Move may update these terms at any time. Continued use of the app constitutes acceptance of the updated terms.",
                  ),
                  _TermsSection(
                    title: "8. Contact Us",
                    content:
                        "For any questions or concerns regarding these terms, please contact our support team via the app or email.",
                  ),
                ],
              ),
            ),
          ),

          // Bottom Agreement & Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    StatefulBuilder(
                      builder: (context, setStateCheckbox) {
                        return Checkbox(
                          value: isAccepted,
                          onChanged: (value) {
                            setState(() {
                              isAccepted = value ?? false;
                            });
                          },
                          activeColor: kPrimaryColor,
                          shape: CircleBorder(), // makes the checkbox round
                        );
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "I have read and agree to all the Terms & Conditions",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: "Continue",
                  color: isAccepted ? kPrimaryColor : Colors.grey,
                  textColor: Colors.white,
                  horizontalPadding: 0,
                  onTap: isAccepted
                      ? () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/email_verification',
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String content;

  const _TermsSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
