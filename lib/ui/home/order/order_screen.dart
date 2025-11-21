import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isLoading = true;
  String searchQuery = "";

  // Sample data
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

    // 1. Removed the unnecessary outer Padding widget here.
    return RefreshIndicator(
      onRefresh: _reload,
      color: kPrimaryColor,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            // Applying horizontal padding only to the search bar and list container
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
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
                  prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 1),

          // Orders List
          Expanded(
            // 3. Removed the hardcoded bottom padding from here.
            // The parent HomeScreen padding now handles the bottom spacing.
            child: isLoading
                ? ListView.builder(
                    // Applying horizontal padding only to the list view
                    padding: const EdgeInsets.only().copyWith(
                      left: 16,
                      right: 16,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : filteredDeliveries.isEmpty
                ? Center(
                    child: Text(
                      "No orders found",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    // Applying horizontal padding only to the list view
                    padding: const EdgeInsets.only().copyWith(
                      left: 16,
                      right: 16,
                    ),
                    itemCount: filteredDeliveries.length,
                    itemBuilder: (context, index) {
                      final item = filteredDeliveries[index];
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

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 2,
                        shadowColor: kPrimaryColor.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
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
                                    onPressed: () {},
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
