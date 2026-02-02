/// ============================================================================
/// غلاف استجابة API العام - نمط أفضل الممارسات
/// Generic API Response Wrapper - Best Practice Pattern
/// ============================================================================
///
/// هذا نمط أفضل الممارسات للتعامل مع استجابات API
/// This is a best practice pattern for handling API responses.
/// يوفر هيكل موحد للاستجابات الناجحة والفاشلة
/// It provides a consistent structure for both successful and failed responses.
///
/// الفوائد | Benefits:
/// 1. تعامل موحد مع الاستجابات في كل التطبيق
///    Uniform response handling across the app
/// 2. وصول آمن للنوع للبيانات المُرجعة
///    Type-safe access to response data
/// 3. سهولة معالجة الأخطاء
///    Easy error handling
/// 4. دعم بيانات التقسيم (pagination)
///    Support for pagination metadata
///
/// مثال الاستخدام | Example usage:
/// ```dart
/// final response = ApiResponse<List<PostModel>>(
///   success: true,
///   data: posts,
///   message: 'Posts fetched successfully',
/// );
///
/// if (response.isSuccess) {
///   print(response.data);
/// } else {
///   print(response.error);
/// }
/// ```

class ApiResponse<T> {
  /// يشير إذا كان استدعاء API ناجحاً
  /// Indicates if the API call was successful
  /// true = نجاح، false = فشل
  /// true = success, false = failure
  final bool success;

  /// البيانات الفعلية المُرجعة من API
  /// The actual data returned by the API
  /// النوع عام (T) لذا يمكنه حمل أي نوع بيانات:
  /// Type is generic (T) so it can hold any data type:
  /// - List<PostModel> لقائمة المنشورات
  ///   List<PostModel> for a list of posts
  /// - PostModel لمنشور واحد
  ///   PostModel for a single post
  /// - String لاستجابات النص البسيطة
  ///   String for simple text responses
  /// - null إذا لم تُرجع بيانات (مثل عمليات DELETE)
  ///   null if no data is returned (like DELETE operations)
  final T? data;

  /// رسالة قابلة للقراءة من API
  /// A human-readable message from the API
  /// مفيدة لـ | Useful for:
  /// - رسائل النجاح ("تم إنشاء المستخدم بنجاح")
  ///   Success messages ("User created successfully")
  /// - وصف الأخطاء ("البريد الإلكتروني موجود مسبقاً")
  ///   Error descriptions ("Email already exists")
  final String? message;

  /// معلومات الخطأ عند فشل الطلب
  /// Error information when the request fails
  /// تحتوي على تفاصيل مثل | Contains details like:
  /// - نوع الخطأ | Error type
  /// - رمز الخطأ | Error code
  /// - رسالة خطأ مفصلة | Detailed error message
  final ApiError? error;

  /// كود حالة HTTP من الاستجابة
  /// HTTP status code from the response
  /// الأكواد الشائعة | Common codes:
  /// - 200: OK - نجاح
  /// - 201: Created - تم الإنشاء
  /// - 400: Bad Request - طلب خاطئ
  /// - 401: Unauthorized - غير مصرح
  /// - 404: Not Found - غير موجود
  /// - 500: Internal Server Error - خطأ في الخادم
  final int? statusCode;

  /// بيانات التقسيم (إن وجدت)
  /// Pagination data (if applicable)
  /// تُستخدم عند جلب قوائم مقسمة
  /// Used when fetching paginated lists
  final PaginationInfo? pagination;

  /// المُنشئ مع معاملات مسماة للوضوح
  /// Constructor with named parameters for clarity
  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.statusCode,
    this.pagination,
  });

  /// getter مريح للتحقق من نجاح الاستجابة
  /// Convenient getter to check if response was successful
  bool get isSuccess => success && error == null;

  /// getter مريح للتحقق من وجود بيانات
  /// Convenient getter to check if response has data
  bool get hasData => data != null;

  /// ========================================
  /// Factory constructor للاستجابات الناجحة
  /// Factory constructor for successful responses
  /// ========================================
  /// يسهل إنشاء استجابات نجاح مع بيانات
  /// Makes it easy to create success responses with data
  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message ?? 'Success',
      statusCode: statusCode ?? 200,
    );
  }

  /// ========================================
  /// Factory constructor للاستجابات الفاشلة
  /// Factory constructor for error responses
  /// ========================================
  /// يسهل إنشاء استجابات خطأ
  /// Makes it easy to create error responses
  factory ApiResponse.failure(
    String errorMessage, {
    int? statusCode,
    String? errorType,
  }) {
    return ApiResponse(
      success: false,
      data: null,
      message: errorMessage,
      error: ApiError(
        message: errorMessage,
        type: errorType ?? 'UnknownError',
        statusCode: statusCode,
      ),
      statusCode: statusCode,
    );
  }
}

