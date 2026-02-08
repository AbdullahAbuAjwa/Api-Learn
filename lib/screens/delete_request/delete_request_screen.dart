import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controllers.dart';

/// ============================================================================
/// شاشة DELETE: توضح حذف البيانات عبر API باستخدام GetX
/// DELETE Screen: Demonstrates Deleting Data via API using GetX
/// ============================================================================
///
/// هذه الشاشة توضح | This screen demonstrates:
/// 1. تنفيذ طلبات DELETE لإزالة الموارد
///    Making DELETE requests to remove resources
/// 2. مربعات تأكيد قبل الحذف
///    Confirmation dialogs before deletion
/// 3. تحديثات واجهة المستخدم التفاؤلية
///    Optimistic UI updates
/// 4. معالجة أخطاء الحذف
///    Handling deletion errors
/// 5. وظيفة التراجع (مفهوم الحذف الناعم)
///    Undo functionality (soft delete concept)
///
/// أهداف التعلم | Learning Objectives:
/// - فهم كيف تعمل طلبات DELETE
///   Understand how DELETE requests work
/// - تعلم أنماط تجربة المستخدم للتأكيد
///   Learn about confirmation UX patterns
/// - رؤية التحديثات التفاؤلية مقابل التشاؤمية
///   See optimistic vs pessimistic updates
/// - فهم عدم التكرار (idempotency) لـ DELETE
///   Understand idempotency of DELETE
/// ============================================================================

/// شاشة حذف المنشورات باستخدام GetView
/// Delete request screen using GetView
class DeleteRequestScreen extends GetView<DeleteRequestController> {
  const DeleteRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // عنوان الشاشة | Screen title
        title: const Text('طلب DELETE - DELETE Request'),
        actions: [
          // زر التحديث | Refresh button
          Obx(
            () => IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.fetchPosts,
              tooltip: 'تحديث - Refresh',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ========================================
          // بطاقة المعلومات | Information Card
          // ========================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'طلب DELETE - DELETE Request',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'طلبات DELETE تحذف الموارد من الخادم. '
                  'اسحب لليسار على منشور أو اضغط زر الحذف لإزالته.\n'
                  'DELETE requests remove resources from the server. '
                  'Swipe left on a post or tap the delete button to remove it.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),

          // ========================================
          // قائمة المنشورات | Posts List
          // ========================================
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  /// بناء المحتوى التفاعلي | Build reactive content
  Widget _buildContent(BuildContext context) {
    return Obx(() {
      // حالة التحميل | Loading state
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // حالة الخطأ | Error state
      if (controller.errorMessage.value != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(controller.errorMessage.value!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.fetchPosts,
                child: const Text('إعادة المحاولة - Retry'),
              ),
            ],
          ),
        );
      }

      // حالة القائمة الفارغة | Empty state
      if (controller.posts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('تم حذف جميع المنشورات! - All posts deleted!'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.fetchPosts,
                child: const Text('إعادة تحميل المنشورات - Reload Posts'),
              ),
            ],
          ),
        );
      }

      // قائمة المنشورات مع السحب للتحديث | Posts list with pull-to-refresh
      return RefreshIndicator(
        onRefresh: controller.fetchPosts,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            return _buildPostCard(context, post);
          },
        ),
      );
    });
  }

  /// بناء بطاقة المنشور مع السحب للحذف
  /// Build post card with swipe-to-delete
  Widget _buildPostCard(BuildContext context, post) {
    return Obx(() {
      // التحقق مما إذا كان المنشور قيد الحذف | Check if post is being deleted
      final isDeleting = controller.deletingIds.contains(post.id);

      // Dismissible يسمح بالسحب للحذف | Dismissible allows swipe-to-delete
      return Dismissible(
        key: Key('post_${post.id}'),
        direction: DismissDirection.endToStart,
        // خلفية السحب (أيقونة الحذف) | Swipe background (delete icon)
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        // تأكيد الحذف قبل السحب | Confirm delete before dismiss
        confirmDismiss: (_) => controller.confirmDelete(post),
        // تنفيذ الحذف بعد السحب | Execute delete after dismiss
        onDismissed: (_) => controller.deletePost(post),
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            enabled: !isDeleting,
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('${post.id}'),
            ),
            title: Text(
              post.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // زر الحذف | Delete button
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: isDeleting
                  ? null
                  : () async {
                      // تأكيد ثم حذف | Confirm then delete
                      final confirmed = await controller.confirmDelete(post);
                      if (confirmed) {
                        controller.deletePost(post);
                      }
                    },
              tooltip: 'حذف المنشور - Delete post',
            ),
          ),
        ),
      );
    });
  }
}
