import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/ui/login/forgot_password_screen.dart';
import 'package:konek2move/ui/register/terms_and_condition_screen.dart';
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
      // _checkIfCompleted();
    });
  }

  Future<void> _checkBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool("biometric_enabled") ?? false;

    if (!mounted) return;

    setState(() => showBiometric = enabled);

    if (enabled) {
      _biometricLogin();
    }
  }

  Future<void> _biometricLogin() async {
    final LocalAuthentication auth = LocalAuthentication();

    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Login using your biometrics or device PIN',
        biometricOnly: false, // allow PIN fallback
      );

      if (!didAuthenticate) return; // cancel if user fails

      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString("email");
      final password = prefs.getString("password");

      if (email == null || password == null) {
        _showTopMessage(
          context,
          message: "No saved credentials for biometric login",
          isError: true,
        );
        return;
      }

      setState(() => isLoading = true);

      // Call your normal login API
      final response = await ApiServices().signin(email, password);

      if (response.retCode == '201') {
        final token = response.data.jwtToken;
        final firstName = response.data.driver.firstName;
        final driverCode = response.data.driver.driverCode;
        final activeStatus = response.data.driver.active;

        await prefs.setString("jwt_token", token);
        await prefs.setString("first_name", firstName);
        await prefs.setString("driver_code", driverCode);
        await prefs.setBool("active", activeStatus);

        _showTopMessage(context, message: "Login successful!");

        Navigator.pushReplacementNamed(context, "/home");
      } else {
        _showTopMessage(context, message: response.error, isError: true);
      }
    } catch (e) {
      _showTopMessage(
        context,
        message: "Use fingerprint or FaceID to login",
        isError: true,
      );
    } finally {
      setState(() => isLoading = false);
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

      if (response.retCode == '201') {
        final token = response.data.jwtToken;
        final firstName = response.data.driver.firstName;
        final driverCode = response.data.driver.driverCode;
        final activeStatus = response.data.driver.active;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("first_name", firstName);
        await prefs.setString("email", emailController.text.trim());
        await prefs.setString("password", passwordController.text.trim());
        await prefs.setString("jwt_token", token);
        await prefs.setString("driver_code", driverCode);
        await prefs.setBool("active", activeStatus);

        _showTopMessage(context, message: "Login successful!");
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        _showTopMessage(context, message: response.error, isError: true);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // center content
            children: [
              // Top image
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Image.asset(
                    "assets/images/login.png",
                    height: 180, // standard height for consistency
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Title
              Text(
                "Ready to Move with Konek2Move?",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Login now and get your deliveries on the go!",
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 35),

              // Email field
              _buildLabel("Email"),
              const SizedBox(height: 8),
              _buildEmailField(),
              const SizedBox(height: 20),

              // Password field
              _buildLabel("Password"),
              const SizedBox(height: 8),
              _buildPasswordField(),

              const SizedBox(height: 12),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              if (showBiometric)
                Center(
                  child: TextButton.icon(
                    onPressed: _biometricLogin,
                    icon: Icon(Icons.fingerprint_rounded, color: kPrimaryColor),
                    label: Text(
                      'Login with Biometrics',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (showBiometric) const SizedBox(height: 25),

              // Login button
              CustomButton(
                text: isLoading ? "Logging in..." : "Login",
                horizontalPadding: 0,
                color: (isButtonEnabled && !isLoading)
                    ? kPrimaryColor
                    : Colors.grey,
                textColor: Colors.white,
                onTap: (isButtonEnabled && !isLoading) ? _onLogin : null,
              ),
              const SizedBox(height: 20),

              // Signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
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
                        fontWeight: FontWeight.bold,
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

  Widget _buildLabel(String text) => Row(
    children: [
      Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ],
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
