import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';

/// ============================================================================
/// شاشة PUT/PATCH: توضح تحديث البيانات عبر API
/// PUT/PATCH Screen: Demonstrates Updating Data via API
/// ============================================================================
///
/// هذه الشاشة توضح | This screen demonstrates:
/// 1. طلبات PUT (استبدال المورد بالكامل)
///    PUT requests (full resource replacement)
/// 2. طلبات PATCH (تحديث جزئي)
///    PATCH requests (partial updates)
/// 3. الفرق بين PUT و PATCH
///    Difference between PUT and PATCH
/// 4. تعبئة النموذج المسبق للتحرير
///    Form pre-population for editing
/// 5. التحديثات التفاؤلية مقابل التشاؤمية
///    Optimistic vs pessimistic updates
///
/// أهداف التعلم | Learning Objectives:
/// - فهم دلالات PUT مقابل PATCH
///   Understand PUT vs PATCH semantics
/// - متى تستخدم كل طريقة
///   Learn when to use each method
/// - رؤية أنماط التحديث عملياً
///   See update patterns in action
/// - فهم عدم التكرار في طرق HTTP
///   Understand idempotency in HTTP methods
/// ============================================================================

class UpdateRequestScreen extends StatefulWidget {
  const UpdateRequestScreen({super.key});

  @override
  State<UpdateRequestScreen> createState() => _UpdateRequestScreenState();
}

class _UpdateRequestScreenState extends State<UpdateRequestScreen> {
  final PostApiService _postService = PostApiService(dioClient);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  List<PostModel> _posts = [];
  PostModel? _selectedPost;
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _successMessage;
  String? _errorMessage;

  /// Track which update method to use
  bool _usePatch = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _postService.getAllPosts();

    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.hasData) {
        _posts = response.data!.take(10).toList();
      } else {
        _errorMessage = response.error?.message ?? 'Failed to fetch posts';
      }
    });
  }

  /// اختيار منشور للتحرير | Select a post for editing
  void _selectPost(PostModel post) {
    setState(() {
      _selectedPost = post;
      _titleController.text = post.title;
      _bodyController.text = post.body;
      _successMessage = null;
      _errorMessage = null;
    });
  }

  /// ========================================
  /// تحديث منشور (PUT أو PATCH)
  /// Update Post (PUT or PATCH)
  /// ========================================
  Future<void> _updatePost() async {
    if (_selectedPost == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
      _successMessage = null;
      _errorMessage = null;
    });

    ApiResponse<PostModel> response;

    if (_usePatch) {
      // ========================================
      // PATCH Request - Partial Update
      // ========================================
      // Only send the fields that changed
      // The server should merge these with existing data
      response = await _postService.patchPost(
        id: _selectedPost!.id,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
    } else {
      // ========================================
      // PUT Request - Full Replacement
      // ========================================
      // Send the complete resource
      // The server replaces the entire resource
      final updatedPost = _selectedPost!.copyWith(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
      response = await _postService.updatePost(updatedPost);
    }

    setState(() {
      _isUpdating = false;

      if (response.isSuccess && response.hasData) {
        _successMessage =
            'تم تحديث المنشور بنجاح باستخدام ${_usePatch ? "PATCH" : "PUT"}!\nPost updated successfully using ${_usePatch ? "PATCH" : "PUT"}!';

        // تحديث القائمة المحلية | Update the local list
        final index = _posts.indexWhere((p) => p.id == _selectedPost!.id);
        if (index != -1) {
          _posts[index] = response.data!;
        }

        _selectedPost = response.data;
      } else {
        _errorMessage =
            response.error?.message ??
            'فشل في تحديث المنشور - Failed to update post';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديث PUT & PATCH - PUT & PATCH Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchPosts,
            tooltip: 'تحديث - Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // ========================================
                // Posts List (Left Panel)
                // ========================================
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'اختر منشوراً للتحرير - Select a Post to Edit',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'اضغط على منشور لتحميله في المحرر\nTap on a post to load it into the editor',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            final isSelected = _selectedPost?.id == post.id;

                            return Card(
                              color: isSelected
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                  : null,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text('${post.id}'),
                                ),
                                title: Text(
                                  post.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  post.body,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                selected: isSelected,
                                onTap: () => _selectPost(post),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                const VerticalDivider(width: 1),

                // ========================================
                // Edit Form (Right Panel)
                // ========================================
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // PUT vs PATCH explanation
                        Card(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PUT مقابل PATCH - PUT vs PATCH',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                _buildComparison(
                                  'PUT',
                                  '• يستبدل المورد بالكامل\n• يجب إرسال جميع الحقول\n• عملية غير متكررة (idempotent)\n'
                                      '• Replaces entire resource\n• All fields must be sent\n• Idempotent operation',
                                ),
                                const SizedBox(height: 8),
                                _buildComparison(
                                  'PATCH',
                                  '• يحدث فقط الحقول المحددة\n• حمولة طلب أصغر\n• أفضل للتحديثات الجزئية\n'
                                      '• Updates only specified fields\n• Smaller request payload\n• Better for partial updates',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Method selector
                        Row(
                          children: [
                            const Text('طريقة التحديث: - Update Method: '),
                            const SizedBox(width: 16),
                            ChoiceChip(
                              label: const Text('PATCH'),
                              selected: _usePatch,
                              onSelected: (_) =>
                                  setState(() => _usePatch = true),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('PUT'),
                              selected: !_usePatch,
                              onSelected: (_) =>
                                  setState(() => _usePatch = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Edit form
                        if (_selectedPost != null) ...[
                          Text(
                            'تحرير منشور #${_selectedPost!.id} - Editing Post #${_selectedPost!.id}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),

                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(
                                    labelText: 'العنوان - Title',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'العنوان مطلوب - Title is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _bodyController,
                                  decoration: const InputDecoration(
                                    labelText: 'المحتوى - Body',
                                    border: OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                  ),
                                  maxLines: 5,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'المحتوى مطلوب - Body is required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          FilledButton.icon(
                            onPressed: _isUpdating ? null : _updatePost,
                            icon: _isUpdating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              _isUpdating
                                  ? 'جاري التحديث... - Updating...'
                                  : 'تحديث باستخدام ${_usePatch ? "PATCH" : "PUT"} - Update with ${_usePatch ? "PATCH" : "PUT"}',
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),

                          if (_successMessage != null) ...[
                            const SizedBox(height: 16),
                            Card(
                              color: Colors.green.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _successMessage!,
                                      style: const TextStyle(
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
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
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ] else ...[
                          // لم يتم اختيار منشور | No post selected
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'اختر منشوراً من القائمة للتحرير\nSelect a post from the list to edit',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildComparison(String method, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: method == 'PATCH' ? Colors.blue : Colors.orange,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            method,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
