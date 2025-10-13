import 'package:bytebank/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData bytebankTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.corBytebank,
    brightness: Brightness.dark,
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 30,
      fontStyle: FontStyle.italic,
    ),
    bodyMedium: GoogleFonts.inter(),
    displaySmall: GoogleFonts.inter(),
  ),

  //Decoration dos Inputs
  inputDecorationTheme: InputDecorationTheme(
    // Estilo padrão para todos os rótulos de campos de texto
    labelStyle: const TextStyle(color: AppColors.corBytebank), 
    
    // Cor padrão para todos os ícones prefixo/sufixo
    prefixIconColor: AppColors.cinzaCardTexto, 
    
    // Estilo de Borda Padrão (será aplicado a border/enabledBorder/errorBorder se não especificado)
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.verdeClaroHover),
    ),
    
    // Sobrescrevendo apenas a Borda Focada (quando o usuário clica)
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(
        color: AppColors.verdeClaroHover,
        width: 2, // Maior destaque ao focar
      ),
    ),
    
    // Sobrescrevendo a Borda de Erro (o 'errorBorder' e 'focusedErrorBorder' padrão do Flutter)
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    
    // Se você quer que a borda "enabled" (normal) use a cor do `verdeClaroHover`
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.verdeClaroHover),
    ),
  ),
  
);

