// import 'package:flutter/material.dart';
// import 'package:konek2move/core/constants/app_colors.dart';
// import 'package:konek2move/core/widgets/custom_button.dart';
// import 'package:konek2move/ui/login/login_screen.dart';
// import 'package:konek2move/ui/register/terms_and_condition_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fade;
//   late Animation<Offset> _slide;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 450),
//     );

//     _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

//     _slide = Tween<Offset>(
//       begin: const Offset(-0.3, 0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       precacheImage(const AssetImage("assets/images/splash.png"), context);
//       if (mounted) _controller.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final top = MediaQuery.of(context).padding.top;
//     final bottom = MediaQuery.of(context).padding.bottom;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 24,
//             right: 24,
//             top: top, // ✅ Standard AppBar height
//             bottom: bottom + 24, // ✅ Bottom safe-area + spacing
//           ),

//           child: Column(
//             children: [
//               FadeTransition(
//                 opacity: _fade,
//                 child: SlideTransition(
//                   position: _slide,
//                   child: Image.asset(
//                     "assets/images/splash.png",
//                     height: size.height * 0.40,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               Text(
//                 "Ready to Move with",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
//               ),
//               Text(
//                 "Konek2Move?",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
//               ),

//               const SizedBox(height: 16),

//               const Text(
//                 "Seamless logistics that move your CARD Indogrosir orders safety to your store.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                   height: 1.7,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),

//               const Spacer(),

//               // ===== BUTTONS =====
//               CustomButton(
//                 radius: 30,
//                 horizontalPadding: 0,
//                 text: "Get Started",
//                 color: kPrimaryColor,
//                 textColor: Colors.white,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => TermsAndConditionScreen(),
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 10),

//               CustomButton(
//                 radius: 30,
//                 horizontalPadding: 0,
//                 text: "Login",
//                 color: kWhiteButtonColor,
//                 textColor: kPrimaryColor,
//                 borderColor: kPrimaryColor,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => LoginScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/ui/login/login_screen.dart';
import 'package:konek2move/ui/register/terms_and_condition_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isNavigating = false; // ✅ prevent double tap & lag

  late Animation<double> _fadeImage;
  late Animation<Offset> _slideImage;
  late Animation<double> _scaleImage;

  late Animation<double> _fadeText;
  late Animation<Offset> _slideText;

  late Animation<double> _fadeButtons;
  late Animation<Offset> _slideButtons;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // ===== IMAGE =====
    _fadeImage = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _slideImage = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _scaleImage = Tween(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // ===== TEXT =====
    _fadeText = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
    );

    _slideText = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );

    // ===== BUTTONS =====
    _fadeButtons = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _slideButtons = Tween(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage("assets/images/splash.png"), context);
      _controller.forward();
    });
  }

  Future<void> _navigate(Widget page) async {
    if (_isNavigating) return;
    _isNavigating = true;

    HapticFeedback.lightImpact();

    // ✅ STOP animations before navigation (MAIN FIX)
    _controller.stop();

    // allow current frame to finish
    await Future.delayed(const Duration(milliseconds: 16));
    if (!mounted) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      _isNavigating = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            padding.top,
            24,
            padding.bottom + 24,
          ),
          child: Column(
            children: [
              // ===== IMAGE =====
              FadeTransition(
                opacity: _fadeImage,
                child: SlideTransition(
                  position: _slideImage,
                  child: ScaleTransition(
                    scale: _scaleImage,
                    child: Image.asset(
                      "assets/images/splash.png",
                      height: size.height * 0.40,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ===== TEXT =====
              FadeTransition(
                opacity: _fadeText,
                child: SlideTransition(
                  position: _slideText,
                  child: Column(
                    children: const [
                      Text(
                        "Ready to Move with",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        "Konek2Move?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Seamless logistics for delivering CARD Indogrosir orders securely to your store.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ===== BUTTONS =====
              FadeTransition(
                opacity: _fadeButtons,
                child: SlideTransition(
                  position: _slideButtons,
                  child: Column(
                    children: [
                      CustomButton(
                        radius: 24,
                        text: "Get Started",
                        color: kPrimaryColor,
                        textColor: Colors.white,
                        onTap: () => _navigate(const TermsAndConditionScreen()),
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        radius: 24,
                        text: "Login",
                        color: kWhiteButtonColor,
                        textColor: kPrimaryColor,
                        borderColor: kPrimaryColor,
                        onTap: () => _navigate(const LoginScreen()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
