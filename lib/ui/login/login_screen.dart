import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/core/widgets/custom_fields.dart';
import 'package:konek2move/ui/login/forgot_password_screen.dart';
import 'package:konek2move/ui/register/terms_and_condition_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen>
//     with TickerProviderStateMixin {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideRightAnimation;
//
//   bool isEmailValid = false;
//   bool isPasswordNotEmpty = false;
//   bool isPasswordVisible = false;
//   bool showBiometric = false;
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     emailController.addListener(_validateInputs);
//     passwordController.addListener(_validateInputs);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _checkBiometricEnabled();
//       // _checkIfCompleted();
//     });
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//
//     // Fade In
//     _fadeAnimation = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//
//     // Slide from LEFT → RIGHT
//     _slideRightAnimation = Tween<Offset>(
//       begin: const Offset(-0.8, 0), // start far left
//       end: const Offset(0, 0), // end at normal position
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//
//     _controller.forward();
//   }
//
//   Future<void> _checkBiometricEnabled() async {
//     final prefs = await SharedPreferences.getInstance();
//     final enabled = prefs.getBool("biometric_enabled") ?? false;
//
//     if (!mounted) return;
//
//     setState(() => showBiometric = enabled);
//
//     if (enabled) {
//       _biometricLogin();
//     }
//   }
//
//   Future<void> _biometricLogin() async {
//     final LocalAuthentication auth = LocalAuthentication();
//
//     try {
//       final bool didAuthenticate = await auth.authenticate(
//         localizedReason: 'Login using your biometrics or device PIN',
//         biometricOnly: false, // allow PIN fallback
//       );
//
//       if (!didAuthenticate) return; // cancel if user fails
//
//       final prefs = await SharedPreferences.getInstance();
//       final email = prefs.getString("email");
//       final password = prefs.getString("password");
//
//       if (email == null || password == null) {
//         _showTopMessage(
//           context,
//           message: "No saved credentials for biometric login",
//           isError: true,
//         );
//         return;
//       }
//
//       setState(() => isLoading = true);
//
//       // Call your normal login API
//       final response = await ApiServices().signin(email, password);
//
//       if (response.retCode == '201') {
//         final token = response.data.jwtToken;
//         final firstName = response.data.driver.firstName;
//         final driverCode = response.data.driver.driverCode;
//         final activeStatus = response.data.driver.active;
//
//         await prefs.setString("jwt_token", token);
//         await prefs.setString("first_name", firstName);
//         await prefs.setString("driver_code", driverCode);
//         await prefs.setBool("active", activeStatus);
//
//         Navigator.pushReplacementNamed(context, "/home");
//       } else {
//         _showTopMessage(context, message: response.error, isError: true);
//       }
//     } catch (e) {
//       _showTopMessage(
//         context,
//         message: "Use fingerprint or FaceID to login",
//         isError: true,
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   void _validateInputs() {
//     final emailText = emailController.text.trim();
//     final passwordText = passwordController.text;
//
//     setState(() {
//       isEmailValid =
//           emailText.isNotEmpty &&
//           emailText.toLowerCase().endsWith('@gmail.com');
//       isPasswordNotEmpty = passwordText.isNotEmpty;
//     });
//   }
//
//   void _togglePasswordVisibility() {
//     setState(() {
//       isPasswordVisible = !isPasswordVisible;
//     });
//   }
//
//   void _onLogin() async {
//     if (!isEmailValid || !isPasswordNotEmpty || isLoading) return;
//
//     setState(() {
//       isLoading = true; // Disable button
//     });
//
//     try {
//       final response = await ApiServices().signin(
//         emailController.text.trim(),
//         passwordController.text.trim(),
//       );
//
//       if (response.retCode == '201') {
//         final token = response.data.jwtToken;
//         final firstName = response.data.driver.firstName;
//         final driverCode = response.data.driver.driverCode;
//         final activeStatus = response.data.driver.active;
//
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString("first_name", firstName);
//         await prefs.setString("email", emailController.text.trim());
//         await prefs.setString("password", passwordController.text.trim());
//         await prefs.setString("jwt_token", token);
//         await prefs.setString("driver_code", driverCode);
//         await prefs.setBool("active", activeStatus);
//
//         _showTopMessage(context, message: "Login successful!");
//         Navigator.pushReplacementNamed(context, "/home");
//       } else {
//         _showTopMessage(context, message: response.error, isError: true);
//       }
//     } catch (e) {
//       _showTopMessage(context, message: "Error: $e", isError: true);
//     } finally {
//       setState(() {
//         isLoading = false; // Re-enable button
//       });
//     }
//   }
//
//   // Modern Top Message Function
//   void _showTopMessage(
//     BuildContext context, {
//     required String message,
//     bool isError = false,
//   }) {
//     final color = isError ? Colors.redAccent : Colors.green;
//     final icon = isError ? Icons.error_outline : Icons.check_circle_outline;
//
//     Flushbar(
//       margin: EdgeInsets.all(16),
//       borderRadius: BorderRadius.circular(12),
//       backgroundColor: color,
//       icon: Icon(icon, color: Colors.white, size: 28),
//       message: message,
//       duration: Duration(seconds: 3),
//       flushbarPosition: FlushbarPosition.TOP, // <-- show on top
//       animationDuration: Duration(milliseconds: 500),
//     ).show(context);
//   }
//
//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isButtonEnabled = isEmailValid && isPasswordNotEmpty;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start, // center content
//             children: [
//               // Top image
//               const SizedBox(height: 50),
//               FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: SlideTransition(
//                   position: _slideRightAnimation,
//                   child: Center(
//                     child: Image.asset(
//                       "assets/images/login.png",
//                       height: size.height * 0.10,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 50),
//
//               // Title
//               Text(
//                 "Lets get you Login!",
//                 style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
//               ),
//               const SizedBox(height: 5),
//               Text(
//                 "Login now and get your deliveries on the go!",
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey.shade500,
//                   fontWeight: FontWeight.w400,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 35),
//
//               // Email field
//               CustomInputField(
//                 label: "Email",
//                 hint: "Enter your email",
//                 controller: emailController,
//                 prefixSvg: "assets/icons/email.svg",
//               ),
//
//               SizedBox(height: 15),
//               CustomInputField(
//                 label: "Password",
//                 hint: "Enter your password",
//                 controller: passwordController,
//                 obscure: !isPasswordVisible,
//                 prefixSvg: "assets/icons/lock.svg",
//                 suffixSvg: isPasswordVisible
//                     ? "assets/icons/close_eye.svg"
//                     : "assets/icons/open_eye.svg",
//                 onSuffixTap: _togglePasswordVisibility,
//               ),
//
//               const SizedBox(height: 12),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
//                     );
//                   },
//                   child: Text(
//                     'Forgot Password?',
//                     style: TextStyle(
//                       color: kPrimaryColor,
//                       fontWeight: FontWeight.w500,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//               if (showBiometric)
//                 Center(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: kPrimaryColor.withOpacity(0.06),
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: TextButton.icon(
//                       onPressed: _biometricLogin,
//                       icon: Icon(
//                         Icons.fingerprint_rounded,
//                         color: kPrimaryColor,
//                       ),
//                       label: Text(
//                         'Login with Biometrics',
//                         style: TextStyle(
//                           color: kPrimaryColor,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               if (showBiometric) const SizedBox(height: 25),
//
//               // Login button
//               CustomButton(
//                 text: isLoading ? "Logging in..." : "Login",
//                 horizontalPadding: 0,
//                 color: (isButtonEnabled && !isLoading)
//                     ? kPrimaryColor
//                     : Colors.grey,
//                 textColor: Colors.white,
//                 onTap: (isButtonEnabled && !isLoading) ? _onLogin : null,
//               ),
//               const SizedBox(height: 20),
//
//               // Signup
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Don't have an account? ",
//                     style: TextStyle(
//                       color: Colors.grey.shade500,
//                       fontWeight: FontWeight.w400,
//                       fontSize: 14,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => TermsAndConditionScreen(),
//                         ),
//                       );
//                     },
//                     child: Text(
//                       "Sign Up",
//                       style: TextStyle(
//                         color: kPrimaryColor,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//No Animation
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isEmailValid = false;
  bool isPasswordNotEmpty = false;
  bool isPasswordVisible = false;
  bool showBiometric = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Delay heavy tasks and biometric checks until AFTER UI renders
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _preloadImage();
      _initPreferences();
    });

    emailController.addListener(() => _validateInputs());
    passwordController.addListener(() => _validateInputs());
  }

  /// PRELOAD IMAGE to prevent “first decode” lag
  Future<void> _preloadImage() async {
    await precacheImage(const AssetImage("assets/images/login.png"), context);
  }

  /// Load SharedPreferences + check biometrics (NON BLOCKING)
  Future<void> _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool("biometric_enabled") ?? false;

    if (!mounted) return;
    setState(() => showBiometric = enabled);

    // Delay biometric popup slightly so UI is stable first
    if (enabled) {
      Future.delayed(const Duration(milliseconds: 200), _biometricLogin);
    }
  }

  /// NON-BLOCKING BIOMETRIC LOGIN
  Future<void> _biometricLogin() async {
    final LocalAuthentication auth = LocalAuthentication();

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Login using your biometrics or device PIN',
        biometricOnly: false,
      );

      if (!didAuthenticate) return;

      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString("email");
      final password = prefs.getString("password");

      if (email == null || password == null) {
        _showTopMessage(
          "No saved credentials for biometric login",
          isError: true,
        );
        return;
      }

      setState(() => isLoading = true);

      final response = await ApiServices().signin(email, password);

      if (response.retCode == '201') {
        await prefs.setString("jwt_token", response.data.jwtToken);
        await prefs.setString("first_name", response.data.driver.firstName);
        await prefs.setString("driver_code", response.data.driver.driverCode);
        await prefs.setBool("active", response.data.driver.active);
        await prefs.setString("id", response.data.driver.id.toString());
        await prefs.setString(
          "assigned_store_code",
          response.data.driver.assignedStoreCode,
        );
        await prefs.setString(
          "barangay_code",
          response.data.driver.barangayCode,
        );
        await prefs.setString("user_type", response.data.driver.userType);
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        _showTopMessage(response.error, isError: true);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// VALIDATE INPUTS (NO heavy setState spam)
  void _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    final validEmail =
        email.isNotEmpty && email.toLowerCase().endsWith("@gmail.com");

    final validPassword = password.isNotEmpty;

    if (validEmail != isEmailValid || validPassword != isPasswordNotEmpty) {
      setState(() {
        isEmailValid = validEmail;
        isPasswordNotEmpty = validPassword;
      });
    }
  }

  /// LOGIN
  void _onLogin() async {
    if (!isEmailValid || !isPasswordNotEmpty || isLoading) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiServices().signin(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (response.retCode == '201') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("email", emailController.text.trim());
        await prefs.setString("password", passwordController.text.trim());
        await prefs.setString("jwt_token", response.data.jwtToken);
        await prefs.setString("first_name", response.data.driver.firstName);
        await prefs.setString("driver_code", response.data.driver.driverCode);
        await prefs.setBool("active", response.data.driver.active);
        await prefs.setString("id", response.data.driver.id.toString());
        await prefs.setString(
          "assigned_store_code",
          response.data.driver.assignedStoreCode,
        );
        await prefs.setString(
          "barangay_code",
          response.data.driver.barangayCode,
        );
        await prefs.setString("user_type", response.data.driver.userType);

        // 👉 Do NOT reset isLoading — keep "Logging in…" until navigation
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, "/home");
        return; // Stop execution here
      }

      _showTopMessage(response.error, isError: true);

      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showTopMessage("Error: $e", isError: true);

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// ENHANCED NON-LAG FLUSHBAR
  void _showTopMessage(String message, {bool isError = false}) {
    Flushbar(
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      message: message,
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 180),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;

    final bool canLogin = isEmailValid && isPasswordNotEmpty && !isLoading;

    final safeBottom = MediaQuery.of(context).padding.bottom;
    // Detect 3-button navigation (no safe inset)
    final bool isThreeButtonNav = safeBottom == 0;

    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,

            // ⬇️ FINAL BOTTOM PADDING FIX
            isThreeButtonNav
                ? 16 // 3-button navigation → add 16 so button is visible
                : safeBottom, // gesture navbar → add small buffer
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Konek2Move v1.0.0",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Text(
                "Powered by FSA Asya Philippines Inc | FDSAP.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
            ],
          ),
        ),
      ),

      // ------------ BODY ------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, top + 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HERO IMAGE
              Center(
                child: Image.asset(
                  "assets/images/login.png",
                  height: size.height * 0.12,
                ),
              ),

              const SizedBox(height: 32),

              // TITLE
              const Text(
                "Let's get you Login!",
                style: TextStyle(
                  fontSize: 30, // ⭐ Standard large title
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              // SUBTITLE
              Text(
                "Login now and get your deliveries on the go!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15, // ⭐ Standard subtitle
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 32),

              // EMAIL INPUT
              CustomInputField(
                label: "Email",
                hint: "Enter your email",
                controller: emailController,
                prefixSvg: "assets/icons/email.svg",
              ),

              const SizedBox(height: 16),

              // PASSWORD INPUT
              CustomInputField(
                label: "Password",
                hint: "Enter your password",
                controller: passwordController,
                obscure: !isPasswordVisible,
                prefixSvg: "assets/icons/lock.svg",
                suffixSvg: isPasswordVisible
                    ? "assets/icons/open_eye.svg"
                    : "assets/icons/close_eye.svg",
                onSuffixTap: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              ),

              const SizedBox(height: 12),

              // FORGOT PASSWORD
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 15, // ⭐ Standard link/tab size
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // BIOMETRIC LOGIN
              if (showBiometric)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: _biometricLogin,
                    icon: Icon(Icons.fingerprint_rounded, color: kPrimaryColor),
                    label: Text(
                      'Login with Biometrics',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 15, // ⭐ Standard button text
                      ),
                    ),
                  ),
                ),

              if (showBiometric) const SizedBox(height: 24),

              // LOGIN BUTTON
              CustomButton(
                radius: 24,
                text: isLoading ? "Logging in..." : "Login",
                horizontalPadding: 0,
                color: canLogin ? kPrimaryColor : Colors.grey.shade400,
                textColor: Colors.white,
                onTap: canLogin ? _onLogin : null,
              ),

              const SizedBox(height: 24),

              // SIGN UP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TermsAndConditionScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15, // ⭐ Standard action link
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
