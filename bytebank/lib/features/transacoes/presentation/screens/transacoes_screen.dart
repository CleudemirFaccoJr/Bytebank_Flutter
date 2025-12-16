
import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';

class TransacoesScreen extends StatefulWidget {
  @override
  _TransacoesScreenState createState() => _TransacoesScreenState();
}

class _TransacoesScreenState extends State<TransacoesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transações'),
        backgroundColor: AppColors.corBytebank,
      ),
      body: Center(
        child: Text('Lista de Transações'),
      ),
    );
  }
  
}
