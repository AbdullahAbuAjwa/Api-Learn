import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'dio_interceptors.dart';

/// ============================================================================
/// عميل Dio: إدارة عميل HTTP المركزي
/// Dio Client: Centralized HTTP Client Management
/// ============================================================================
///
/// هذا الكلاس يدير نسخة عميل Dio HTTP مع:
/// This class manages the Dio HTTP client instance with:
/// 1. نمط Singleton لإعدادات متسقة
///    Singleton pattern for consistent configuration
/// 2. تهيئة كسولة (Lazy) لأداء أفضل
///    Lazy initialization for better performance
/// 3. إدارة مركزية للـ interceptors
///    Centralized interceptor management
/// 4. دوال مصنع سهلة الاستخدام
///    Easy-to-use factory methods
///
/// لماذا Singleton لعميل HTTP؟ | Why Singleton for HTTP Client?
/// - يضمن أن جميع الطلبات تستخدم نفس الإعدادات
///   Ensures all requests use the same configuration
/// - يمنع إنشاء نسخ متعددة من العميل
///   Prevents creating multiple client instances
/// - أسهل لإدارة interceptors عالمياً
///   Easier to manage interceptors globally
/// - إدارة أفضل لمجمع الاتصالات والموارد
///   Better connection pooling and resource management
///
/// الاستخدام | Usage:
/// ```dart
/// // الحصول على نسخة Dio المُعدة
/// // Get the configured Dio instance
/// final dio = DioClient.instance;
///
/// // تنفيذ طلب | Make a request
/// final response = await dio.get('/posts');
/// ```
/// ============================================================================

class DioClient {
  /// ========================================
  /// تنفيذ نمط Singleton
  /// Singleton Implementation
  /// ========================================
  ///
  /// نمط Singleton يضمن وجود نسخة واحدة فقط من DioClient
  /// The Singleton pattern ensures only one instance of DioClient exists.
  /// هذا مهم لأن | This is important because:
  /// 1. جميع الطلبات تشارك نفس الإعدادات
  ///    All requests share the same configuration
  /// 2. الـ interceptors تُطبق مرة واحدة
  ///    Interceptors are applied once
  /// 3. مجمع الاتصالات محسّن
  ///    Connection pooling is optimized

  // منشئ خاص - يمنع الإنشاء الخارجي
  // Private constructor - prevents external instantiation
  DioClient._internal();

  // حامل النسخة الثابتة | Static instance holder
  static DioClient? _instance;

  // منشئ المصنع يرجع نسخة singleton
  // Factory constructor returns the singleton instance
  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  // نسخة Dio الفعلية (تهيئة كسولة)
  // The actual Dio instance (lazy initialization)
  Dio? _dio;

  /// الحصول على نسخة Dio المُعدة
  /// Get the configured Dio instance
  ///
  /// هذه نقطة الدخول الرئيسية لتنفيذ طلبات HTTP
  /// This is the main entry point for making HTTP requests.
  /// نسخة Dio مُعدة مع:
  /// The Dio instance is configured with:
  /// - الرابط الأساسي والمهلات من ApiConfig
  ///   Base URL and timeouts from ApiConfig
  /// - interceptor التسجيل للتصحيح
  ///   Logging interceptor for debugging
  /// - interceptor معالجة الأخطاء
  ///   Error handling interceptor
  Dio get instance {
    // تهيئة كسولة - تُنشأ فقط عند الحاجة الأولى
    // Lazy initialization - only create when first needed
    _dio ??= _createDio();
    return _dio!;
  }

  /// ========================================
  /// إنشاء وتكوين نسخة Dio
  /// Dio Instance Creation and Configuration
  /// ========================================
  ///
  /// هذه الدالة تُعد نسخة Dio جديدة مع كل الإعدادات المطلوبة
  /// This method sets up a new Dio instance with all required configuration.
  /// تُستدعى مرة واحدة أثناء التهيئة الكسولة
  /// Called once during lazy initialization.