/// ============================================================================
/// نموذج معلومات خطأ API
/// Model for API Error information
/// ============================================================================
///
/// يوفر تفاصيل خطأ منظمة يمكن | Provides structured error details that can be:
/// - عرضها للمستخدمين | Displayed to users
/// - تسجيلها للتصحيح | Logged for debugging
/// - استخدامها لقرارات استعادة الخطأ | Used for error recovery decisions
class ApiError {
  /// رسالة خطأ قابلة للقراءة - مناسبة للعرض للمستخدمين
  /// Human-readable error message - Suitable for displaying to users
  final String message;

  /// نوع/فئة الخطأ
  /// Error type/category
  /// أمثلة: NetworkError، ValidationError، ServerError
  /// Examples: NetworkError, ValidationError, ServerError
  final String type;

  /// كود حالة HTTP (إن وجد)
  /// HTTP status code (if applicable)
  final int? statusCode;

  /// رمز الخطأ التقني من الخادم - يُستخدم للتعامل البرمجي مع الأخطاء
  /// Technical error code from the server - Used for programmatic error handling
  final String? code;

  /// تفاصيل إضافية عن الخطأ - قد تحتوي أخطاء تحقق خاصة بالحقول
  /// Additional details about the error - May contain field-specific validation errors
  final Map<String, dynamic>? details;

  ApiError({
    required this.message,
    required this.type,
    this.statusCode,
    this.code,
    this.details,
  });

  @override
  String toString() => 'ApiError($type): $message';
}

/// ============================================================================
/// نموذج معلومات التقسيم (Pagination)
/// Model for Pagination Information
/// ============================================================================
///
/// يُستخدم عندما تُرجع APIs بيانات مقسمة
/// Used when APIs return paginated data
/// أنماط التقسيم الشائعة | Common pagination patterns:
/// 1. بناءً على الصفحة: ?page=2&limit=10
///    Page-based: ?page=2&limit=10
/// 2. بناءً على الإزاحة: ?offset=20&limit=10
///    Offset-based: ?offset=20&limit=10
/// 3. بناءً على المؤشر: ?cursor=abc123&limit=10
///    Cursor-based: ?cursor=abc123&limit=10
class PaginationInfo {
  /// رقم الصفحة الحالية (للتقسيم بناءً على الصفحة)
  /// Current page number (for page-based pagination)
  final int currentPage;

  /// إجمالي عدد الصفحات
  /// Total number of pages
  final int totalPages;

  /// إجمالي عدد العناصر في جميع الصفحات
  /// Total number of items across all pages
  final int totalItems;

  /// عدد العناصر في كل صفحة
  /// Number of items per page
  final int itemsPerPage;

  /// هل يوجد عناصر أخرى بعد هذه الصفحة
  /// Whether there are more items after this page
  final bool hasNextPage;

  /// هل يوجد عناصر قبل هذه الصفحة
  /// Whether there are items before this page
  final bool hasPreviousPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Factory constructor لإنشاء معلومات التقسيم من استجابة API
  /// Factory constructor to create pagination info from API response
  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? json['page'] ?? 1,
      totalPages: json['total_pages'] ?? json['totalPages'] ?? 1,
      totalItems: json['total_items'] ?? json['total'] ?? 0,
      itemsPerPage: json['per_page'] ?? json['limit'] ?? 10,
      hasNextPage: json['has_next'] ?? json['hasMore'] ?? false,
      hasPreviousPage: json['has_previous'] ?? (json['page'] ?? 1) > 1,
    );
  }
}
