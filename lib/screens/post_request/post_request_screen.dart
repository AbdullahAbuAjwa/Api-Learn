import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';

/// ============================================================================
/// شاشة POST: توضح إنشاء البيانات عبر API
/// POST Screen: Demonstrates Creating Data via API
/// ============================================================================
///
/// هذه الشاشة توضح | This screen demonstrates:
/// 1. تنفيذ طلبات POST لإنشاء موارد جديدة
///    Making POST requests to create new resources
/// 2. التحقق من صحة النموذج قبل الإرسال
///    Form validation before submission
/// 3. التعامل مع حالة النموذج والإرسال
///    Handling form state and submission
/// 4. عرض ملاحظات النجاح/الخطأ
///    Showing success/error feedback
/// 5. مسح النموذج بعد الإرسال الناجح
///    Clearing form after successful submission
///
/// أهداف التعلم | Learning Objectives:
/// - فهم كيف تعمل طلبات POST
///   Understand how POST requests work
/// - تعلم أنماط التحقق من النماذج
///   Learn form validation patterns
/// - رؤية كيفية إرسال جسم JSON في الطلبات
///   See how to send JSON body in requests
/// - فهم استجابات الخادم للإنشاء
///   Understand server responses for creation
/// ============================================================================

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  // ========================================
  // الخدمة وإدارة النموذج | Service and Form Management
  // ========================================

  final PostApiService _postService = PostApiService(dioClient);

  /// مفتاح النموذج للتحقق من الصحة
  /// Form key for validation
  /// هذا يسمح لنا بالتحقق من جميع حقول النموذج مرة واحدة
  /// This allows us to validate all form fields at once
  final _formKey = GlobalKey<FormState>();

  /// متحكمات النص لحقول النموذج
  /// Text controllers for form fields
  /// تعطينا الوصول لقيمة النص الحالية
  /// These give us access to the current text value
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _userIdController = TextEditingController(text: '1');

  // ========================================
  // متغيرات الحالة | State Variables
  // ========================================

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  /// قائمة المنشورات المُنشأة (للعرض التوضيحي)
  /// List of created posts (for demonstration)
  /// في تطبيق حقيقي، قد تنتقل لشاشة القائمة بدلاً من ذلك
  /// In a real app, you might navigate to a list screen instead
  final List<PostModel> _createdPosts = [];

  @override
  void dispose() {
    // دائماً تخلص من المتحكمات لمنع تسرب الذاكرة
    // Always dispose controllers to prevent memory leaks
    _titleController.dispose();
    _bodyController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  /// ========================================
  /// إنشاء منشور (POST /posts)
  /// Create Post (POST /posts)
  /// ========================================
  ///
  /// هذه الدالة توضح | This method demonstrates:
  /// 1. التحقق من النموذج قبل استدعاء API
  ///    Form validation before API call
  /// 2. تحويل بيانات النموذج إلى جسم الطلب
  ///    Converting form data to request body
  /// 3. معالجة النجاح (عرض رسالة، مسح النموذج)
  ///    Handling success (show message, clear form)
  /// 4. معالجة الأخطاء (عرض رسالة الخطأ)
  ///    Handling errors (show error message)
  Future<void> _createPost() async {
    // الخطوة 1: التحقق من صحة النموذج
    // Step 1: Validate the form
    // هذا يتحقق من جميع validators في TextFormField
    // This checks all TextFormField validators
    if (!_formKey.currentState!.validate()) {
      return; // لا تتابع إذا فشل التحقق | Don't proceed if validation fails
    }

    // الخطوة 2: تحضير البيانات
    // Step 2: Prepare the data
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final userId = int.tryParse(_userIdController.text) ?? 1;

    // الخطوة 3: بدء التحميل
    // Step 3: Start loading
    setState(() {
      _isLoading = true;
      _successMessage = null;
      _errorMessage = null;
    });

    // الخطوة 4: تنفيذ استدعاء API
    // Step 4: Make the API call
    final response = await _postService.createPost(
      title: title,
      body: body,
      userId: userId,
    );

    // الخطوة 5: معالجة الاستجابة
    // Step 5: Handle the response
    setState(() {
      _isLoading = false;

      if (response.isSuccess && response.hasData) {
        // نجاح! | Success!
        _successMessage =
            'تم إنشاء المنشور بنجاح! - Post created successfully!\nالمعرف - ID: ${response.data!.id}';
        _createdPosts.insert(
          0,
          response.data!,
        ); // أضف لأعلى القائمة | Add to top of list

        // مسح النموذج للإدخال التالي
        // Clear the form for the next entry
        _titleController.clear();
        _bodyController.clear();
        // احتفظ بـ userId للراحة | Keep userId for convenience
      } else {
        // خطأ | Error
        _errorMessage =
            response.error?.message ??
            response.message ??
            'فشل في إنشاء المنشور - Failed to create post';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب POST - POST Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========================================
            // بطاقة المعلومات | Information Card
            // ========================================
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'طلب POST - POST Request',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'طلبات POST تُستخدم لإنشاء موارد جديدة على الخادم. '
                      'البيانات تُرسل في جسم الطلب كـ JSON.\n'
                      'POST requests are used to CREATE new resources on the server. '
                      'The data is sent in the request body as JSON.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========================================
            // نموذج إنشاء منشور | Create Post Form
            // ========================================
            Text(
              'إنشاء منشور جديد - Create New Post',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // حقل العنوان | Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان - Title',
                      hintText: 'أدخل عنوان المنشور - Enter post title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      // قواعد التحقق | Validation rules:
                      // 1. ليس فارغاً | Not empty
                      // 2. الحد الأدنى للطول | Minimum length
                      if (value == null || value.trim().isEmpty) {
                        return 'العنوان مطلوب - Title is required';
                      }
                      if (value.trim().length < 3) {
                        return 'العنوان يجب أن يكون 3 أحرف على الأقل - Title must be at least 3 characters';
                      }
                      return null; // التحقق نجح | Validation passed
                    },
                  ),
                  const SizedBox(height: 16),

                  // حقل المحتوى | Body Field
                  TextFormField(
                    controller: _bodyController,
                    decoration: const InputDecoration(
                      labelText: 'المحتوى - Body',
                      hintText: 'أدخل محتوى المنشور - Enter post content',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.article),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'المحتوى مطلوب - Body is required';
                      }
                      if (value.trim().length < 10) {
                        return 'المحتوى يجب أن يكون 10 أحرف على الأقل - Body must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // حقل معرف المستخدم | User ID Field
                  TextFormField(
                    controller: _userIdController,
                    decoration: const InputDecoration(
                      labelText: 'معرف المستخدم - User ID',
                      hintText:
                          'أدخل معرف المستخدم (1-10) - Enter user ID (1-10)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'معرف المستخدم مطلوب - User ID is required';
                      }
                      final userId = int.tryParse(value);
                      if (userId == null) {
                        return 'معرف المستخدم يجب أن يكون رقماً - User ID must be a number';
                      }
                      if (userId < 1 || userId > 10) {
                        return 'معرف المستخدم يجب أن يكون بين 1 و 10 - User ID must be between 1 and 10';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ========================================
            // زر الإرسال | Submit Button
            // ========================================
            FilledButton.icon(
              onPressed: _isLoading ? null : _createPost,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isLoading
                    ? 'جاري الإنشاء... - Creating...'
                    : 'إنشاء منشور - Create Post',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // ========================================
            // رسائل التغذية الراجعة | Feedback Messages
            // ========================================
            if (_successMessage != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ========================================
            // قائمة المنشورات المُنشأة | Created Posts List
            // ========================================
            if (_createdPosts.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'المنشورات المُنشأة حديثاً - Recently Created Posts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...(_createdPosts.map(
                (post) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${post.id}')),
                    title: Text(post.title),
                    subtitle: Text(
                      post.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Chip(label: Text('مستخدم - User ${post.userId}')),
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
