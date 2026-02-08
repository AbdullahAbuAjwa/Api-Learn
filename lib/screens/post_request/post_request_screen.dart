import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controllers.dart';

/// ============================================================================
/// شاشة POST: توضح إنشاء البيانات عبر API باستخدام GetX
/// POST Screen: Demonstrates Creating Data via API using GetX
/// ============================================================================
///
/// هذه الشاشة توضح | This screen demonstrates:
/// 1. استخدام GetView للوصول التلقائي إلى المتحكم
///    Using GetView for automatic controller access
/// 2. استخدام Obx للتحديث التفاعلي للواجهة
///    Using Obx for reactive UI updates
/// 3. التحقق من صحة النموذج قبل الإرسال
///    Form validation before submission
/// 4. عرض ملاحظات النجاح/الخطأ باستخدام Get.snackbar
///    Showing success/error feedback using Get.snackbar
/// 5. مسح النموذج بعد الإرسال الناجح
///    Clearing form after successful submission
///
/// أهداف التعلم | Learning Objectives:
/// - فهم كيفية استخدام GetView بدلاً من StatefulWidget
///   Understand how to use GetView instead of StatefulWidget
/// - تعلم استخدام Obx للاستماع للتغييرات التفاعلية
///   Learn using Obx to listen to reactive changes
/// - رؤية كيفية فصل المنطق عن الواجهة باستخدام GetX
///   See how to separate logic from UI using GetX
/// - فهم أنماط التحقق من النماذج مع GetX
///   Understand form validation patterns with GetX
/// ============================================================================

