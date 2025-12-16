import 'package:flutter/material.dart';
import 'package:bytebank/app_colors.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//Importanto os providers
import 'package:provider/provider.dart';
import 'package:bytebank/features/transacoes/presentation/providers/transacoesprovider.dart';
import 'package:bytebank/features/auth/data/presentation/providers/authprovider.dart';

//Importando o editar
import 'package:bytebank/features/transacoes/presentation/screens/editartransacao_screen.dart';

import 'package:bytebank/features/transacoes/data/models/transacaomodel.dart';

enum TipoFiltro { todas, entrada, saida }
enum OrdemFiltro { recentes, antigos }

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