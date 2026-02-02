import 'package:dio/dio.dart';

/// ============================================================================
/// كلاس إعدادات API - مركز التحكم بالإعدادات
/// API Configuration Class - Central Configuration Hub
/// ============================================================================
///
/// هذا الكلاس يحتوي على جميع إعدادات API الخاصة بك
/// This class holds all configuration settings for your API.
///
/// لماذا نحتاج إعدادات منفصلة؟ | Why have a separate configuration?
/// 1. مصدر واحد للحقيقة لجميع إعدادات API
///    Single source of truth for all API settings
/// 2. سهولة التبديل بين البيئات (dev, staging, prod)
///    Easy to switch between environments (dev, staging, prod)
/// 3. تجميع الأرقام والنصوص السحرية في مكان واحد
///    Keeps magic numbers and strings in one place
/// 4. يجعل الاختبار أسهل (يمكن حقن إعدادات مختلفة)
///    Makes testing easier (can inject different configs)
///
/// أفضل الممارسات | Best Practices:
/// - استخدم متغيرات البيئة للبيانات الحساسة
///   Use environment variables for sensitive data
/// - افصل الإعدادات عن التنفيذ
///   Keep configuration separate from implementation
/// - اجعل تغيير الإعدادات سهلاً بدون تغيير الكود
///   Make it easy to change settings without code changes
/// ============================================================================

class ApiConfig {
  /// ========================================
  /// إعدادات الرابط الأساسي | Base URL Configuration
  /// ========================================
  ///
  /// الرابط الأساسي هو الرابط الجذر لـ API الخاص بك
  /// The base URL is the root URL of your API.
  /// جميع مسارات النقاط النهائية تُلحق بهذا الرابط
  /// All endpoint paths are appended to this URL.
  ///
  /// أمثلة | Examples:
  /// - التطوير: http://localhost:3000/api
  ///   Development: http://localhost:3000/api
  /// - التجربة: https://staging-api.example.com/api
  ///   Staging: https://staging-api.example.com/api
  /// - الإنتاج: https://api.example.com/api
  ///   Production: https://api.example.com/api
  ///
  /// لهذا الدرس، نستخدم JSONPlaceholder - API مجاني وهمي للاختبار
  /// For this tutorial, we're using JSONPlaceholder - a free fake REST API
  /// مثالي للاختبار والنمذجة. زُر: https://jsonplaceholder.typicode.com
  /// Perfect for testing and prototyping. Visit: https://jsonplaceholder.typicode.com
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  /// ========================================
  /// إعدادات المهلة الزمنية | Timeout Configuration
  /// ========================================
  ///
  /// المهلات تمنع تطبيقك من الانتظار للأبد
  /// Timeouts prevent your app from hanging indefinitely.
  /// العمليات المختلفة تحتاج قيم مهلة مختلفة
  /// Different operations need different timeout values.

  /// مهلة الاتصال (بالميلي ثانية)
  /// Connection Timeout (milliseconds)
  /// كم ننتظر لإنشاء الاتصال
  /// How long to wait for a connection to be established
  /// - قيمة أقل: اكتشاف فشل أسرع لكن قد تفشل على الشبكات البطيئة
  ///   Lower value: Faster failure detection but may fail on slow networks
  /// - قيمة أعلى: أكثر تسامحاً مع الشبكات البطيئة لكن تجربة مستخدم أسوأ
  ///   Higher value: More tolerant of slow networks but worse UX
  /// الموصى به: 10-30 ثانية | Recommended: 10-30 seconds
  static const int connectionTimeout = 30000; // 30 ثانية | 30 seconds

  /// مهلة الاستقبال (بالميلي ثانية)
  /// Receive Timeout (milliseconds)
  /// كم ننتظر للخادم لإرسال البيانات بعد إنشاء الاتصال
  /// How long to wait for the server to send data after connection is established
  /// يجب أن تكون أطول من مهلة الاتصال لأن نقل البيانات يأخذ وقتاً
  /// Should be longer than connection timeout since data transfer takes time
  /// الموصى به: 30-60 ثانية للطلبات العادية
  /// Recommended: 30-60 seconds for normal requests
  static const int receiveTimeout = 30000; // 30 ثانية | 30 seconds

