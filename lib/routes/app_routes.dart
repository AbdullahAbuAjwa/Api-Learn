/// ============================================================================
/// أسماء المسارات | Route Names
/// ============================================================================
///
/// لماذا نستخدم مسارات مسماة؟ | Why use named routes?
/// 1. سهولة التنقل | Easy navigation: Get.toNamed('/post')
/// 2. تمرير البيانات | Pass data: Get.toNamed('/post', arguments: data)
/// 3. Deep linking support | دعم الروابط العميقة
/// 4. تنظيم أفضل | Better organization
/// 5. سهولة الصيانة | Easy maintenance
///
/// في GetX، المسارات المسماة تعمل مع الربط (Bindings)
/// In GetX, named routes work with Bindings
/// هذا يعني أن المتحكمات تُنشأ وتُنظف تلقائياً
/// This means controllers are created and cleaned up automatically
/// ============================================================================

abstract class AppRoutes {
  // ثوابت أسماء المسارات | Route name constants
  // نستخدم abstract class حتى لا يمكن إنشاء كائن منها
  // We use abstract class so it can't be instantiated

  /// الشاشة الرئيسية | Home Screen
  static const home = '/';

  /// شاشة طلب GET | GET Request Screen
  static const getRequest = '/get-request';

  /// شاشة طلب POST | POST Request Screen
  static const postRequest = '/post-request';

  /// شاشة طلب UPDATE (PUT/PATCH) | UPDATE Request Screen
  static const updateRequest = '/update-request';

  /// شاشة طلب DELETE | DELETE Request Screen
  static const deleteRequest = '/delete-request';

  /// شاشة رفع الملفات | File Upload Screen
  static const fileUpload = '/file-upload';

  /// شاشة معالجة الأخطاء | Error Handling Screen
  static const errorHandling = '/error-handling';

  /// شاشة أفضل الممارسات | Best Practices Screen
  static const bestPractices = '/best-practices';
}
