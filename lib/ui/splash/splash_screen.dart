import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideRightAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Fade In
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Slide from LEFT → RIGHT
    _slideRightAnimation = Tween<Offset>(
      begin: const Offset(-0.8, 0), // start far left
      end: const Offset(0, 0), // end at normal position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 50),

              /// -------------------------------
              /// RIDER ANIMATION (LEFT → RIGHT)
              /// -------------------------------
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideRightAnimation,
                  child: Image.asset(
                    "assets/images/rider.png",
                    height: size.height * 0.40,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Konek2Move",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: kPrimaryColor,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Empowering your business with seamless logistics. We ensure your orders travel safely from CARD Indogrosir straight to your store.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.7),
              ),

              const Spacer(),

              CustomButton(
                horizontalPadding: 0,
                text: "Get Started",
                color: kPrimaryColor,
                textColor: Colors.white,
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/terms');
                },
              ),

              const SizedBox(height: 12),

              CustomButton(
                horizontalPadding: 0,
                text: "Sign in",
                color: kLightButtonColor,
                textColor: kPrimaryColor,
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
