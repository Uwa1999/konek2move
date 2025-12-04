import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:konek2move/core/services/driver_location_services.dart';
import 'package:provider/provider.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/provider_services.dart';
import 'package:konek2move/ui/home/dashboard/dashboard_screen.dart';
import 'package:konek2move/ui/home/map/map_screen.dart';
import 'package:konek2move/ui/home/order/order_screen.dart';
import 'package:konek2move/ui/home/setting/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    OrderScreen(),
    MapScreen(),
    SettingScreen(),
  ];

  late DriverLocationService _locationService;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final userCode = prefs.getString("driver_code") ?? "";
      if (userCode.isEmpty) return;

      final notifProvider = context.read<NotificationProvider>();

      await notifProvider.fetchNotifications();
      notifProvider.listenLiveNotifications(
        userCode: userCode,
        userType: 'driver',
      );
    });

    _locationService = DriverLocationService();
    _locationService.startMonitoring();
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Listener(
      onPointerDown: (_) => _locationService.userActivityDetected(),
      onPointerMove: (_) => _locationService.userActivityDetected(),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: Consumer<NotificationProvider>(
          builder: (context, notifProvider, _) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  // MAIN CONTENT (RESPECT SPACE FOR APPBAR & BOTTOM NAV)
                  Padding(
                    padding: EdgeInsets.only(
                      top: top + 60,
                      bottom: bottom + 70,
                    ),
                    child: _screens[_selectedIndex],
                  ),

                  // TOP APP BAR
                  _buildAppBar(notifProvider, top),

                  // BOTTOM NAVIGATION
                  _buildBottomNav(bottom),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // APP BAR (MATCH SIZE OF _buildHeader, FIX BADGE CUT)
  // ------------------------------------------------------------
  Widget _buildAppBar(NotificationProvider notifProvider, double top) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: 12,
          top: top + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LEFT placeholder (keeps title centered)
            const SizedBox(width: 40),

            // CENTER TITLE
            Expanded(
              child: Center(
                child: Text(
                  _getTitle(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // RIGHT NOTIF ICON
            _notificationIcon(notifProvider),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ------------------------------------------------------------
  Widget _buildBottomNav(double bottom) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(left: 24, right: 24, bottom: bottom, top: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem("assets/icons/home.svg", "Home", 0),
            _navItem("assets/icons/order.svg", "Orders", 1),
            _navItem("assets/icons/map.svg", "Maps", 2),
            _navItem("assets/icons/setting.svg", "Settings", 3),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PAGE TITLE
  // ------------------------------------------------------------
  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Home";
      case 1:
        return "Orders";
      case 2:
        return "Maps";
      case 3:
        return "Settings";
      default:
        return "";
    }
  }

  // ------------------------------------------------------------
  // NAV ITEMS
  // ------------------------------------------------------------
  Widget _navItem(String icon, String label, int index) {
    bool selected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => setState(() => _selectedIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: selected
                    ? BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      )
                    : null,
                child: Center(
                  child: SvgPicture.asset(
                    icon,
                    width: 35,
                    height: 35,
                    colorFilter: ColorFilter.mode(
                      selected ? kPrimaryColor : Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: selected ? kPrimaryColor : Colors.grey,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationIcon(NotificationProvider notifProvider) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, '/notification'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              "assets/icons/notification.svg",
              width: 26,
              height: 26,
              colorFilter: const ColorFilter.mode(
                kPrimaryColor,
                BlendMode.srcIn,
              ),
            ),
          ),

          if (notifProvider.unreadCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  '${notifProvider.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
