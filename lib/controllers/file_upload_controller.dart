import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/core.dart';
import '../models/models.dart';

/// ============================================================================
/// متحكم رفع الملفات - إدارة رفع الملفات باستخدام GetX
/// File Upload Controller - Managing file uploads with GetX
/// ============================================================================
///
/// هذا المتحكم يوضح | This controller demonstrates:
/// 1. رفع الملفات باستخدام multipart/form-data
///    Uploading files using multipart/form-data
/// 2. تتبع تقدم الرفع في الوقت الفعلي
///    Real-time upload progress tracking
/// 3. التحقق من صحة الملف قبل الرفع
///    File validation before upload
/// 4. إلغاء عملية الرفع
///    Canceling upload operations
/// ============================================================================

class FileUploadController extends GetxController {
  // ========================================
  // الخدمات | Services
  // ========================================

  final FileUploadService _uploadService = FileUploadService(dioClient);

  // ========================================
  // المتغيرات التفاعلية | Reactive Variables
  // ========================================

  /// الملف المختار للرفع | Selected file for upload
  final selectedFilePath = Rxn<String>();

  /// اسم الملف المختار | Selected file name
  final selectedFileName = ''.obs;

  /// حجم الملف | File size
  final fileSize = 0.obs;

  /// حالة الرفع | Upload state
  final isUploading = false.obs;

  /// تقدم الرفع (0.0 - 1.0) | Upload progress (0.0 - 1.0)
  final uploadProgress = 0.0.obs;

  /// نسبة التقدم المعروضة | Displayed progress percentage
  final progressText = '0%'.obs;

  /// رسالة الحالة | Status message
  final statusMessage = Rxn<String>();

  /// لون الحالة | Status color
  final statusColor = Colors.grey.obs;

  /// سجل عمليات الرفع | Upload history
  final uploadHistory = <FileUploadResponse>[].obs;

  /// نتيجة الرفع الأخيرة | Last upload result
  final lastUploadResult = Rxn<FileUploadResponse>();

  // ========================================
  // اختيار الملف | File Selection
  // ========================================

  /// محاكاة اختيار ملف (في التطبيق الحقيقي يُستخدم file_picker)
  /// Simulate file selection (in real app use file_picker)
  ///
  /// في تطبيق حقيقي ستستخدم | In a real app you would use:
  /// ```dart
  /// final result = await FilePicker.platform.pickFiles();
  /// if (result != null) {
  ///   selectFile(result.files.single.path!);
  /// }
  /// ```
  void selectFile(String path) {
    selectedFilePath.value = path;
    selectedFileName.value = path.split('/').last;

    // حساب حجم الملف | Calculate file size
    final file = File(path);
    if (file.existsSync()) {
      fileSize.value = file.lengthSync();
    }

    statusMessage.value =
        'ملف مختار: ${selectedFileName.value}\nFile selected: ${selectedFileName.value}';
    statusColor.value = Colors.blue;
  }

  // ========================================
  // رفع الملف | Upload File
  // ========================================

  /// رفع الملف المختار إلى الخادم
  /// Upload selected file to server
  ///
  /// يوضح | Demonstrates:
  /// - إنشاء FormData مع الملف
  ///   Creating FormData with file
  /// - تتبع التقدم عبر callback
  ///   Progress tracking via callback
  /// - معالجة النجاح والخطأ
  ///   Success and error handling
  Future<void> uploadFile() async {
    if (selectedFilePath.value == null) {
      Get.snackbar(
        'تنبيه - Warning',
        'الرجاء اختيار ملف أولاً - Please select a file first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    // التحقق من حجم الملف | Check file size
    if (fileSize.value > ApiConfig.maxFileSize) {
      statusMessage.value =
          'الملف كبير جداً. الحد الأقصى: ${ApiConfig.maxFileSize ~/ (1024 * 1024)}MB\n'
          'File too large. Maximum: ${ApiConfig.maxFileSize ~/ (1024 * 1024)}MB';
      statusColor.value = Colors.red;
      return;
    }

    isUploading.value = true;
    uploadProgress.value = 0.0;
    progressText.value = '0%';
    statusMessage.value = 'جاري الرفع... - Uploading...';
    statusColor.value = Colors.blue;

    final response = await _uploadService.uploadFile(
      selectedFilePath.value!,
      onProgress: (progress) {
        // تحديث التقدم تفاعلياً | Update progress reactively
        uploadProgress.value = progress.progress;
        progressText.value = progress.progressText;
        statusMessage.value =
            'جاري الرفع: ${progress.progressText}\nUploading: ${progress.progressText}';
      },
    );

    isUploading.value = false;

    if (response.isSuccess && response.hasData) {
      uploadProgress.value = 1.0;
      progressText.value = '100%';
      statusMessage.value =
          'تم الرفع بنجاح! ✅\nUpload successful! ✅\n'
          'اسم الملف: ${response.data!.filename}\n'
          'Filename: ${response.data!.filename}';
      statusColor.value = Colors.green;
      lastUploadResult.value = response.data;
      uploadHistory.insert(0, response.data!);

      Get.snackbar(
        'نجاح - Success',
        'تم رفع الملف بنجاح - File uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } else {
      statusMessage.value =
          'فشل الرفع: ${response.error?.message}\n'
          'Upload failed: ${response.error?.message}';
      statusColor.value = Colors.red;
    }
  }

  // ========================================
  // إعادة تعيين | Reset
  // ========================================

  /// إعادة تعيين حالة الرفع
  /// Reset upload state
  void resetUpload() {
    selectedFilePath.value = null;
    selectedFileName.value = '';
    fileSize.value = 0;
    uploadProgress.value = 0.0;
    progressText.value = '0%';
    statusMessage.value = null;
    statusColor.value = Colors.grey;
    lastUploadResult.value = null;
  }
}
