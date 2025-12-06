import 'package:flutter/material.dart';
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
          _header(context),

          // ---------- CONTENT ----------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTIONS
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

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ---------- BOTTOM ACTION ----------
          _buildBottomAction(context),
        ],
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _header(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      height: topPad + 80,
      width: double.infinity,
      padding: EdgeInsets.only(top: topPad, left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // TITLE
          const Text(
            "Terms & Conditions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          // BACK BUTTON
          Positioned(
            left: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 22,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- PERFECT BOTTOM ACTION ----------
  Widget _buildBottomAction(BuildContext context) {
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    // GLOBAL bottom padding logic from your nav bar
    final double safeBottom = viewInsets > 0
        ? 16 // keyboard open → minimal padding
        : (viewPadding > 0 ? viewPadding : 16);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(24, 16, 24, safeBottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 1.4, // adjust size here (1.0 = default)
                    child: Checkbox(
                      value: isAccepted,
                      onChanged: (val) {
                        setState(() => isAccepted = val ?? false);
                      },
                      activeColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4), // modern look
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "I have read and agree to all the ",
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: "Terms & Conditions",
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: kPrimaryColor, // green highlight
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              CustomButton(
                radius: 30,
                text: "Continue",
                horizontalPadding: 0,
                textColor: Colors.white,
                color: isAccepted ? kPrimaryColor : Colors.grey.shade300,
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
      padding: const EdgeInsets.only(bottom: 24),
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
          const SizedBox(height: 8),
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
