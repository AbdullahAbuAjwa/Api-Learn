import 'package:get/get.dart';
import '../core/core.dart';
import '../models/models.dart';

/// ============================================================================
/// متحكم طلب GET - إدارة حالة جلب البيانات باستخدام GetX
/// GET Request Controller - Managing data fetching state with GetX
/// ============================================================================
///
/// هذا المتحكم يوضح | This controller demonstrates:
/// 1. استخدام .obs لجعل المتغيرات تفاعلية
///    Using .obs to make variables reactive
/// 2. الحصول على البيانات من API باستخدام Dio
///    Fetching data from API using Dio
/// 3. إدارة حالات التحميل والخطأ والنجاح
///    Managing loading, error, and success states
/// 4. التقسيم الصفحي (Pagination)
///    Pagination support
/// 5. دورة حياة المتحكم (onInit, onClose)
///    Controller lifecycle (onInit, onClose)
///
/// لماذا GetxController بدل StatefulWidget؟
/// Why GetxController instead of StatefulWidget?
/// - فصل منطق العمل عن واجهة المستخدم
///   Separates business logic from UI
/// - أسهل للاختبار | Easier to test
/// - إعادة استخدام المنطق في شاشات متعددة
///   Reuse logic across multiple screens
/// - إدارة حالة أنظف | Cleaner state management
/// ============================================================================

class GetRequestController extends GetxController {
  // ========================================
  // الخدمات | Services
  // ========================================

  final PostApiService _postService = PostApiService(dioClient);

  // ========================================
  // المتغيرات التفاعلية | Reactive Variables
  // ========================================
  // في GetX، نستخدم .obs لجعل المتغيرات تفاعلية
  // In GetX, we use .obs to make variables reactive
  // أي تغيير في هذه المتغيرات سيُحدّث الواجهة تلقائياً
  // Any change to these variables will automatically update the UI

  /// قائمة المنشورات المجلوبة | List of fetched posts
  final posts = <PostModel>[].obs;

  /// حالة التحميل | Loading state
  final isLoading = false.obs;

  /// رسالة الخطأ | Error message
  final errorMessage = Rxn<String>();

  /// المنشور المختار للعرض التفصيلي | Selected post for detail view
  final selectedPost = Rxn<PostModel>();

  // ========================================
  // التقسيم الصفحي | Pagination
  // ========================================

  /// فلترة حسب معرف المستخدم | Filter by user ID
  /// null يعني عرض الكل | null means show all
  final filterByUserId = Rxn<int>();

  /// الصفحة الحالية | Current page
  final currentPage = 1.obs;

  /// عدد العناصر في كل صفحة | Items per page
  final int itemsPerPage = 10;

  /// هل يوجد صفحات أخرى | Has more pages
  final hasMore = true.obs;

  // ========================================
  // دورة الحياة | Lifecycle
  // ========================================

  /// تُستدعى عند إنشاء المتحكم
  /// Called when controller is created
  /// مكان مثالي لجلب البيانات الأولية
  /// Perfect place to fetch initial data
  @override
  void onInit() {
    super.onInit();
    fetchAllPosts();
  }

  // ========================================
  // جلب جميع المنشورات | Fetch All Posts
  // ========================================

  /// جلب جميع المنشورات من API
  /// Fetch all posts from API
  ///
  /// هذه الدالة توضح | This method demonstrates:
  /// - تحديث حالة التحميل تفاعلياً
  ///   Updating loading state reactively
  /// - تحويل استجابة API إلى نماذج
  ///   Converting API response to models
  /// - معالجة الأخطاء | Error handling
  Future<void> fetchAllPosts() async {
    isLoading.value = true;
    errorMessage.value = null;
    filterByUserId.value = null;

    final response = await _postService.getAllPosts();

    isLoading.value = false;

    if (response.isSuccess && response.hasData) {
      posts.value = response.data!;
    } else {
      errorMessage.value =
          response.error?.message ??
          'فشل في جلب المنشورات - Failed to fetch posts';
    }
  }

  // ========================================
  // جلب منشور واحد بالمعرف | Fetch Single Post
  // ========================================

  /// جلب منشور محدد بمعرفه
  /// Fetch a specific post by its ID
  Future<void> fetchPostById(int id) async {
    isLoading.value = true;
    errorMessage.value = null;

    final response = await _postService.getPostById(id);

    isLoading.value = false;

    if (response.isSuccess && response.hasData) {
      selectedPost.value = response.data;
    } else {
      errorMessage.value =
          response.error?.message ??
          'فشل في جلب المنشور - Failed to fetch post';
    }
  }

  // ========================================
  // جلب منشورات مستخدم | Fetch User Posts
  // ========================================

  /// جلب منشورات مستخدم معين
  /// Fetch posts for a specific user
  Future<void> fetchPostsByUser(int userId) async {
    isLoading.value = true;
    errorMessage.value = null;
    filterByUserId.value = userId;

    final response = await _postService.getPostsByUser(userId);

    isLoading.value = false;

    if (response.isSuccess && response.hasData) {
      posts.value = response.data!;
    } else {
      errorMessage.value =
          response.error?.message ??
          'فشل في جلب المنشورات - Failed to fetch posts';
    }
  }

  // ========================================
  // جلب مع تقسيم صفحي | Fetch with Pagination
  // ========================================

  /// جلب المنشورات مع دعم التقسيم الصفحي
  /// Fetch posts with pagination support
  Future<void> fetchPostsPaginated({bool loadMore = false}) async {
    if (loadMore && !hasMore.value) return;

    if (loadMore) {
      currentPage.value++;
    } else {
      currentPage.value = 1;
      posts.clear();
    }

    isLoading.value = true;
    errorMessage.value = null;

    final response = await _postService.getPostsPaginated(
      page: currentPage.value,
      limit: itemsPerPage,
    );

    isLoading.value = false;

    if (response.isSuccess && response.hasData) {
      if (loadMore) {
        posts.addAll(response.data!);
      } else {
        posts.value = response.data!;
      }
      hasMore.value = response.pagination?.hasNextPage ?? false;
    } else {
      errorMessage.value =
          response.error?.message ??
          'فشل في جلب المنشورات - Failed to fetch posts';
    }
  }

  // ========================================
  // تحديث البيانات | Refresh Data
  // ========================================

  /// إعادة تحميل جميع البيانات
  /// Reload all data
  Future<void> refreshPosts() async {
    currentPage.value = 1;
    hasMore.value = true;
    await fetchAllPosts();
  }
}
