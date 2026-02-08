import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controllers.dart';
import '../../models/models.dart';

/// ============================================================================
/// شاشة GET: توضح جلب البيانات من API (باستخدام GetX)
/// GET Screen: Demonstrates Fetching Data from API (using GetX)
/// ============================================================================
///
/// هذه الشاشة توضح | This screen demonstrates:
/// 1. استخدام GetView للربط التلقائي مع المتحكم
///    Using GetView for automatic controller binding
/// 2. استخدام Obx() للتحديث التفاعلي للواجهة
///    Using Obx() for reactive UI updates
/// 3. جلب البيانات من API | Fetching data from API
/// 4. الفلترة والتقسيم الصفحي | Filtering and pagination
///
/// GetView<T> مقابل StatefulWidget:
/// GetView<T> vs StatefulWidget:
/// - GetView يوفر وصولاً مباشراً للمتحكم عبر controller
///   GetView provides direct access to controller via controller
/// - لا حاجة لـ setState - Obx يتعامل مع التحديثات
///   No need for setState - Obx handles updates
/// - المنطق في المتحكم، الواجهة في الشاشة
///   Logic in controller, UI in screen
/// ============================================================================

class GetRequestScreen extends GetView<GetRequestController> {
  const GetRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات GET - GET Requests'),
        actions: [
          // Obx يراقب التغييرات في المتغيرات التفاعلية
          // Obx watches changes in reactive variables
          Obx(
            () => IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.fetchAllPosts,
              tooltip: 'تحديث جميع المنشورات - Refresh all posts',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ========================================
          // قسم الفلترة | Filter Section
          // ========================================
          _buildFilterSection(context),

          // ========================================
          // قسم المحتوى | Content Section
          // ========================================
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  /// بناء قسم chips الفلترة
  /// Build the filter chips section
  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'فلترة حسب المستخدم - Filter by User:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Row(
                children: [
                  // chip "الكل" | "All" chip
                  FilterChip(
                    label: const Text('جميع المنشورات - All Posts'),
                    selected: controller.filterByUserId.value == null,
                    onSelected: (_) => controller.fetchAllPosts(),
                  ),
                  const SizedBox(width: 8),
                  // chips فلترة المستخدم | User filter chips
                  ...List.generate(5, (index) {
                    final userId = index + 1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('المستخدم $userId - User $userId'),
                        selected: controller.filterByUserId.value == userId,
                        onSelected: (_) => controller.fetchPostsByUser(userId),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء منطقة المحتوى الرئيسية (تفاعلية مع Obx)
  /// Build the main content area (reactive with Obx)
  Widget _buildContent(BuildContext context) {
    // Obx يُعيد بناء هذا الجزء فقط عند تغيير المتغيرات التفاعلية
    // Obx rebuilds only this part when reactive variables change
    return Obx(() {
      // عرض مؤشر التحميل | Show loading indicator
      if (controller.isLoading.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري جلب المنشورات... - Fetching posts...'),
            ],
          ),
        );
      }

      // عرض رسالة الخطأ | Show error message
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
              Text(
                controller.errorMessage.value!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.fetchAllPosts,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة - Retry'),
              ),
            ],
          ),
        );
      }

      // عرض حالة فارغة | Show empty state
      if (controller.posts.isEmpty) {
        return const Center(child: Text('لا توجد منشورات - No posts found'));
      }

      // عرض قائمة المنشورات | Show posts list
      return RefreshIndicator(
        onRefresh: controller.fetchAllPosts,
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

  /// بناء بطاقة لمنشور واحد
  /// Build a card for a single post
  Widget _buildPostCard(BuildContext context, PostModel post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text('${post.id}'),
        ),
        title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text('المستخدم ${post.userId}'),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () => _showPostDetail(context, post),
              tooltip: 'عرض التفاصيل - View details',
            ),
          ],
        ),
        onTap: () => _showPostDetail(context, post),
      ),
    );
  }

  /// عرض تفاصيل المنشور باستخدام Get.dialog
  /// Show post details using Get.dialog
  void _showPostDetail(BuildContext context, PostModel post) {
    // نستخدم Get.dialog بدل showDialog
    // We use Get.dialog instead of showDialog
    Get.dialog(
      AlertDialog(
        title: Text('منشور #${post.id} - Post #${post.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'العنوان - Title:',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(post.title),
              const SizedBox(height: 16),
              Text(
                'المحتوى - Body:',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(post.body),
              const SizedBox(height: 16),
              Text(
                'معرف المستخدم - User ID: ${post.userId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            // Get.back() بدل Navigator.pop()
            // Get.back() instead of Navigator.pop()
            onPressed: () => Get.back(),
            child: const Text('إغلاق - Close'),
          ),
        ],
      ),
    );
  }
}
