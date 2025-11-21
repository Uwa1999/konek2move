// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:konek2move/core/constants/app_colors.dart';
// import 'package:konek2move/ui/home/dashboard/dashboard_screen.dart';
// import 'package:konek2move/ui/home/map/map_screen.dart';
// import 'package:konek2move/ui/home/order/order_screen.dart';
// import 'package:konek2move/ui/home/setting/setting_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//
//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }
//
//   final List<Widget> _screens = [
//     const DashboardScreen(),
//     const OrderScreen(),
//     const MapScreen(),
//     const SettingScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Custom AppBar
//       body: Column(
//         children: [
//           Container(
//             height: 80,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(20),
//                 bottomRight: Radius.circular(20),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12,
//                   blurRadius: 10,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Center(
//                   child: Text(
//                     _getTitle(),
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   right: 16,
//                   child: GestureDetector(
//                     onTap: () => Navigator.pushReplacementNamed(
//                       context,
//                       '/notification',
//                     ),
//
//                     child: Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         SvgPicture.asset(
//                           "assets/icons/notification.svg",
//                           width: 30,
//                           height: 30,
//                           colorFilter: const ColorFilter.mode(
//                             kPrimaryColor,
//                             BlendMode.srcIn,
//                           ),
//                         ),
//                         // Notification badge
//                         Positioned(
//                           right: -4,
//                           top: -4,
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: Colors.white,
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: const Text(
//                               '3', // Sample notification count
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Main content
//           Expanded(child: _screens[_selectedIndex]),
//         ],
//       ),
//
//       // Bottom Navigation Bar
//       bottomNavigationBar: Container(
//         height: 90,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 10,
//               offset: const Offset(0, -3),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _navItem("assets/icons/home.svg", "Home", 0),
//             _navItem("assets/icons/order.svg", "Orders", 1),
//             _navItem("assets/icons/map.svg", "Maps", 2),
//             _navItem("assets/icons/setting.svg", "Settings", 3),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getTitle() {
//     switch (_selectedIndex) {
//       case 0:
//         return "Home";
//       case 1:
//         return "Orders";
//       case 2:
//         return "Maps";
//       case 3:
//         return "Settings";
//       default:
//         return "";
//     }
//   }
//
//   Widget _navItem(String icon, String label, int index) {
//     bool isSelected = _selectedIndex == index;
//
//     return Expanded(
//       child: InkWell(
//         splashColor: Colors.transparent,
//         highlightColor: Colors.transparent,
//         onTap: () => _onItemTapped(index),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 width: 50,
//                 height: 50,
//                 decoration: isSelected
//                     ? BoxDecoration(
//                         color: kPrimaryColor.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(16),
//                       )
//                     : null,
//                 child: Center(
//                   child: SvgPicture.asset(
//                     icon,
//                     width: 35,
//                     height: 35,
//                     colorFilter: ColorFilter.mode(
//                       isSelected ? kPrimaryColor : Colors.grey,
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                 ),
//               ),
//
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: isSelected ? kPrimaryColor : Colors.grey,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/ui/home/dashboard/dashboard_screen.dart';
import 'package:konek2move/ui/home/map/map_screen.dart';
import 'package:konek2move/ui/home/order/order_screen.dart';
import 'package:konek2move/ui/home/setting/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const OrderScreen(),
    const MapScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the Scaffold with MediaQuery to prevent the screen from resizing
    // when the keyboard is open, ensuring the navbar stays at the bottom.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // Set viewInsets to zero to ignore the soft keyboard's height
        viewInsets: EdgeInsets.zero,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        // You can also add resizeToAvoidBottomInset: false here for extra robustness
        // resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.only(
                top: 80, // same as AppBar height
                bottom:
                    110, // space for bottom nav (90 height + 16 vertical margin * 2)
              ),
              child: _screens[_selectedIndex],
            ),

            // Custom AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
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
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          '/notification',
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/notification.svg",
                              width: 30,
                              height: 30,
                              colorFilter: const ColorFilter.mode(
                                kPrimaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Text(
                                  '3',
                                  style: TextStyle(
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
            ),

            // Floating Bottom Navigation Bar (Stays at the very bottom)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 90,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
            ),
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
