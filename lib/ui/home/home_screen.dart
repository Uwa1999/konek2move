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

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  void initState() {
    super.initState();

    // Initialize notifications after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final userCode = prefs.getString("driver_code") ?? "";
      if (userCode.isEmpty) return;

      final notifProvider = context.read<NotificationProvider>();

      // Fetch existing notifications
      await notifProvider.fetchNotifications(
        // userCode: userCode,
        // userType: 'driver',
      );

      // Listen for live notifications
      notifProvider.listenLiveNotifications(
        userCode: userCode,
        userType: 'driver',
      );
    });

    // Initialize driver location service
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
    // Wrap the whole Scaffold with Listener to detect user activity
    return Listener(
      onPointerDown: (_) => _locationService.userActivityDetected(),
      onPointerMove: (_) => _locationService.userActivityDetected(),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: Consumer<NotificationProvider>(
          builder: (context, notifProvider, _) {
            return Scaffold(
              backgroundColor: Colors.grey[100],
              body: Stack(
                children: [
                  // Main content
                  Padding(
                    padding: const EdgeInsets.only(top: 80, bottom: 110),
                    child: _screens[_selectedIndex],
                  ),

                  // Custom AppBar
                  _buildAppBar(notifProvider),

                  // Floating Bottom Navigation
                  _buildBottomNav(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(NotificationProvider notifProvider) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                _getTitle(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              right: 16,
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/notification'),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/icons/notification.svg",
                          width: 30,
                          height: 30,
                          colorFilter: const ColorFilter.mode(
                            kPrimaryColor,
                            BlendMode.srcIn,
                          ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  Widget _navItem(String icon, String label, int index) {
    bool isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => _onItemTapped(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: isSelected
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
                      isSelected ? kPrimaryColor : Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? kPrimaryColor : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
