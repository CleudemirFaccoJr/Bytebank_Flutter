import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';

enum TipoFiltro { todas, entrada, saida }
enum OrdemFiltro { recentes, antigos }

//Esta tela é a de Extrato de Transações

class TransacoesScreen extends StatefulWidget {
  @override
  _TransacoesScreenState    createState() => _TransacoesScreenState();  
} 

class _TransacoesScreenState extends State<TransacoesScreen> {
  TipoFiltro _tipoFiltro = TipoFiltro.todas;
  OrdemFiltro _ordemFiltro = OrdemFiltro.recentes;

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