import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/core.dart';
import '../models/models.dart';

/// ============================================================================
/// متحكم طلب DELETE - إدارة حذف البيانات باستخدام GetX
/// DELETE Request Controller - Managing data deletion with GetX
/// ============================================================================
///
/// هذا المتحكم يوضح | This controller demonstrates:
/// 1. تنفيذ طلبات DELETE لحذف الموارد
///    Making DELETE requests to remove resources
/// 2. مربعات تأكيد الحذف | Confirmation dialogs
/// 3. التحديث التفاؤلي مقابل التشاؤمي
///    Optimistic vs pessimistic UI updates
/// 4. وظيفة التراجع (Undo) | Undo functionality
/// 5. السحب للحذف | Swipe-to-delete pattern
/// ============================================================================

class DeleteRequestController extends GetxController {
  // ========================================
  // الخدمات | Services
  // ========================================

  final PostApiService _postService = PostApiService(dioClient);

  // ========================================
  // المتغيرات التفاعلية | Reactive Variables
  // ========================================

  /// قائمة المنشورات | Posts list
  final posts = <PostModel>[].obs;

  /// حالة التحميل | Loading state
  final isLoading = true.obs;

  /// رسالة الخطأ | Error message
  final errorMessage = Rxn<String>();

  /// معرفات المنشورات الجاري حذفها (لعرض مؤشر التحميل)
  /// IDs of posts being deleted (for showing loading indicator)
  final deletingIds = <int>{}.obs;

  /// المنشورات المحذوفة مؤخراً (للتراجع)
  /// Recently deleted posts (for undo)
  final recentlyDeleted = <PostModel>[].obs;

  // ========================================
  // دورة الحياة | Lifecycle
  // ========================================

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  // ========================================
  // جلب المنشورات | Fetch Posts
  // ========================================

  /// جلب المنشورات للعرض
  /// Fetch posts to display
  Future<void> fetchPosts() async {
    isLoading.value = true;
    errorMessage.value = null;

    final response = await _postService.getAllPosts();

    isLoading.value = false;

    if (response.isSuccess && response.hasData) {
      // خذ أول 10 فقط للعرض التوضيحي
      // Only take first 10 for demo
      posts.value = response.data!.take(10).toList();
    } else {
      errorMessage.value =
          response.error?.message ??
          'فشل في جلب المنشورات - Failed to fetch posts';
    }
  }

  // ========================================
  // حذف منشور - النهج التشاؤمي
  // Delete Post - Pessimistic Approach
  // ========================================

  /// حذف منشور (انتظر تأكيد الخادم ثم حدّث الواجهة)
  /// Delete a post (wait for server confirmation then update UI)
  ///
  /// النهج التشاؤمي: لا نحذف من الواجهة حتى ينجح الخادم
  /// Pessimistic approach: don't remove from UI until server succeeds
  Future<void> deletePost(PostModel post) async {
    // علّم كجاري الحذف | Mark as deleting
    deletingIds.add(post.id);

    // نفذ طلب DELETE | Make DELETE request
    final response = await _postService.deletePost(post.id);

    // أزل علامة الحذف | Remove deleting mark
    deletingIds.remove(post.id);

    if (response.isSuccess) {
      // احذف من القائمة | Remove from list
      posts.removeWhere((p) => p.id == post.id);
      // احفظ للتراجع | Save for undo
      recentlyDeleted.add(post);
      // أظهر رسالة نجاح | Show success message
      _showDeleteSuccessSnackbar(post);
    } else {
      _showErrorSnackbar(
        response.error?.message ?? 'فشل في حذف المنشور - Failed to delete post',
      );
    }
  }

  // ========================================
  // حذف تفاؤلي - نهج بديل
  // Optimistic Delete - Alternative Approach
  // ========================================

  /// حذف تفاؤلي (احذف من الواجهة فوراً، تراجع إذا فشل)
  /// Optimistic delete (remove from UI immediately, rollback if fails)
  Future<void> deletePostOptimistic(PostModel post) async {
    // الخطوة 1: احذف من الواجهة فوراً
    // Step 1: Remove from UI immediately
    final index = posts.indexOf(post);
    posts.remove(post);

    // الخطوة 2: نفذ استدعاء API
    // Step 2: Make API call
    final response = await _postService.deletePost(post.id);

    // الخطوة 3: تراجع إذا فشل
    // Step 3: Rollback if failed
    if (!response.isSuccess) {
      posts.insert(index, post);
      _showErrorSnackbar(
        'فشل الحذف. تم التراجع - Failed to delete. Changes reverted.',
      );
    } else {
      recentlyDeleted.add(post);
      _showDeleteSuccessSnackbar(post);
    }
  }

  // ========================================
  // تأكيد الحذف | Confirm Delete
  // ========================================

  /// عرض مربع تأكيد قبل الحذف
  /// Show confirmation dialog before deleting
  ///
  /// أفضل ممارسة: دائماً أكّد الإجراءات المدمرة
  /// Best Practice: Always confirm destructive actions
  Future<bool> confirmDelete(PostModel post) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف المنشور؟ - Delete Post?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'هل أنت متأكد من حذف هذا المنشور؟\nAre you sure you want to delete this post?',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Get.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يمكن التراجع عن هذا الإجراء.\nThis action cannot be undone.',
              style: TextStyle(
                color: Get.theme.colorScheme.error,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء - Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('حذف - Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ========================================
  // التراجع عن الحذف | Undo Delete
  // ========================================

  /// استعادة منشور محذوف
  /// Restore a deleted post
  void undoDelete(PostModel post) {
    recentlyDeleted.remove(post);
    posts.insert(0, post);
    Get.snackbar(
      'تمت الاستعادة - Restored',
      'تمت استعادة المنشور - Post restored',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // ========================================
  // رسائل Snackbar | Snackbar Messages
  // ========================================

  void _showDeleteSuccessSnackbar(PostModel post) {
    Get.snackbar(
      'تم الحذف - Deleted',
      'تم حذف المنشور: ${post.title}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      mainButton: TextButton(
        onPressed: () => undoDelete(post),
        child: const Text(
          'تراجع - Undo',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'خطأ - Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}
