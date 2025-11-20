import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
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
      _isDriverActive = prefs.getBool("driver_active") ?? false;
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
          message: "Biometric error: ${e.toString()}",
          isError: true,
        );
        print(e.toString());
      }
    });
  }

  Future<void> _toggleDriverStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("driver_active", value);
    setState(() {
      _isDriverActive = value;
    });

    _showTopMessage(
      context,
      message: value ? "You are ONLINE" : "You are OFFLINE",
      isError: false,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align left
                  children: [
                    // --- Profile Header ---
                    Center(
                      child: Column(
                        children: const [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Ottokonek Rider",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "ottokonek@fortress-asya.com",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Section Title ---
                    const Text(
                      "CONTENT",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- Driver Status ---
                    _buildToggleTile(
                      icon: CupertinoIcons.person_crop_circle_fill,
                      title: "Go Online / Offline",
                      subtitle: "Activate to receive new orders",
                      value: _isDriverActive,
                      onChanged: _toggleDriverStatus,
                      activeColor: kPrimaryColor,
                    ),
                    const SizedBox(height: 10),

                    // --- Biometric ---
                    _buildToggleTile(
                      icon: Icons.fingerprint_rounded,
                      title: "Biometric Login",
                      subtitle: "Use fingerprint or FaceID to login",
                      value: _isBiometricEnabled,
                      onChanged: _toggleBiometric,
                    ),
                  ],
                ),
              ),
            ),

            // --- Logout at bottom ---
            CustomButton(
              horizontalPadding: 0,
              text: "Log out",
              color: kPrimaryRedColor,
              textColor: kLightButtonColor,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: Center(child: Icon(icon, color: kPrimaryColor, size: 40)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
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
}
