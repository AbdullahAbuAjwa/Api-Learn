import 'package:get/get.dart';
import '../controllers/controllers.dart';

/// ============================================================================
/// الربط الأولي - حقن التبعيات عند بدء التطبيق
/// Initial Binding - Dependency injection at app startup
/// ============================================================================
///
/// ما هي الـ Bindings في GetX؟ | What are Bindings in GetX?
/// - الـ Bindings هي طريقة لحقن التبعيات (Dependency Injection)
///   Bindings are a way to inject dependencies
/// - تُنشئ المتحكمات تلقائياً عند الحاجة إليها
///   They create controllers automatically when needed
/// - تُنظف المتحكمات تلقائياً عند إغلاق الشاشة
///   They clean up controllers when the screen is closed
///
/// أنواع حقن التبعيات في GetX | DI types in GetX:
/// - Get.put(): إنشاء فوري | Immediate creation
/// - Get.lazyPut(): إنشاء عند الاستخدام الأول | Created on first use
/// - Get.putAsync(): إنشاء غير متزامن | Async creation
///
/// لماذا نستخدم Bindings بدل Get.put() المباشر؟
/// Why use Bindings instead of direct Get.put()?
/// 1. فصل منطق حقن التبعيات عن الواجهة
///    Separates DI logic from UI
/// 2. تنظيم أفضل للكود | Better code organization
/// 3. سهولة الاختبار | Easier testing
/// 4. تنظيف تلقائي للذاكرة | Automatic memory cleanup
/// ============================================================================

/// ========================================
/// ربط الشاشة الرئيسية | Home Binding
/// ========================================
/// لا يحتاج متحكم خاص - الشاشة الرئيسية بسيطة
/// No special controller needed - home screen is simple

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // لا شيء تحتاج حقنه للشاشة الرئيسية
    // Nothing to inject for the home screen
  }
}

/// ========================================
/// ربط شاشة GET | GET Screen Binding
/// ========================================

class GetRequestBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut يُنشئ المتحكم عند أول استخدام فقط
    // Get.lazyPut creates controller only on first use
    Get.lazyPut<GetRequestController>(() => GetRequestController());
  }
}

/// ========================================
/// ربط شاشة POST | POST Screen Binding
/// ========================================

class PostRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostRequestController>(() => PostRequestController());
  }
}

/// ========================================
/// ربط شاشة UPDATE (PUT/PATCH) | UPDATE Screen Binding
/// ========================================

class UpdateRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UpdateRequestController>(() => UpdateRequestController());
  }
}

/// ========================================
/// ربط شاشة DELETE | DELETE Screen Binding
/// ========================================

class DeleteRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeleteRequestController>(() => DeleteRequestController());
  }
}

/// ========================================
/// ربط شاشة رفع الملفات | File Upload Screen Binding
/// ========================================

class FileUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FileUploadController>(() => FileUploadController());
  }
}

/// ========================================
/// ربط شاشة معالجة الأخطاء | Error Handling Screen Binding
/// ========================================

class ErrorHandlingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ErrorHandlingController>(() => ErrorHandlingController());
  }
}
