import 'dart:io';
import 'package:dio/dio.dart';
import '../../models/models.dart';
import '../config/api_config.dart';
import '../exceptions/api_exceptions.dart';
import '../network/dio_client.dart';

/// ============================================================================
/// File Upload Service: Demonstrates File Upload with Dio
/// ============================================================================
///
/// This service demonstrates:
/// 1. Uploading single files
/// 2. Uploading multiple files
/// 3. Uploading files with additional form data
/// 4. Progress tracking during upload
/// 5. File validation before upload
///
/// Key Concepts:
///
/// Content-Type for File Uploads:
/// - Regular JSON: application/json
/// - File Upload: multipart/form-data
///
/// FormData:
/// - A container for form data including files
/// - Automatically sets correct content-type
/// - Handles file encoding
///
/// MultipartFile:
/// - Represents a file in FormData
/// - Created from file path, bytes, or stream
/// - Includes filename and content-type
/// ============================================================================

class FileUploadService {
  final DioClient _client;

  FileUploadService(this._client);

  /// ========================================
  /// Upload Single File
  /// ========================================
  ///
  /// This method demonstrates:
  /// - Creating FormData with a file
  /// - Progress tracking with onSendProgress
  /// - Extended timeout for large files
  ///
  /// Parameters:
  /// - filePath: Path to the file on device
  /// - onProgress: Callback for upload progress (optional)
  ///
  /// Example usage:
  /// ```dart
  /// final result = await fileUploadService.uploadFile(
  ///   '/path/to/image.jpg',
  ///   onProgress: (progress) {
  ///     print('Upload: ${progress.percentage}%');
  ///   },
  /// );
  /// ```
  Future<ApiResponse<FileUploadResponse>> uploadFile(
    String filePath, {
    void Function(UploadProgress progress)? onProgress,
  }) async {
    try {
      // =====================================
      // Step 1: Validate the file
      // =====================================
      // Always validate files before uploading to:
      // - Prevent uploading invalid files
      // - Give early feedback to users
      // - Save bandwidth and server resources

      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        return ApiResponse.failure(
          'File not found: $filePath',
          errorType: 'FileNotFoundError',
        );
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > ApiConfig.maxFileSize) {
        return ApiResponse.failure(
          'File too large. Maximum size is ${ApiConfig.maxFileSize ~/ (1024 * 1024)}MB',
          errorType: 'FileTooLargeError',
        );
      }

      // =====================================
      // Step 2: Create FormData with the file
      // =====================================
      // FormData.fromMap creates a FormData object from a Map
      // Special keys like 'file' contain MultipartFile objects

      final fileName = filePath.split('/').last;

      final formData = FormData.fromMap({
        // 'file' is the field name expected by the server
        // Different APIs may expect different field names
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          // Content-type is auto-detected, but can be specified:
          // contentType: MediaType.parse('image/jpeg'),
        ),

        // You can include additional form fields with the file
        'description': 'Uploaded from Flutter API Learn app',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // =====================================
      // Step 3: Make the upload request
      // =====================================

      final response = await _client.instance.post(
        ApiConfig.fileUploadUrl,
        data: formData,
        options: Options(
          // Content-type is set automatically for FormData
          // But we can set other options:
          headers: {'Accept': 'application/json'},
          // Extended timeout for file uploads
          sendTimeout: const Duration(milliseconds: ApiConfig.uploadTimeout),
          receiveTimeout: const Duration(milliseconds: ApiConfig.uploadTimeout),
        ),
        // Progress callback - called periodically during upload
        onSendProgress: (int sent, int total) {
          // Create progress object and call the callback
          if (onProgress != null) {
            onProgress(UploadProgress(sentBytes: sent, totalBytes: total));
          }
        },
      );

      // =====================================
      // Step 4: Handle the response
      // =====================================

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the response
        // Note: httpbin.org returns the request data back to us
        // Real APIs would return file metadata
        final uploadResponse = FileUploadResponse(
          success: true,
          filename: fileName,
          fileSize: fileSize,
          message: 'File uploaded successfully',
        );

        return ApiResponse.success(
          uploadResponse,
          message: 'File uploaded successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.failure(
        'File upload failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final exception = ApiExceptionHandler.handleDioException(e);
      return ApiResponse.failure(
        exception.message,
        statusCode: exception.statusCode,
      );
    } catch (e) {
      return ApiResponse.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// ========================================
  /// Upload Multiple Files
  /// ========================================
  ///
  /// This method demonstrates:
  /// - Uploading multiple files in one request
  /// - Using array field names for multiple files
  /// - Combined progress tracking
  ///
  /// Some APIs accept:
  /// - Multiple fields: file1, file2, file3
  /// - Array notation: files[], files[]
  /// - Same field name: file, file, file
  Future<ApiResponse<List<FileUploadResponse>>> uploadMultipleFiles(
    List<String> filePaths, {
    void Function(UploadProgress progress)? onProgress,
  }) async {
    try {
      // Validate all files first
      int totalSize = 0;
      final files = <MapEntry<String, MultipartFile>>[];

      for (final filePath in filePaths) {
        final file = File(filePath);

        if (!await file.exists()) {
          return ApiResponse.failure(
            'File not found: $filePath',
            errorType: 'FileNotFoundError',
          );
        }

        final fileSize = await file.length();
        totalSize += fileSize;

        if (totalSize > ApiConfig.maxFileSize * 5) {
          return ApiResponse.failure(
            'Total file size too large',
            errorType: 'FileTooLargeError',
          );
        }

        final fileName = filePath.split('/').last;
        final multipartFile = await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        );

        // Using array notation for multiple files
        files.add(MapEntry('files', multipartFile));
      }

      // Create FormData with multiple files
      final formData = FormData();
      for (final entry in files) {
        formData.files.add(entry);
      }

      final response = await _client.instance.post(
        ApiConfig.fileUploadUrl,
        data: formData,
        options: Options(
          sendTimeout: const Duration(
            milliseconds: ApiConfig.uploadTimeout * 2,
          ),
          receiveTimeout: const Duration(
            milliseconds: ApiConfig.uploadTimeout * 2,
          ),
        ),
        onSendProgress: (int sent, int total) {
          if (onProgress != null) {
            onProgress(UploadProgress(sentBytes: sent, totalBytes: total));
          }
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Create responses for each file
        final responses = filePaths
            .map(
              (path) => FileUploadResponse(
                success: true,
                filename: path.split('/').last,
                message: 'Uploaded successfully',
              ),
            )
            .toList();

        return ApiResponse.success(
          responses,
          message: '${filePaths.length} files uploaded successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.failure(
        'Failed to upload files',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final exception = ApiExceptionHandler.handleDioException(e);
      return ApiResponse.failure(
        exception.message,
        statusCode: exception.statusCode,
      );
    } catch (e) {
      return ApiResponse.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// ========================================
  /// Upload File with Additional Data
  /// ========================================
  ///
  /// This demonstrates uploading a file along with
  /// form fields (like a profile picture with user data)
  Future<ApiResponse<FileUploadResponse>> uploadFileWithData(
    String filePath, {
    required Map<String, dynamic> additionalData,
    void Function(UploadProgress progress)? onProgress,
  }) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        return ApiResponse.failure(
          'File not found: $filePath',
          errorType: 'FileNotFoundError',
        );
      }

      final fileName = filePath.split('/').last;

      // Create FormData with both file and additional fields
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        // Spread the additional data into the form
        ...additionalData,
      });

      final response = await _client.instance.post(
        ApiConfig.fileUploadUrl,
        data: formData,
        options: Options(
          sendTimeout: const Duration(milliseconds: ApiConfig.uploadTimeout),
        ),
        onSendProgress: (int sent, int total) {
          if (onProgress != null) {
            onProgress(UploadProgress(sentBytes: sent, totalBytes: total));
          }
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
          FileUploadResponse(
            success: true,
            filename: fileName,
            message: 'File and data uploaded successfully',
          ),
          message: 'Upload successful',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.failure(
        'Upload failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final exception = ApiExceptionHandler.handleDioException(e);
      return ApiResponse.failure(
        exception.message,
        statusCode: exception.statusCode,
      );
    } catch (e) {
      return ApiResponse.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// ========================================
  /// Upload File from Bytes
  /// ========================================
  ///
  /// Sometimes you have file data as bytes (e.g., from image picker)
  /// rather than a file path. This method handles that case.
  Future<ApiResponse<FileUploadResponse>> uploadFileFromBytes(
    List<int> bytes, {
    required String fileName,
    void Function(UploadProgress progress)? onProgress,
  }) async {
    try {
      // Create MultipartFile from bytes
      final multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);

      final formData = FormData.fromMap({'file': multipartFile});

      final response = await _client.instance.post(
        ApiConfig.fileUploadUrl,
        data: formData,
        onSendProgress: (int sent, int total) {
          if (onProgress != null) {
            onProgress(UploadProgress(sentBytes: sent, totalBytes: total));
          }
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
          FileUploadResponse(
            success: true,
            filename: fileName,
            fileSize: bytes.length,
            message: 'File uploaded successfully',
          ),
          message: 'Upload successful',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.failure(
        'Upload failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final exception = ApiExceptionHandler.handleDioException(e);
      return ApiResponse.failure(
        exception.message,
        statusCode: exception.statusCode,
      );
    } catch (e) {
      return ApiResponse.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
