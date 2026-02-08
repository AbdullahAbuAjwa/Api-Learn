import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controllers.dart';

/// ============================================================================
/// شاشة PUT/PATCH: توضح تحديث البيانات عبر API باستخدام GetX
/// PUT/PATCH Screen: Demonstrates Updating Data via API using GetX
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

/// شاشة تحديث المنشورات باستخدام GetView
/// Update request screen using GetView
class UpdateRequestScreen extends GetView<UpdateRequestController> {
  const UpdateRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // عنوان الشاشة | Screen title
        title: const Text('تحديث PUT & PATCH - PUT & PATCH Requests'),
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
      // محتوى الشاشة التفاعلي | Reactive screen content
      body: Obx(() {
        // عرض مؤشر التحميل أثناء جلب البيانات
        // Show loading indicator while fetching data
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Row(
          children: [
            // ========================================
            // قائمة المنشورات (اللوحة اليسرى)
            // Posts List (Left Panel)
            // ========================================
            Expanded(flex: 2, child: _buildPostsList(context)),

            // الفاصل العمودي | Vertical Divider
            const VerticalDivider(width: 1),

            // ========================================
            // نموذج التحرير (اللوحة اليمنى)
            // Edit Form (Right Panel)
            // ========================================
            Expanded(flex: 3, child: _buildEditPanel(context)),
          ],
        );
      }),
    );
  }

  /// بناء قائمة المنشورات | Build posts list
  Widget _buildPostsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // رأس القائمة | List header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
        // قائمة المنشورات التفاعلية | Reactive posts list
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: controller.posts.length,
              itemBuilder: (context, index) {
                final post = controller.posts[index];
                final isSelected = controller.selectedPost.value?.id == post.id;

                return Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${post.id}')),
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
                    onTap: () => controller.selectPost(post),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// بناء لوحة التحرير | Build edit panel
  Widget _buildEditPanel(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ========================================
          // بطاقة شرح PUT مقابل PATCH
          // PUT vs PATCH explanation card
          // ========================================
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PUT مقابل PATCH - PUT vs PATCH',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // مقارنة PUT | PUT comparison
                  _buildComparison(
                    context,
                    'PUT',
                    '• يستبدل المورد بالكامل\n• يجب إرسال جميع الحقول\n• عملية غير متكررة (idempotent)\n'
                        '• Replaces entire resource\n• All fields must be sent\n• Idempotent operation',
                  ),
                  const SizedBox(height: 8),
                  // مقارنة PATCH | PATCH comparison
                  _buildComparison(
                    context,
                    'PATCH',
                    '• يحدث فقط الحقول المحددة\n• حمولة طلب أصغر\n• أفضل للتحديثات الجزئية\n'
                        '• Updates only specified fields\n• Smaller request payload\n• Better for partial updates',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ========================================
          // محدد طريقة التحديث | Method selector
          // ========================================
          Obx(
            () => Row(
              children: [
                const Text('طريقة التحديث: - Update Method: '),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('PATCH'),
                  selected: controller.usePatch.value,
                  onSelected: (_) => controller.toggleMethod(true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('PUT'),
                  selected: !controller.usePatch.value,
                  onSelected: (_) => controller.toggleMethod(false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ========================================
          // نموذج التحرير أو رسالة الاختيار
          // Edit form or selection message
          // ========================================
          Obx(() {
            // إذا تم اختيار منشور | If a post is selected
            if (controller.selectedPost.value != null) {
              return _buildEditForm(context);
            }

            // لم يتم اختيار منشور | No post selected
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'اختر منشوراً من القائمة للتحرير\nSelect a post from the list to edit',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// بناء نموذج التحرير | Build edit form
  Widget _buildEditForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // عنوان التحرير | Edit heading
        Obx(
          () => Text(
            'تحرير منشور #${controller.selectedPost.value!.id} - Editing Post #${controller.selectedPost.value!.id}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 16),

        // نموذج الإدخال | Input form
        Form(
          key: controller.formKey,
          child: Column(
            children: [
              // حقل العنوان | Title field
              TextFormField(
                controller: controller.titleController,
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
              // حقل المحتوى | Body field
              TextFormField(
                controller: controller.bodyController,
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

        // زر التحديث | Update button
        Obx(
          () => FilledButton.icon(
            onPressed: controller.isUpdating.value
                ? null
                : controller.updatePost,
            icon: controller.isUpdating.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              controller.isUpdating.value
                  ? 'جاري التحديث... - Updating...'
                  : 'تحديث باستخدام ${controller.usePatch.value ? "PATCH" : "PUT"} - Update with ${controller.usePatch.value ? "PATCH" : "PUT"}',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        // رسالة النجاح | Success message
        Obx(() {
          if (controller.successMessage.value != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        controller.successMessage.value!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // رسالة الخطأ | Error message
        Obx(() {
          if (controller.errorMessage.value != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  /// بناء عنصر المقارنة | Build comparison item
  Widget _buildComparison(
    BuildContext context,
    String method,
    String description,
  ) {
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
