import 'package:flutter/material.dart';
import 'package:bytebank/features/saldo/presentation/screens/dashboard_screen.dart';
import 'package:bytebank/features/auth/presentation/screens/profile_screen.dart';
import 'package:bytebank/features/auth/presentation/screens/login_screen.dart';

class AppRoutes {
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String login = '/login';
}

final Map<String, WidgetBuilder> routes = {
  AppRoutes.dashboard: (context) => const DashboardScreen(),
  AppRoutes.profile: (context) => const ProfileScreen(),
  AppRoutes.login: (context) => const LoginScreen(),
};
