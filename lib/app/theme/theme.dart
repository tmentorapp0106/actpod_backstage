import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static const Color seed = AppColors.brand;

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.surface,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textPrimary),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.onBrand, 
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.onBrand, 
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.onBrand,
        foregroundColor: AppColors.brand,
        side: const BorderSide(color: AppColors.brand),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.brand),
    ),
    
      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.black87,
      ),

      // Cards
       cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(0),
    ),
      // Divider
      dividerTheme: DividerThemeData(color: AppColors.borderSubtle, thickness: 1),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.brand, width: 1.5),
        ),
      ),
      
      radioTheme: RadioThemeData(
      fillColor: WidgetStatePropertyAll(seed),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStatePropertyAll(seed),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? seed.withOpacity(.5) : null,
      ),
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? seed : null,
      ),
    ),

    //（可選）Chip/Divider 也鎖成灰系，避免再帶紫
    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFFF3F4F6),
      side: BorderSide(color: Color(0xFFE5E7EB)),
      selectedColor: Color(0xFFFFE8B0),
      labelStyle: TextStyle(color: Color(0xFF374151)),
    ),
  );
}

class ColorRoles {
  const ColorRoles();

  // Brand
  Color get brand => AppColors.brand;
  Color get onBrand => AppColors.onBrand;

  // Status
  Color get info => AppColors.statusInfo;
  Color get error => AppColors.statusError;
  Color get success => AppColors.statusSuccess;
  Color get highlight => AppColors.statusHighlight;

  // Background / Surface
  Color get bg => AppColors.background;
  Color get surface => AppColors.surface;
  Color get card => AppColors.surface; // 你之後可以拆 card 色

  // Border
  Color get borderSubtle => AppColors.borderSubtle;
  Color get border => AppColors.border;
  Color get borderStrong => AppColors.borderStrong;

  // Text
  Color get text => AppColors.textPrimary;
  Color get textSubtle => AppColors.textSecondary;
  Color get textDisabled => AppColors.textDisabled;
  Color get textOnPrimary => AppColors.textOnPrimary;
}

/// 讓所有 widget 都可以直接用 context.color.xxx
extension ColorRolesContext on BuildContext {
  ColorRoles get color => const ColorRoles();
}
