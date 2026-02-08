import 'package:get/get.dart';
import '../bindings/bindings.dart';
import '../routes/app_routes.dart';
import '../screens/screens.dart';

/// ============================================================================
/// صفحات التطبيق - ربط المسارات بالشاشات والتبعيات
/// App Pages - Linking routes with screens and dependencies
/// ============================================================================
///
/// كل GetPage تحتوي على: | Each GetPage contains:
/// - name: اسم المسار | Route name (e.g., '/get-request')
/// - page: الشاشة المعروضة | The screen widget to display
/// - binding: حقن التبعيات | Dependency injection binding
/// - transition: حركة الانتقال | Screen transition animation
///
/// GetX يُنشئ المتحكمات عند فتح الشاشة ويُنظفها عند إغلاقها
/// GetX creates controllers when opening screens and cleans them on close
/// ============================================================================

class AppPages {
  /// قائمة جميع صفحات التطبيق | List of all app pages
  static final pages = <GetPage>[
    // =============================================
    // الشاشة الرئيسية | Home Screen
    // =============================================
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      // الحركة الافتراضية | Default transition
      transition: Transition.fadeIn,
    ),

    // =============================================
    // شاشة طلبات GET | GET Requests Screen
    // =============================================
    GetPage(
      name: AppRoutes.getRequest,
      page: () => const GetRequestScreen(),
      binding: GetRequestBinding(),
      transition: Transition.rightToLeft,
    ),

    // =============================================
    // شاشة طلبات POST | POST Requests Screen
    // =============================================
    GetPage(
      name: AppRoutes.postRequest,
      page: () => const PostRequestScreen(),
      binding: PostRequestBinding(),
      transition: Transition.rightToLeft,
    ),

    // =============================================
    // شاشة طلبات UPDATE | UPDATE Requests Screen
    // =============================================
    GetPage(
      name: AppRoutes.updateRequest,
      page: () => const UpdateRequestScreen(),
      binding: UpdateRequestBinding(),
      transition: Transition.rightToLeft,
    ),

    // =============================================
    // شاشة طلبات DELETE | DELETE Requests Screen
    // =============================================
    GetPage(
      name: AppRoutes.deleteRequest,
      page: () => const DeleteRequestScreen(),
      binding: DeleteRequestBinding(),
      transition: Transition.rightToLeft,
    ),

    // =============================================
    // شاشة رفع الملفات | File Upload Screen
    // =============================================
    GetPage(
      name: AppRoutes.fileUpload,
      page: () => const FileUploadScreen(),
      binding: FileUploadBinding(),
      transition: Transition.rightToLeft,
    ),

    // =============================================
    // شاشة معالجة الأخطاء | Error Handling Screen
    // =============================================
    GetPage(
      name: AppRoutes.errorHandling,
      page: () => const ErrorHandlingScreen(),
      binding: ErrorHandlingBinding(),
      transition: Transition.rightToLeft,
    ),

    // =============================================
    // شاشة أفضل الممارسات | Best Practices Screen
    // =============================================
    GetPage(
      name: AppRoutes.bestPractices,
      page: () => const BestPracticesScreen(),
      // لا تحتاج binding لأنها شاشة معلومات فقط
      // No binding needed as it's just an info screen
      transition: Transition.rightToLeft,
    ),
  ];
}
