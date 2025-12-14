import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/services/model_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'order_details_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;
  List<OrderRecord> _allOrders = [];
  List<OrderRecord> _orders = [];

  String? _selectedStatus;

  final List<String> _allStatuses = [
    "assigned",
    "accepted",
    "at_pickup",
    "picked_up",
    "en_route",
    "failed",
    "delivered",
  ];

  final List<String> hideStatuses = [
    "accepted",
    "at_pickup",
    "picked_up",
    "en_route",
    "failed",
    "delivered",
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // FETCH ORDERS
  // =====================================================
  Future<void> _fetchOrders() async {
    setState(() => isLoading = true);

    try {
      final OrderResponse res = await ApiServices().getOrder();

      final filtered = res.data.records.where((order) {
        final int assignedDriverId = order.assignedDriverId;
        return assignedDriverId != 0 || assignedDriverId == 0;
      }).toList();

      _allOrders = filtered;
      _orders = filtered;
    } catch (e, s) {
      debugPrint("ORDER ERROR: $e");
      debugPrintStack(stackTrace: s);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _reload() async => _fetchOrders();

  // =====================================================
  // SEARCH + STATUS FILTER
  // =====================================================
  void _applyFilters() {
    final q = searchController.text.toLowerCase();

    setState(() {
      _orders = _allOrders.where((o) {
        final matchesSearch =
            q.isEmpty ||
            o.orderNo.toLowerCase().contains(q) ||
            (o.customer?.name.toLowerCase() ?? "").contains(q) ||
            o.pickupAddress.toLowerCase().contains(q) ||
            o.deliveryAddress.toLowerCase().contains(q);

        final matchesStatus =
            _selectedStatus == null ||
            o.status.toLowerCase() == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                color: kPrimaryColor,
                onRefresh: _reload,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  children: [
                    if (isLoading)
                      ..._buildShimmer()
                    else if (_orders.isEmpty)
                      _buildEmpty()
                    else
                      ..._orders.map(_buildOrderCard),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // SEARCH BAR
  // =====================================================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "Search order...",
                  border: InputBorder.none,
                ),
              ),
            ),
            if (searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  searchController.clear();
                  _applyFilters();
                },
                child: const Icon(Icons.close, color: kPrimaryRedColor),
              ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _showStatusFilter,
              child: Icon(
                Icons.filter_list,
                color: _selectedStatus == null
                    ? Colors.grey.shade600
                    : kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // FILTER BOTTOM SHEET
  // =====================================================
  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // =====================
                // TITLE (FIXED)
                // =====================
                const Text(
                  "Filter by Status",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 16),

                // =====================
                // SCROLLABLE LIST ONLY
                // =====================
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _statusTile("All", null),
                      ..._allStatuses.map(
                        (status) => _statusTile(status, status),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelSheet() {
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                  'Cancel Delivery?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to cancel this delivery request?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Yes, Cancel Delivery',
                  color: kPrimaryRedColor,
                  textColor: kDefaultIconLightColor,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'No, Keep Delivery',
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

  Widget _statusTile(String label, String? value) {
    final bool isSelected = _selectedStatus == value;

    return ListTile(
      title: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? kPrimaryColor : Colors.black,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: kPrimaryColor)
          : null,
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedStatus = value;
          _applyFilters();
        });
      },
    );
  }

  // =====================================================
  // STATES
  // =====================================================
  List<Widget> _buildShimmer() => List.generate(
    3,
    (_) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 220,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    ),
  );

  Widget _buildEmpty() {
    return Padding(
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
    );
  }

  // =====================================================
  // ORDER CARD
  // =====================================================
  Widget _buildOrderCard(OrderRecord order) {
    final bg = getStatusColor(order.status);
    final text = getStatusTextColor(order.status);
    final date = DateTime.tryParse(order.createdAt);

    final bool showCancel = !hideStatuses.contains(order.status.toLowerCase());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: kPrimaryColor.withOpacity(0.10),
                child: const Icon(
                  Icons.person,
                  color: Colors.black54,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customer?.name ?? "Unknown Customer",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text("Order #${order.orderNo}"),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bg.withOpacity(.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(fontSize: 10, color: text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(Icons.store, order.pickupAddress),
          _infoRow(Icons.location_on, order.deliveryAddress),
          if (date != null)
            _infoRow(
              Icons.timer,
              DateFormat("MMM d, yyyy • h:mm a").format(date),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _primaryBtn(
                  "View Details",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(order: order),
                      ),
                    );
                  },
                ),
              ),
              if (showCancel) const SizedBox(width: 10),
              if (showCancel)
                Expanded(
                  child: _dangerBtn(
                    "Cancel",
                    onTap: () {
                      _showCancelSheet();
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
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
      ),
    );
  }

  // =====================================================
  // BUTTONS
  // =====================================================
  Widget _primaryBtn(String title, {required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(title),
    );
  }

  Widget _dangerBtn(String title, {required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryRedColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Text(title),
    );
  }

  // =====================================================
  // STATUS COLORS
  // =====================================================
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
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

  Color getStatusTextColor(String status) => getStatusColor(status);
}
