import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

/// ============================================================================
/// الشاشة الرئيسية - مركز التنقل (باستخدام GetX)
/// Home Screen - Navigation Hub (using GetX)
/// ============================================================================
///
/// هذه الشاشة تعمل كنقطة التنقل الرئيسية
/// This screen serves as the main navigation point
///
/// ملاحظة: نستخدم StatelessWidget بدل GetView لأن هذه الشاشة
/// Note: We use StatelessWidget instead of GetView because this screen
/// لا تحتاج متحكم خاص - هي شاشة تنقل فقط
/// doesn't need a controller - it's just a navigation screen
///
/// التنقل يتم باستخدام Get.toNamed() بدل Navigator.push()
/// Navigation uses Get.toNamed() instead of Navigator.push()
/// ============================================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Learn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(),
            tooltip: 'حول التطبيق - About this app',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ========================================
          // بطاقة الترحيب | Welcome Card
          // ========================================
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحباً بك في API Learn!',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'أتقن REST APIs مع Flutter و Dio و GetX',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'هذا التطبيق يوضح جميع مفاهيم API الرئيسية بما في ذلك عمليات CRUD، '
                    'تحليل JSON، رفع الملفات، معالجة الأخطاء، وأفضل الممارسات.\n'
                    'يستخدم GetX لإدارة الحالة وحقن التبعيات والتنقل.',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ========================================
          // قسم: أساليب HTTP | Section: HTTP Methods
          // ========================================
          _buildSectionHeader(context, 'أساليب HTTP - HTTP Methods'),
          const SizedBox(height: 12),

          // التنقل باستخدام Get.toNamed() بدل Navigator.push()
          // Navigation using Get.toNamed() instead of Navigator.push()
          _buildNavigationCard(
            context,
            title: 'طلب GET',
            subtitle: 'جلب البيانات من الخادم - Fetch data from server',
            icon: Icons.download,
            color: Colors.green,
            onTap: () => Get.toNamed(AppRoutes.getRequest),
          ),

          _buildNavigationCard(
            context,
            title: 'طلب POST',
            subtitle: 'إنشاء موارد جديدة - Create new resources',
            icon: Icons.add_circle,
            color: Colors.blue,
            onTap: () => Get.toNamed(AppRoutes.postRequest),
          ),

          _buildNavigationCard(
            context,
            title: 'طلب PUT & PATCH',
            subtitle: 'تحديث الموارد الموجودة - Update existing resources',
            icon: Icons.edit,
            color: Colors.orange,
            onTap: () => Get.toNamed(AppRoutes.updateRequest),
          ),

          _buildNavigationCard(
            context,
            title: 'طلب DELETE',
            subtitle: 'حذف الموارد من الخادم - Remove resources from server',
            icon: Icons.delete,
            color: Colors.red,
            onTap: () => Get.toNamed(AppRoutes.deleteRequest),
          ),

          const SizedBox(height: 24),

          // ========================================
          // قسم: مواضيع متقدمة | Section: Advanced Topics
          // ========================================
          _buildSectionHeader(context, 'مواضيع متقدمة - Advanced Topics'),
          const SizedBox(height: 12),

          _buildNavigationCard(
            context,
            title: 'رفع الملفات',
            subtitle: 'رفع الملفات مع تتبع التقدم - Upload files with progress',
            icon: Icons.cloud_upload,
            color: Colors.purple,
            onTap: () => Get.toNamed(AppRoutes.fileUpload),
          ),

          _buildNavigationCard(
            context,
            title: 'معالجة الأخطاء',
            subtitle:
                'التعامل مع أخطاء API بأناقة - Handle API errors gracefully',
            icon: Icons.error_outline,
            color: Colors.amber,
            onTap: () => Get.toNamed(AppRoutes.errorHandling),
          ),

          const SizedBox(height: 24),

          // ========================================
          // قسم: المرجع | Section: Reference
          // ========================================
          _buildSectionHeader(context, 'المرجع - Reference'),
          const SizedBox(height: 12),

          _buildNavigationCard(
            context,
            title: 'أفضل ممارسات API',
            subtitle: 'دليل ومرجع شامل - Complete guide and reference',
            icon: Icons.book,
            color: Colors.teal,
            onTap: () => Get.toNamed(AppRoutes.bestPractices),
          ),

          const SizedBox(height: 32),

          // ========================================
          // بطاقة النصائح السريعة | Quick Tips Card
          // ========================================
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'نصائح سريعة - Quick Tips',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('📖 اقرأ التعليقات في الكود المصدري'),
                  _buildTip('📖 Read the comments in the source code'),
                  _buildTip('🔍 استكشف كل شاشة لترى المفاهيم قيد التنفيذ'),
                  _buildTip('🔄 جرب التحديث وتنفيذ استدعاءات API'),
                  _buildTip('⚠️ اختبر سيناريوهات الخطأ لفهم معالجة الأخطاء'),
                  _buildTip('🎯 التطبيق يستخدم GetX لإدارة الحالة والتنقل'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.outline,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text),
    );
  }

  /// عرض مربع حوار "حول التطبيق"
  /// Show "About" dialog
  void _showAboutDialog() {
    Get.dialog(
      AboutDialog(
        applicationName: 'API Learn',
        applicationVersion: '1.0.0 (GetX)',
        applicationIcon: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.api,
            size: 32,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        children: const [
          Text(
            'تطبيق Flutter شامل لتعلم مفاهيم REST API '
            'باستخدام حزمة Dio مع إدارة حالة GetX.\n\n'
            'A comprehensive Flutter application for learning REST API concepts '
            'using Dio package with GetX state management.\n\n'
            'المواضيع المغطاة | Topics covered:\n'
            '• مفاهيم RESTful API\n'
            '• النماذج وتحليل JSON\n'
            '• GET / POST / PUT / PATCH / DELETE\n'
            '• رفع الملفات | File upload\n'
            '• معالجة الأخطاء | Error handling\n'
            '• أفضل الممارسات | Best practices\n'
            '• إدارة الحالة بـ GetX | State management with GetX',
          ),
        ],
      ),
    );
  }
}
