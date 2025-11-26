import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;
  String firstName = '';

  @override
  void initState() {
    super.initState();
    // Simulate loading data
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
    });
    _loadFirstName();
  }

  Future<void> _loadFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('first_name'); // key you used
    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        firstName = savedName;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        color: kPrimaryColor,
        onRefresh: _refreshDashboard,
        child: isLoading
            ? _buildShimmer()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildHeader(), const SizedBox(height: 20)],
                ),
              ),
      ),
    );
  }

  // Header with greeting and Go Online toggle
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, $firstName!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Ready to deliver today?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  // Shimmer loader
  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
