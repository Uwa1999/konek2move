import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/services/model_services.dart';
import 'package:konek2move/core/services/provider_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/core/widgets/custom_home_appbar.dart';
import 'package:konek2move/ui/home/home_screen.dart';
import 'chat/order_chat_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderRecord order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with TickerProviderStateMixin {
  // Throttle route requests

  static const double _dropoffRadiusMeters = 50;

  File? _proofImage;
  File? _signatureImage;
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();

  // Locations
  LatLng? _currentLocation;
  late final LatLng pickupLocation;
  late final LatLng dropOffLocation;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription? _notifSub;

  // State

  bool isLoading = false;
  bool _isSubmitting = false;
  bool _autoPickupTriggered = false;

  bool _isWithinDropoffRange() {
    if (_currentLocation == null) return false;

    final distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      dropOffLocation.latitude,
      dropOffLocation.longitude,
    );

    return distance <= _dropoffRadiusMeters;
  }

  // Delivery state
  String routeTarget = 'accepted';
  late String deliveryStatus;

  String get uiStatus => deliveryStatus;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    deliveryStatus = widget.order.status.toString().toLowerCase();
    _syncRouteTargetWithStatus();

    pickupLocation = LatLng(widget.order.pickupLat, widget.order.pickupLng);
    dropOffLocation = LatLng(
      widget.order.deliveryLat,
      widget.order.deliveryLng,
    );

    deliveryStatus = widget.order.status.toString().toLowerCase();

    // compute static pickup->drop-off route
    _computePickupToDropoff().ignore();

    // initialize location (async)
    _initLocationAndMap();

    // setup realtime notifications listener (microtask to ensure context available)
    Future.microtask(_listenRealtimeNotifications);
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _notifSub?.cancel();
    _photoController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
  Future<void> _listenRealtimeNotifications() async {
    final provider = context.read<ChatProvider>();
    try {
      _notifSub = ApiServices().listenNotifications().listen((event) {
        _handleRealtimeChat(event, provider);
      });
    } catch (e) {
      // silent
    }
  }

  // -------------------------------------------------------------------------
  // Map & location initialization
  // -------------------------------------------------------------------------
  Future<void> _initLocationAndMap() async {
    LocationPermission permission;
    try {
      permission = await Geolocator.requestPermission();
    } catch (_) {
      permission = LocationPermission.denied;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Use fallback coordinates and still show map
      _currentLocation = const LatLng(14.0580, 121.3240);

      return;
    }

    // Attempt an initial position with a short timeout to avoid blocking
    try {
      final pos = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 8),
      );
      _currentLocation = LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      _currentLocation = const LatLng(14.0580, 121.3240);
    }

    // subscribe to position changes with minimal overhead
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 8, // reduce frequency to avoid too many updates
          ),
        ).listen(
          (Position p) {
            _currentLocation = LatLng(p.latitude, p.longitude);

            // auto transitions
            _handleAutoTransitions();
          },
          onError: (e) {
            // ignore silently in production; consider logging to remote service
          },
        );
  }

  void _handleAutoTransitions() {
    if (_currentLocation == null) return;

    final distanceToPickup = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      pickupLocation.latitude,
      pickupLocation.longitude,
    );

    // ------------------------------------------------------------------
    // AUTO: arrived at pickup (ONLY after manual "Start to Pickup")
    // ------------------------------------------------------------------
    final bool canAutoPickup =
        routeTarget == 'pickup' &&
        deliveryStatus == 'accepted' &&
        distanceToPickup <= _dropoffRadiusMeters;

    if (canAutoPickup && !_autoPickupTriggered) {
      _autoPickupTriggered = true;

      _setDeliveryStatus('at_pickup').ignore();
      return;
    }

    // ------------------------------------------------------------------
    // AUTO: switch route to dropoff AFTER pickup confirmed
    // ------------------------------------------------------------------
    if (deliveryStatus == 'picked_up' && routeTarget != 'dropoff') {
      routeTarget = 'dropoff';
    }
  }

  // -------------------------------------------------------------------------
  // Directions API handling (throttled)
  // -------------------------------------------------------------------------
  Future<void> _computePickupToDropoff() async {
    try {
      final origin = '${pickupLocation.latitude},${pickupLocation.longitude}';
      final dest = '${dropOffLocation.latitude},${dropOffLocation.longitude}';

      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&mode=driving&key=${Secrets.googleApiKey}',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      if (data['routes'] == null || (data['routes'] as List).isEmpty) return;
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Delivery lifecycle / API
  // -------------------------------------------------------------------------
  Future<void> _setDeliveryStatus(String nextStatus) async {
    if (deliveryStatus == nextStatus) return;
    if (_currentLocation == null) return;

    try {
      final res = await ApiServices().updateStatus(
        orderId: widget.order.id,
        status: nextStatus,
        lng: _currentLocation!.longitude.toString(),
        lat: _currentLocation!.latitude.toString(),
      );

      if (!mounted) return;

      setState(() {
        deliveryStatus = nextStatus;
      });

      _showApiIndicator(
        title: 'Status Updated',
        message: res.message,
        success: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showApiIndicator(
        title: 'Status Update Failed',
        message: e.toString(),
        success: false,
      );
    }
  }

  // Action flows
  Future<void> _acceptOrder() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    // Accepting the order only updates status
    await _setDeliveryStatus('accepted');

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _onStartToPickup() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      routeTarget = 'pickup';
      _autoPickupTriggered = false; // ✅ reset here
    });

    await _setDeliveryStatus('accepted');

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _startToPickup() async {
    await _onStartToPickup();
  }

  Future<void> _onPackageCollected() async {
    await _setDeliveryStatus('picked_up');

    setState(() {
      routeTarget = 'dropoff';
    });
  }

  Future<void> _onStartDropoff() async => _setDeliveryStatus('en_route');

  Future<void> _onCompleteDelivery() async {
    if (!_isWithinDropoffRange()) {
      _showApiIndicator(
        title: "Too Far",
        message: "You must be near the customer location to complete delivery.",
        success: false,
      );
      return;
    }

    _showCompleteDeliverySheet();
  }

  Future<void> _updateDeliveryStatusSilently(String nextStatus) async {
    if (deliveryStatus == nextStatus) return;
    if (_currentLocation == null) return;

    try {
      await ApiServices().updateStatus(
        orderId: widget.order.id,
        status: nextStatus,
        lng: _currentLocation!.longitude.toString(),
        lat: _currentLocation!.latitude.toString(),
      );

      if (!mounted) return;

      setState(() {
        deliveryStatus = nextStatus;
      });
    } catch (e) {
      // ❌ NO UI HERE
      debugPrint("❌ Failed to update status: $e");
      rethrow; // let caller decide what to show
    }
  }

  Future<String> _submitCompletedDelivery() async {
    if (_proofImage == null || _signatureImage == null) {
      throw Exception("Please upload photo and signature.");
    }

    final api = ApiServices();

    final response = await api.proof(
      orderNo: widget.order.orderNo,
      recipientName: widget.order.customer!.name,
      photoItem: _proofImage!,
      signature: _signatureImage!,
    );

    if (response.retCode != "200") {
      throw Exception(response.message);
    }

    // ✅ silent update (NO dialog)
    await _updateDeliveryStatusSilently('delivered');

    // ✅ return backend message dynamically
    return response.message;
  }

  // // -------------------------------------------------------------------------
  // // Chat / notifications
  // // -------------------------------------------------------------------------
  void _handleRealtimeChat(Map<String, dynamic> event, ChatProvider provider) {
    final data = event['data'];
    if (data == null) return;

    if (!(data['topic']?.toString().contains('chat.new_message') ?? false)) {
      return;
    }

    final meta = data['meta'];
    if (meta == null) return;

    if (meta['sender_type'] != 'driver') provider.incrementUnread();
  }

  void _showApiIndicator({
    required String title,
    required String message,
    required bool success,
  }) {
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: success ? Colors.green : Colors.red,
      icon: Icon(
        success ? Icons.check_circle : Icons.error,
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
    ).show(context);
  }

  void _syncRouteTargetWithStatus() {
    switch (deliveryStatus) {
      case 'accepted':
      case 'at_pickup':
        routeTarget = 'pickup';
        break;

      case 'picked_up':
      case 'en_route':
        routeTarget = 'dropoff';
        break;

      default:
        // assigned, delivered, failed, etc.
        routeTarget = 'accepted';
    }
  }

  Future<void> _callNumber(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Dialer failed: $e');
    }
  }

  Future<void> navigateToPickup(double lat, double lng) async {
    final Uri uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Navigation launch failed: $e');
    }
  }

  Future<File?> _pickImageFromCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile == null) return null;

    return File(pickedFile.path);
  }

  Future<File?> _openSignaturePad(BuildContext context) async {
    final SignatureController controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    File? resultFile;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                const Text(
                  "Customer Signature",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Signature(
                    controller: controller,
                    backgroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _dangerBtn(
                        "Clear",
                        onTap: () => controller.clear(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _primaryBtn(
                        "Save",
                        onTap: () async {
                          if (controller.isNotEmpty) {
                            final Uint8List? pngBytes = await controller
                                .toPngBytes();

                            if (pngBytes != null) {
                              final dir = await getTemporaryDirectory();
                              final filePath = path.join(
                                dir.path,
                                'signature_${DateTime.now().millisecondsSinceEpoch}.png',
                              );

                              final file = File(filePath);
                              await file.writeAsBytes(pngBytes);

                              resultFile = file;
                            }
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();
    return resultFile;
  }

  // -------------------------------------------------------------------------
  // UI builders (kept compact & efficient)
  // -------------------------------------------------------------------------

  Widget _buildDeliveryDetails() {
    final details = [
      {
        'icon': Icons.storefront,
        'title': 'Pickup',
        'main': widget.order.supplierName,
        'sub': widget.order.supplierAddress,
      },
      {
        'icon': Icons.location_on,
        'title': 'Drop-off',
        'main': widget.order.customer?.name ?? 'Unknown Customer',
        'sub': widget.order.deliveryAddress,
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TIMELINE
          Column(
            children: List.generate(details.length * 2 - 1, (i) {
              if (i.isEven) {
                return Icon(
                  details[i ~/ 2]['icon'] as IconData,
                  size: 22,
                  color: kPrimaryColor,
                );
              }
              return Container(
                width: 2,
                height: 56,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade300,
              );
            }),
          ),

          const SizedBox(width: 16),

          /// DETAILS
          Expanded(
            child: Column(
              children: details.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _buildDetailRow(
                    title: d['title'] as String,
                    mainText: d['main'] as String,
                    subText: d['sub'] as String,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String mainText,
    required String subText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          mainText,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
        ),
        if (subText.isNotEmpty)
          Text(
            subText,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
      ],
    );
  }

  Widget _buildReceiverCard() {
    final receiverName = widget.order.customer?.name ?? 'Unknown Customer';
    final receiverPhone = widget.order.contactPhone.trim();
    final receiverAddress = widget.order.deliveryAddress;
    final totalAmount = widget.order.totalAmount.toStringAsFixed(2);

    Widget actionIcon({
      required IconData icon,
      required VoidCallback onTap,
      Color? color,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: (color ?? kPrimaryColor).withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: color ?? kPrimaryColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: kPrimaryColor, size: 24),
              ),
              const SizedBox(width: 14),

              /// NAME + DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiverName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Receiver Details",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      receiverAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Delivery Address",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      receiverPhone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              /// ACTIONS (COLUMN)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (receiverPhone.isNotEmpty)
                    actionIcon(
                      icon: Icons.phone,
                      onTap: () => _callNumber(receiverPhone),
                    ),

                  const SizedBox(height: 12),

                  Consumer<ChatProvider>(
                    builder: (_, provider, __) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          actionIcon(
                            icon: Icons.message,
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();

                              if (!mounted) return; // 🔥 FIX

                              final chatId = widget.order.chat?.id ?? 0;
                              final orderNo = widget.order.orderNo;
                              final userType =
                                  prefs.getString("user_type") ?? "";
                              final driverCode =
                                  prefs.getString("driver_code") ?? "";

                              provider.clearUnread();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderChatScreen(
                                    chatId: chatId,
                                    orderNo: orderNo,
                                    userType: userType,
                                    userCode: driverCode,
                                  ),
                                ),
                              );
                            },
                          ),

                          if (provider.unreadCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  provider.unreadCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          /// TOTAL
          Row(
            children: [
              Text(
                "TOTAL AMOUNT",
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Text(
                "₱ $totalAmount",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryBtn(String title, {required VoidCallback onTap}) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(title),
      ),
    );
  }

  Widget _dangerBtn(String title, {required VoidCallback onTap}) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryRedColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(title),
      ),
    );
  }

  void _showCompleteDeliverySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final canSubmit =
                _photoController.text.isNotEmpty &&
                _signatureController.text.isNotEmpty;

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Confirm Delivery",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      "Upload proof and collect customer signature.",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 20),

                    /// 📸 CAMERA
                    _proofTile(
                      title: "Delivery Photo",
                      hasValue: _photoController.text.isNotEmpty,
                      idleIcon: Icons.camera_alt_rounded,
                      completedIcon: Icons.photo_rounded,
                      onTap: () async {
                        final File? img = await _pickImageFromCamera(
                          sheetContext,
                        );
                        if (img != null) {
                          setModalState(() {
                            _proofImage = img;
                            _photoController.text =
                                img.path; // ✅ APPLY CONTROLLER
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    /// ✍️ SIGNATURE (FIXED TYPE)
                    _proofTile(
                      title: "Customer Signature",
                      hasValue: _signatureController.text.isNotEmpty,
                      idleIcon: Icons.edit_rounded,
                      completedIcon: Icons.draw_rounded,
                      onTap: () async {
                        final File? sigFile = await _openSignaturePad(
                          sheetContext,
                        );
                        if (sigFile != null) {
                          setModalState(() {
                            _signatureImage = sigFile;
                            _signatureController.text =
                                sigFile.path; // ✅ APPLY CONTROLLER
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      radius: 24,
                      text: _isSubmitting
                          ? "Submitting delivery…"
                          : "Complete Delivery",
                      color: canSubmit && !_isSubmitting
                          ? kPrimaryColor
                          : Colors.grey.shade400,
                      textColor: Colors.white,
                      onTap: (!canSubmit || _isSubmitting)
                          ? null
                          : () async {
                              setModalState(() => _isSubmitting = true);

                              try {
                                final message =
                                    await _submitCompletedDelivery();

                                if (!mounted) return;

                                // ✅ show dynamic backend message
                                // _showTopMessage(message);
                                _showApiIndicator(
                                  title: 'Status Updated',
                                  message: message,
                                  success: true,
                                );
                              } catch (e) {
                                _showApiIndicator(
                                  message: e.toString().replaceFirst(
                                    'Exception: ',
                                    '',
                                  ),
                                  success: false,
                                  title: 'Error',
                                );
                              } finally {
                                if (mounted) {
                                  setModalState(() => _isSubmitting = false);
                                }
                              }
                            },
                    ),
                  ],
                ),
              ),
            );
          },
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

  void _navigateByStatus() {
    final bool isDropoff =
        deliveryStatus == 'picked_up' || deliveryStatus == 'en_route';

    final double lat = isDropoff
        ? widget.order.deliveryLat
        : widget.order.pickupLat;

    final double lng = isDropoff
        ? widget.order.deliveryLng
        : widget.order.pickupLng;

    navigateToPickup(lat, lng);
  }

  // -------------------------------------------------------------------------
  // Build (NO SHIMMER)
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    final safeBottom = padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomHomeAppBar(
        title: 'Order Details',
        showTrailing: ![
          'accepted',
          'at_pickup',
          'picked_up',
          'en_route',
          'delivered',
        ].contains(uiStatus),
        trailingText: 'Cancel',
        onLeadingTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: 1)),
        ),
        onTrailingTap: _showCancelSheet,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, safeBottom + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// RECEIVER CARD (DIRECT)
                  _buildReceiverCard(),

                  const SizedBox(height: 12),

                  /// DELIVERY DETAILS (DIRECT)
                  _buildDeliveryDetails(),
                ],
              ),
            ),
          ),
        ],
      ),

      /// STATUS BUTTON (DIRECT)
      bottomNavigationBar: _buildStatusButton(),
    );
  }

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

  Widget _buildStatusButton() {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bool isThreeButtonNav = safeBottom == 0;

    final bool shouldShow =
        deliveryStatus != 'delivered' && deliveryStatus != 'failed';
    if (!shouldShow) return const SizedBox.shrink();

    String label = '';
    VoidCallback? onTap;

    switch (deliveryStatus) {
      case 'assigned':
        label = isLoading ? 'Accepting…' : 'Accept Order';
        onTap = isLoading ? null : _acceptOrder;
        break;

      case 'accepted':
        label = isLoading ? 'Starting…' : 'Start to Pickup';
        onTap = isLoading ? null : _startToPickup;
        break;

      case 'at_pickup':
        label = 'Package Collected';
        onTap = _onPackageCollected;
        break;

      case 'picked_up':
        label = 'Start Drop-off';
        onTap = _onStartDropoff;
        break;

      case 'en_route':
        label = 'Complete Delivery';
        onTap = _onCompleteDelivery;
        break;

      default:
        return const SizedBox.shrink();
    }

    return SafeArea(
      bottom: false,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        offset: Offset.zero,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  isThreeButtonNav ? 16 : safeBottom + 16,
                ),
                child: Row(
                  children: [
                    if ([
                      'accepted',
                      'at_pickup',
                      'picked_up',
                      'en_route',
                    ].contains(deliveryStatus))
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.navigation,
                            color: getStatusColor(
                              deliveryStatus,
                            ).withOpacity(0.9),
                            size: 28,
                          ),
                          onPressed: _navigateByStatus,
                        ),
                      ),
                    if ([
                      'accepted',
                      'at_pickup',
                      'picked_up',
                      'en_route',
                    ].contains(deliveryStatus))
                      const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        radius: 24,
                        text: label,
                        horizontalPadding: 0,
                        textColor: Colors.white,
                        color: onTap != null
                            ? kPrimaryColor
                            : Colors.grey.shade400,
                        onTap: onTap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _proofTile({
    required String title,
    required bool hasValue,
    required VoidCallback onTap,
    required IconData idleIcon,
    required IconData completedIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1.5,
            color: hasValue ? kPrimaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasValue ? completedIcon : idleIcon,
              color: hasValue ? kPrimaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hasValue)
              const Icon(Icons.check_circle, color: kPrimaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}

// ================================
// ISOLATE HELPERS (TOP LEVEL ONLY)
// ================================

List<LatLng> decodePolylineIsolate(String encoded) {
  final List<LatLng> poly = [];
  int index = 0, lat = 0, lng = 0;

  while (index < encoded.length) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    poly.add(LatLng(lat / 1e5, lng / 1e5));
  }

  return poly;
}

Map<String, dynamic> parseDirectionsIsolate(String body) {
  final data = json.decode(body);
  if (data == null || data['routes'] == null || data['routes'].isEmpty) {
    return {};
  }

  final route = data['routes'][0];
  final leg = route['legs'][0];

  return {
    'distance': leg['distance']['value'],
    'duration': leg['duration']['value'],
    'polyline': route['overview_polyline']['points'],
  };
}
