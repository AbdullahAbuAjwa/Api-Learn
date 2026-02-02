import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';

/// ============================================================================
/// File Upload Screen: Demonstrates File Upload with Dio
/// ============================================================================
///
/// This screen demonstrates:
/// 1. Selecting files (simulated for demonstration)
/// 2. Upload progress tracking
/// 3. FormData creation
/// 4. Handling upload responses
/// 5. Multiple file uploads
///
/// Learning Objectives:
/// - Understand multipart/form-data requests
/// - Learn to track upload progress
/// - See file validation patterns
/// - Understand FormData and MultipartFile
///
/// Note: This is a demonstration screen. In a real app, you would:
/// - Use image_picker or file_picker package
/// - Handle actual file selection
/// - Show image previews
/// ============================================================================

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  // ========================================
  // Service and State
  // ========================================

  // ignore: unused_field - Used in real implementation
  final FileUploadService _uploadService = FileUploadService(dioClient);

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _successMessage;
  String? _errorMessage;

  /// Selected file path (simulated)
  String? _selectedFilePath;

  /// Upload history for demonstration
  final List<FileUploadResponse> _uploadHistory = [];

  /// ========================================
  /// Simulated File Selection
  /// ========================================
  ///
  /// In a real app, you would use:
  /// - image_picker package for photos/videos
  /// - file_picker package for general files
  ///
  /// Example with image_picker:
  /// ```dart
  /// final ImagePicker picker = ImagePicker();
  /// final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  /// if (image != null) {
  ///   setState(() => _selectedFilePath = image.path);
  /// }
  /// ```
  void _selectFile() {
    // For demonstration, we'll create a temporary file
    // In a real app, this would open a file picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Selection (Demo)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'In a real app, you would use:\n'
              '• image_picker for photos\n'
              '• file_picker for documents\n\n'
              'For this demo, we\'ll simulate a file selection.',
            ),
            const SizedBox(height: 16),
            const Text('Select a simulated file:'),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('photo.jpg'),
              subtitle: const Text('2.5 MB'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedFilePath = '/tmp/demo_photo.jpg';
                });
                _showInfoSnackBar('Selected: photo.jpg (simulated)');
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('document.pdf'),
              subtitle: const Text('1.2 MB'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedFilePath = '/tmp/demo_document.pdf';
                });
                _showInfoSnackBar('Selected: document.pdf (simulated)');
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('video.mp4'),
              subtitle: const Text('15 MB - Too large!'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedFilePath = '/tmp/demo_large_video.mp4';
                });
                _showInfoSnackBar(
                  'Selected: video.mp4 (will fail - too large)',
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// ========================================
  /// Upload File Demo
  /// ========================================
  ///
  /// This demonstrates the upload flow without actually uploading
  /// since we don't have a real file. In a real app, you would:
  /// 1. Get the actual file path from file picker
  /// 2. Call _uploadService.uploadFile(actualFilePath)
  Future<void> _uploadFile() async {
    if (_selectedFilePath == null) {
      _showErrorSnackBar('Please select a file first');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _successMessage = null;
      _errorMessage = null;
    });

    // Simulate upload progress for demonstration
    // In a real app, progress comes from the onProgress callback
    await _simulateUploadProgress();

    setState(() {
      _isUploading = false;

      // Simulate success/failure based on "file size"
      if (_selectedFilePath!.contains('large')) {
        _errorMessage = 'File too large. Maximum size is 10MB.';
      } else {
        final fileName = _selectedFilePath!.split('/').last;
        _successMessage = 'File "$fileName" uploaded successfully!';

        // Add to history
        _uploadHistory.insert(
          0,
          FileUploadResponse(
            success: true,
            filename: fileName,
            fileSize: fileName.contains('photo') ? 2621440 : 1258291,
            message: 'Uploaded at ${DateTime.now().toIso8601String()}',
          ),
        );

        // Clear selection
        _selectedFilePath = null;
      }
    });
  }

  /// Simulate upload progress for demonstration
  Future<void> _simulateUploadProgress() async {
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _uploadProgress = i / 100;
        });
      }
    }
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Upload')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========================================
            // Information Card
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
                          'File Upload with Dio',
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
                    _buildInfoItem(
                      'Content-Type',
                      'multipart/form-data (not application/json)',
                    ),
                    _buildInfoItem(
                      'FormData',
                      'Container for files and form fields',
                    ),
                    _buildInfoItem(
                      'MultipartFile',
                      'Represents a file in the request',
                    ),
                    _buildInfoItem(
                      'onSendProgress',
                      'Callback for tracking upload progress',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========================================
            // Code Example Card
            // ========================================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Code Example',
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
                        '''// Create FormData with file
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    filePath,
    filename: 'photo.jpg',
  ),
  'description': 'My photo',
});

// Upload with progress tracking
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
            // File Selection Section
            // ========================================
            Text(
              'Upload Demo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Selected file display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _selectedFilePath != null
                          ? Icons.insert_drive_file
                          : Icons.cloud_upload_outlined,
                      size: 64,
                      color: _selectedFilePath != null
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFilePath != null
                          ? _selectedFilePath!.split('/').last
                          : 'No file selected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Progress indicator (shown during upload)
                    if (_isUploading) ...[
                      LinearProgressIndicator(value: _uploadProgress),
                      const SizedBox(height: 8),
                      Text(
                        '${(_uploadProgress * 100).toStringAsFixed(1)}% uploaded',
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isUploading ? null : _selectFile,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Select File'),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: _isUploading || _selectedFilePath == null
                              ? null
                              : _uploadFile,
                          icon: _isUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.cloud_upload),
                          label: Text(_isUploading ? 'Uploading...' : 'Upload'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ========================================
            // Feedback Messages
            // ========================================
            if (_successMessage != null)
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
                          _successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_errorMessage != null)
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
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ========================================
            // Upload History
            // ========================================
            if (_uploadHistory.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'Upload History',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...(_uploadHistory.map(
                (upload) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(upload.filename ?? 'Unknown file'),
                    subtitle: Text(upload.formattedSize),
                    trailing: Text(
                      upload.message?.split('T').last.split('.').first ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
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
