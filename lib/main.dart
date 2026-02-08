import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';

/// ============================================================================
/// تطبيق API Learn - نقطة الدخول الرئيسية (باستخدام GetX)
/// API Learn App - Main Entry Point (using GetX)
/// ============================================================================
///
/// هذا التطبيق مصمم كمرجع تعليمي شامل لتكامل Flutter API
/// This application is designed as a comprehensive learning reference for
/// باستخدام Dio و GetX. يغطي:
/// Flutter API integration using Dio & GetX. It covers:
///
/// 1. مفاهيم RESTful API
///    RESTful API Concepts
///
/// 2. النماذج وتحليل JSON
///    Models & JSON Parsing
///
/// 3. أساليب HTTP (GET, POST, PUT, PATCH, DELETE)
///    HTTP Methods (GET, POST, PUT, PATCH, DELETE)
///
/// 4. رفع الملفات | File Upload
///
/// 5. معالجة الأخطاء | Error Handling
///
/// 6. أفضل الممارسات | Best Practices
///
/// =========================================
/// لماذا GetX؟ | Why GetX?
/// =========================================
/// - إدارة حالة بسيطة وقوية | Simple and powerful state management
/// - حقن تبعيات مدمج | Built-in dependency injection
/// - إدارة مسارات مدمجة | Built-in route management
/// - أدوات مساعدة (Snackbar, Dialog, BottomSheet)
///   Utility tools (Snackbar, Dialog, BottomSheet)
///
/// GetMaterialApp بدل MaterialApp:
/// GetMaterialApp instead of MaterialApp:
/// - تضيف دعم التنقل المسمى مع GetX
///   Adds named navigation support with GetX
/// - تضيف حقن التبعيات التلقائي
///   Adds automatic dependency injection
/// - تضيف دعم Snackbar/Dialog/BottomSheet بدون context
///   Adds Snackbar/Dialog/BottomSheet without context
/// ============================================================================

/// نقطة الدخول الرئيسية للتطبيق
/// Main entry point of the application
void main() {
  runApp(const ApiLearnApp());
}

/// ============================================================================
/// الودجت الجذر للتطبيق (GetMaterialApp)
/// Root widget of the application (GetMaterialApp)
/// ============================================================================
class ApiLearnApp extends StatelessWidget {
  const ApiLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم GetMaterialApp بدل MaterialApp
    // We use GetMaterialApp instead of MaterialApp
    return GetMaterialApp(
      // عنوان التطبيق | App title
      title: 'API Learn',

      // ========================================
      // إعدادات الثيم الفاتح | Light Theme
      // ========================================
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),

      // ========================================
      // إعدادات الثيم الداكن | Dark Theme
      // ========================================
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),

      // اتباع إعدادات النظام | Follow system setting
      themeMode: ThemeMode.system,

      // تعطيل شعار التصحيح | Disable debug banner
      debugShowCheckedModeBanner: false,

      // ========================================
      // إعدادات GetX للتنقل | GetX Navigation Setup
      // ========================================

      // المسار الأولي | Initial route
      initialRoute: AppRoutes.home,

      // صفحات التطبيق (مسارات + شاشات + ربط)
      // App pages (routes + screens + bindings)
      getPages: AppPages.pages,

      // الفترة الافتراضية للانتقال | Default transition duration
      defaultTransition: Transition.cupertino,

      // تمكين السجل | Enable logging
      enableLog: true,
    );
  }
}
