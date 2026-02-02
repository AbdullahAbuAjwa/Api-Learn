import 'dart:async';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';

/// ============================================================================
/// Dio Interceptors: Request/Response Middleware
/// ============================================================================
///
/// Interceptors are a powerful feature of Dio that allow you to:
/// 1. Modify requests before they're sent (add headers, log data)
/// 2. Modify responses before they reach your code
/// 3. Handle errors in a centralized way
/// 4. Implement cross-cutting concerns like authentication, caching, retries
///
/// Think of interceptors like security checkpoints at an airport:
/// - Check-in (onRequest): Prepare and verify your request
/// - Security (onError): Handle problems
/// - Arrival (onResponse): Process what you received
/// ============================================================================

/// ============================================================================
/// Logging Interceptor
/// ============================================================================
///
/// Purpose: Log all HTTP requests and responses for debugging
///
/// What it logs:
/// - Request URL and method
/// - Request headers
/// - Request body (for POST/PUT)
/// - Response status and data
/// - Error information
///
/// Best Practice: Only enable in development, disable in production
/// to avoid exposing sensitive data in logs

class LoggingInterceptor extends Interceptor {
  /// Whether to print full request/response bodies
  /// Set to false for cleaner logs or to hide sensitive data
  final bool logBody;

  /// Whether to print headers
  /// Headers may contain sensitive auth tokens
  final bool logHeaders;

  LoggingInterceptor({this.logBody = true, this.logHeaders = true});

  /// Called BEFORE the request is sent
  /// Perfect for logging what we're about to send
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().toIso8601String();

    // Create a readable log message
    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln(
      '╔══════════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ 🚀 API REQUEST - $timestamp');
    buffer.writeln(
      '╠══════════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ Method: ${options.method}');
    buffer.writeln('║ URL: ${options.uri}');

    // Log query parameters separately for clarity
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('║ Query Params: ${options.queryParameters}');
    }

    // Log headers if enabled
    if (logHeaders && options.headers.isNotEmpty) {
      buffer.writeln('║ Headers:');
      options.headers.forEach((key, value) {
        // Hide sensitive values
        final displayValue = _isSensitiveHeader(key)
            ? '***HIDDEN***'
            : value.toString();
        buffer.writeln('║   $key: $displayValue');
      });
    }

    // Log request body if enabled and present
    if (logBody && options.data != null) {
      buffer.writeln('║ Body:');
      buffer.writeln('║   ${_formatJson(options.data)}');
    }

    buffer.writeln(
      '╚══════════════════════════════════════════════════════════════',
    );

    developer.log(buffer.toString(), name: 'API');

    // IMPORTANT: Always call handler.next() to continue the request chain
    // Without this, the request will hang
    handler.next(options);
  }

  /// Called AFTER a successful response is received
  /// Perfect for logging what we got back
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final timestamp = DateTime.now().toIso8601String();

    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln(
      '╔══════════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ ✅ API RESPONSE - $timestamp');
    buffer.writeln(
      '╠══════════════════════════════════════════════════════════════',
    );
    buffer.writeln(
      '║ Status: ${response.statusCode} ${response.statusMessage}',
    );
    buffer.writeln('║ URL: ${response.requestOptions.uri}');

    // Log response headers if enabled
    if (logHeaders) {
      buffer.writeln('║ Headers:');
      response.headers.forEach((name, values) {
        buffer.writeln('║   $name: ${values.join(', ')}');
      });
    }

    // Log response body if enabled
    if (logBody && response.data != null) {
      buffer.writeln('║ Data:');
      final dataStr = _formatJson(response.data);
      // Truncate very long responses
      if (dataStr.length > 1000) {
        buffer.writeln('║   ${dataStr.substring(0, 1000)}...[truncated]');
      } else {
        buffer.writeln('║   $dataStr');
      }
    }

    buffer.writeln(
      '╚══════════════════════════════════════════════════════════════',
    );

    developer.log(buffer.toString(), name: 'API');

    // Continue the response chain
    handler.next(response);
  }

  /// Called when an ERROR occurs
  /// Perfect for logging failures and debugging issues
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final timestamp = DateTime.now().toIso8601String();

    final buffer = StringBuffer();
    buffer.writeln('');
    buffer.writeln(
      '╔══════════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ ❌ API ERROR - $timestamp');
    buffer.writeln(
      '╠══════════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ Type: ${err.type}');
    buffer.writeln('║ Message: ${err.message}');
    buffer.writeln('║ URL: ${err.requestOptions.uri}');

    if (err.response != null) {
      buffer.writeln('║ Status: ${err.response?.statusCode}');
      buffer.writeln('║ Response: ${err.response?.data}');
    }

    buffer.writeln(
      '╚══════════════════════════════════════════════════════════════',
    );

    developer.log(buffer.toString(), name: 'API', level: 1000);

    // Continue the error chain
    handler.next(err);
  }

  /// Check if a header contains sensitive information
  bool _isSensitiveHeader(String key) {
    final sensitiveKeys = ['authorization', 'cookie', 'x-api-key', 'token'];
    return sensitiveKeys.contains(key.toLowerCase());
  }

  /// Format data for logging
  String _formatJson(dynamic data) {
    if (data == null) return 'null';
    if (data is String) return data;
    return data.toString();
  }
}

/// ============================================================================
/// Authentication Interceptor
/// ============================================================================
///
/// Purpose: Automatically add authentication tokens to requests
///
/// Features:
/// - Adds Bearer token to all requests
/// - Can refresh expired tokens
/// - Handles authentication failures
///
/// How it works:
/// 1. Before each request, checks for a valid token
/// 2. Adds the token to the Authorization header
/// 3. If a request fails with 401, can attempt to refresh the token

