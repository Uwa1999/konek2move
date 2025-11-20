import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/ui/login/forgot_password_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    emailController.addListener(_validateInputs);
    passwordController.addListener(_validateInputs);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricEnabled();
    });
  }

  Future<void> _checkBiometricEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool enabled = prefs.getBool("biometric_enabled") ?? false;

    setState(() {
      showBiometric = enabled;
    });

    if (enabled) {
      _biometricLogin();
    }
  }

  Future<void> _biometricLogin() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Login using your biometrics',
        biometricOnly: true,
      );

      if (authenticated) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _validateInputs() {
    final emailText = emailController.text.trim();
    final passwordText = passwordController.text;

    setState(() {
      isEmailValid =
          emailText.isNotEmpty &&
          emailText.toLowerCase().endsWith('@gmail.com');
      isPasswordNotEmpty = passwordText.isNotEmpty;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void _onLogin() async {
    if (!isEmailValid || !isPasswordNotEmpty || isLoading) return;

    setState(() {
      isLoading = true; // Disable button
    });

    try {
      final response = await ApiServices().signin(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (response.retCode == '200') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("email", emailController.text.trim());
        await prefs.setString("password", passwordController.text.trim());

        Navigator.pushReplacementNamed(context, "/home");
      } else {
        _showTopMessage(
          context,
          message: response.error ?? response.message,
          isError: true,
        );
      }
    } catch (e) {
      _showTopMessage(context, message: "Error: $e", isError: true);
    } finally {
      setState(() {
        isLoading = false; // Re-enable button
      });
    }
  }

  // Modern Top Message Function
  void _showTopMessage(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final color = isError ? Colors.redAccent : Colors.green;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    Flushbar(
      margin: EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: color,
      icon: Icon(icon, color: Colors.white, size: 28),
      message: message,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP, // <-- show on top
      animationDuration: Duration(milliseconds: 500),
    ).show(context);
  }

  // Modern SnackBar Function
  void _showModernSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final color = isError ? Colors.redAccent : Colors.green;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
        duration: Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message, style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled = isEmailValid && isPasswordNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("assets/images/login.png"),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        "Hello! Welcome to Konek2Move",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Login to unlock your ride",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      _buildLabel("Email"),
                      const SizedBox(height: 5),
                      _buildEmailField(),
                      const SizedBox(height: 15),
                      _buildLabel("Password"),
                      const SizedBox(height: 5),
                      _buildPasswordField(),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (showBiometric)
                        TextButton.icon(
                          onPressed: _biometricLogin,
                          icon: Icon(
                            Icons.fingerprint_rounded,
                            color: kPrimaryColor,
                          ),
                          label: Text(
                            'Login with Biometrics',
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CustomButton(
                    text: isLoading ? "Logging in..." : "Login",
                    horizontalPadding: 0,
                    color: (isButtonEnabled && !isLoading)
                        ? kPrimaryColor
                        : Colors.grey,
                    textColor: Colors.white,
                    onTap: (isButtonEnabled && !isLoading) ? _onLogin : null,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/terms'),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
  );

  Widget _buildEmailField() => TextField(
    controller: emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
      hintText: "Enter your email",
      hintStyle: TextStyle(color: Colors.grey.shade600),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _buildPasswordField() => TextField(
    controller: passwordController,
    obscureText: !isPasswordVisible,
    decoration: InputDecoration(
      hintText: "Enter your password",
      hintStyle: TextStyle(color: Colors.grey.shade600),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: Colors.grey.shade600,
        ),
        onPressed: _togglePasswordVisibility,
      ),
    ),
  );
}
