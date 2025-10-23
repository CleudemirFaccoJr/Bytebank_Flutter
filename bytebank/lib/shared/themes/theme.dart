import 'package:bytebank/app_colors.dart';
import 'package:flutter/material.dart';

final ThemeData bytebankTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.corBytebank,
    brightness: Brightness.dark,
  ),

  scaffoldBackgroundColor: Colors.white,

  //Decoration dos Inputs
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: AppColors.corBytebank), 
    
    prefixIconColor: AppColors.cinzaCardTexto, 
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.verdeClaroHover),
    ),
    
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(
        color: AppColors.verdeClaroHover,
        width: 2,
      ),
    ),
    
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.verdeClaroHover),
    ),
  ),
  
);