class AuthInterceptor extends Interceptor {
  /// Function to get the current auth token
  /// In a real app, this would read from secure storage
  final Future<String?> Function()? getToken;

  /// Function to refresh an expired token
  /// Called when a 401 error is received
  final Future<String?> Function()? refreshToken;

  /// Function called when authentication completely fails
  /// Use this to redirect to login screen
  final void Function()? onAuthFailure;

  AuthInterceptor({this.getToken, this.refreshToken, this.onAuthFailure});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get the current token
    if (getToken != null) {
      final token = await getToken!();

      if (token != null && token.isNotEmpty) {
        // Add Bearer token to Authorization header
        // Format: "Bearer <token>"
        // This is the OAuth 2.0 standard format
        options.headers['Authorization'] = 'Bearer $token';

        developer.log(
          'Added auth token to request: ${options.uri}',
          name: 'Auth',
        );
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is 401 Unauthorized
    if (err.response?.statusCode == 401) {
      developer.log('Received 401, attempting token refresh', name: 'Auth');

      // Attempt to refresh the token
      if (refreshToken != null) {
        try {
          final newToken = await refreshToken!();

          if (newToken != null) {
            developer.log('Token refreshed successfully', name: 'Auth');

            // Retry the original request with new token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            // Create a new Dio instance to avoid infinite loops
            final dio = Dio();
            final response = await dio.fetch(options);

            // Return the successful response
            handler.resolve(response);
            return;
          }
        } catch (e) {
          developer.log('Token refresh failed: $e', name: 'Auth');
        }
      }

      // If we couldn't refresh, notify about auth failure
      onAuthFailure?.call();
    }

    // Continue with the error
    handler.next(err);
  }
}

/// ============================================================================
/// Retry Interceptor
/// ============================================================================
///
/// Purpose: Automatically retry failed requests
///
/// When to retry:
/// - Network timeouts
/// - Connection errors
/// - 5xx server errors (server is temporarily unavailable)
///
/// When NOT to retry:
/// - 4xx client errors (retry won't fix the problem)
/// - Successful requests
/// - After max retry attempts

class RetryInterceptor extends Interceptor {
  /// Dio instance for retrying requests
  final Dio dio;

  /// Maximum number of retry attempts
  final int maxRetries;

  /// Delay between retries (uses exponential backoff)
  final Duration retryDelay;

  /// Status codes that should trigger a retry
  final List<int> retryStatusCodes;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.retryStatusCodes = const [408, 500, 502, 503, 504],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if we should retry
    if (_shouldRetry(err)) {
      final extra = err.requestOptions.extra;
      final retryCount = extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        developer.log(
          'Retrying request (attempt ${retryCount + 1}/$maxRetries): ${err.requestOptions.uri}',
          name: 'Retry',
        );

        // Exponential backoff: wait longer between each retry
        // Attempt 1: 1 second
        // Attempt 2: 2 seconds
        // Attempt 3: 4 seconds
        final delay = retryDelay * (1 << retryCount);
        await Future.delayed(delay);

        // Update retry count
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        try {
          // Retry the request
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } on DioException catch (e) {
          // If retry also failed, continue with that error
          handler.next(e);
          return;
        }
      }
    }

    // Continue with the original error
    handler.next(err);
  }

  /// Determine if a request should be retried
  bool _shouldRetry(DioException err) {
    // Retry on network errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on specific status codes
    final statusCode = err.response?.statusCode;
    if (statusCode != null && retryStatusCodes.contains(statusCode)) {
      return true;
    }

    return false;
  }
}

/// ============================================================================
/// Cache Interceptor (Basic Example)
/// ============================================================================
///
/// Purpose: Cache GET requests to reduce network calls
///
/// Benefits:
/// - Faster response times for cached data
/// - Works offline (for cached content)
/// - Reduces server load and bandwidth usage
///
/// Note: This is a simplified in-memory cache for educational purposes.
/// For production, use a proper caching solution like:
/// - dio_cache_interceptor package
/// - Hive or SQLite for persistent caching

class CacheInterceptor extends Interceptor {
  /// In-memory cache storage
  /// Key: URL, Value: Cached response
  final Map<String, CachedResponse> _cache = {};

  /// How long to keep items in cache
  final Duration maxAge;

  CacheInterceptor({this.maxAge = const Duration(minutes: 5)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only cache GET requests
    if (options.method.toUpperCase() != 'GET') {
      handler.next(options);
      return;
    }

    // Check if we have a cached response
    final cacheKey = options.uri.toString();
    final cached = _cache[cacheKey];

    if (cached != null && !cached.isExpired) {
      developer.log('Returning cached response for: $cacheKey', name: 'Cache');

      // Return cached response
      handler.resolve(
        Response(
          requestOptions: options,
          data: cached.data,
          statusCode: 200,
          statusMessage: 'OK (cached)',
        ),
      );
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only cache successful GET requests
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      final cacheKey = response.requestOptions.uri.toString();

      _cache[cacheKey] = CachedResponse(
        data: response.data,
        timestamp: DateTime.now(),
        maxAge: maxAge,
      );

      developer.log('Cached response for: $cacheKey', name: 'Cache');
    }

    handler.next(response);
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
    developer.log('Cache cleared', name: 'Cache');
  }

  /// Remove a specific entry from cache
  void invalidate(String url) {
    _cache.remove(url);
    developer.log('Invalidated cache for: $url', name: 'Cache');
  }
}

/// Helper class for cached responses
class CachedResponse {
  final dynamic data;
  final DateTime timestamp;
  final Duration maxAge;

  CachedResponse({
    required this.data,
    required this.timestamp,
    required this.maxAge,
  });

  /// Check if the cached response has expired
  bool get isExpired => DateTime.now().difference(timestamp) > maxAge;
}
