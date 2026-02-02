import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';

/// ============================================================================
/// شاشة DELETE: توضح حذف البيانات عبر API
/// DELETE Screen: Demonstrates Deleting Data via API
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

class DeleteRequestScreen extends StatefulWidget {
  const DeleteRequestScreen({super.key});

  @override
  State<DeleteRequestScreen> createState() => _DeleteRequestScreenState();
}

class _DeleteRequestScreenState extends State<DeleteRequestScreen> {
  // ========================================
  // الخدمة والحالة | Service and State
  // ========================================

  final PostApiService _postService = PostApiService(dioClient);

  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  /// تتبع المنشورات التي يتم حذفها للتغذية البصرية
  /// Track posts being deleted for UI feedback
  /// هذا يسمح بعرض حالة تحميل على عناصر محددة
  /// This allows showing a loading state on specific items
  final Set<int> _deletingIds = {};

  /// المنشورات المحذوفة مؤخراً لوظيفة التراجع
  /// Recently deleted posts for undo functionality
  /// في تطبيق حقيقي، هذا قد يُفعّل حذفاً ناعماً على الخادم
  /// In a real app, this might trigger a soft delete on the server
  final List<PostModel> _recentlyDeleted = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  /// جلب المنشورات للعرض | Fetch posts to display
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _postService.getAllPosts();

    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.hasData) {
        // خذ أول 10 فقط للعرض التوضيحي | Only take first 10 for demo
        _posts = response.data!.take(10).toList();
      } else {
        _errorMessage =
            response.error?.message ??
            'فشل في جلب المنشورات - Failed to fetch posts';
      }
    });
  }

  /// ========================================
  /// حذف منشور (DELETE /posts/{id})
  /// Delete Post (DELETE /posts/{id})
  /// ========================================
  ///
  /// هذا يوضح نمطين | This demonstrates two patterns:
  /// 1. التشاؤمي: انتظر تأكيد الخادم، ثم حدّث الواجهة
  ///    Pessimistic: Wait for server confirmation, then update UI
  /// 2. التفاؤلي: حدّث الواجهة فوراً، تراجع إذا فشل الخادم
  ///    Optimistic: Update UI immediately, rollback if server fails
  ///
  /// نستخدم النهج التشاؤمي هنا للأمان
  /// We're using the pessimistic approach here for safety.
  Future<void> _deletePost(PostModel post) async {
    // الخطوة 1: ضع علامة حذف جارٍ (للتغذية البصرية)
    // Step 1: Mark as deleting (for UI feedback)
    setState(() {
      _deletingIds.add(post.id);
    });

    // الخطوة 2: نفذ طلب DELETE
    // Step 2: Make the DELETE request
    final response = await _postService.deletePost(post.id);

    // الخطوة 3: عالج الاستجابة
    // Step 3: Handle the response
    setState(() {
      _deletingIds.remove(post.id);

      if (response.isSuccess) {
        // احذف من القائمة | Remove from list
        _posts.removeWhere((p) => p.id == post.id);

        // احفظ للتراجع | Save for undo
        _recentlyDeleted.add(post);

        // أظهر snackbar النجاح مع خيار التراجع
        // Show success snackbar with undo option
        _showDeleteSuccessSnackbar(post);
      } else {
        // أظهر الخطأ | Show error
        _showErrorSnackbar(
          response.error?.message ??
              'فشل في حذف المنشور - Failed to delete post',
        );
      }
    });
  }

  /// ========================================
  /// الحذف التفاؤلي (نهج بديل)
  /// Optimistic Delete (Alternative Approach)
  /// ========================================
  ///
  /// هذه الدالة توضح النهج التفاؤلي
  /// This method shows the optimistic approach:
  /// - احذف من الواجهة فوراً | Remove from UI immediately
  /// - نفذ استدعاء API | Make API call
  /// - استعد إذا فشل | Restore if it fails
  Future<void> deletePostOptimistic(PostModel post) async {
    // الخطوة 1: احذف من الواجهة فوراً (تفاؤلي)
    // Step 1: Remove from UI immediately (optimistic)
    final index = _posts.indexOf(post);
    setState(() {
      _posts.remove(post);
    });

    // الخطوة 2: نفذ استدعاء API
    // Step 2: Make the API call
    final response = await _postService.deletePost(post.id);

    // الخطوة 3: عالج الفشل بالتراجع
    // Step 3: Handle failure by rolling back
    if (!response.isSuccess) {
      setState(() {
        // استعد المنشور في موقعه الأصلي
        // Restore the post at its original position
        _posts.insert(index, post);
      });
      _showErrorSnackbar(
        'فشل الحذف. تم التراجع عن التغييرات - Failed to delete. Changes reverted.',
      );
    } else {
      _recentlyDeleted.add(post);
      _showDeleteSuccessSnackbar(post);
    }
  }

  /// أظهر مربع تأكيد قبل الحذف
  /// Show confirmation dialog before deleting
  ///
  /// أفضل ممارسة: دائماً أكّد الإجراءات المدمرة
  /// Best Practice: Always confirm destructive actions
  Future<bool> _confirmDelete(PostModel post) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يمكن التراجع عن هذا الإجراء.\nThis action cannot be undone.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء - Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('حذف - Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// التراجع عن الحذف (استعادة المنشور للقائمة)
  /// Undo delete (restore post to list)
  ///
  /// ملاحظة: هذا تراجع للواجهة فقط للتوضيح
  /// Note: This is a UI-only undo for demonstration.
  /// في تطبيق حقيقي، ستفعل التالي | In a real app, you would:
  /// - استخدم الحذف الناعم على الخادم | Use soft delete on the server
  /// - استدعِ نقطة نهاية API للاستعادة | Call an undelete/restore API endpoint
  void _undoDelete(PostModel post) {
    setState(() {
      _recentlyDeleted.remove(post);
      // أضف مرة أخرى لبداية القائمة | Add back to the beginning of the list
      _posts.insert(0, post);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت استعادة المنشور - Post restored'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// أظهر snackbar النجاح مع خيار التراجع
  /// Show success snackbar with undo option
  void _showDeleteSuccessSnackbar(PostModel post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف المنشور - Post "${post.title}" deleted'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'تراجع - Undo',
          onPressed: () => _undoDelete(post),
        ),
      ),
    );
  }

  /// أظهر snackbar الخطأ | Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب DELETE - DELETE Request'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchPosts,
            tooltip: 'تحديث - Refresh',
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
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
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
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPosts,
              child: const Text('إعادة المحاولة - Retry'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('تم حذف جميع المنشورات! - All posts deleted!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPosts,
              child: const Text('إعادة تحميل المنشورات - Reload Posts'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  /// بناء بطاقة المنشور مع السحب للحذف
  /// Build post card with swipe-to-delete
  Widget _buildPostCard(PostModel post) {
    final isDeleting = _deletingIds.contains(post.id);

    // Dismissible يسمح بالسحب للحذف | Dismissible allows swipe-to-delete
    return Dismissible(
      key: Key('post_${post.id}'),
      direction: DismissDirection.endToStart,
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
      confirmDismiss: (_) => _confirmDelete(post),
      onDismissed: (_) => _deletePost(post),
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
          title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            post.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: isDeleting
                ? null
                : () async {
                    final confirmed = await _confirmDelete(post);
                    if (confirmed) {
                      _deletePost(post);
                    }
                  },
            tooltip: 'حذف المنشور - Delete post',
          ),
        ),
      ),
    );
  }
}
