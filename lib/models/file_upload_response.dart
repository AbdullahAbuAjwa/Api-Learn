/// ============================================================================
/// نموذج استجابة رفع الملفات
/// File Upload Response Model
/// ============================================================================
///
/// هذا النموذج يتعامل مع استجابات APIs لرفع الملفات
/// This model handles responses from file upload APIs.
/// رفع الملفات حالة خاصة في REST APIs لأن:
/// File uploads are a special case in REST APIs because:
/// 1. تستخدم نوع محتوى multipart/form-data
///    They use multipart/form-data content type
/// 2. قد تتضمن الاستجابة بيانات وصفية للملف
///    Response may include file metadata
/// 3. غالباً ما يُحتاج لتتبع التقدم
///    Progress tracking is often needed
///
/// مثال استجابة من خدمة رفع الملفات:
/// Example response from a file upload service:
/// ```json
/// {
///   "success": true,
///   "data": {
///     "id": "file123",
///     "filename": "photo.jpg",
///     "size": 1024567,
///     "url": "https://api.example.com/files/file123",
///     "thumbnailUrl": "https://api.example.com/files/file123/thumb"
///   }
/// }
/// ```

class FileUploadResponse {
  /// هل نجح الرفع
  /// Whether the upload was successful
  final bool success;

  /// المعرف الفريد المُعين للملف المرفوع
  /// Unique identifier assigned to the uploaded file
  final String? fileId;

  /// اسم الملف الأصلي أو المعين من الخادم
  /// Original filename or server-assigned filename
  final String? filename;

  /// حجم الملف بالبايت
  /// File size in bytes
  final int? fileSize;

  /// الرابط حيث يمكن الوصول للملف
  /// URL where the file can be accessed
  final String? fileUrl;

  /// رابط الصورة المصغرة (لرفع الصور)
  /// URL for thumbnail (for image uploads)
  final String? thumbnailUrl;

  /// نوع MIME للملف المرفوع
  /// MIME type of the uploaded file
  final String? mimeType;

  /// رسالة الخادم عن الرفع
  /// Server message about the upload
  final String? message;

  /// رسالة الخطأ إذا فشل الرفع
  /// Error message if upload failed
  final String? error;

  FileUploadResponse({
    required this.success,
    this.fileId,
    this.filename,
    this.fileSize,
    this.fileUrl,
    this.thumbnailUrl,
    this.mimeType,
    this.message,
    this.error,
  });

  /// ========================================
  /// Factory constructor لفك تسلسل JSON
  /// Factory constructor for JSON deserialization
  /// ========================================
  /// يتعامل مع تنسيقات استجابة API المختلفة
  /// Handles various API response formats
  factory FileUploadResponse.fromJson(Map<String, dynamic> json) {
    // استجابات API يمكن أن تكون منظمة بشكل مختلف
    // API responses can be structured differently
    // هنا نتعامل مع الهياكل المسطحة والمتداخلة
    // Here we handle both flat and nested structures

    final data = json['data'] as Map<String, dynamic>? ?? json;

    return FileUploadResponse(
      success: json['success'] as bool? ?? true,
      fileId: data['id']?.toString() ?? data['fileId']?.toString(),
      filename: data['filename'] as String? ?? data['name'] as String?,
      fileSize: data['size'] as int? ?? data['fileSize'] as int?,
      fileUrl: data['url'] as String? ?? data['fileUrl'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String? ?? data['thumb'] as String?,
      mimeType: data['mimeType'] as String? ?? data['type'] as String?,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }

  /// ========================================
  /// خاصية محسوبة للحصول على حجم الملف بصيغة مقروءة
  /// Computed property to get human-readable file size
  /// ========================================
  /// تحول البايت إلى KB أو MB أو GB حسب الحاجة
  /// Converts bytes to KB, MB, or GB as appropriate
  String get formattedSize {
    if (fileSize == null) return 'Unknown';

    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;

    if (fileSize! >= gb) {
      return '${(fileSize! / gb).toStringAsFixed(2)} GB';
    } else if (fileSize! >= mb) {
      return '${(fileSize! / mb).toStringAsFixed(2)} MB';
    } else if (fileSize! >= kb) {
      return '${(fileSize! / kb).toStringAsFixed(2)} KB';
    } else {
      return '$fileSize bytes';
    }
  }

  @override
  String toString() {
    return 'FileUploadResponse(success: $success, filename: $filename, size: $formattedSize)';
  }
}

/// ============================================================================
/// نموذج تتبع تقدم الرفع
/// Model for tracking upload progress
/// ============================================================================
///
/// يُستخدم لعرض أشرطة التقدم وحالة الرفع للمستخدمين
/// Used to show progress bars and upload status to users
/// Dio يوفر هذه القيم من خلال callback الـ onSendProgress
/// Dio provides these values through its onSendProgress callback
class UploadProgress {
  /// البايتات التي تم إرسالها حتى الآن
  /// Bytes that have been sent so far
  final int sentBytes;

  /// إجمالي البايتات المراد إرسالها
  /// Total bytes to be sent
  final int totalBytes;

  /// التقدم كقيمة بين 0.0 و 1.0
  /// Progress as a value between 0.0 and 1.0
  double get progress {
    if (totalBytes == 0) return 0.0;
    return sentBytes / totalBytes;
  }

  /// التقدم كنسبة مئوية (0-100)
  /// Progress as a percentage (0-100)
  double get percentage => progress * 100;

  /// نص التقدم بصيغة مقروءة
  /// Human-readable progress text
  String get progressText => '${percentage.toStringAsFixed(1)}%';

  UploadProgress({required this.sentBytes, required this.totalBytes});

  @override
  String toString() => 'Upload Progress: $progressText';
}
