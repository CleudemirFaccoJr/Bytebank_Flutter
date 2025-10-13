import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';

class Navigationbar extends StatelessWidget{
  final int currentIndex;
  final Function(int) onTap;

  const Navigationbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
    Center(child: Text("Início")),
    Center(child: Text("Transferências")),
    Center(child: Text("Investimentos")),
    Center(child: Text("Perfil")),
  ];

  return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      backgroundColor: AppColors.corBytebank,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on_outlined),
          label: 'Transações',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.graphic_eq_rounded),
          label: 'Investimentos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          label: 'Perfil',
        ),
      ],
      );

  }
}