import 'package:flutter/material.dart';

/// ============================================================================
/// شاشة أفضل ممارسات API: دليل مرجعي للطلاب
/// API Best Practices Screen: Reference Guide for Students
/// ============================================================================
///
/// هذه الشاشة تعمل كدليل مرجعي شامل يغطي:
/// This screen serves as a comprehensive reference guide covering:
/// 1. مبادئ تصميم RESTful API
///    RESTful API design principles
/// 2. طرق HTTP واستخدامها الصحيح
///    HTTP methods and their proper usage
/// 3. استراتيجيات معالجة الأخطاء
///    Error handling strategies
/// 4. أفضل ممارسات الأمان
///    Security best practices
/// 5. تحسين الأداء
///    Performance optimization
/// 6. أنماط تنظيم الكود
///    Code organization patterns
///
/// هذه شاشة توثيقية - لا يتم إجراء استدعاءات API هنا
/// This is a documentation screen - no API calls are made here
/// ============================================================================

/// شاشة أفضل الممارسات (StatelessWidget - لا تحتاج متحكم)
/// Best practices screen (StatelessWidget - no controller needed)
class BestPracticesScreen extends StatelessWidget {
  const BestPracticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // شريط التطبيق | App bar
      appBar: AppBar(
        title: const Text('أفضل ممارسات API - API Best Practices'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ========================================
          // مفاهيم RESTful API
          // RESTful API Concepts
          // ========================================
          _buildSection(
            context,
            title: '🌐 مفاهيم RESTful API - RESTful API Concepts',
            icon: Icons.api,
            color: Colors.blue,
            items: [
              // نقل الحالة التمثيلية | Representational State Transfer
              _BestPracticeItem(
                title:
                    'REST = نقل الحالة التمثيلية - Representational State Transfer',
                description:
                    'نمط معماري لتصميم تطبيقات الشبكة. يستخدم طرق HTTP القياسية وهو عديم الحالة.\n'
                    'An architectural style for designing networked applications. '
                    'It uses standard HTTP methods and is stateless.',
              ),
              // الموارد | Resources
              _BestPracticeItem(
                title: 'الموارد - Resources',
                description:
                    'كل شيء هو مورد يُحدد بعنوان URL.\n'
                    'Everything is a resource identified by a URL.\n'
                    '• /users - مجموعة المستخدمين - Collection of users\n'
                    '• /users/1 - مستخدم واحد - Single user\n'
                    '• /users/1/posts - منشورات المستخدم - User\'s posts',
              ),
              // عدم الحالة | Statelessness
              _BestPracticeItem(
                title: 'عدم الحالة - Statelessness',
                description:
                    'كل طلب يحتوي على جميع المعلومات اللازمة. الخادم لا يخزن حالة العميل بين الطلبات.\n'
                    'Each request contains all information needed. '
                    'The server doesn\'t store client state between requests.',
              ),
              // واجهة موحدة | Uniform Interface
              _BestPracticeItem(
                title: 'واجهة موحدة - Uniform Interface',
                description:
                    'استخدم طرق HTTP القياسية بشكل متسق:\n'
                    'Use standard HTTP methods consistently:\n'
                    '• GET - قراءة - Read\n'
                    '• POST - إنشاء - Create\n'
                    '• PUT - تحديث كامل - Full Update\n'
                    '• PATCH - تحديث جزئي - Partial Update\n'
                    '• DELETE - حذف - Remove',
              ),
            ],
          ),

          // ========================================
          // طرق HTTP
          // HTTP Methods
          // ========================================
          _buildSection(
            context,
            title: '📡 طرق HTTP - HTTP Methods',
            icon: Icons.http,
            color: Colors.green,
            items: [
              // GET - قراءة/جلب | GET - Read/Retrieve
              _BestPracticeItem(
                title: 'GET - قراءة/جلب - Read/Retrieve',
                description:
                    '• لا يجب أن يعدّل البيانات - Should NOT modify data\n'
                    '• آمن وغير متكرر - Safe and idempotent\n'
                    '• يمكن تخزينه مؤقتاً - Can be cached\n'
                    '• المعاملات في سلسلة استعلام URL - Parameters in URL query string',
              ),
              // POST - إنشاء | POST - Create
              _BestPracticeItem(
                title: 'POST - إنشاء - Create',
                description:
                    '• ينشئ موارد جديدة - Creates new resources\n'
                    '• غير متكرر (استدعاؤه مرتين ينشئ موردين) - NOT idempotent (calling twice creates two resources)\n'
                    '• البيانات في جسم الطلب - Data in request body\n'
                    '• يرجع 201 Created عند النجاح - Returns 201 Created on success',
              ),
              // PUT - تحديث كامل | PUT - Full Update
              _BestPracticeItem(
                title: 'PUT - تحديث كامل - Full Update',
                description:
                    '• يستبدل المورد بالكامل - Replaces entire resource\n'
                    '• غير متكرر (نفس النتيجة إذا استُدعي عدة مرات) - Idempotent (same result if called multiple times)\n'
                    '• أرسل المورد الكامل في الجسم - Send complete resource in body\n'
                    '• ينشئ إذا لم يكن موجوداً (upsert) - Creates if doesn\'t exist (upsert)',
              ),
              // PATCH - تحديث جزئي | PATCH - Partial Update
              _BestPracticeItem(
                title: 'PATCH - تحديث جزئي - Partial Update',
                description:
                    '• يحدث حقولاً محددة فقط - Updates specific fields only\n'
                    '• حمولة أصغر من PUT - Smaller payload than PUT\n'
                    '• قد لا يكون غير متكرر - May not be idempotent\n'
                    '• مفضّل لإرسال النماذج - Preferred for form submissions',
              ),
              // DELETE - حذف | DELETE - Remove
              _BestPracticeItem(
                title: 'DELETE - حذف - Remove',
                description:
                    '• يحذف مورداً - Removes a resource\n'
                    '• غير متكرر - Idempotent\n'
                    '• عادة يرجع 200 OK أو 204 No Content - Usually returns 200 OK or 204 No Content\n'
                    '• فكّر في الحذف الناعم للتراجع - Consider soft delete for reversibility',
              ),
            ],
          ),

          // ========================================
          // معالجة الأخطاء
          // Error Handling
          // ========================================
          _buildSection(
            context,
            title: '⚠️ معالجة الأخطاء - Error Handling',
            icon: Icons.error_outline,
            color: Colors.orange,
            items: [
              // استخدام أنواع استثناءات محددة | Use Specific Exception Types
              _BestPracticeItem(
                title:
                    'استخدم أنواع استثناءات محددة - Use Specific Exception Types',
                description:
                    'أنشئ استثناءات مخصصة لأخطاء مختلفة:\n'
                    'Create custom exceptions for different errors:\n'
                    '• NetworkException - مشاكل الاتصال - Connection issues\n'
                    '• ServerException - أخطاء 5xx - 5xx errors\n'
                    '• ClientException - أخطاء 4xx - 4xx errors\n'
                    '• ValidationException - أخطاء الإدخال - Input errors',
              ),
              // رسائل سهلة للمستخدم | User-Friendly Messages
              _BestPracticeItem(
                title: 'رسائل سهلة للمستخدم - User-Friendly Messages',
                description:
                    '• لا تعرض أخطاء تقنية للمستخدمين - Don\'t show technical errors to users\n'
                    '• قدّم ملاحظات قابلة للتنفيذ - Provide actionable feedback\n'
                    '• اقترح حلولاً (أعد المحاولة، تحقق من الإنترنت) - Suggest solutions (retry, check internet)\n'
                    '• سجّل التفاصيل التقنية للتصحيح - Log technical details for debugging',
              ),
              // تنفيذ منطق إعادة المحاولة | Implement Retry Logic
              _BestPracticeItem(
                title: 'نفّذ منطق إعادة المحاولة - Implement Retry Logic',
                description:
                    '• أعد المحاولة عند الأخطاء المؤقتة (انتهاء المهلة، 5xx) - Retry on transient failures (timeouts, 5xx)\n'
                    '• استخدم التراجع الأسي - Use exponential backoff\n'
                    '• حدد عدد محاولات إعادة المحاولة - Limit retry attempts\n'
                    '• لا تعد المحاولة عند أخطاء 4xx - Don\'t retry on 4xx errors',
              ),
              // التدهور الرشيق | Graceful Degradation
              _BestPracticeItem(
                title: 'التدهور الرشيق - Graceful Degradation',
                description:
                    '• اعرض البيانات المخزنة مؤقتاً عند عدم الاتصال - Show cached data when offline\n'
                    '• وفّر تجربة أولوية عدم الاتصال - Provide offline-first experience\n'
                    '• ضع العمليات في قائمة انتظار للمزامنة لاحقاً - Queue operations for later sync\n'
                    '• اعرض محتوى جزئياً عند الإمكان - Show partial content when possible',
              ),
            ],
          ),

          // ========================================
          // الأمان
          // Security
          // ========================================
          _buildSection(
            context,
            title: '🔒 أفضل ممارسات الأمان - Security Best Practices',
            icon: Icons.security,
            color: Colors.red,
            items: [
              // استخدم دائماً HTTPS | Always Use HTTPS
              _BestPracticeItem(
                title: 'استخدم دائماً HTTPS - Always Use HTTPS',
                description:
                    '• يشفّر البيانات أثناء النقل - Encrypts data in transit\n'
                    '• يتحقق من هوية الخادم - Validates server identity\n'
                    '• مطلوب لتطبيقات الإنتاج - Required for production apps\n'
                    '• لا ترسل بيانات حساسة عبر HTTP - Never send sensitive data over HTTP',
              ),
              // المصادقة | Authentication
              _BestPracticeItem(
                title: 'المصادقة - Authentication',
                description:
                    '• استخدم معايير الصناعة (OAuth 2.0, JWT) - Use industry standards (OAuth 2.0, JWT)\n'
                    '• خزّن الرموز بأمان (flutter_secure_storage) - Store tokens securely (flutter_secure_storage)\n'
                    '• نفّذ تجديد الرمز - Implement token refresh\n'
                    '• امسح الرموز عند تسجيل الخروج - Clear tokens on logout',
              ),
              // لا تكتب الأسرار في الكود | Don't Hardcode Secrets
              _BestPracticeItem(
                title: 'لا تكتب الأسرار في الكود - Don\'t Hardcode Secrets',
                description:
                    '• استخدم متغيرات البيئة - Use environment variables\n'
                    '• خزّن مفاتيح API بأمان - Store API keys securely\n'
                    '• لا تودع الأسرار في git - Don\'t commit secrets to git\n'
                    '• استخدم ملفات .env للإعدادات - Use .env files for configuration',
              ),
              // التحقق من الإدخال | Input Validation
              _BestPracticeItem(
                title: 'التحقق من الإدخال - Input Validation',
                description:
                    '• تحقق في العميل والخادم - Validate on client AND server\n'
                    '• نظّف إدخال المستخدم - Sanitize user input\n'
                    '• لا تثق ببيانات العميل - Don\'t trust client data\n'
                    '• نفّذ تحديد المعدل - Implement rate limiting',
              ),
            ],
          ),

          // ========================================
          // الأداء
          // Performance
          // ========================================
          _buildSection(
            context,
            title: '⚡ تحسين الأداء - Performance Optimization',
            icon: Icons.speed,
            color: Colors.purple,
            items: [
              // التخزين المؤقت | Caching
              _BestPracticeItem(
                title: 'التخزين المؤقت - Caching',
                description:
                    '• خزّن استجابات GET مؤقتاً - Cache GET responses\n'
                    '• استخدم ETags للتحقق - Use ETags for validation\n'
                    '• نفّذ دعم عدم الاتصال - Implement offline support\n'
                    '• احترم ترويسات Cache-Control - Respect Cache-Control headers',
              ),
              // التصفح | Pagination
              _BestPracticeItem(
                title: 'التصفح - Pagination',
                description:
                    '• لا تجلب جميع البيانات دفعة واحدة - Don\'t fetch all data at once\n'
                    '• نفّذ التمرير اللانهائي - Implement infinite scroll\n'
                    '• استخدم التصفح المبني على المؤشر لمجموعات البيانات الكبيرة - Use cursor-based pagination for large datasets\n'
                    '• اعرض حالات التحميل بين الصفحات - Show loading states between pages',
              ),
              // تحسين الطلبات | Request Optimization
              _BestPracticeItem(
                title: 'تحسين الطلبات - Request Optimization',
                description:
                    '• اجمع الطلبات عند الإمكان - Batch requests when possible\n'
                    '• استخدم طلبات متوازية للبيانات المستقلة - Use parallel requests for independent data\n'
                    '• أخّر إدخال البحث - Debounce search inputs\n'
                    '• ألغِ الطلبات المنتهية الصلاحية - Cancel outdated requests',
              ),
              // تجميع الاتصالات | Connection Pooling
              _BestPracticeItem(
                title: 'تجميع الاتصالات - Connection Pooling',
                description:
                    '• أعد استخدام اتصالات HTTP - Reuse HTTP connections\n'
                    '• استخدم نسخة Dio واحدة - Use a single Dio instance\n'
                    '• اضبط المهلات المناسبة - Configure appropriate timeouts\n'
                    '• نفّذ الحفاظ على الاتصال - Implement connection keep-alive',
              ),
            ],
          ),

          // ========================================
          // تنظيم الكود
          // Code Organization
          // ========================================
          _buildSection(
            context,
            title: '📁 تنظيم الكود - Code Organization',
            icon: Icons.folder_outlined,
            color: Colors.teal,
            items: [
              // معمارية متعددة الطبقات | Layered Architecture
              _BestPracticeItem(
                title: 'معمارية متعددة الطبقات - Layered Architecture',
                description:
                    '• طبقة الواجهة - الشاشات والعناصر - UI Layer - Screens and widgets\n'
                    '• طبقة الخدمة - استدعاءات API - Service Layer - API calls\n'
                    '• طبقة المستودع - تجريد البيانات - Repository Layer - Data abstraction\n'
                    '• طبقة النماذج - فئات البيانات - Model Layer - Data classes',
              ),
              // المسؤولية الواحدة | Single Responsibility
              _BestPracticeItem(
                title: 'المسؤولية الواحدة - Single Responsibility',
                description:
                    '• خدمة واحدة لكل مورد API - One service per API resource\n'
                    '• افصل الاهتمامات (واجهة، منطق، بيانات) - Separate concerns (UI, logic, data)\n'
                    '• اجعل الفئات مركزة - Keep classes focused\n'
                    '• استخدم حقن التبعيات - Use dependency injection',
              ),
              // إدارة الإعدادات | Configuration Management
              _BestPracticeItem(
                title: 'إدارة الإعدادات - Configuration Management',
                description:
                    '• مركز إعدادات API - Centralize API configuration\n'
                    '• استخدم ثوابت لنقاط النهاية - Use constants for endpoints\n'
                    '• ادعم بيئات متعددة - Support multiple environments\n'
                    '• اجعل المهلات قابلة للإعداد - Make timeouts configurable',
              ),
              // أمان الأنواع | Type Safety
              _BestPracticeItem(
                title: 'أمان الأنواع - Type Safety',
                description:
                    '• استخدم نماذج مكتوبة، وليس dynamic - Use typed models, not dynamic\n'
                    '• استفد من سلامة Dart من null - Leverage Dart null safety\n'
                    '• ولّد كود تسلسل JSON - Generate JSON serialization code\n'
                    '• تجنب تحويل الأنواع - Avoid type casting',
              ),
            ],
          ),

          // ========================================
          // أنماط شائعة
          // Common Patterns
          // ========================================
          _buildSection(
            context,
            title: '🎯 أنماط شائعة - Common Patterns',
            icon: Icons.pattern,
            color: Colors.indigo,
            items: [
              // نمط المستودع | Repository Pattern
              _BestPracticeItem(
                title: 'نمط المستودع - Repository Pattern',
                description:
                    'جرّد مصادر البيانات خلف واجهة مشتركة. يسمح بالتبديل بين API والتخزين المؤقت والبيانات الوهمية بسهولة.\n'
                    'Abstract data sources behind a common interface. '
                    'Allows switching between API, cache, and mock data easily.',
              ),
              // عميل HTTP مفرد | Singleton HTTP Client
              _BestPracticeItem(
                title: 'عميل HTTP مفرد - Singleton HTTP Client',
                description:
                    'استخدم نسخة عميل HTTP واحدة مشتركة. يضمن إعدادات متسقة وإعادة استخدام الاتصالات.\n'
                    'Use one shared HTTP client instance. '
                    'Ensures consistent configuration and connection reuse.',
              ),
              // معترضات للاهتمامات المشتركة | Interceptors for Cross-Cutting Concerns
              _BestPracticeItem(
                title:
                    'معترضات للاهتمامات المشتركة - Interceptors for Cross-Cutting Concerns',
                description:
                    'استخدم المعترضات لـ:\nUse interceptors for:\n'
                    '• إضافة ترويسات المصادقة - Adding auth headers\n'
                    '• تسجيل الطلبات/الاستجابات - Logging requests/responses\n'
                    '• معالجة تجديد الرمز - Handling token refresh\n'
                    '• تنفيذ منطق إعادة المحاولة - Implementing retry logic',
              ),
              // غلاف استجابة عام | Generic Response Wrapper
              _BestPracticeItem(
                title: 'غلاف استجابة عام - Generic Response Wrapper',
                description:
                    'غلّف استجابات API في فئة عامة. يوفر معالجة نجاح/خطأ متسقة عبر التطبيق.\n'
                    'Wrap API responses in a generic class. '
                    'Provides consistent success/error handling across the app.',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ========================================
          // بطاقة المرجع السريع | Quick Reference Card
          // ========================================
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 مرجع سريع - Quick Reference',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // صفوف المرجع السريع | Quick reference rows
                  _buildQuickRef('GET', '200 OK', 'جلب البيانات - Fetch data'),
                  _buildQuickRef(
                    'POST',
                    '201 Created',
                    'إنشاء مورد - Create resource',
                  ),
                  _buildQuickRef('PUT', '200 OK', 'تحديث كامل - Full update'),
                  _buildQuickRef(
                    'PATCH',
                    '200 OK',
                    'تحديث جزئي - Partial update',
                  ),
                  _buildQuickRef(
                    'DELETE',
                    '200/204',
                    'حذف مورد - Remove resource',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء قسم قابل للتوسيع | Build expandable section
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<_BestPracticeItem> items,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        initiallyExpanded: false,
        children: items.map((item) => _buildItem(context, item)).toList(),
      ),
    );
  }

  /// بناء عنصر أفضل ممارسة | Build best practice item
  Widget _buildItem(BuildContext context, _BestPracticeItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان العنصر | Item title
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // وصف العنصر | Item description
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء صف مرجع سريع | Build quick reference row
  Widget _buildQuickRef(String method, String status, String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // شارة الطريقة | Method badge
          SizedBox(
            width: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getMethodColor(method),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                method,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // كود الحالة | Status code
          SizedBox(
            width: 80,
            child: Text(
              status,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          // وصف الإجراء | Action description
          Expanded(child: Text(action)),
        ],
      ),
    );
  }

  /// الحصول على لون الطريقة | Get method color
  Color _getMethodColor(String method) {
    switch (method) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'PATCH':
        return Colors.purple;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// فئة مساعدة لعناصر أفضل الممارسات
/// Helper class for best practice items
class _BestPracticeItem {
  /// عنوان العنصر | Item title
  final String title;

  /// وصف العنصر | Item description
  final String description;

  _BestPracticeItem({required this.title, required this.description});
}
