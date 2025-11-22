import 'package:flutter/material.dart';
import 'package:konek2move/ui/home/home_screen.dart';
import 'package:konek2move/ui/home/notification/notification_screen.dart';
import 'package:konek2move/ui/home/order/order_screen.dart';
import 'package:konek2move/ui/home/setting/setting_screen.dart';
import 'package:konek2move/ui/login/login_screen.dart';
import 'package:konek2move/ui/register/email.dart';
import 'package:konek2move/ui/register/terms_and_condition_screen.dart';
import 'package:konek2move/ui/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String email = '/email_verification';
  static const String terms = '/terms';
  static const String home = '/home';
  static const String order = '/order';
  static const String setting = '/setting';
  static const String notif = '/notification';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    email: (context) => const EmailScreen(),
    terms: (context) => const TermsAndConditionScreen(),
    home: (context) => const HomeScreen(),
    order: (context) => const OrderScreen(),
    setting: (context) => const SettingScreen(),
    notif: (context) => const NotificationScreen(),
  };
}
