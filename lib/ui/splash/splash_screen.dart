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

import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/ui/login/login_screen.dart';
import 'package:konek2move/ui/register/register_screen.dart';
import 'package:konek2move/ui/register/terms_and_condition_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _fadeImage = const AlwaysStoppedAnimation(0.0);
  late Animation<Offset> _slideImage = const AlwaysStoppedAnimation(
    Offset.zero,
  );
  late Animation<double> _scaleImage = const AlwaysStoppedAnimation(1.0);

  late Animation<double> _fadeText = const AlwaysStoppedAnimation(0.0);
  late Animation<Offset> _slideText = const AlwaysStoppedAnimation(Offset.zero);

  late Animation<double> _fadeButtons = const AlwaysStoppedAnimation(0.0);
  late Animation<Offset> _slideButtons = const AlwaysStoppedAnimation(
    Offset.zero,
  );

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // ===== IMAGE ANIMATION =====
    _fadeImage = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _slideImage = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
          ),
        );

    _scaleImage = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // ===== TEXT ANIMATION =====
    _fadeText = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
    );

    _slideText = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
          ),
        );

    // ===== BUTTON ANIMATION =====
    _fadeButtons = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _slideButtons =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage("assets/images/splash.png"), context);
      if (mounted) _controller.forward();
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
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: top, // Standard AppBar height spacing
            bottom: bottom + 24,
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

              // ===== TEXT CONTENT =====
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
                        "Seamless logistics that move your CARD Indogrosir orders safety to your store.",
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TermsAndConditionScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      CustomButton(
                        radius: 24,
                        text: "Login",
                        color: kWhiteButtonColor,
                        textColor: kPrimaryColor,
                        borderColor: kPrimaryColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        },
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
