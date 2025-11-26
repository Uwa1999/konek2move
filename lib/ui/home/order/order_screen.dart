import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:shimmer/shimmer.dart';

import 'new_order_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isLoading = true;
  String searchQuery = "";
  String? selectedReason;

  final List<String> cancelReasons = [
    "Customer not answering",
    "Incorrect address",
    "Unable to locate customer",
    "Traffic/delivery conditions too difficult",
    "Item not ready for pickup",
    "Health/emergency issue",
    "Vehicle breakdown",
    "Order cancelled by customer",
    "Other reason",
  ];

  List<Map<String, String>> deliveries = [
    {
      "title": "Parcel for John Doe",
      "pickup": "123 Main St, Cityville",
      "dropoff": "456 Market St, Townsville",
      "time": "Today, 11:00 AM",
      "status": "Pending",
    },
    {
      "title": "Package for Jane Smith",
      "pickup": "789 Industrial Rd, Cityville",
      "dropoff": "321 Oak Ave, Townsville",
      "time": "Today, 3:00 PM",
      "status": "In Progress",
    },
    {
      "title": "Documents for Acme Corp",
      "pickup": "22 Baker St, Cityville",
      "dropoff": "88 Pine Rd, Townsville",
      "time": "Tomorrow, 9:00 AM",
      "status": "Pending",
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
    });
  }

  Future<void> _reload() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoading = false);
  }

  void _showCancelReasonSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  "Select Cancel Reason",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...cancelReasons.map((reason) {
                  return ListTile(
                    title: Text(reason),
                    onTap: () {
                      setState(() {
                        selectedReason = reason;
                      });
                      Navigator.pop(context);
                      Flushbar(
                        message: "Cancelled: $reason",
                        backgroundColor: kPrimaryRedColor,
                        margin: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(12),
                        duration: const Duration(seconds: 3),
                        flushbarPosition: FlushbarPosition.TOP,
                        icon: const Icon(Icons.cancel, color: Colors.white),
                      ).show(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDeliveries = deliveries
        .where(
          (item) =>
              item['title']!.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              item['pickup']!.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              item['dropoff']!.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Search & Orders
          Expanded(
            child: RefreshIndicator(
              color: kPrimaryColor,
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: "Search orders",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: kPrimaryColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Orders List
                  if (isLoading)
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (filteredDeliveries.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Text(
                          "No orders found",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredDeliveries.map((item) {
                      Color statusColor;
                      switch (item['status']) {
                        case "Pending":
                          statusColor = Colors.orange;
                          break;
                        case "In Progress":
                          statusColor = Colors.blue;
                          break;
                        case "Completed":
                          statusColor = Colors.green;
                          break;
                        default:
                          statusColor = Colors.grey;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Status
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_shipping,
                                    color: kPrimaryColor,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item['title']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item['status']!,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Pickup
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.my_location,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      "Pickup: ${item['pickup']!}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Drop-off
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      "Drop-off: ${item['dropoff']!}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Time
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    item['time']!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              // Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => NewOrderScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Start Delivery",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _showCancelReasonSheet(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryRedColor,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (selectedReason != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    "Selected reason: $selectedReason",
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
