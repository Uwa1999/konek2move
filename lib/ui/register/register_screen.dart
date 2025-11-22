import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
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
  bool isPasswordVisible = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? selectedSuffix;
  String? selectedGender;
  String? selectedVehicle;

  int _currentStep = 0; // 0 = personal, 1 = contact, 2 = vehicle
  final PageController _pageController = PageController();

  List<String> suffixOptions = [];
  List<String> genderOptions = [];
  List<String> vehicleOptions = [];

  Future<void> _pickImage(
    Function(File) onImagePicked,
    BuildContext context,
  ) async {
    final ImagePicker picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Image",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Choose where to get your image from",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue[50],
                          child: SvgPicture.asset(
                            'assets/icons/camera.svg',
                            width: 35,
                            height: 35,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text("Camera", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.green[50],
                          child: SvgPicture.asset(
                            'assets/icons/gallery.svg',
                            width: 35,
                            height: 35,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text("Gallery", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        onImagePicked(File(pickedFile.path));
      }
    }
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

      //  List<String> vehicles = (dropdowns['vehicle_type'] ?? []).toList();

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(),
          _buildProgressSteps(),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // lock swipe
              children: [
                _buildPersonalInfoStep(),
                _buildContactInfoStep(),
                _buildVehicleInfoStep(),
                _buildSetupPasswordStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // APP BAR
  // ---------------------------------------------------------
  Widget _buildAppBar() {
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
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            ),
          ),
          const Center(
            child: Text(
              "Registration",
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

  // ---------------------------------------------------------
  // PROGRESS STEPS
  // ---------------------------------------------------------
  Widget _buildProgressSteps() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
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

  // ---------------------------------------------------------
  // STEP 1 — PERSONAL INFO
  // ---------------------------------------------------------
  Widget _buildPersonalInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      Image.asset(
                        "assets/images/register.png",
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  _buildSectionTitle("First Name", required: true),
                  const SizedBox(height: 10),
                  _buildTextField(_fnameController, "First Name"),
                  const SizedBox(height: 15),
                  _buildSectionTitle("Middle Name"),
                  const SizedBox(height: 10),
                  _buildTextField(_mnameController, "Middle Name (Optional)"),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Last Name", required: true),
                            const SizedBox(height: 10),
                            _buildTextField(_lnameController, "Last Name"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Suffix"),
                            const SizedBox(height: 10),
                            // _buildDropdownFields(
                            //   "Suffix",
                            //   suffixOptions.isEmpty
                            //       ? ["Loading..."]
                            //       : suffixOptions,
                            //   selectedSuffix,
                            //   (value) {
                            //     setState(() {
                            //       selectedSuffix = value;
                            //       _suffixController.text = value ?? "";
                            //     });
                            //   },
                            // ),
                            _buildDropdownFields(
                              context,
                              "Suffix",
                              suffixOptions.isEmpty
                                  ? ["Loading.."]
                                  : suffixOptions,
                              selectedSuffix,
                              (value) {
                                setState(() {
                                  selectedSuffix = value;
                                  _suffixController.text = value ?? "";
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle("Gender", required: true),
                  const SizedBox(height: 10),

                  // _buildDropdownFields(
                  //   "Select Gender",
                  //   genderOptions.isEmpty ? ["Loading..."] : genderOptions,
                  //   selectedGender,
                  //   (value) {
                  //     setState(() {
                  //       selectedGender = value;
                  //       _genderController.text = value ?? "";
                  //     });
                  //   },
                  // ),
                  _buildDropdownFields(
                    context,
                    "Select Gender",
                    genderOptions.isEmpty ? ["Loading..."] : genderOptions,
                    selectedGender,
                    (value) {
                      setState(() {
                        selectedGender = value;
                        _genderController.text = value ?? "";
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Button at the bottom
          CustomButton(
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
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 2 — CONTACT INFO
  // ---------------------------------------------------------
  Widget _buildContactInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      Image.asset(
                        "assets/images/contact.png",
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  _buildSectionTitle("Mobile Number", required: true),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _mobileController,
                    "e.g., 09123456789",
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle("Email Address", required: true),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _emailController,
                    "e.g., name@example.com",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle("Complete Address", required: true),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _addressController,
                    "House No., Street, Barangay, City",
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Buttons at the bottom
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  horizontalPadding: 0,
                  text: "Back",
                  color: Colors.grey,
                  textColor: Colors.white,
                  onTap: () {
                    setState(() => _currentStep = 0);
                    _pageController.animateToPage(
                      0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  horizontalPadding: 0,
                  text: "Next",
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
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 3 — VEHICLE INFO
  // ---------------------------------------------------------
  Widget _buildVehicleInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      Image.asset(
                        "assets/images/vehicle.png",
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 15),
                  _buildSectionTitle("Driver’s License Number", required: true),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _licenseController,
                    "Driver’s License Number",
                    maxLength: 12,
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle("Vehicle Type", required: true),
                  const SizedBox(height: 10),
                  // _buildDropdownFields(
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
                  _buildDropdownFields(
                    context,
                    "Select Vehicle Type",
                    vehicleOptions.isEmpty ? ["Loading..."] : vehicleOptions,
                    selectedVehicle,
                    (value) {
                      setState(() {
                        selectedVehicle = value;
                        _vehicleController.text = value ?? "";
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  // -------------------------------------
                ],
              ),
            ),
          ),

          // Buttons at the bottom
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: "Back",
                  horizontalPadding: 0,
                  color: Colors.grey,
                  textColor: Colors.white,
                  onTap: () {
                    setState(() => _currentStep = 1);
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  horizontalPadding: 0,
                  text: "Next",
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
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // STEP 4 — SET-UP PASSWORD
  // ---------------------------------------------------------
  Widget _buildSetupPasswordStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      Image.asset(
                        "assets/images/password.png",
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  _buildSectionTitle("Password", required: true),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _passwordController,
                    "Enter your password",
                    isPassword: true,
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle("Confirm Password", required: true),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _confirmPasswordController,
                    "Enter confirm password",
                    isPassword: true,
                    isConfirm: true,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Buttons at the bottom
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  horizontalPadding: 0,
                  text: "Back",
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
              SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  text: "Register",
                  horizontalPadding: 0,
                  color: _isFormValid() ? kPrimaryColor : Colors.grey,
                  textColor: Colors.white,
                  onTap: _isFormValid() ? _onRegister : null,
                ),
              ),
            ],
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
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
  }) {
    bool obscureText =
        isPassword &&
        !(isConfirm ? _isConfirmPasswordVisible : _isPasswordVisible);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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

  Widget _buildDropdownFields(
    BuildContext context,
    String hint,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 50,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    hint,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ...options.map((e) {
                    return ListTile(
                      title: Text(e),
                      onTap: () {
                        Navigator.pop(context);
                        onChanged(e);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 17),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedValue ?? hint,
              style: TextStyle(
                fontSize: 16,
                color: selectedValue == null ? Colors.black54 : Colors.black,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