  /// مهلة الإرسال (بالميلي ثانية)
  /// Send Timeout (milliseconds)
  /// كم ننتظر عند إرسال البيانات للخادم
  /// How long to wait when sending data to the server
  /// مهم لطلبات POST مع أجسام كبيرة
  /// Important for POST requests with large bodies
  /// الموصى به: 30-60 ثانية | Recommended: 30-60 seconds
  static const int sendTimeout = 30000; // 30 ثانية | 30 seconds

  /// ========================================
  /// إعدادات رفع الملفات | File Upload Configuration
  /// ========================================

  /// لرفع الملفات، نستخدم خدمة API وهمية
  /// For file uploads, we use a mock API service
  /// في الإنتاج، هذا سيكون نقطة نهاية رفع الملفات الخاصة بك
  /// In production, this would be your file upload endpoint
  /// httpbin.org خدمة اختبار HTTP مجانية
  /// httpbin.org is a free HTTP testing service
  static const String fileUploadUrl = 'https://httpbin.org/post';

  /// الحد الأقصى لحجم الملف بالبايت (10 MB)
  /// Maximum file size in bytes (10 MB)
  /// يمنع رفع ملفات كبيرة جداً
  /// Prevents uploading files that are too large
  static const int maxFileSize = 10 * 1024 * 1024;

  /// مهلة ممتدة لرفع الملفات (دقيقتين)
  /// Extended timeout for file uploads (2 minutes)
  /// رفع الملفات يحتاج وقتاً أكثر من الطلبات العادية
  /// File uploads need more time than regular requests
  static const int uploadTimeout = 120000;

  /// ========================================
  /// نقاط نهاية API | API Endpoints
  /// ========================================
  ///
  /// تخزين النقاط النهائية كثوابت له عدة فوائد:
  /// Storing endpoints as constants has several benefits:
  /// 1. دعم الإكمال التلقائي في IDE
  ///    Autocomplete support in IDE
  /// 2. فحص أخطاء الكتابة وقت الترجمة
  ///    Compile-time checking for typos
  /// 3. سهولة التحديث إذا تغيرت النقاط النهائية
  ///    Easy to update if endpoints change
  /// 4. مرجع مركزي لجميع النقاط النهائية المتاحة
  ///    Central reference for all available endpoints

  /// نقاط نهاية المنشورات (عمليات CRUD)
  /// Posts endpoints (CRUD operations)
  static const String postsEndpoint = '/posts';
  static String postByIdEndpoint(int id) => '/posts/$id';
  static String postsByUserEndpoint(int userId) => '/posts?userId=$userId';

  /// نقاط نهاية المستخدمين
  /// Users endpoints
  static const String usersEndpoint = '/users';
  static String userByIdEndpoint(int id) => '/users/$id';

  /// نقاط نهاية التعليقات
  /// Comments endpoints
  static const String commentsEndpoint = '/comments';
  static String commentsByPostEndpoint(int postId) => '/posts/$postId/comments';

  /// ========================================
  /// رؤوس HTTP | HTTP Headers
  /// ========================================
  ///
  /// الرؤوس الافتراضية تُرسل مع كل طلب
  /// Default headers sent with every request.
  /// يمكن تجاوزها على أساس كل طلب
  /// These can be overridden on a per-request basis.

  /// الرؤوس الافتراضية لجميع الطلبات
  /// Default headers for all requests
  static Map<String, String> get defaultHeaders => {
    // Content-Type: يخبر الخادم بتنسيق البيانات التي ترسلها
    // Content-Type: Tells the server what format you're sending
    // application/json يعني أننا نرسل بيانات JSON
    // application/json means we're sending JSON data
    'Content-Type': 'application/json',

    // Accept: يخبر الخادم بالتنسيق الذي تريده في الاستجابة
    // Accept: Tells the server what format you want in response
    'Accept': 'application/json',

    // رأس تطبيق مخصص (مثال)
    // Custom app header (example)
    // مفيد للتحليلات والتصحيح على جانب الخادم
    // Useful for analytics and debugging on the server side
    'X-App-Version': '1.0.0',
  };

