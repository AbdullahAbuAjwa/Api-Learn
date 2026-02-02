import 'package:flutter/material.dart';
import 'screens/screens.dart';

/// ============================================================================
/// تطبيق API Learn - نقطة الدخول الرئيسية
/// API Learn App - Main Entry Point
/// ============================================================================
///
/// هذا التطبيق مصمم كمرجع تعليمي شامل لتكامل Flutter API
/// This application is designed as a comprehensive learning reference for
/// باستخدام Dio. يغطي:
/// Flutter API integration using Dio. It covers:
///
/// 1. مفاهيم RESTful API
///    RESTful API Concepts
///    - فهم بنية REST
///      Understanding REST architecture
///    - أساليب HTTP وأغراضها
///      HTTP methods and their purposes
///    - دورة حياة الطلب/الاستجابة
///      Request/Response lifecycle
///
/// 2. النماذج وتحليل JSON
///    Models & JSON Parsing
///    - إنشاء نماذج Dart من JSON
///      Creating Dart models from JSON
///    - استخدام json_serializable لتوليد الكود
///      Using json_serializable for code generation
///    - التعامل مع الكائنات المتداخلة والحقول الاختيارية
///      Handling nested objects and nullable fields
///
/// 3. أساليب HTTP
///    HTTP Methods
///    - GET: جلب البيانات
///      GET: Fetching data
///    - POST: إنشاء الموارد
///      POST: Creating resources
///    - PUT: تحديث كامل للمورد
///      PUT: Full resource update
///    - PATCH: تحديث جزئي
///      PATCH: Partial update
///    - DELETE: حذف الموارد
///      DELETE: Removing resources
///
/// 4. رفع الملفات
///    File Upload
///    - طلبات multipart/form-data
///      Multipart/form-data requests
///    - تتبع التقدم
///      Progress tracking
///    - FormData و MultipartFile
///      FormData and MultipartFile
///
/// 5. معالجة الأخطاء
///    Error Handling
///    - كلاسات استثناءات مخصصة
///      Custom exception classes
///    - معالجة أخطاء الشبكة
///      Network error handling
///    - رسائل خطأ سهلة للمستخدم
///      User-friendly error messages
///    - آليات إعادة المحاولة
///      Retry mechanisms
///
/// 6. أفضل الممارسات
///    Best Practices
///    - تنظيم الكود
///      Code organization
///    - اعتبارات الأمان
///      Security considerations
///    - تحسين الأداء
///      Performance optimization
///    - الأنماط الشائعة
///      Common patterns
/// ============================================================================

/// نقطة الدخول الرئيسية للتطبيق
/// Main entry point of the application
void main() {
  // تشغيل التطبيق | Run the app
  runApp(const ApiLearnApp());
}

/// ============================================================================
/// الودجت الجذر للتطبيق
/// Root widget of the application
/// ============================================================================
///
/// هذا StatelessWidget لأن إعدادات التطبيق لا تتغير
/// This is a StatelessWidget because the app configuration doesn't change.
/// يُعد | It sets up:
/// - MaterialApp مع تصميم Material 3
///   MaterialApp with Material 3 design
/// - إعدادات الثيم | Theme configuration
/// - هيكل التنقل | Navigation structure
class ApiLearnApp extends StatelessWidget {
  const ApiLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // عنوان التطبيق (يظهر في مبدل المهام)
      // App title (shown in task switcher)
      title: 'API Learn',

      // إعدادات الثيم باستخدام Material 3
      // Theme configuration using Material 3
      theme: ThemeData(
        // استخدام لغة تصميم Material 3
        // Use Material 3 design language
        useMaterial3: true,

        // توليد مخطط الألوان من لون أساسي
        // Generate color scheme from a seed color
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),

        // ثيم البطاقات لتنسيق متسق
        // Card theme for consistent styling
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // ثيم شريط التطبيق | AppBar theme
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),

      // الثيم الداكن | Dark theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),

      // اتباع إعدادات ثيم النظام
      // Follow system theme setting
      themeMode: ThemeMode.system,

      // تعطيل شعار التصحيح
      // Disable the debug banner
      debugShowCheckedModeBanner: false,

      // الشاشة الرئيسية | Home screen
      home: const HomeScreen(),
    );
  }
}

/// ============================================================================
/// الشاشة الرئيسية - مركز التنقل
/// Home Screen - Navigation Hub
/// ============================================================================
///
/// هذه الشاشة تعمل كنقطة التنقل الرئيسية لجميع وحدات تعلم API المختلفة
/// This screen serves as the main navigation point for all the different
/// كل بطاقة تربط بموضوع محدد
/// API learning modules. Each card links to a specific topic.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Learn'),
        actions: [
          // زر المعلومات | Info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
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
                              'أتقن REST APIs مع Flutter و Dio',
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
                    'تحليل JSON، رفع الملفات، معالجة الأخطاء، وأفضل الممارسات.',
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

          _buildNavigationCard(
            context,
            title: 'طلب GET',
            subtitle: 'جلب البيانات من الخادم - Fetch data from server',
            icon: Icons.download,
            color: Colors.green,
            onTap: () => _navigateTo(context, const GetRequestScreen()),
          ),

          _buildNavigationCard(
            context,
            title: 'طلب POST',
            subtitle: 'إنشاء موارد جديدة - Create new resources',
            icon: Icons.add_circle,
            color: Colors.blue,
            onTap: () => _navigateTo(context, const PostRequestScreen()),
          ),

          _buildNavigationCard(
            context,
            title: 'طلب PUT & PATCH',
            subtitle: 'تحديث الموارد الموجودة - Update existing resources',
            icon: Icons.edit,
            color: Colors.orange,
            onTap: () => _navigateTo(context, const UpdateRequestScreen()),
          ),

          _buildNavigationCard(
            context,
            title: 'طلب DELETE',
            subtitle: 'حذف الموارد من الخادم - Remove resources from server',
            icon: Icons.delete,
            color: Colors.red,
            onTap: () => _navigateTo(context, const DeleteRequestScreen()),
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
            onTap: () => _navigateTo(context, const FileUploadScreen()),
          ),

          _buildNavigationCard(
            context,
            title: 'معالجة الأخطاء',
            subtitle:
                'التعامل مع أخطاء API بأناقة - Handle API errors gracefully',
            icon: Icons.error_outline,
            color: Colors.amber,
            onTap: () => _navigateTo(context, const ErrorHandlingScreen()),
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
            onTap: () => _navigateTo(context, const BestPracticesScreen()),
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

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'API Learn',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.api,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      children: const [
        Text(
          'تطبيق Flutter شامل لتعلم مفاهيم REST API '
          'باستخدام حزمة Dio.\n\n'
          'A comprehensive Flutter application for learning REST API concepts '
          'using Dio package.\n\n'
          'المواضيع المغطاة | Topics covered:\n'
          '• مفاهيم RESTful API\n'
          '• النماذج وتحليل JSON\n'
          '• GET / POST / PUT / PATCH / DELETE\n'
          '• رفع الملفات | File upload\n'
          '• معالجة الأخطاء | Error handling\n'
          '• أفضل الممارسات | Best practices',
        ),
      ],
    );
  }
}
