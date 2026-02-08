import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controllers.dart';

/// ============================================================================
/// شاشة رفع الملفات: توضح رفع الملفات باستخدام Dio و GetX
/// File Upload Screen: Demonstrates File Upload with Dio and GetX
/// ============================================================================
///
/// هذه الشاشة توضح | This screen demonstrates:
/// 1. اختيار الملفات (محاكاة للتوضيح)
///    Selecting files (simulated for demonstration)
/// 2. تتبع تقدم الرفع
///    Upload progress tracking
/// 3. إنشاء FormData
///    FormData creation
/// 4. معالجة استجابات الرفع
///    Handling upload responses
/// 5. رفع ملفات متعددة
///    Multiple file uploads
///
/// أهداف التعلم | Learning Objectives:
/// - فهم طلبات multipart/form-data
///   Understand multipart/form-data requests
/// - تعلم تتبع تقدم الرفع
///   Learn to track upload progress
/// - رؤية أنماط التحقق من الملفات
///   See file validation patterns
/// - فهم FormData و MultipartFile
///   Understand FormData and MultipartFile
///
/// ملاحظة: هذه شاشة توضيحية. في تطبيق حقيقي:
/// Note: This is a demonstration screen. In a real app:
/// - استخدم حزمة image_picker أو file_picker
///   Use image_picker or file_picker package
/// - تعامل مع اختيار الملفات الفعلي
///   Handle actual file selection
/// - اعرض معاينات الصور
///   Show image previews
/// ============================================================================

