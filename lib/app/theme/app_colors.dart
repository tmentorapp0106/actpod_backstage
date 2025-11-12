import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Basic Colors
  static const Color brand = Color(0xFFFFBC1F);
  static const Color onBrand = Color(0xFFFFFFFF);

  // Functional Colors
  static const Color statusInfo = Color(0xFF4B93FF);      // 審核中 / 資訊
  static const Color statusError = Color(0xFFFB685C);     // 未通過 / 錯誤狀態
  static const Color statusSuccess = Color(0xFF4C9A80);   // 已排程 / 成功狀態
  static const Color statusHighlight = Color(0xFFFFBC1F); // 新發布 / 主推焦點（ActPod Yellow）

  // Border Colors
  static const borderSubtle = Color(0xFFF5F5F5); // 淡，弱存在感
  static const border = Color(0xFFBDBDBD);       // 中等，標準框線
  static const borderStrong = Color(0xFF989898); // 明顯，用於交互

  // Background Colors
  static const surface = Color(0xFFFFFFFF);     // 淡，弱
  static const background = Color(0xFFF5F5F5);           // 中等，標準背景


  //Button Colors
  static const buttonPrimary = Color(0xFFFFBC1F);
  static const buttonOnPrimary = Color(0xFFFFFFFF);
  static const buttonPrimaryDisabled = Color(0xFFBDBDBD);
  static const buttonSecondary = Color(0xFF666666);
  static const buttonOnSecondary = Color(0xFFF5F5F5);

  // Text Colors
  static const textPrimary = Color(0xFF000000);    
  static const textSecondary = Color(0xFF666666);   
  static const textDisabled = Color(0xFFBDBDBD);      
  static const textOnPrimary = Color(0xFFFFFFFF);     

}