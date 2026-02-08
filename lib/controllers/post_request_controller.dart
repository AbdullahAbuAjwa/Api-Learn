import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/core.dart';
import '../models/models.dart';

/// ============================================================================
/// متحكم طلب POST - إدارة إنشاء البيانات باستخدام GetX
/// POST Request Controller - Managing data creation with GetX
/// ============================================================================
///
/// هذا المتحكم يوضح | This controller demonstrates:
/// 1. إدارة حالة النموذج (Form) مع GetX
///    Managing form state with GetX
/// 2. التحقق من صحة المدخلات قبل الإرسال
///    Input validation before submission
/// 3. إنشاء موارد جديدة عبر POST
///    Creating new resources via POST
/// 4. عرض رسائل النجاح والخطأ باستخدام GetX Snackbar
///    Showing success/error messages using GetX Snackbar
/// ============================================================================

class PostRequestController extends GetxController {
  // ========================================
  // الخدمات | Services
  // ========================================

  final PostApiService _postService = PostApiService(dioClient);

  // ========================================
  // متحكمات النموذج | Form Controllers
  // ========================================

  /// مفتاح النموذج للتحقق من الصحة
  /// Form key for validation
  final formKey = GlobalKey<FormState>();

  /// متحكمات النص | Text controllers
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final userIdController = TextEditingController(text: '1');

  // ========================================
  // المتغيرات التفاعلية | Reactive Variables
  // ========================================

  /// حالة التحميل | Loading state
  final isLoading = false.obs;

  /// رسالة النجاح | Success message
  final successMessage = Rxn<String>();

  /// رسالة الخطأ | Error message
  final errorMessage = Rxn<String>();

  /// قائمة المنشورات المُنشأة | List of created posts
  final createdPosts = <PostModel>[].obs;

  // ========================================
  // تنظيف الموارد | Cleanup Resources
  // ========================================

  @override
  void onClose() {
    // دائماً تخلص من المتحكمات لمنع تسرب الذاكرة
    // Always dispose controllers to prevent memory leaks
    titleController.dispose();
    bodyController.dispose();
    userIdController.dispose();
    super.onClose();
  }

  // ========================================
  // إنشاء منشور (POST /posts)
  // Create Post (POST /posts)
  // ========================================

  /// إنشاء منشور جديد عبر API
  /// Create a new post via API
  ///
  /// الخطوات | Steps:
  /// 1. التحقق من النموذج | Validate form
  /// 2. تحضير البيانات | Prepare data
  /// 3. إرسال الطلب | Send request
  /// 4. معالجة الاستجابة | Handle response
  Future<void> createPost() async {
    // الخطوة 1: التحقق من صحة النموذج
    // Step 1: Validate the form
    if (!formKey.currentState!.validate()) return;

    // الخطوة 2: تحضير البيانات
    // Step 2: Prepare the data
    final title = titleController.text.trim();
    final body = bodyController.text.trim();
    final userId = int.tryParse(userIdController.text) ?? 1;

    // الخطوة 3: بدء التحميل
    // Step 3: Start loading
    isLoading.value = true;
    successMessage.value = null;
    errorMessage.value = null;

    // الخطوة 4: تنفيذ استدعاء API
    // Step 4: Make the API call
    final response = await _postService.createPost(
      title: title,
      body: body,
      userId: userId,
    );

    // الخطوة 5: معالجة الاستجابة
    // Step 5: Handle the response
    isLoading.value = false;

    if (response.isSuccess && response.hasData) {
      // نجاح! | Success!
      successMessage.value =
          'تم إنشاء المنشور بنجاح! المعرف: ${response.data!.id}\n'
          'Post created successfully! ID: ${response.data!.id}';
      createdPosts.insert(0, response.data!);

      // مسح النموذج | Clear form
      titleController.clear();
      bodyController.clear();

      // إظهار رسالة نجاح باستخدام GetX Snackbar
      // Show success message using GetX Snackbar
      Get.snackbar(
        'نجاح - Success',
        'تم إنشاء المنشور بنجاح! - Post created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else {
      // خطأ | Error
      errorMessage.value =
          response.error?.message ??
          response.message ??
          'فشل في إنشاء المنشور - Failed to create post';
    }
  }

  // ========================================
  // مسح النموذج | Clear Form
  // ========================================

  /// مسح جميع حقول النموذج وإعادة تعيين الحالة
  /// Clear all form fields and reset state
  void clearForm() {
    titleController.clear();
    bodyController.clear();
    userIdController.text = '1';
    successMessage.value = null;
    errorMessage.value = null;
  }
}
