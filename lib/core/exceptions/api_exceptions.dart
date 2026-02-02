import 'package:dio/dio.dart';

/// ============================================================================
/// Custom Exception Classes for API Error Handling
/// ============================================================================
///
/// Why Custom Exceptions?
/// 1. They provide meaningful, specific error information
/// 2. They allow for type-based error handling (catch specific exceptions)
/// 3. They improve code readability and maintainability
/// 4. They can carry additional context about what went wrong
///
/// Exception Hierarchy:
/// - ApiException (base class)
///   ├── NetworkException (no internet, timeout)
///   ├── ServerException (5xx errors)
///   ├── ClientException (4xx errors)
///   │   ├── UnauthorizedException (401)
///   │   ├── ForbiddenException (403)
///   │   └── NotFoundException (404)
///   └── ValidationException (422, validation errors)
/// ============================================================================

/// Base exception class for all API-related errors
///
/// All custom API exceptions extend this base class
/// This allows you to catch all API errors with a single catch block
///
/// Usage:
/// ```dart
/// try {
///   await apiService.getPosts();
/// } on ApiException catch (e) {
///   // Handle any API-related error
///   print('API Error: ${e.message}');
/// }
/// ```
class ApiException implements Exception {
  /// Human-readable error message
  final String message;

  /// HTTP status code (if applicable)
  final int? statusCode;

  /// Original error that caused this exception
  /// Useful for debugging and logging
  final dynamic originalError;

  /// Stack trace when the exception occurred
  final StackTrace? stackTrace;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Exception for network-related errors
///
/// Thrown when:
/// - No internet connection
/// - Connection timeout
/// - DNS resolution failed
/// - Server is unreachable
///
/// This is different from server errors (5xx) because
/// the request never reached the server
class NetworkException extends ApiException {
  /// Type of network error for more specific handling
  final NetworkErrorType errorType;

