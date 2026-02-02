import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';

/// ============================================================================
/// شاشة GET: توضح جلب البيانات من API
/// GET Screen: Demonstrates Fetching Data from API
/// ============================================================================
///
/// هذه الشاشة توضح | This screen demonstrates:
/// 1. تنفيذ طلبات GET لجلب البيانات
///    Making GET requests to fetch data
/// 2. التعامل مع حالات التحميل
///    Handling loading states
/// 3. عرض رسائل الخطأ
///    Displaying error messages
/// 4. تحليل وعرض بيانات JSON
///    Parsing and displaying JSON data
/// 5. مفاهيم التقسيم (Pagination)
///    Pagination concepts
///
/// أهداف التعلم | Learning Objectives:
/// - فهم كيف تعمل طلبات GET
///   Understand how GET requests work
/// - تعلم التعامل مع العمليات غير المتزامنة في Flutter
///   Learn to handle async operations in Flutter
/// - رؤية تحليل JSON قيد التنفيذ
///   See JSON parsing in action
/// - فهم معالجة الأخطاء في واجهة المستخدم
///   Understand error handling in UI
/// ============================================================================

class GetRequestScreen extends StatefulWidget {
  const GetRequestScreen({super.key});

  @override
  State<GetRequestScreen> createState() => _GetRequestScreenState();
}

class _GetRequestScreenState extends State<GetRequestScreen> {
  // ========================================
  // متغيرات الحالة | State Variables
  // ========================================

  /// نسخة خدمة API - ننشئها مرة ونعيد استخدامها لجميع الطلبات
  /// The API service instance - We create it once and reuse it for all requests
  final PostApiService _postService = PostApiService(dioClient);

  /// قائمة المنشورات المجلوبة من API
  /// List of posts fetched from the API
  /// فارغة مبدئياً، تُملأ بعد الجلب الناجح
  /// Initially empty, populated after successful fetch
  List<PostModel> _posts = [];

  /// حالة التحميل - true عندما يكون هناك طلب قيد التنفيذ
  /// Loading state - true when a request is in progress
  /// تُستخدم لعرض مؤشر التحميل وتعطيل الأزرار
  /// Used to show loading indicator and disable buttons
  bool _isLoading = false;

  /// رسالة الخطأ للعرض إذا فشل الطلب
  /// Error message to display if request fails
  /// null تعني لا يوجد خطأ | null means no error
  String? _errorMessage;

  /// المنشور المحدد لعرض التفاصيل
  /// Selected post for detail view
  /// null تعني لا يوجد منشور محدد | null means no post is selected
  PostModel? _selectedPost;

  /// الفلتر الحالي - null يعني عرض الكل، وإلا فلترة حسب userId
  /// Current filter - null means show all, otherwise filter by userId
  int? _filterByUserId;

  @override
  void initState() {
    super.initState();
    // جلب المنشورات عند تحميل الشاشة
    // Fetch posts when screen loads
    // هذا نمط شائع لجلب البيانات
    // This is a common pattern for data fetching
    _fetchAllPosts();
  }