  Dio _createDio() {
    // إنشاء Dio مع الإعدادات الأساسية
    // Create Dio with base configuration
    final dio = Dio(ApiConfig.baseOptions);

    // إضافة interceptors بترتيب التنفيذ
    // Add interceptors in order of execution
    // الترتيب مهم! الـ interceptors تُنفذ بترتيب إضافتها
    // Order matters! Interceptors execute in the order they're added

    // 1. Logging Interceptor (أولاً، ليسجل الطلب الأصلي)
    // 1. Logging Interceptor (first, so it logs original request)
    // يُضاف فقط في وضع التطوير
    // Only add in development mode
    if (EnvironmentConfig.enableLogging) {
      dio.interceptors.add(LoggingInterceptor(logBody: true, logHeaders: true));
    }

    // 2. Auth Interceptor (يضيف التوكنات قبل إرسال الطلب)
    // 2. Auth Interceptor (adds tokens before request is sent)
    // ألغِ التعليق عندما يكون لديك مصادقة مُنفذة:
    // Uncomment when you have authentication implemented:
    // dio.interceptors.add(AuthInterceptor(
    //   getToken: () async {
    //     // استرجاع التوكن من التخزين الآمن
    //     // Retrieve token from secure storage
    //     return await SecureStorage.getToken();
    //   },
    //   refreshToken: () async {
    //     // تنفيذ منطق تجديد التوكن
    //     // Implement token refresh logic
    //     return await AuthService.refreshToken();
    //   },
    //   onAuthFailure: () {
    //     // الانتقال لشاشة تسجيل الدخول
    //     // Navigate to login screen
    //     NavigationService.navigateToLogin();
    //   },
    // ));

    // 3. Retry Interceptor (يعيد محاولة الطلبات الفاشلة)
    // 3. Retry Interceptor (retries failed requests)
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        maxRetries: 3,
        retryDelay: const Duration(seconds: 1),
      ),
    );

    // 4. Cache Interceptor (اختياري - يخزن طلبات GET مؤقتاً)
    // 4. Cache Interceptor (optional - cache GET requests)
    // dio.interceptors.add(CacheInterceptor(
    //   maxAge: const Duration(minutes: 5),
    // ));

    return dio;
  }

  /// ========================================
  /// دوال مريحة لطلبات HTTP
  /// Convenience Methods for HTTP Requests
  /// ========================================
  ///
  /// هذه الدوال توفر API أنظف للعمليات الشائعة
  /// These methods provide a cleaner API for common operations.
  /// تغلف دوال Dio مع معالجة أخطاء وتسجيل إضافي
  /// They wrap Dio's methods with additional error handling and logging.

  /// ========================================
  /// تنفيذ طلب GET
  /// Perform a GET request
  /// ========================================
  ///
  /// GET يُستخدم لاسترجاع البيانات من الخادم
  /// GET is used to retrieve data from the server.
  /// يجب ألا يُعدل أي بيانات على الخادم
  /// It should NOT modify any data on the server.
  ///
  /// المعاملات | Parameters:
  /// - path: مسار النقطة النهائية (يُلحق بـ baseUrl)
  ///         The endpoint path (appended to baseUrl)
  /// - queryParameters: معاملات استعلام URL (?key=value)
  ///                   URL query parameters (?key=value)
  /// - options: خيارات طلب إضافية
  ///           Additional request options
  /// - cancelToken: رمز لإلغاء الطلب
  ///               Token to cancel the request
  ///
  /// مثال | Example:
  /// ```dart
  /// // GET بسيط | Simple GET
  /// final response = await client.get('/posts');
  ///
  /// // GET مع معاملات استعلام: /posts?userId=1
  /// // GET with query parameters: /posts?userId=1
  /// final response = await client.get('/posts', queryParameters: {'userId': 1});
  /// ```
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return instance.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// ========================================
  /// تنفيذ طلب POST
  /// Perform a POST request
  /// ========================================
  ///
  /// POST يُستخدم لإنشاء موارد جديدة على الخادم
  /// POST is used to create new resources on the server.
  /// يرسل البيانات في جسم الطلب
  /// It sends data in the request body.
  ///
  /// المعاملات | Parameters:
  /// - path: مسار النقطة النهائية
  ///         The endpoint path
  /// - data: جسم الطلب (سيُحول لـ JSON)
  ///         The request body (will be serialized to JSON)
  /// - queryParameters: معاملات استعلام URL
  ///                   URL query parameters
  /// - options: خيارات طلب إضافية
  ///           Additional request options
  ///
  /// مثال | Example:
  /// ```dart
  /// final response = await client.post('/posts', data: {
  ///   'title': 'منشور جديد',  // New Post
  ///   'body': 'المحتوى هنا',  // Content here
  ///   'userId': 1,
  /// });
  /// ```
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return instance.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// ========================================
  /// تنفيذ طلب PUT
  /// Perform a PUT request
  /// ========================================
  ///
  /// PUT يُستخدم لتحديث مورد موجود بالكامل
  /// PUT is used to update an existing resource completely.
  /// يستبدل المورد بالكامل بالبيانات المُقدمة
  /// It replaces the entire resource with the provided data.
  ///
  /// الفرق بين PUT و PATCH:
  /// Difference between PUT and PATCH:
  /// - PUT: استبدال المورد بالكامل
  ///        Replace entire resource
  /// - PATCH: تحديث حقول معينة فقط
  ///          Update only specific fields
  ///
  /// مثال | Example:
  /// ```dart
  /// final response = await client.put('/posts/1', data: {
  ///   'id': 1,
  ///   'title': 'عنوان محدث',  // Updated Title
  ///   'body': 'محتوى محدث',   // Updated Content
  ///   'userId': 1,
  /// });
  /// ```
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return instance.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// ========================================
  /// تنفيذ طلب PATCH
  /// Perform a PATCH request
  /// ========================================
  ///
  /// PATCH يُستخدم لتحديث جزئي لمورد
  /// PATCH is used to partially update a resource.
  /// فقط الحقول المُقدمة في جسم الطلب تُحدث
  /// Only the fields provided in the request body are updated.
  ///
  /// مثال | Example:
  /// ```dart
  /// // تحديث العنوان فقط، الحقول الأخرى تبقى كما هي
  /// // Only update the title, keep other fields unchanged
  /// final response = await client.patch('/posts/1', data: {
  ///   'title': 'عنوان جديد فقط',  // New Title Only
  /// });
  /// ```
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return instance.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// ========================================
  /// تنفيذ طلب DELETE
  /// Perform a DELETE request
  /// ========================================
  ///
  /// DELETE يُستخدم لإزالة مورد من الخادم
  /// DELETE is used to remove a resource from the server.
  /// عادة لا يحتوي على جسم طلب
  /// Usually doesn't have a request body.
  ///
  /// مثال | Example:
  /// ```dart
  /// final response = await client.delete('/posts/1');
  /// ```
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return instance.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// ========================================
  /// دالة رفع الملفات
  /// File Upload Method
  /// ========================================
  ///
  /// رفع الملفات يستخدم multipart/form-data بدلاً من JSON
  /// File uploads use multipart/form-data instead of JSON.
  /// Dio يتعامل مع ترميز الملف تلقائياً
  /// Dio handles the file encoding automatically.
  ///
  /// المفاهيم الأساسية | Key concepts:
  /// - FormData: حاوية لبيانات الملفات والنصوص
  ///             Container for file and text data
  /// - MultipartFile: يمثل ملف للرفع
  ///                 Represents a file to be uploaded
  /// - onSendProgress: callback لتقدم الرفع
  ///                  Callback for upload progress
  ///
  /// مثال | Example:
  /// ```dart
  /// final response = await client.uploadFile(
  ///   '/upload',
  ///   filePath: '/path/to/file.jpg',
  ///   fileName: 'photo.jpg',
  ///   onProgress: (sent, total) {
  ///     print('التقدم: ${sent / total * 100}%');
  ///     print('Progress: ${sent / total * 100}%');
  ///   },
  /// );
  /// ```
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    String? fileName,
    String fileFieldName = 'file',
    Map<String, dynamic>? additionalData,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // إنشاء FormData للرفع متعدد الأجزاء
    // Create FormData for multipart upload
    final formData = FormData.fromMap({
      // إضافة الملف | Add the file
      fileFieldName: await MultipartFile.fromFile(filePath, filename: fileName),
      // إضافة أي حقول نموذج إضافية
      // Add any additional form fields
      ...?additionalData,
    });

    return instance.post<T>(
      path,
      data: formData,
      options: Options(
        // تجاوز content-type لرفع الملفات
        // Override content-type for file uploads
        contentType: 'multipart/form-data',
        // مهلة ممتدة لرفع الملفات
        // Extended timeout for file uploads
        sendTimeout: const Duration(milliseconds: ApiConfig.uploadTimeout),
      ),
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
  }

  /// ========================================
  /// دالة إلغاء الطلب
  /// Cancel Request Method
  /// ========================================
  ///
  /// CancelToken يسمح لك بإلغاء الطلبات الجارية
  /// CancelToken allows you to cancel ongoing requests.
  /// مفيد لـ | Useful for:
  /// - المستخدم ينتقل بعيداً عن الشاشة
  ///   User navigates away from a screen
  /// - تغيير إدخال البحث (إلغاء البحث السابق)
  ///   Search input changes (cancel previous search)
  /// - معالجة المهلة الزمنية
  ///   Timeout handling
  ///
  /// الاستخدام | Usage:
  /// ```dart
  /// final cancelToken = CancelToken();
  ///
  /// // بدء الطلب | Start the request
  /// client.get('/slow-endpoint', cancelToken: cancelToken);
  ///
  /// // إلغاء إذا لزم الأمر | Cancel if needed
  /// cancelToken.cancel('المستخدم ألغى');  // User cancelled
  /// ```
  CancelToken createCancelToken() {
    return CancelToken();
  }
}

/// ============================================================================
/// نسخة DioClient العالمية
/// Global DioClient Instance
/// ============================================================================
///
/// getter مريح للوصول لـ singleton DioClient
/// A convenience getter for accessing the DioClient singleton.
/// هذا يسهل الاستيراد والاستخدام في كل التطبيق
/// This makes it easy to import and use throughout the app.
///
/// الاستخدام | Usage:
/// ```dart
/// import 'package:api_learn/core/network/dio_client.dart';
///
/// final response = await dioClient.get('/posts');
/// ```

final dioClient = DioClient();