  NetworkException({
    required super.message,
    required this.errorType,
    super.statusCode,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NetworkException($errorType): $message';
}

/// Types of network errors
///
/// Categorizing network errors helps in:
/// 1. Showing appropriate messages to users
/// 2. Deciding retry strategies
/// 3. Logging and monitoring
enum NetworkErrorType {
  /// No internet connection detected
  noConnection,

  /// Request took too long (timeout)
  timeout,

  /// Server cannot be reached
  serverUnreachable,

  /// DNS resolution failed
  dnsError,

  /// SSL/TLS certificate error
  sslError,

  /// Connection was cancelled
  cancelled,

  /// Unknown network error
  unknown,
}

/// Exception for server errors (5xx status codes)
///
/// Thrown when the server encounters an error
/// These are typically not the client's fault
///
/// Common scenarios:
/// - 500: Internal Server Error
/// - 502: Bad Gateway
/// - 503: Service Unavailable
/// - 504: Gateway Timeout
class ServerException extends ApiException {
  ServerException({
    required super.message,
    super.statusCode,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Base class for client errors (4xx status codes)
///
/// Thrown when the client made an invalid request
/// These errors typically require client-side fixes
class ClientException extends ApiException {
  ClientException({
    required super.message,
    super.statusCode,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ClientException: $message (Status: $statusCode)';
}

/// Exception for authentication errors (401 Unauthorized)
///
/// Thrown when:
/// - User is not logged in
/// - Token is expired
/// - Token is invalid
///
/// Handling:
/// - Redirect to login screen
/// - Refresh the authentication token
/// - Clear stored credentials
class UnauthorizedException extends ClientException {
  UnauthorizedException({
    super.message = 'Authentication required. Please log in.',
    super.statusCode = 401,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception for forbidden access (403 Forbidden)
///
/// Different from 401:
/// - 401: User is NOT authenticated (not logged in)
/// - 403: User IS authenticated but NOT authorized (no permission)
///
/// Thrown when:
/// - User doesn't have permission to access a resource
/// - User's subscription doesn't include this feature
/// - IP is blocked or rate limited
class ForbiddenException extends ClientException {
  ForbiddenException({
    super.message = 'You do not have permission to access this resource.',
    super.statusCode = 403,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Exception for resource not found (404 Not Found)
///
/// Thrown when:
/// - Requested resource doesn't exist
/// - URL is incorrect
/// - Resource was deleted
class NotFoundException extends ClientException {
  NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception for validation errors (422 Unprocessable Entity)
///
/// Thrown when the server understands the request but
/// the data doesn't pass validation
///
/// Contains field-specific error messages for form validation
class ValidationException extends ClientException {
  /// Map of field names to error messages
  /// Example: {'email': 'Invalid email format', 'password': 'Too short'}
  final Map<String, String>? errors;

  ValidationException({
    super.message = 'Validation failed. Please check your input.',
    this.errors,
    super.statusCode = 422,
    super.originalError,
    super.stackTrace,
  });

  /// Get error message for a specific field
  String? getFieldError(String fieldName) => errors?[fieldName];

  /// Check if a specific field has an error
  bool hasFieldError(String fieldName) =>
      errors?.containsKey(fieldName) ?? false;

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'ValidationException: $message\nErrors: $errors';
    }
    return 'ValidationException: $message';
  }
}

/// Exception for bad requests (400 Bad Request)
///
/// Thrown when:
/// - Request body is malformed
/// - Required parameters are missing
/// - Invalid parameter values
class BadRequestException extends ClientException {
  BadRequestException({
    super.message = 'Bad request. Please check your input.',
    super.statusCode = 400,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'BadRequestException: $message';
}

/// Exception for rate limiting (429 Too Many Requests)
///
/// Thrown when the API rate limit is exceeded
///
/// Handling:
/// - Show retry timer to user
/// - Implement exponential backoff
/// - Cache responses to reduce requests
class RateLimitException extends ClientException {
  /// When the rate limit resets (if provided by API)
  final DateTime? retryAfter;

  RateLimitException({
    super.message = 'Too many requests. Please try again later.',
    this.retryAfter,
    super.statusCode = 429,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'RateLimitException: $message (Retry after: $retryAfter)';
}

/// ============================================================================
/// Exception Handler Utility
/// ============================================================================
///
/// Converts Dio errors into our custom exceptions
/// This centralizes error handling logic and ensures consistent exceptions

class ApiExceptionHandler {
  /// Convert DioException to appropriate custom exception
  ///
  /// This method analyzes the DioException and creates
  /// the most appropriate custom exception based on:
  /// 1. Error type (timeout, network, etc.)
  /// 2. HTTP status code
  /// 3. Server response body
  static ApiException handleDioException(DioException error) {
    // Handle based on DioException type
    switch (error.type) {
      // Connection timeout - request took too long to establish connection
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          message:
              'Connection timed out. Please check your internet connection.',
          errorType: NetworkErrorType.timeout,
          originalError: error,
        );

      // Send timeout - request took too long to send data
      case DioExceptionType.sendTimeout:
        return NetworkException(
          message: 'Sending data timed out. Please try again.',
          errorType: NetworkErrorType.timeout,
          originalError: error,
        );

      // Receive timeout - server took too long to respond
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Server is taking too long to respond. Please try again.',
          errorType: NetworkErrorType.timeout,
          originalError: error,
        );

      // Request was cancelled (user or programmatically)
      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request was cancelled.',
          errorType: NetworkErrorType.cancelled,
          originalError: error,
        );

      // Bad response - server returned an error status code
      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      // Connection error - couldn't establish connection
      case DioExceptionType.connectionError:
        return NetworkException(
          message:
              'Unable to connect to server. Please check your internet connection.',
          errorType: NetworkErrorType.noConnection,
          originalError: error,
        );

      // Bad certificate - SSL/TLS issues
      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Security certificate error. Please contact support.',
          errorType: NetworkErrorType.sslError,
          originalError: error,
        );

      // Unknown error - fallback
      case DioExceptionType.unknown:
        // Check if it's an internet connectivity issue
        if (error.error != null &&
            error.error.toString().contains('SocketException')) {
          return NetworkException(
            message: 'No internet connection. Please check your network.',
            errorType: NetworkErrorType.noConnection,
            originalError: error,
          );
        }
        return ApiException(
          message: error.message ?? 'An unexpected error occurred.',
          originalError: error,
        );
    }
  }

  /// Handle HTTP response errors (4xx, 5xx status codes)
  static ApiException _handleResponseError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;

    // Try to extract error message from response body
    String message = _extractErrorMessage(response);

    // Handle based on status code
    switch (statusCode) {
      case 400:
        return BadRequestException(message: message, originalError: error);

      case 401:
        return UnauthorizedException(message: message, originalError: error);

      case 403:
        return ForbiddenException(message: message, originalError: error);

      case 404:
        return NotFoundException(message: message, originalError: error);

      case 422:
        // Extract validation errors if available
        final errors = _extractValidationErrors(response);
        return ValidationException(
          message: message,
          errors: errors,
          originalError: error,
        );

      case 429:
        // Extract retry-after header if available
        final retryAfter = _extractRetryAfter(response);
        return RateLimitException(
          message: message,
          retryAfter: retryAfter,
          originalError: error,
        );

      // Server errors (5xx)
      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: message.isNotEmpty
              ? message
              : 'Server error occurred. Please try again later.',
          statusCode: statusCode,
          originalError: error,
        );

      default:
        // Handle other 4xx errors as client errors
        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          return ClientException(
            message: message,
            statusCode: statusCode,
            originalError: error,
          );
        }
        // Handle other 5xx errors as server errors
        if (statusCode != null && statusCode >= 500) {
          return ServerException(
            message: message,
            statusCode: statusCode,
            originalError: error,
          );
        }
        return ApiException(
          message: message,
          statusCode: statusCode,
          originalError: error,
        );
    }
  }

  /// Extract error message from response body
  ///
  /// APIs return errors in different formats:
  /// 1. { "message": "Error message" }
  /// 2. { "error": "Error message" }
  /// 3. { "errors": ["Error 1", "Error 2"] }
  /// 4. Plain text: "Error message"
  static String _extractErrorMessage(Response? response) {
    if (response?.data == null) {
      return 'An error occurred';
    }

    final data = response!.data;

    // If response is already a string
    if (data is String) {
      return data.isNotEmpty ? data : 'An error occurred';
    }

    // If response is a map (JSON object)
    if (data is Map<String, dynamic>) {
      // Try common error message keys
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString() ??
          (data['errors'] is List
              ? (data['errors'] as List).join(', ')
              : null) ??
          'An error occurred';
    }

    return 'An error occurred';
  }

  /// Extract validation errors for form fields
  static Map<String, String>? _extractValidationErrors(Response? response) {
    if (response?.data == null || response!.data is! Map) {
      return null;
    }

    final data = response.data as Map<String, dynamic>;

    // Common formats:
    // 1. { "errors": { "field": "message" } }
    // 2. { "errors": { "field": ["message1", "message2"] } }

    final errors = data['errors'];
    if (errors == null || errors is! Map) {
      return null;
    }

    final result = <String, String>{};
    errors.forEach((key, value) {
      if (value is String) {
        result[key.toString()] = value;
      } else if (value is List && value.isNotEmpty) {
        result[key.toString()] = value.first.toString();
      }
    });

    return result.isEmpty ? null : result;
  }

  /// Extract retry-after header for rate limiting
  static DateTime? _extractRetryAfter(Response? response) {
    final header = response?.headers['retry-after']?.first;
    if (header == null) return null;

    // Header can be seconds or a date
    final seconds = int.tryParse(header);
    if (seconds != null) {
      return DateTime.now().add(Duration(seconds: seconds));
    }

    // Try parsing as date
    return DateTime.tryParse(header);
  }
}