/// شاشة رفع الملفات باستخدام GetView
/// File upload screen using GetView
class FileUploadScreen extends GetView<FileUploadController> {
  const FileUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // شريط التطبيق | App bar
      appBar: AppBar(title: const Text('رفع الملفات - File Upload')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========================================
            // بطاقة المعلومات | Information Card
            // ========================================
            Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          color: Theme.of(
                            context,
                          ).colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'رفع الملفات مع Dio - File Upload with Dio',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // عناصر المعلومات | Info items
                    _buildInfoItem(
                      context,
                      'Content-Type',
                      'multipart/form-data (ليس application/json - not application/json)',
                    ),
                    _buildInfoItem(
                      context,
                      'FormData',
                      'حاوية للملفات وحقول النموذج - Container for files and form fields',
                    ),
                    _buildInfoItem(
                      context,
                      'MultipartFile',
                      'يمثل ملفاً في الطلب - Represents a file in the request',
                    ),
                    _buildInfoItem(
                      context,
                      'onSendProgress',
                      'دالة رد لتتبع تقدم الرفع - Callback for tracking upload progress',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========================================
            // بطاقة مثال الكود | Code Example Card
            // ========================================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مثال الكود - Code Example',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const SelectableText(
                        '''// إنشاء FormData مع ملف | Create FormData with file
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    filePath,
    filename: 'photo.jpg',
  ),
  'description': 'My photo',
});

// الرفع مع تتبع التقدم | Upload with progress tracking
final response = await dio.post(
  '/upload',
  data: formData,
  onSendProgress: (sent, total) {
    print('\${(sent/total*100).toFixed(1)}%');
  },
);''',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========================================
            // قسم اختيار الملف | File Selection Section
            // ========================================
            Text(
              'عرض توضيحي للرفع - Upload Demo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // عرض الملف المختار | Selected file display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(
                  () => Column(
                    children: [
                      // أيقونة الملف | File icon
                      Icon(
                        controller.selectedFilePath.value != null
                            ? Icons.insert_drive_file
                            : Icons.cloud_upload_outlined,
                        size: 64,
                        color: controller.selectedFilePath.value != null
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      // اسم الملف | File name
                      Text(
                        controller.selectedFileName.value.isNotEmpty
                            ? controller.selectedFileName.value
                            : 'لا يوجد ملف مختار - No file selected',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      // مؤشر التقدم (يُعرض أثناء الرفع)
                      // Progress indicator (shown during upload)
                      if (controller.isUploading.value) ...[
                        LinearProgressIndicator(
                          value: controller.uploadProgress.value,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(controller.uploadProgress.value * 100).toStringAsFixed(1)}% تم الرفع - uploaded',
                        ),
                        const SizedBox(height: 16),
                      ],

                      // أزرار الاختيار والرفع | Select and upload buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // زر اختيار الملف | Select file button
                          OutlinedButton.icon(
                            onPressed: controller.isUploading.value
                                ? null
                                : () => _showFileSelectionDialog(),
                            icon: const Icon(Icons.attach_file),
                            label: const Text('اختيار ملف - Select File'),
                          ),
                          const SizedBox(width: 16),
                          // زر الرفع | Upload button
                          FilledButton.icon(
                            onPressed:
                                controller.isUploading.value ||
                                    controller.selectedFilePath.value == null
                                ? null
                                : controller.uploadFile,
                            icon: controller.isUploading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.cloud_upload),
                            label: Text(
                              controller.isUploading.value
                                  ? 'جاري الرفع... - Uploading...'
                                  : 'رفع - Upload',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ========================================
            // رسائل التغذية الراجعة | Feedback Messages
            // ========================================
            Obx(() {
              // رسالة الحالة | Status message
              if (controller.statusMessage.value != null) {
                return Card(
                  color: controller.statusColor.value == Colors.green
                      ? Colors.green.shade50
                      : controller.statusColor.value == Colors.red
                      ? Colors.red.shade50
                      : Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          controller.statusColor.value == Colors.green
                              ? Icons.check_circle
                              : controller.statusColor.value == Colors.red
                              ? Icons.error
                              : Icons.info,
                          color: controller.statusColor.value,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.statusMessage.value!,
                            style: TextStyle(
                              color: controller.statusColor.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // ========================================
            // سجل الرفع | Upload History
            // ========================================
            Obx(() {
              if (controller.uploadHistory.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'سجل الرفع - Upload History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    // عناصر السجل | History items
                    ...controller.uploadHistory.map(
                      (upload) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          // اسم الملف | File name
                          title: Text(
                            upload.filename ?? 'ملف غير معروف - Unknown file',
                          ),
                          // حجم الملف | File size
                          subtitle: Text(upload.formattedSize),
                          // وقت الرفع | Upload time
                          trailing: Text(
                            upload.message?.split('T').last.split('.').first ??
                                '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  /// عرض مربع حوار اختيار الملف (محاكاة)
  /// Show file selection dialog (simulated)
  void _showFileSelectionDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('اختيار ملف (تجريبي) - File Selection (Demo)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'في تطبيق حقيقي، ستستخدم:\n'
              'In a real app, you would use:\n'
              '• image_picker للصور - for photos\n'
              '• file_picker للمستندات - for documents\n\n'
              'لهذا العرض التوضيحي، سنحاكي اختيار ملف.\n'
              'For this demo, we\'ll simulate a file selection.',
            ),
            const SizedBox(height: 16),
            const Text('اختر ملفاً محاكياً: - Select a simulated file:'),
            const SizedBox(height: 8),
            // خيار صورة | Photo option
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('photo.jpg'),
              subtitle: const Text('2.5 MB'),
              onTap: () {
                Get.back();
                controller.selectFile('/tmp/demo_photo.jpg');
              },
            ),
            // خيار مستند | Document option
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('document.pdf'),
              subtitle: const Text('1.2 MB'),
              onTap: () {
                Get.back();
                controller.selectFile('/tmp/demo_document.pdf');
              },
            ),
            // خيار فيديو كبير | Large video option
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('video.mp4'),
              subtitle: const Text('15 MB - كبير جداً! - Too large!'),
              onTap: () {
                Get.back();
                controller.selectFile('/tmp/demo_large_video.mp4');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء - Cancel'),
          ),
        ],
      ),
    );
  }

  /// بناء عنصر معلومات | Build info item
  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
