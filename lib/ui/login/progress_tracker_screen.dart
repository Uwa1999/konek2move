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
    "Review your application",
    "Your account is now active",
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
    });
  }

  Future<void> _refreshProgress() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Application Progress",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),
              Text(
                "Track your onboarding progress",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: _refreshProgress,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      if (isLoading) {
                        return _loadingShimmer();
                      }

                      bool isCompleted = index < _currentStep;
                      bool isCurrent = index == _currentStep;

                      return _progressTile(
                        title: steps[index],
                        description: stepDescriptions[index],
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        isLast: index == steps.length - 1,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),
              CustomButton(
                text: "Exit",
                color: kPrimaryColor,
                textColor: Colors.white,
                horizontalPadding: 0,
                onTap: () => Navigator.pushReplacementNamed(context, "/login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------
  // SIMPLE MODERN SHIMMER
  // --------------------------------------
  Widget _loadingShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 26,
              height: 26,
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
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(height: 12, width: 160, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------
  // CLEAN PROGRESS TILE
  // --------------------------------------
  Widget _progressTile({
    required String title,
    required String description,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Circle
            Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? kPrimaryColor
                        : isCurrent
                        ? kPrimaryColor.withOpacity(0.15)
                        : Colors.grey.shade300,
                    border: Border.all(
                      color: isCompleted || isCurrent
                          ? kPrimaryColor
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : isCurrent
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),

                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: isCompleted ? kPrimaryColor : Colors.grey.shade300,
                  ),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isCompleted || isCurrent
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                    if (isCompleted || isCurrent) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
