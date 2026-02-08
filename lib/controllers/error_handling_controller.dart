import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/core.dart';

/// ============================================================================
/// متحكم معالجة الأخطاء - اختبار سيناريوهات الأخطاء المختلفة
/// Error Handling Controller - Testing various error scenarios
/// ============================================================================
///
/// هذا المتحكم يوضح | This controller demonstrates:
/// 1. أنواع مختلفة من الأخطاء (شبكة، خادم، عميل)
///    Different error types (network, server, client)
/// 2. استراتيجيات معالجة الأخطاء
///    Error handling strategies
/// 3. آليات إعادة المحاولة | Retry mechanisms
/// 4. رسائل خطأ سهلة للمستخدم
///    User-friendly error messages
/// ============================================================================

class ErrorHandlingController extends GetxController {
  // ========================================
  // الخدمات | Services
  // ========================================

  final PostApiService _postService = PostApiService(dioClient);

  // ========================================
  // المتغيرات التفاعلية | Reactive Variables
  // ========================================

  /// رسالة الحالة | Status message
  final statusMessage = Rxn<String>();

  /// حالة التحميل | Loading state
  final isLoading = false.obs;

  /// لون الحالة | Status color
  final statusColor = Colors.grey.obs;

  /// أيقونة الحالة | Status icon
  final statusIcon = Icons.info.obs;

  // ========================================
  // اختبار طلب ناجح | Test Successful Request
  // ========================================

  /// اختبار طلب ناجح - GET /posts/1
  /// Test successful request - GET /posts/1
  Future<void> testSuccessfulRequest() async {
    _startLoading();

    final response = await _postService.getPostById(1);

    isLoading.value = false;

    if (response.isSuccess) {
      statusMessage.value =
          '✅ نجاح! - Success!\n\n'
          'كود الحالة - Status Code: 200\n'
          'عنوان المنشور - Post Title: ${response.data?.title}\n'
          'معرف المستخدم - User ID: ${response.data?.userId}';
      statusColor.value = Colors.green;
      statusIcon.value = Icons.check_circle;
    } else {
      _setError(response.error?.message ?? 'Failed');
    }
  }

  // ========================================
  // اختبار 404 غير موجود | Test 404 Not Found
  // ========================================

  /// اختبار طلب مورد غير موجود
  /// Test requesting a non-existent resource
  Future<void> testNotFound() async {
    _startLoading();
    statusMessage.value =
        'جاري طلب منشور غير موجود...\nRequesting non-existent post...';

    final response = await _postService.getPostById(999999);

    isLoading.value = false;

    if (!response.isSuccess) {
      statusMessage.value =
          '⚠️ غير موجود! - Not Found!\n\n'
          'كود الحالة - Status Code: ${response.statusCode}\n'
          'نوع الخطأ - Error Type: ${response.error?.type}\n'
          'الرسالة - Message: ${response.error?.message}\n\n'
          'هذا متوقع عند طلب مورد غير موجود.\n'
          'This is expected when requesting a resource that doesn\'t exist.';
      statusColor.value = Colors.orange;
      statusIcon.value = Icons.search_off;
    } else {
      statusMessage.value = 'نجح بشكل غير متوقع! - Unexpectedly succeeded!';
      statusColor.value = Colors.green;
      statusIcon.value = Icons.check_circle;
    }
  }

  // ========================================
  // اختبار نقطة نهاية غير صالحة | Test Invalid Endpoint
  // ========================================

  /// اختبار نقطة نهاية غير موجودة
  /// Test a non-existent endpoint
  Future<void> testInvalidEndpoint() async {
    _startLoading();
    statusMessage.value =
        'جاري طلب نقطة نهاية غير صالحة...\nRequesting invalid endpoint...';

    try {
      await dioClient.get('/this-endpoint-does-not-exist');

      isLoading.value = false;
      statusMessage.value =
          'اكتمل الطلب (قد يكون أرجع بيانات فارغة)\nRequest completed (may have returned empty data)';
      statusColor.value = Colors.orange;
      statusIcon.value = Icons.warning;
    } catch (e) {
      isLoading.value = false;
      statusMessage.value =
          '❌ خطأ! - Error!\n\n'
          'نوع الاستثناء - Exception Type: ${e.runtimeType}\n'
          'الرسالة - Message: ${e.toString()}\n\n'
          'هذا يوضح كيفية التعامل مع النقاط النهائية غير الصالحة.\n'
          'This demonstrates how invalid endpoints are handled.';
      statusColor.value = Colors.red;
      statusIcon.value = Icons.error;
    }
  }

  // ========================================
  // اختبار طلب شبكة مع مراحل | Test Network Request with Steps
  // ========================================

  /// محاكاة طلب شبكة مع خطوات مرئية
  /// Simulate a network request with visible steps
  Future<void> testNetworkRequest() async {
    _startLoading();

    // محاكاة المراحل | Simulate steps
    statusMessage.value =
        'الخطوة 1: بدء الطلب...\nStep 1: Initiating request...';
    await Future.delayed(const Duration(milliseconds: 500));

    statusMessage.value =
        'الخطوة 2: الاتصال بالخادم...\nStep 2: Connecting to server...';
    await Future.delayed(const Duration(milliseconds: 500));

    statusMessage.value =
        'الخطوة 3: انتظار الاستجابة...\nStep 3: Waiting for response...';

    final response = await _postService.getAllPosts();

    statusMessage.value =
        'الخطوة 4: تحليل الاستجابة...\nStep 4: Parsing response...';
    await Future.delayed(const Duration(milliseconds: 300));

    isLoading.value = false;

    if (response.isSuccess) {
      statusMessage.value =
          '✅ اكتمل! - Complete!\n\n'
          'تم جلب ${response.data?.length} منشور\n'
          'Fetched ${response.data?.length} posts\n'
          'الحالة - Status: ${response.statusCode}\n\n'
          'جميع الخطوات اكتملت بنجاح.\n'
          'All steps completed successfully.';
      statusColor.value = Colors.green;
      statusIcon.value = Icons.check_circle;
    } else {
      _setError(response.error?.message ?? 'Failed');
    }
  }

  // ========================================
  // دوال مساعدة | Helper Methods
  // ========================================

  void _startLoading() {
    isLoading.value = true;
    statusMessage.value = 'جاري تنفيذ الطلب...\nMaking request...';
    statusColor.value = Colors.blue;
    statusIcon.value = Icons.hourglass_empty;
  }

  void _setError(String message) {
    statusMessage.value = '❌ فشل: $message\n❌ Failed: $message';
    statusColor.value = Colors.red;
    statusIcon.value = Icons.error;
  }
}
