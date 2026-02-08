import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/core.dart';
import '../models/models.dart';

/// ============================================================================
/// متحكم طلب التحديث (PUT/PATCH) - إدارة تحديث البيانات باستخدام GetX
/// Update Request Controller (PUT/PATCH) - Managing data updates with GetX
/// ============================================================================
///
/// هذا المتحكم يوضح | This controller demonstrates:
/// 1. الفرق بين PUT (استبدال كامل) و PATCH (تحديث جزئي)
///    Difference between PUT (full replace) and PATCH (partial update)
/// 2. تعبئة النموذج المسبق للتحرير
///    Pre-populating form for editing
/// 3. إدارة حالة الاختيار والتحرير
///    Managing selection and editing state
/// ============================================================================

class UpdateRequestController extends GetxController {
  // ========================================
  // الخدمات | Services
  // ========================================

  final PostApiService _postService = PostApiService(dioClient);

  // ========================================
  // متحكمات النموذج | Form Controllers
  // ========================================

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  // ========================================
  // المتغيرات التفاعلية | Reactive Variables
  // ========================================

  /// قائمة المنشورات | Posts list
  final posts = <PostModel>[].obs;

  /// حالة التحميل الأولي | Initial loading state
  final isLoading = true.obs;

  /// حالة التحديث | Update loading state
  final isUpdating = false.obs;

  /// المنشور المختار للتحرير | Selected post for editing
  final selectedPost = Rxn<PostModel>();

  /// استخدام PATCH أم PUT | Use PATCH or PUT
  final usePatch = true.obs;

  /// رسالة النجاح | Success message
  final successMessage = Rxn<String>();

  /// رسالة الخطأ | Error message
  final errorMessage = Rxn<String>();

  // ========================================
  // دورة الحياة | Lifecycle
  // ========================================

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  // ========================================
  // جلب المنشورات | Fetch Posts
  // ========================================

  /// جلب المنشورات للعرض في القائمة
  /// Fetch posts to display in the list
  Future<void> fetchPosts() async {
    isLoading.value = true;
    errorMessage.value = null;

    final response = await _postService.getAllPosts();

    isLoading.value = false;

    if (response.isSuccess && response.hasData) {
      posts.value = response.data!.take(10).toList();
    } else {
      errorMessage.value =
          response.error?.message ??
          'فشل في جلب المنشورات - Failed to fetch posts';
    }
  }

  // ========================================
  // اختيار منشور للتحرير | Select Post for Editing
  // ========================================

  /// اختيار منشور وتعبئة النموذج ببياناته
  /// Select a post and populate form with its data
  void selectPost(PostModel post) {
    selectedPost.value = post;
    titleController.text = post.title;
    bodyController.text = post.body;
    successMessage.value = null;
    errorMessage.value = null;
  }

  // ========================================
  // تحديث المنشور (PUT أو PATCH)
  // Update Post (PUT or PATCH)
  // ========================================

  /// تحديث المنشور المختار
  /// Update the selected post
  ///
  /// يستخدم PUT أو PATCH بناءً على اختيار المستخدم
  /// Uses PUT or PATCH based on user selection
  Future<void> updatePost() async {
    if (selectedPost.value == null) return;
    if (!formKey.currentState!.validate()) return;

    isUpdating.value = true;
    successMessage.value = null;
    errorMessage.value = null;

    final ApiResponse<PostModel> response;

    if (usePatch.value) {
      // PATCH: تحديث جزئي - أرسل فقط الحقول المتغيرة
      // PATCH: Partial update - send only changed fields
      response = await _postService.patchPost(
        id: selectedPost.value!.id,
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
      );
    } else {
      // PUT: استبدال كامل - أرسل جميع الحقول
      // PUT: Full replacement - send all fields
      final updatedPost = selectedPost.value!.copyWith(
        title: titleController.text.trim(),
        body: bodyController.text.trim(),
      );
      response = await _postService.updatePost(updatedPost);
    }

    isUpdating.value = false;

    if (response.isSuccess && response.hasData) {
      successMessage.value =
          'تم تحديث المنشور بنجاح باستخدام ${usePatch.value ? "PATCH" : "PUT"}!\n'
          'Post updated successfully using ${usePatch.value ? "PATCH" : "PUT"}!';

      // تحديث القائمة المحلية | Update the local list
      final index = posts.indexWhere((p) => p.id == selectedPost.value!.id);
      if (index != -1) {
        posts[index] = response.data!;
      }
      selectedPost.value = response.data;
    } else {
      errorMessage.value =
          response.error?.message ??
          'فشل في تحديث المنشور - Failed to update post';
    }
  }

  // ========================================
  // تبديل طريقة التحديث | Toggle Update Method
  // ========================================

  /// التبديل بين PUT و PATCH
  /// Toggle between PUT and PATCH
  void toggleMethod(bool patch) {
    usePatch.value = patch;
  }
}