  /// ========================================
  /// جلب جميع المنشورات (GET /posts)
  /// Fetch All Posts (GET /posts)
  /// ========================================
  ///
  /// هذه الدالة توضح التدفق الكامل لطلب GET:
  /// This method demonstrates the complete flow of a GET request:
  /// 1. تعيين حالة التحميل | Set loading state
  /// 2. تنفيذ استدعاء API | Make the API call
  /// 3. معالجة النجاح (تحديث البيانات) | Handle success (update data)
  /// 4. معالجة الأخطاء (عرض رسالة) | Handle errors (show message)
  /// 5. إعادة تعيين حالة التحميل | Reset loading state
  Future<void> _fetchAllPosts() async {
    // الخطوة 1: تعيين حالة التحميل ومسح أي أخطاء سابقة
    // Step 1: Set loading state and clear any previous errors
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _filterByUserId = null;
    });

    // الخطوة 2: تنفيذ استدعاء API
    // Step 2: Make the API call
    // الخدمة تتعامل مع كل تفاصيل HTTP
    // The service handles all the HTTP details
    final response = await _postService.getAllPosts();

    // الخطوة 3 و 4: معالجة الاستجابة
    // Step 3 & 4: Handle the response
    setState(() {
      _isLoading = false;

      if (response.isSuccess && response.hasData) {
        // نجاح: تحديث قائمة المنشورات
        // Success: Update the posts list
        _posts = response.data!;
      } else {
        // خطأ: عرض رسالة الخطأ
        // Error: Show error message
        _errorMessage =
            response.error?.message ??
            response.message ??
            'فشل في جلب المنشورات - Failed to fetch posts';
      }
    });
  }

  /// ========================================
  /// جلب منشور واحد (GET /posts/{id})
  /// Fetch Single Post (GET /posts/{id})
  /// ========================================
  ///
  /// يوضح جلب مورد محدد بواسطة المعرف
  /// Demonstrates fetching a specific resource by ID
  /// هذا مفيد لعرض التفاصيل
  /// This is useful for detail views
  Future<void> _fetchPostById(int id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _postService.getPostById(id);

    setState(() {
      _isLoading = false;

      if (response.isSuccess && response.hasData) {
        _selectedPost = response.data;
        // عرض مربع حوار التفاصيل | Show detail dialog
        _showPostDetailDialog();
      } else {
        _errorMessage =
            response.error?.message ??
            'فشل في جلب المنشور - Failed to fetch post';
      }
    });
  }

  /// ========================================
  /// جلب المنشورات حسب المستخدم (GET /posts?userId={userId})
  /// Fetch Posts by User (GET /posts?userId={userId})
  /// ========================================
  ///
  /// يوضح استخدام معاملات الاستعلام لفلترة النتائج
  /// Demonstrates using query parameters to filter results
  /// الخادم يتعامل مع الفلترة | The server handles the filtering
  ///
  /// معاملات الاستعلام تُستخدم لـ:
  /// Query parameters are used for:
  /// - الفلترة: ?status=active | Filtering: ?status=active
  /// - التقسيم: ?page=2&limit=10 | Pagination: ?page=2&limit=10
  /// - الترتيب: ?sort=name&order=asc | Sorting: ?sort=name&order=asc
  /// - البحث: ?q=search+term | Searching: ?q=search+term
  Future<void> _fetchPostsByUser(int userId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _filterByUserId = userId;
    });

    final response = await _postService.getPostsByUser(userId);

    setState(() {
      _isLoading = false;

      if (response.isSuccess && response.hasData) {
        _posts = response.data!;
      } else {
        _errorMessage =
            response.error?.message ??
            'فشل في جلب المنشورات - Failed to fetch posts';
      }
    });
  }

  /// عرض مربع حوار تفاصيل المنشور
  /// Show post detail dialog
  void _showPostDetailDialog() {
    if (_selectedPost == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('منشور #${_selectedPost!.id} - Post #${_selectedPost!.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // العنوان | Title
              Text(
                'العنوان - Title:',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(_selectedPost!.title),
              const SizedBox(height: 16),

              // المحتوى | Body
              Text(
                'المحتوى - Body:',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(_selectedPost!.body),
              const SizedBox(height: 16),

              // معرف المستخدم | User ID
              Text(
                'معرف المستخدم - User ID: ${_selectedPost!.userId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق - Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات GET - GET Requests'),
        actions: [
          // زر التحديث | Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchAllPosts,
            tooltip: 'تحديث جميع المنشورات - Refresh all posts',
          ),
        ],
      ),
      body: Column(
        children: [
          // ========================================
          // قسم الفلترة | Filter Section
          // ========================================
          _buildFilterSection(),

          // ========================================
          // قسم المحتوى | Content Section
          // ========================================
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  /// بناء قسم chips الفلترة
  /// Build the filter chips section
  Widget _buildFilterSection() {
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
            child: Row(
              children: [
                // chip "الكل" | "All" chip
                FilterChip(
                  label: const Text('جميع المنشورات - All Posts'),
                  selected: _filterByUserId == null,
                  onSelected: (_) => _fetchAllPosts(),
                ),
                const SizedBox(width: 8),
                // chips فلترة المستخدم | User filter chips
                ...List.generate(5, (index) {
                  final userId = index + 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('المستخدم $userId - User $userId'),
                      selected: _filterByUserId == userId,
                      onSelected: (_) => _fetchPostsByUser(userId),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// بناء منطقة المحتوى الرئيسية
  /// Build the main content area
  Widget _buildContent() {
    // عرض مؤشر التحميل | Show loading indicator
    if (_isLoading) {
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
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchAllPosts,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة - Retry'),
            ),
          ],
        ),
      );
    }

    // عرض حالة فارغة | Show empty state
    if (_posts.isEmpty) {
      return const Center(child: Text('لا توجد منشورات - No posts found'));
    }

    // عرض قائمة المنشورات | Show posts list
    return RefreshIndicator(
      onRefresh: _fetchAllPosts,
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

  /// بناء بطاقة لمنشور واحد
  /// Build a card for a single post
  Widget _buildPostCard(PostModel post) {
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
              onPressed: () => _fetchPostById(post.id),
              tooltip: 'عرض التفاصيل - View details',
            ),
          ],
        ),
        onTap: () => _fetchPostById(post.id),
      ),
    );
  }
}
