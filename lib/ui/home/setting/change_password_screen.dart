import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_appbar.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/core/widgets/custom_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool isValid = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEmail();

    _passwordController.addListener(_validateInputs);
    _confirmPasswordController.addListener(_validateInputs);
  }

  // 🔥 Load stored email from login to auto-fill
  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString("email") ?? "";

    if (!mounted) return;

    setState(() {
      _emailController.text = storedEmail;
    });

    _validateInputs();
  }

  void _validateInputs() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final valid =
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword;

    setState(() => isValid = valid);
  }

  Future<void> _onSubmit() async {
    if (!isValid || isLoading) return;

    setState(() => isLoading = true);

    try {
      final ApiServices api = ApiServices();
      final response = await api.emailVerification(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (response.retCode == '200') {
        // After OTP sent, continue your flow here...
      } else {
        _showTopMessage(context, message: response.error, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showTopMessage(
          context,
          message: 'Failed to send OTP: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: CustomAppBar(
        title: "Change Password",
        leadingIcon: Icons.arrow_back,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please enter your new password. Make sure it is secure and easy for you to remember.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 24),
            CustomInputField(
              label: "Email",
              hint: "Enter your email",
              controller: _emailController,
              prefixSvg: "assets/icons/email.svg",
            ),
            const SizedBox(height: 16),
            CustomInputField(
              required: true,
              label: "Password",
              hint: "Enter your password",
              controller: _passwordController,
              obscure: !_isPasswordVisible,
              prefixSvg: "assets/icons/lock.svg",
              suffixSvg: _isPasswordVisible
                  ? "assets/icons/open_eye.svg"
                  : "assets/icons/close_eye.svg",
              onSuffixTap: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            const SizedBox(height: 16),
            CustomInputField(
              required: true,
              label: "Confirm Password",
              hint: "Re-enter your password",
              controller: _confirmPasswordController,
              obscure: !_isConfirmPasswordVisible,
              prefixSvg: "assets/icons/lock.svg",
              suffixSvg: _isConfirmPasswordVisible
                  ? "assets/icons/open_eye.svg"
                  : "assets/icons/close_eye.svg",
              onSuffixTap: () => setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

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
            isThreeButtonNav ? 16 : safeBottom + 24,
          ),
          child: CustomButton(
            radius: 30,
            text: isLoading ? "Submitting..." : "Submit",
            horizontalPadding: 0,
            textColor: Colors.white,
            color: isValid ? kPrimaryColor : Colors.grey.shade300,
            onTap: isValid && !isLoading ? _onSubmit : null,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Center(
            child: Text(
              "Change Password",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        children: required
            ? const [
                TextSpan(
                  text: " *",
                  style: TextStyle(color: Colors.red),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    bool isPassword = false,
    bool isConfirm = false,
    bool readOnly = false,
  }) {
    bool obscureText =
        isPassword &&
        !(isConfirm ? _isConfirmPasswordVisible : _isPasswordVisible);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLength: maxLength,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        counterText: "",
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (isConfirm) {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    } else {
                      _isPasswordVisible = !_isPasswordVisible;
                    }
                  });
                },
              )
            : null,
      ),
    );
  }
}
