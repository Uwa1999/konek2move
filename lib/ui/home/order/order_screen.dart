import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/provider_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'order_details_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController searchController = TextEditingController();
  String? selectedReason;
  String searchText = "";
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      searchText = searchController.text; // remove setState spam here
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _hasLoaded = true;
        context.read<OrderProvider>().fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await context.read<OrderProvider>().fetchOrders();
  }

  // Cancel modal bottom sheet
  void _showCancelSheet() {
    final bottom = MediaQuery.of(context).padding.bottom;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Cancel Delivery?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to cancel this delivery request?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: "Yes, Cancel Delivery",
                  color: kPrimaryRedColor,
                  textColor: kDefaultIconLightColor,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: "No, Keep Delivery",
                  color: kLightButtonColor,
                  textColor: kPrimaryColor,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final allOrders = provider.orderResponse?.data.records ?? [];
    final expectedRows = provider.orderResponse?.data.totalCount ?? 3;

    final orders = allOrders.where((order) {
      final target = searchText.toLowerCase();

      return order.orderNo.toLowerCase().contains(target) ||
          (order.customer?.name.toLowerCase() ?? "").contains(target) ||
          order.pickupAddress.toLowerCase().contains(target) ||
          order.deliveryAddress.toLowerCase().contains(target);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =========================
            // SEARCH BAR
            // =========================
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: FocusScope(
                child: Focus(
                  onFocusChange: (_) => setState(() {}),
                  child: Builder(
                    builder: (context) {
                      final isFocused = Focus.of(context).hasFocus;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isFocused
                                ? kPrimaryColor
                                : Colors.grey.shade300,
                            width: 1.4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 22,
                              color: isFocused
                                  ? kPrimaryColor
                                  : Colors.grey.shade500,
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: TextField(
                                controller: searchController,
                                onChanged: (value) {
                                  searchText = value;
                                  final provider = context
                                      .read<OrderProvider>();

                                  if (value.isEmpty) {
                                    provider.resetSearch();
                                  } else {
                                    provider.searchOrders(value);
                                  }

                                  setState(() {}); // minimal rebuild
                                },
                                cursorColor: kPrimaryColor,
                                decoration: InputDecoration(
                                  hintText: "Search order...",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),

                            if (searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  searchController.clear();
                                  setState(() => searchText = "");
                                  context.read<OrderProvider>().resetSearch();
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: kPrimaryRedColor,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ===================================
            // LIST CONTENT
            // ===================================
            Expanded(
              child: RefreshIndicator(
                color: kPrimaryColor,
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  children: [
                    // =======================
                    // LOADING STATE
                    // =======================
                    if (provider.isLoading)
                      ...List.generate(
                        expectedRows == 0 ? 3 : expectedRows,
                        (i) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              height: 220,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      )
                    // =======================
                    // EMPTY STATE
                    // =======================
                    else if (orders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/cart.svg",
                              height: 90,
                              width: 90,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "No Orders Found",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "There are no active orders right now.\nPlease check again later.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    // =======================
                    // ORDERS LIST
                    // =======================
                    else
                      ...orders.map((order) {
                        final bgColor = getStatusColor(order.status);
                        final textColor = getStatusTextColor(order.status);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ============================
                              // CUSTOMER + STATUS
                              // ============================
                              Row(
                                children: [
                                  // Avatar Circle
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: kPrimaryColor.withOpacity(
                                      0.10,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.black54,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Customer Name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.customer?.name ??
                                              "Unknown Customer",

                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Order #${order.orderNo}",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Order Status Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: bgColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      order.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: textColor,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // ============================
                              // PICKUP / DELIVERY INFORMATION
                              // ============================
                              _infoRow(
                                Icons.store_mall_directory,
                                order.pickupAddress,
                              ),
                              const SizedBox(height: 5),
                              _infoRow(
                                Icons.location_on_rounded,
                                order.deliveryAddress,
                              ),
                              const SizedBox(height: 5),
                              _infoRow(
                                Icons.timer_rounded,
                                DateFormat(
                                  "MMM d, yyyy - h:mm a",
                                ).format(DateTime.parse(order.createdAt)),
                              ),

                              const SizedBox(height: 20),

                              // ============================
                              // ACTION BUTTONS
                              // ============================
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Delivery Info (Primary)
                                  Expanded(
                                    child: _primaryBtn(
                                      "View Details",
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                OrderDetailScreen(order: order),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  if (!hideStatuses.contains(
                                    order.status.toLowerCase(),
                                  ))
                                    Expanded(
                                      child: _dangerBtn(
                                        "Cancel",
                                        onTap: () => _showCancelSheet(),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // SMALLER CLEANER INFO ROW WIDGET
  // ==================================================
  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  // ==================================================
  // BUTTONS
  // ==================================================
  Widget _primaryBtn(String title, {required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _dangerBtn(String title, {required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryRedColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  final hideStatuses = [
    "accepted",
    "at_pickup",
    "picked_up",
    "en_route",
    "failed",
    "delivered",
  ];

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "assigned":
        return Colors.grey.withOpacity(0.18);
      case "accepted":
        return Colors.blue.withOpacity(0.18); // Calm blue
      case "at_pickup":
        return Colors.orange.withOpacity(0.18); // Warm orange
      case "picked_up":
        return Colors.deepPurple.withOpacity(0.18); // Modern purple
      case "en_route":
        return Colors.teal.withOpacity(0.18); // Fresh teal
      case "failed":
        return Colors.red.withOpacity(0.18); // Soft red
      case "delivered":
        return Colors.green.withOpacity(0.18); // Pastel green
      default:
        return Colors.grey.withOpacity(0.20); // Neutral gray
    }
  }

  Color getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case "assigned":
        return Colors.grey;
      case "accepted":
        return Colors.blue;
      case "at_pickup":
        return Colors.orange;
      case "picked_up":
        return Colors.deepPurple;
      case "en_route":
        return Colors.teal;
      case "failed":
        return Colors.red;
      case "delivered":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
