import 'package:flutter/material.dart';
import 'package:bytebank/screens/dashboard_screen.dart';
import 'package:bytebank/screens/profile_screen.dart';

class AppRoutes {
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
}

final Map<String, WidgetBuilder> routes = {
  AppRoutes.dashboard: (context) => const DashboardScreen(),
  AppRoutes.profile: (context) => const ProfileScreen(),
};