  /// ========================================
  /// بناء خيارات الطلب | Request Options Builder
  /// ========================================
  ///
  /// ينشئ الخيارات الأساسية لـ Dio مع جميع الإعدادات مطبقة
  /// Creates base options for Dio with all configurations applied.
  /// هذا يضمن إعدادات متسقة عبر التطبيق
  /// This ensures consistent settings across the application.

  static BaseOptions get baseOptions => BaseOptions(
    // الرابط الأساسي لجميع الطلبات
    // Base URL for all requests
    baseUrl: baseUrl,

    // قيم المهلة | Timeout values
    connectTimeout: const Duration(milliseconds: connectionTimeout),
    receiveTimeout: const Duration(milliseconds: receiveTimeout),
    sendTimeout: const Duration(milliseconds: sendTimeout),

    // الرؤوس الافتراضية | Default headers
    headers: defaultHeaders,

    // نوع الاستجابة (كيف يجب أن يحلل Dio الاستجابة)
    // Response type (how Dio should parse the response)
    // ResponseType.json: يحلل استجابات JSON تلقائياً
    // ResponseType.json: Automatically parse JSON responses
    responseType: ResponseType.json,

    // ما إذا كان يجب التحقق من أكواد الحالة (رمي خطأ عند 4xx/5xx)
    // Whether to validate status codes (throw error on 4xx/5xx)
    // نتعامل مع هذا بأنفسنا للمزيد من التحكم
    // We handle this ourselves for more control
    validateStatus: (status) {
      // أرجع true لمنع Dio من رمي خطأ عند أي حالة
      // Return true to prevent Dio from throwing on any status
      // سنتعامل مع أكواد الأخطاء في معالجة الاستثناءات
      // We'll handle error statuses in our exception handling
      return status != null && status < 500;
    },
  );
}

/// ============================================================================
/// إعدادات البيئة | Environment Configuration
/// ============================================================================
///
/// يدير بيئات API المختلفة (تطوير، تجربة، إنتاج)
/// Manages different API environments (development, staging, production)
///
/// في تطبيق حقيقي، ستفعل | In a real app, you would:
/// 1. تحديد البيئة عبر إعدادات البناء
///    Set environment via build configuration
/// 2. استخدام متغيرات البيئة للقيم الحساسة
///    Use environment variables for sensitive values
/// 3. عدم إيداع أسرار الإنتاج في كود المصدر أبداً
///    Never commit production secrets to source control

enum Environment { development, staging, production }

class EnvironmentConfig {
  // البيئة الحالية - غيّرها بناءً على بنائك
  // Current environment - change this based on your build
  static const Environment current = Environment.development;

  /// الحصول على الرابط الأساسي للبيئة الحالية
  /// Get base URL for current environment
  static String get baseUrl {
    switch (current) {
      case Environment.development:
        return 'https://jsonplaceholder.typicode.com';
      case Environment.staging:
        // في تطبيق حقيقي: return 'https://staging-api.example.com';
        // In real app: return 'https://staging-api.example.com';
        return 'https://jsonplaceholder.typicode.com';
      case Environment.production:
        // في تطبيق حقيقي: return 'https://api.example.com';
        // In real app: return 'https://api.example.com';
        return 'https://jsonplaceholder.typicode.com';
    }
  }

  /// ما إذا كان يجب تفعيل سجلات التصحيح
  /// Whether to enable debug logging
  static bool get enableLogging {
    switch (current) {
      case Environment.development:
        return true; // سجّل كل شيء في التطوير | Log everything in development
      case Environment.staging:
        return true; // سجّل للتصحيح | Log for debugging
      case Environment.production:
        return false; // عطّل التسجيل في الإنتاج | Disable logging in production
    }
  }
}
