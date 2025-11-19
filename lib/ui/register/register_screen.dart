import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/ui/register/register_success_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  // Set-up Password
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isMobileValid = false;
  bool isPasswordVisible = false;
  String? selectedGender;
  String? selectedSuffix;
  String? selectedVehicle;

  int _currentStep = 0; // 0 = personal, 1 = contact, 2 = vehicle
  final PageController _pageController = PageController();

  final List<String> genderOptions = ["Male", "Female"];
  final List<String> suffixOptions = ["Jr.", "Sr.", "III"];
  List<String> vehicleOptions = [];

  File? _drivingLicenseFront;
  File? _drivingLicenseBack;

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
    _emailController.addListener(_onFieldChanged);
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
    return _mobileController.text.length == 11 &&
        _mobileController.text.startsWith('09') &&
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

  void _onRegister() {
    if (!_isFormValid()) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterSuccessScreen()),
    );
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
      List<String> vehicles = (dropdowns['vehicle_type'] ?? [])
          .map(
            (e) => e.isNotEmpty
                ? e[0].toUpperCase() + e.substring(1).toLowerCase()
                : e,
          )
          .toList();

      setState(() {
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
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stepCircle("1", "Personal Info", _currentStep >= 0),

          _stepCircle("2", "Contact Details", _currentStep >= 1),

          _stepCircle("3", "Vehicle Details", _currentStep >= 2),

          _stepCircle("4", "Set-up Password", _currentStep >= 3),
        ],
      ),
    );
  }

  Widget _stepCircle(
    String number,
    String label,
    bool active, {
    bool isLast = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: active
                ? LinearGradient(
                    colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: active ? null : Colors.grey.shade300,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? kPrimaryColor : Colors.grey.shade500,
          ),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 2,
            width: 30,
            color: active ? kPrimaryColor : Colors.grey.shade300,
          ),
      ],
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
                            _buildDropdownField(
                              "Suffix",
                              suffixOptions,
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
                  _buildDropdownField(
                    "Select Gender",
                    genderOptions,
                    selectedGender,
                    (value) {
                      setState(() {
                        selectedGender = value;
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
                    "e.g. 09XXXXXXXXX",
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle("Email Address", required: true),
                  const SizedBox(height: 10),
                  _buildTextField(_emailController, "@gmail.com"),
                  const SizedBox(height: 15),
                  _buildSectionTitle("Address", required: true),
                  const SizedBox(height: 10),
                  _buildTextField(_addressController, "Current Address"),
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
                  _buildSectionTitle("Vehicle Type", required: true),
                  const SizedBox(height: 10),
                  _buildDropdownFields(
                    "Vehicle Type",
                    vehicleOptions.isEmpty ? ["Loading..."] : vehicleOptions,
                    selectedVehicle,
                    (value) {
                      setState(() {
                        selectedVehicle = value;
                        _vehicleController.text = value ?? "";
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle("License Number", required: true),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _licenseController,
                    "License Number",
                    maxLength: 12,
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
                    "Enter your confirm password",
                    isPassword: true,
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
  }) {
    bool obscureText = isPassword;

    return StatefulBuilder(
      builder: (context, setState) {
        return TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
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
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildDropdownField(
    String hint,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: SizedBox(
          height: 20,
          child: DropdownButton<String>(
            hint: Text(hint),
            value: selectedValue,
            isExpanded: true,
            onChanged: onChanged,
            items: options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFields(
    String hint,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: SizedBox(
          height: 20,
          child: DropdownButton<String>(
            hint: Text(hint),
            value: selectedValue,
            isExpanded: true,
            onChanged: onChanged,
            items: options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ),
    );
  }
}
