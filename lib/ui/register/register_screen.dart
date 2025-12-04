import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/core/widgets/custom_dropdown.dart';
import 'package:konek2move/core/widgets/custom_fields.dart';
import 'package:konek2move/ui/login/progress_tracker_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String email;
  const RegisterScreen({super.key, required this.email});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Personal Info
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _mnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  // Contact Info
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  // final TextEditingController _regionController = TextEditingController();

  // Vehicle Info
  File? _drivingLicenseFront;
  File? _drivingLicenseBack;
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  // Set-up Password
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isMobileValid = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? selectedSuffix;
  String? selectedGender;
  String? selectedVehicle;
  // String? selectedRegion;

  int _currentStep = 0; // 0 = personal, 1 = contact, 2 = vehicle
  final PageController _pageController = PageController();

  List<String> suffixOptions = [];
  List<String> genderOptions = [];
  List<String> vehicleOptions = [];
  // List<String> regionOptions = [];

  Future<void> _pickImage(
    Function(File) onImagePicked,
    BuildContext context,
  ) async {
    final ImagePicker picker = ImagePicker();
    final bottom = MediaQuery.of(context).padding.bottom;

    await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- DRAG HANDLE (Same as CustomDropdownField) ---
              Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // --- TITLE ---
              const Text(
                "Select Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              // --- SUBTITLE ---
              Text(
                "Choose where to get your image from",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 24),

              // --- GRID OPTIONS (Camera / Gallery) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.blue[50],
                          child: SvgPicture.asset(
                            "assets/icons/camera.svg",
                            width: 32,
                            height: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("Camera", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.green[50],
                          child: SvgPicture.asset(
                            "assets/icons/gallery.svg",
                            width: 32,
                            height: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("Gallery", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Divider(),

              // --- CANCEL BUTTON ---
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    ).then((source) async {
      if (source != null) {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          onImagePicked(File(pickedFile.path));
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fnameController.addListener(_onFieldChanged);
    _mnameController.addListener(_onFieldChanged);
    _lnameController.addListener(_onFieldChanged);
    _genderController.addListener(_onFieldChanged);
    _mobileController.addListener(_onFieldChanged);
    _vehicleController.addListener(_onFieldChanged);
    _licenseController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _emailController.text = widget.email;
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
    _loadDropdownOptions();
  }

  bool _isFormValid() {
    return isMobileValid &&
        _fnameController.text.isNotEmpty &&
        _lnameController.text.isNotEmpty &&
        selectedGender != null &&
        selectedGender!.isNotEmpty &&
        _vehicleController.text.isNotEmpty &&
        _licenseController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text &&
        _drivingLicenseFront != null &&
        _drivingLicenseBack != null;
  }

  bool _isPersonalInfoValid() {
    return _fnameController.text.isNotEmpty &&
        _lnameController.text.isNotEmpty &&
        selectedGender != null &&
        selectedGender!.isNotEmpty;
  }

  bool _isContactInfoValid() {
    return _mobileController.text.trim().length == 11 &&
        _mobileController.text.trim().startsWith('09') &&
        _emailController.text.endsWith('@gmail.com') &&
        _addressController.text.isNotEmpty;
  }

  bool _isVehicleInfoValid() {
    return _drivingLicenseFront != null &&
        _drivingLicenseBack != null &&
        _vehicleController.text.isNotEmpty &&
        _licenseController.text.isNotEmpty;
  }

  void _onFieldChanged() {
    final mobileValid =
        _mobileController.text.length == 11 &&
        _mobileController.text.startsWith('09');
    setState(() {
      isMobileValid = mobileValid;
    });
  }

  void _onRegister() async {
    if (!_isFormValid()) return;

    // Print all input data for debugging
    print('--- Registration Data ---');
    print('First Name: ${_fnameController.text.trim()}');
    print('Middle Name: ${_mnameController.text.trim()}');
    print('Last Name: ${_lnameController.text.trim()}');
    print('Suffix: $selectedSuffix');
    print('Gender: $selectedGender');
    print('Email: ${_emailController.text.trim()}');
    print('Phone: ${_mobileController.text.trim()}');
    print('Address: ${_addressController.text.trim()}');
    // print('Region: ${_regionController.text.trim()}');
    print('Password: ${_passwordController.text}');
    print('Vehicle Type: ${_vehicleController.text.trim()}');
    print('License Number: ${_licenseController.text.trim()}');
    print('License Front File Path: ${_drivingLicenseFront?.path}');
    print('License Back File Path: ${_drivingLicenseBack?.path}');
    print('-------------------------');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiServices().signup(
        firstName: _fnameController.text.trim(),
        middleName: _mnameController.text.trim().isEmpty
            ? null
            : _mnameController.text.trim(),
        lastName: _lnameController.text.trim(),
        suffix: selectedSuffix,
        gender: selectedGender!,
        email: _emailController.text.trim(),
        phone: _mobileController.text.trim(),
        address: _addressController.text.trim(),
        // region: selectedRegion,
        password: _passwordController.text,
        vehicleType: _vehicleController.text.trim(),
        licenseNumber: _licenseController.text.trim(),
        licenseFront: _drivingLicenseFront!,
        licenseBack: _drivingLicenseBack!,
      );

      Navigator.pop(context); // Close loading dialog

      if (response.retCode == '200') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProgressTrackerScreen()),
        );
      } else {
        _showTopMessage(context, message: response.error, isError: true);
      }
    } catch (e) {
      Navigator.pop(context);
      _showTopMessage(
        context,
        message: 'Registration failed: $e',
        isError: true,
      );
    }
  }

  // Modern Top Flushbar function
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
    _fnameController.dispose();
    _mnameController.dispose();
    _lnameController.dispose();
    _suffixController.dispose();
    _genderController.dispose();
    _mobileController.dispose();
    _vehicleController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    // _regionController.dispose();
    _emailController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownOptions() async {
    try {
      final Map<String, List<String>> dropdowns = await ApiServices()
          .fetchDropdownOptions();

      // Capitalize first letter of each vehicle option
      List<String> suffix = (dropdowns['suffix'] ?? []).toList();
      List<String> gender = (dropdowns['gender'] ?? []).toList();
      List<String> vehicles = (dropdowns['vehicle_type'] ?? []).toList();

      setState(() {
        suffixOptions = suffix;
        genderOptions = gender;
        vehicleOptions = vehicles;
      });
    } catch (e) {
      debugPrint("Error loading dropdowns: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(top),
          _buildProgressSteps(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInfoStep(bottom),
                _buildContactInfoStep(bottom),
                _buildVehicleInfoStep(bottom),
                _buildSetupPasswordStep(bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // HEADER WITH SOFT SHADOW + SPACING
  // ---------------------------------------------------------
  Widget _buildHeader(double top) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: top + 12, // ⭐ dynamic safe-area spacing
        bottom: 16, // ⭐ balanced bottom spacing
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),

        // ⭐ Modern Soft Shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            "Registration",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          Positioned(
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.arrow_back, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP PROGRESS INDICATOR WITH CONSISTENT SPACING
  // ---------------------------------------------------------
  Widget _buildProgressSteps() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _modernStep(0, "Personal Info"),
          _stepConnector(0),
          _modernStep(1, "Contact Details"),
          _stepConnector(1),
          _modernStep(2, "Vehicle Details"),
          _stepConnector(2),
          _modernStep(3, "Set-up Password"),
        ],
      ),
    );
  }

  Widget _modernStep(int index, String label) {
    bool isActive = _currentStep >= index;
    bool isCurrent = _currentStep == index;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 34 : 30,
          height: isCurrent ? 34 : 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? kPrimaryColor : Colors.grey.shade300,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: isCurrent ? 14 : 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey.shade600,
              ),
              child: Text("${index + 1}"),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isActive ? kPrimaryColor : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  /// Horizontal line between circles
  Widget _stepConnector(int index) {
    bool isActive = _currentStep > index;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep(double bottom) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "Create an account to start delivering",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        "assets/images/register.png",
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  CustomInputField(
                    required: true,
                    label: "First Name",
                    hint: "First Name",
                    controller: _fnameController,
                  ),

                  const SizedBox(height: 16),

                  CustomInputField(
                    label: "Middle Name",
                    hint: "Middle Name (Optional)",
                    controller: _mnameController,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomInputField(
                          required: true,
                          label: "Last Name",
                          hint: "Last Name",
                          controller: _lnameController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: CustomDropdownField(
                          label: "Suffix",
                          hint: "Suffix",
                          options: suffixOptions,
                          value: selectedSuffix,
                          onChanged: (val) {
                            setState(() {
                              selectedSuffix = val;
                              _suffixController.text = val ?? "";
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  CustomDropdownField(
                    label: "Gender",
                    hint: "Select Gender",
                    options: genderOptions,
                    value: selectedGender,
                    required: true,
                    onChanged: (val) {
                      setState(() {
                        selectedGender = val;
                        _genderController.text = val ?? "";
                      });
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // BUTTON AT BOTTOM
          Padding(
            padding: EdgeInsets.only(bottom: bottom),
            child: CustomButton(
              radius: 30,
              text: "Next",
              horizontalPadding: 0,
              color: _isPersonalInfoValid() ? kPrimaryColor : Colors.grey,
              textColor: Colors.white,
              onTap: _isPersonalInfoValid()
                  ? () {
                      setState(() => _currentStep = 1);
                      _pageController.animateToPage(
                        1,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 2 — CONTACT INFO
  // ---------------------------------------------------------
  Widget _buildContactInfoStep(double bottom) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "We’ll need your contact details",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        "assets/images/contact.png",
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  CustomInputField(
                    required: true,
                    label: "Mobile Number",
                    hint: "e.g., 09123456789",
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                  ),

                  // ✉ EMAIL ADDRESS
                  CustomInputField(
                    required: true,
                    label: "Email Address",
                    hint: "name@example.com",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // 🏠 COMPLETE ADDRESS
                  CustomInputField(
                    required: true,
                    label: "Complete Address",
                    hint: "House No., Street, Barangay, City",
                    controller: _addressController,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          /// ⬅️ BACK / NEXT BUTTONS
          Padding(
            padding: EdgeInsets.only(bottom: bottom),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    radius: 30,
                    icon: Icon(CupertinoIcons.back),
                    horizontalPadding: 0,
                    color: Colors.grey,
                    textColor: Colors.white,
                    onTap: () {
                      setState(() => _currentStep = 0);
                      _pageController.jumpToPage(0);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    radius: 30,
                    text: "Next Step",
                    horizontalPadding: 0,
                    color: _isContactInfoValid() ? kPrimaryColor : Colors.grey,
                    textColor: Colors.white,
                    onTap: _isContactInfoValid()
                        ? () {
                            setState(() => _currentStep = 2);
                            _pageController.animateToPage(
                              2,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 3 — VEHICLE INFO
  // ---------------------------------------------------------
  Widget _buildVehicleInfoStep(double bottom) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "Please provide your vehicle details",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        "assets/images/vehicle.png",
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // FRONT LICENSE
                  _buildDocumentUploadItem(
                    title: "Driving License (Front)",
                    subtitle:
                        "Upload a clear photo of the front side of your vehicle’s license plate. Ensure the plate number is fully visible and legible, with no obstructions or glare.",
                    imageFile: _drivingLicenseFront,
                    onUploadTap: () {
                      _pickImage((file) {
                        setState(() {
                          _drivingLicenseFront = file;
                        });
                      }, context);
                    },
                  ),

                  const SizedBox(height: 16),

                  // BACK LICENSE
                  _buildDocumentUploadItem(
                    title: "Driving License (Back)",
                    subtitle:
                        "Upload a clear photo of the back side of your vehicle’s license plate. Make sure the plate number is fully visible and readable, with no obstructions or glare.",
                    imageFile: _drivingLicenseBack,
                    onUploadTap: () {
                      _pickImage((file) {
                        setState(() {
                          _drivingLicenseBack = file;
                        });
                      }, context);
                    },
                  ),

                  const SizedBox(height: 16),

                  // DRIVER’S LICENSE NUMBER
                  CustomInputField(
                    required: true,
                    label: "Driver’s License Number",
                    hint: "Driver’s License Number",
                    controller: _licenseController,
                    maxLength: 12,
                  ),

                  // // VEHICLE TYPE
                  // _buildSectionTitle("Vehicle Type", required: true),
                  // const SizedBox(height: 10),
                  //
                  // _buildDropdownFields(
                  //   context,
                  //   "Select Vehicle Type",
                  //   vehicleOptions.isEmpty ? ["Loading..."] : vehicleOptions,
                  //   selectedVehicle,
                  //   (value) {
                  //     setState(() {
                  //       selectedVehicle = value;
                  //       _vehicleController.text = value ?? "";
                  //     });
                  //   },
                  // ),
                  CustomDropdownField(
                    label: "Vehicle Type",
                    hint: "Select Vehicle Type",
                    options: vehicleOptions,
                    value: selectedVehicle,
                    required: true,
                    onChanged: (val) {
                      setState(() {
                        selectedVehicle = val;
                        _vehicleController.text = val ?? "";
                      });
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          /// ⬅️ BACK / NEXT BUTTONS
          Padding(
            padding: EdgeInsets.only(bottom: bottom),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    radius: 30,
                    icon: Icon(CupertinoIcons.back),
                    horizontalPadding: 0,
                    color: Colors.grey,
                    textColor: Colors.white,
                    onTap: () {
                      setState(() => _currentStep = 1);
                      _pageController.animateToPage(
                        1,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    radius: 30,
                    text: "Next Step",
                    horizontalPadding: 0,
                    color: _isVehicleInfoValid() ? kPrimaryColor : Colors.grey,
                    textColor: Colors.white,
                    onTap: _isVehicleInfoValid()
                        ? () {
                            setState(() => _currentStep = 3);
                            _pageController.animateToPage(
                              3,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 4 — SET UP PASSWORD
  // ---------------------------------------------------------
  Widget _buildSetupPasswordStep(double bottom) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "We’ll need to set-up your password",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        "assets/images/password.png",
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // PASSWORD
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
                    onSuffixTap: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CONFIRM PASSWORD
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
                      () => _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible,
                    ),
                  ),

                  // const SizedBox(height: 16),
                  //
                  // Container(
                  //   padding: const EdgeInsets.all(12),
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey.shade100,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: Colors.grey.shade300),
                  //   ),
                  //   child: const Text(
                  //     "Your password must contain at least:\n"
                  //     "• 8 characters\n"
                  //     "• 1 uppercase letter\n"
                  //     "• 1 lowercase letter\n"
                  //     "• 1 number",
                  //     style: TextStyle(
                  //       fontSize: 13,
                  //       color: Colors.black87,
                  //       height: 1.4,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          /// ⬅️ BACK / REGISTER BUTTONS
          Padding(
            padding: EdgeInsets.only(bottom: bottom),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    radius: 30,
                    icon: Icon(CupertinoIcons.back),
                    horizontalPadding: 0,
                    color: Colors.grey,
                    textColor: Colors.white,
                    onTap: () {
                      setState(() => _currentStep = 2);
                      _pageController.animateToPage(
                        2,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: CustomButton(
                    radius: 30,
                    text: "Finish",
                    horizontalPadding: 0,
                    color: _isFormValid() ? kPrimaryColor : Colors.grey,
                    textColor: Colors.white,
                    onTap: _isFormValid() ? _onRegister : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // REUSABLE WIDGETS
  // ---------------------------------------------------------

  Widget _buildDocumentUploadItem({
    required String title,
    required String subtitle,
    required File? imageFile,
    required VoidCallback onUploadTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    children: const [
                      TextSpan(
                        text: " *",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onUploadTap,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: imageFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 30, color: Colors.black87),
                        const SizedBox(height: 8),
                        Text(
                          "Upload Photo",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                        width: 110,
                        height: 110,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
