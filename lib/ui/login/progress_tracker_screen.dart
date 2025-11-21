import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:shimmer/shimmer.dart';

class ProgressTrackerScreen extends StatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
  State<ProgressTrackerScreen> createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  // Keep current step fixed at 4
  final int _currentStep = 4;

  final List<String> steps = [
    "Personal Info",
    "Contact Details",
    "Vehicle Details",
    "Set-up Password",
    "Application Review",
    "Account Activated",
  ];

  final List<String> stepDescriptions = [
    "Provide your personal information",
    "Fill in your contact details",
    "Add your vehicle information",
    "Create a secure password",
    "Review your application details",
    "Your account is now active",
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate initial loading
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
    });
  }

  Future<void> _refreshProgress() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Keep _currentStep static
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Application Progress",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: _refreshProgress,
                  child: ListView.builder(
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      if (isLoading) {
                        // Shimmer placeholder
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        height: 18,
                                        width: double.infinity,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        height: 14,
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.6,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Actual progress tracker
                      bool isCompleted = index < _currentStep;
                      bool isCurrent = index == _currentStep;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              // Step Circle
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isCompleted
                                      ? LinearGradient(
                                          colors: [
                                            kPrimaryColor,
                                            kPrimaryColor.withOpacity(0.7),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: !isCompleted && !isCurrent
                                      ? Colors.grey[300]
                                      : null,
                                  border: Border.all(
                                    color: isCurrent || isCompleted
                                        ? kPrimaryColor
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                  boxShadow: isCurrent
                                      ? [
                                          BoxShadow(
                                            color: kPrimaryColor.withOpacity(
                                              0.3,
                                            ),
                                            spreadRadius: 2,
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                    : isCurrent
                                    ? Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: kPrimaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              // Connecting Line
                              if (index != steps.length - 1)
                                Container(
                                  width: 2,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isCompleted
                                          ? [
                                              kPrimaryColor,
                                              kPrimaryColor.withOpacity(0.5),
                                            ]
                                          : [
                                              Colors.grey[300]!,
                                              Colors.grey[300]!,
                                            ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  steps[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isCompleted || isCurrent
                                        ? Colors.black87
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (isCurrent || isCompleted)
                                  Text(
                                    stepDescriptions[index],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              CustomButton(
                text: "Exit",
                horizontalPadding: 0,
                color: kPrimaryColor,
                textColor: Colors.white,
                onTap: () => Navigator.pushReplacementNamed(context, "/login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
