import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/ui/home/setting/change_password_screen.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isBiometricEnabled = false;
  bool _isDriverActive = false; // Driver online/offline
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool("biometric_enabled") ?? false;
      _isDriverActive = prefs.getBool("active") ?? false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final canCheck = await auth.canCheckBiometrics;
      final available = await auth.getAvailableBiometrics();

      if (!canCheck || available.isEmpty) {
        _showTopMessage(
          context,
          message: "No biometrics available on this device",
          isError: true,
        );
        return;
      }

      try {
        bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Confirm to enable biometric login',
          biometricOnly: true,
        );

        if (didAuthenticate) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool("biometric_enabled", value);
          setState(() {
            _isBiometricEnabled = value;
          });

          _showTopMessage(
            context,
            message: value
                ? "Biometric login enabled"
                : "Biometric login disabled",
            isError: false,
          );
        }
      } on Exception catch (e) {
        _showTopMessage(
          context,
          message:
              "You canceled the biometric setup. Biometric login remains disabled.",
          isError: true,
        );
      }
    });
  }

  Future<void> _toggleDriverStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("active", value);
    setState(() {
      _isDriverActive = value;
    });

    _showTopMessage(
      context,
      message: value ? "You are ONLINE" : "You are OFFLINE",
      isError: !value,
    );
  }

  // Modern Top Flushbar function (reusable)
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CONTENT",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Change Password
                  _buildActionTile(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    subtitle: "Update your account password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 5),

                  // Driver Status
                  _buildToggleTile(
                    icon: CupertinoIcons.person_crop_circle_fill,
                    title: "Go Online / Offline",
                    subtitle: "Activate to receive new orders",
                    value: _isDriverActive,
                    onChanged: _toggleDriverStatus,
                    activeColor: kPrimaryColor,
                  ),
                  const SizedBox(height: 5),

                  // Biometric
                  _buildToggleTile(
                    icon: Icons.fingerprint_rounded,
                    title: "Biometric Login",
                    subtitle: "Use fingerprint or FaceID to login",
                    value: _isBiometricEnabled,
                    onChanged: _toggleBiometric,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
            child: CustomButton(
              horizontalPadding: 0,
              text: "Log out",
              color: kPrimaryRedColor,
              textColor: kLightButtonColor,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  // Toggle Tile (with switch)
  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
    Color? activeColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 32),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              )
            : null,
        trailing: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: activeColor ?? kPrimaryColor,
        ),
      ),
    );
  }

  // Action Tile (without switch, tappable)
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 32),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
