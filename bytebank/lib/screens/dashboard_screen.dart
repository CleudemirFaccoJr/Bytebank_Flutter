import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentPageIndex = 0;

  final List<Widget> pages = [
    Center(child: Text("Início")),
    Center(child: Text("Transferências")),
    Center(child: Text("Investimentos")),
    Center(child: Text("Perfil")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.monetization_on),
            icon: Icon(Icons.monetization_on_outlined),
            label: 'Transferências',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.graphic_eq_rounded),
            icon: Icon(Icons.graphic_eq_rounded),
            label: 'Investimentos',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outlined),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
