// lib/app/theme/app_color_scheme.dart
import 'package:flutter/material.dart';

class AppColorScheme {
  AppColorScheme._(); // 防止被 new

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
     // ✅ 品牌主色
    primary:Color(0xFFFFBC1F),
    onPrimary:Color(0xFFFFFFFF),

    // ✅ 成功 / 排程 / 綠色語意
    secondary: Color(0xFF4C9A80),
    onSecondary: Colors.white,

    // ✅ 資訊 / 審核 / 藍色語意
    tertiary: Color(0xFF4B93FF),
    onTertiary: Colors.white,

    // ✅ 錯誤狀態
    error: Color(0xFFFB685C),
    onError: Colors.white,

    // ✅ 整體背景
    background: Color(0xFFF5F5F5),
    onBackground:Color(0xFF000000),

    // ✅ 卡片 / 表面
    surface: Color(0xFFFFFFFF),
    onSurface:Color(0xFF000000),

    // ✅ 容器（可之後再 refinement）
    primaryContainer: Color(0xFFFFE19A),
    onPrimaryContainer: Color(0xFF3E2900),

    secondaryContainer:Color(0xFF4C9A80),
    onSecondaryContainer: Colors.white,

    // ✅ 淡框線 / 分隔線
    surfaceVariant:Color(0xFFF5F5F5),
    onSurfaceVariant: Color(0xFF666666),

    outline:Color(0xFFBDBDBD),
    outlineVariant:  Color(0xFFF5F5F5),

    // ✅ 反轉（深色 Snackbar / BottomSheet）
    inverseSurface: Color(0xFF000000),
    onInverseSurface:Color(0xFFFFFFFF),
    inversePrimary: Color(0xFFFFBC1F),

    shadow: Colors.black,
    scrim: Colors.black,
  );
}