// الشاشة ترث من GetView بدلاً من StatefulWidget
// The screen extends GetView instead of StatefulWidget
// هذا يوفر وصولاً تلقائياً للمتحكم عبر خاصية controller
// This provides automatic access to the controller via the controller property
class PostRequestScreen extends GetView<PostRequestController> {
  const PostRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب POST - POST Request'),
        actions: [
          // زر مسح النموذج - Clear form button
          // يستدعي clearForm من المتحكم مباشرةً
          // Calls clearForm from the controller directly
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'مسح النموذج - Clear Form',
            onPressed: controller.clearForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========================================
            // بطاقة المعلومات | Information Card
            // ========================================
            _buildInfoCard(context),
            const SizedBox(height: 24),

            // ========================================
            // نموذج إنشاء منشور | Create Post Form
            // ========================================
            Text(
              'إنشاء منشور جديد - Create New Post',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // النموذج لا يحتاج Obx لأنه يعتمد على مفتاح النموذج والمتحكمات
            // The form doesn't need Obx as it relies on form key and text controllers
            _buildForm(),
            const SizedBox(height: 24),

            // ========================================
            // زر الإرسال | Submit Button
            // يستخدم Obx للاستماع لحالة التحميل
            // Uses Obx to listen to loading state
            // ========================================
            _buildSubmitButton(),
            const SizedBox(height: 16),

            // ========================================
            // رسائل التغذية الراجعة | Feedback Messages
            // تستخدم Obx للتفاعل مع تغييرات الرسائل
            // Uses Obx to react to message changes
            // ========================================
            _buildFeedbackMessages(),

            // ========================================
            // قائمة المنشورات المُنشأة | Created Posts List
            // تستخدم Obx للتحديث عند إضافة منشور جديد
            // Uses Obx to update when a new post is added
            // ========================================
            _buildCreatedPostsList(context),
          ],
        ),
      ),
    );
  }

  /// ========================================
  /// بطاقة المعلومات التوضيحية
  /// Informational Card
  /// ========================================
  /// تعرض شرحاً مختصراً عن طلبات POST
  /// Displays a brief explanation about POST requests
  Widget _buildInfoCard(BuildContext context) {
    return Card(
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
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'طلب POST - POST Request',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
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
    );
  }

  /// ========================================
  /// نموذج إدخال البيانات
  /// Data Input Form
  /// ========================================
  /// يحتوي على ثلاثة حقول: العنوان، المحتوى، ومعرف المستخدم
  /// Contains three fields: title, body, and user ID
  /// لا يحتاج Obx لأن TextFormField يُدار بواسطة TextEditingController
  /// Doesn't need Obx because TextFormField is managed by TextEditingController
  Widget _buildForm() {
    return Form(
      // استخدام مفتاح النموذج من المتحكم - Using form key from controller
      key: controller.formKey,
      child: Column(
        children: [
          // حقل العنوان | Title Field
          TextFormField(
            // الوصول للمتحكم عبر controller.xxxController
            // Accessing controller via controller.xxxController
            controller: controller.titleController,
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
            controller: controller.bodyController,
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
            controller: controller.userIdController,
            decoration: const InputDecoration(
              labelText: 'معرف المستخدم - User ID',
              hintText: 'أدخل معرف المستخدم (1-10) - Enter user ID (1-10)',
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
    );
  }

  /// ========================================
  /// زر الإرسال
  /// Submit Button
  /// ========================================
  /// يستخدم Obx للاستماع إلى حالة التحميل (isLoading)
  /// Uses Obx to listen to loading state (isLoading)
  /// عندما تتغير قيمة isLoading، يُعاد بناء هذا الجزء فقط
  /// When isLoading value changes, only this part is rebuilt
  Widget _buildSubmitButton() {
    // Obx يستمع تلقائياً لأي متغير .obs يُستخدم بداخله
    // Obx automatically listens to any .obs variable used inside it
    return Obx(() {
      return FilledButton.icon(
        // تعطيل الزر أثناء التحميل - Disable button while loading
        onPressed: controller.isLoading.value ? null : controller.createPost,
        icon: controller.isLoading.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send),
        label: Text(
          controller.isLoading.value
              ? 'جاري الإنشاء... - Creating...'
              : 'إنشاء منشور - Create Post',
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    });
  }

  /// ========================================
  /// رسائل التغذية الراجعة (نجاح / خطأ)
  /// Feedback Messages (Success / Error)
  /// ========================================
  /// تستخدم Obx للتفاعل مع التغييرات في رسائل النجاح والخطأ
  /// Uses Obx to react to changes in success and error messages
  /// Rxn<String> تسمح بقيم null، وتُحدّث الواجهة عند التغيير
  /// Rxn<String> allows null values, and updates UI on change
  Widget _buildFeedbackMessages() {
    return Obx(() {
      return Column(
        children: [
          // رسالة النجاح - Success Message
          if (controller.successMessage.value != null)
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
                        controller.successMessage.value!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // رسالة الخطأ - Error Message
          if (controller.errorMessage.value != null)
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
                        controller.errorMessage.value!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  /// ========================================
  /// قائمة المنشورات المُنشأة
  /// Created Posts List
  /// ========================================
  /// تعرض جميع المنشورات التي تم إنشاؤها بنجاح
  /// Displays all successfully created posts
  /// تستخدم Obx مع RxList للتحديث التلقائي عند إضافة/حذف عناصر
  /// Uses Obx with RxList for automatic updates on add/remove items
  Widget _buildCreatedPostsList(BuildContext context) {
    return Obx(() {
      // إذا لم يتم إنشاء أي منشور بعد، لا تعرض شيئاً
      // If no posts created yet, show nothing
      if (controller.createdPosts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // عنوان القسم مع عدد المنشورات
          // Section title with posts count
          Text(
            'المنشورات المُنشأة حديثاً (${controller.createdPosts.length}) - Recently Created Posts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // قائمة المنشورات - Posts List
          // استخدام ListView.builder للأداء الأفضل
          // Using ListView.builder for better performance
          ListView.builder(
            // منع التمرير الداخلي لأن القائمة داخل SingleChildScrollView
            // Prevent inner scrolling since list is inside SingleChildScrollView
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.createdPosts.length,
            itemBuilder: (context, index) {
              final post = controller.createdPosts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  // أيقونة المعرف - ID Icon
                  leading: CircleAvatar(child: Text('${post.id}')),
                  // عنوان المنشور - Post Title
                  title: Text(post.title),
                  // محتوى المنشور - Post Body
                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // شارة معرف المستخدم - User ID Chip
                  trailing: Chip(label: Text('مستخدم - User ${post.userId}')),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}
