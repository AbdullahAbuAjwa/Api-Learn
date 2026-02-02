import 'package:dio/dio.dart';
import '../../models/models.dart';
import '../config/api_config.dart';
import '../exceptions/api_exceptions.dart';
import '../network/dio_client.dart';

/// ============================================================================
/// Post API Service: Complete CRUD Operations Example
/// ============================================================================
///
/// This service demonstrates all CRUD operations using Dio:
/// - CREATE: POST request to create new posts
/// - READ: GET requests to fetch posts (single and list)
/// - UPDATE: PUT/PATCH requests to modify posts
/// - DELETE: DELETE request to remove posts
///
/// Design Patterns Used:
/// 1. Repository Pattern: Separates data access from business logic
/// 2. Single Responsibility: One service per resource type
/// 3. Error Handling: Converts network errors to domain exceptions
///
/// Best Practices Demonstrated:
/// - Type-safe return values using generics
/// - Comprehensive error handling
/// - Consistent API response structure
/// - Detailed documentation for each method
/// ============================================================================

class PostApiService {
  /// The Dio client instance for making HTTP requests
  final DioClient _client;

  /// Constructor with dependency injection
  ///
  /// Why use dependency injection?
  /// 1. Makes testing easier (can inject mock client)
  /// 2. Follows SOLID principles
  /// 3. Allows flexible configuration
  ///
  /// Usage:
  /// ```dart
  /// // Production
  /// final service = PostApiService(dioClient);
  ///
  /// // Testing
  /// final service = PostApiService(mockDioClient);
  /// ```
  PostApiService(this._client);

  /// ========================================
  /// GET: Fetch All Posts
  /// ========================================
  ///
  /// RESTful Endpoint: GET /posts
  ///
  /// This demonstrates:
  /// - Making GET requests
  /// - Parsing JSON arrays
  /// - Error handling
  /// - Type conversion
  ///
  /// HTTP Details:
  /// - Method: GET
  /// - URL: https://jsonplaceholder.typicode.com/posts
  /// - Response: Array of post objects
  ///
  /// Returns:
  /// - Success: ApiResponse with List<PostModel>
  /// - Failure: ApiResponse with error details
  Future<ApiResponse<List<PostModel>>> getAllPosts() async {
    try {
      // Make the GET request
      // The endpoint is defined in ApiConfig for maintainability
      final response = await _client.get(ApiConfig.postsEndpoint);

      // Check if request was successful (status code 200-299)
      if (response.statusCode == 200) {
        // Parse the JSON array into a list of PostModel objects
        // response.data is a List<dynamic> from the JSON array
        final List<PostModel> posts = (response.data as List)
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Return success response with the parsed data
        return ApiResponse.success(
          posts,
          message: 'Successfully fetched ${posts.length} posts',
          statusCode: response.statusCode,
        );
      }

      // Handle non-200 responses
      return ApiResponse.failure(
        'Failed to fetch posts',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      // Convert Dio exceptions to our custom exceptions
      final exception = ApiExceptionHandler.handleDioException(e);
      return ApiResponse.failure(
        exception.message,
        statusCode: exception.statusCode,
        errorType: exception.runtimeType.toString(),
      );
    } catch (e) {
      // Handle unexpected errors
      return ApiResponse.failure(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// ========================================
  /// GET: Fetch Single Post by ID
  /// ========================================
  ///
  /// RESTful Endpoint: GET /posts/{id}
  ///
  /// This demonstrates:
  /// - Path parameters in URLs
  /// - Fetching single resources
  /// - 404 handling for non-existent resources
  ///
  /// Parameters:
  /// - id: The unique identifier of the post to fetch
  ///
  /// HTTP Details:
  /// - Method: GET
  /// - URL: https://jsonplaceholder.typicode.com/posts/1
  /// - Response: Single post object
  Future<ApiResponse<PostModel>> getPostById(int id) async {
    try {
      // Use the dynamic endpoint generator from ApiConfig
      final response = await _client.get(ApiConfig.postByIdEndpoint(id));

      if (response.statusCode == 200) {
        // Parse single JSON object to PostModel
        final post = PostModel.fromJson(response.data as Map<String, dynamic>);

        return ApiResponse.success(
          post,
          message: 'Successfully fetched post #$id',
          statusCode: response.statusCode,
        );
      }

      // Handle 404 specifically
      if (response.statusCode == 404) {
        return ApiResponse.failure(
          'Post with ID $id not found',
          statusCode: 404,
          errorType: 'NotFoundException',
        );
      }

      return ApiResponse.failure(
        'Failed to fetch post #$id',
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
  /// GET: Fetch Posts with Query Parameters
  /// ========================================
  ///
  /// RESTful Endpoint: GET /posts?userId={userId}
  ///
  /// This demonstrates:
  /// - Query parameters (?key=value)
  /// - Filtering data on the server
  ///
  /// Query parameters are used for:
  /// - Filtering: ?status=active
  /// - Pagination: ?page=2&limit=10
  /// - Sorting: ?sort=name&order=asc
  /// - Searching: ?q=search+term
  ///
  /// Parameters:
  /// - userId: Filter posts by user ID
  Future<ApiResponse<List<PostModel>>> getPostsByUser(int userId) async {
    try {
      // Query parameters are passed as a Map
      // Dio automatically encodes them: /posts?userId=1
      final response = await _client.get(
        ApiConfig.postsEndpoint,
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final List<PostModel> posts = (response.data as List)
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return ApiResponse.success(
          posts,
          message: 'Found ${posts.length} posts for user #$userId',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.failure(
        'Failed to fetch posts for user #$userId',
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
  /// POST: Create New Post
  /// ========================================
  ///
  /// RESTful Endpoint: POST /posts
  ///
  /// This demonstrates:
  /// - Making POST requests
  /// - Sending JSON body data
  /// - Handling created resources
  ///
  /// HTTP Details:
  /// - Method: POST
  /// - URL: https://jsonplaceholder.typicode.com/posts
  /// - Content-Type: application/json
  /// - Request Body: JSON object with post data
  /// - Response: Created post with assigned ID
  ///
  /// Parameters:
  /// - title: The title of the new post
  /// - body: The content of the new post
  /// - userId: The ID of the user creating the post
  Future<ApiResponse<PostModel>> createPost({
    required String title,
    required String body,
    required int userId,
  }) async {
    try {
      // The request body is automatically converted to JSON by Dio
      final response = await _client.post(
        ApiConfig.postsEndpoint,
        data: {'title': title, 'body': body, 'userId': userId},
      );

      // 201 Created is the standard response for successful POST
      if (response.statusCode == 201 || response.statusCode == 200) {
        final post = PostModel.fromJson(response.data as Map<String, dynamic>);

        return ApiResponse.success(
          post,
          message: 'Post created successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.failure(
        'Failed to create post',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final exception = ApiExceptionHandler.handleDioException(e);

      // Special handling for validation errors
      if (exception is ValidationException) {
        return ApiResponse.failure(
          exception.message,
          statusCode: 422,
          errorType: 'ValidationException',
        );
      }

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
  /// PUT: Update Entire Post
  /// ========================================
  ///
  /// RESTful Endpoint: PUT /posts/{id}
  ///
  /// This demonstrates:
  /// - Making PUT requests
  /// - Full resource replacement
  /// - Update vs Create semantics
  ///
  /// PUT vs PATCH:
  /// - PUT: Replaces the ENTIRE resource. All fields must be provided.
  /// - PATCH: Updates only the specified fields.
  ///
  /// HTTP Details:
  /// - Method: PUT
  /// - URL: https://jsonplaceholder.typicode.com/posts/1
  /// - Request Body: Complete post object
  /// - Response: Updated post
  Future<ApiResponse<PostModel>> updatePost(PostModel post) async {
    try {
      final response = await _client.put(
        ApiConfig.postByIdEndpoint(post.id),
        data: post.toJson(),
      );

      if (response.statusCode == 200) {
        final updatedPost = PostModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        return ApiResponse.success(
          updatedPost,
          message: 'Post #${post.id} updated successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.failure(
        'Failed to update post #${post.id}',
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
  /// PATCH: Partial Update
  /// ========================================
  ///
  /// RESTful Endpoint: PATCH /posts/{id}
  ///
  /// This demonstrates:
  /// - Making PATCH requests
  /// - Partial resource updates
  /// - Updating only changed fields
  ///
  /// Benefits of PATCH over PUT:
  /// 1. Smaller request size (only changed fields)
  /// 2. Reduced risk of overwriting concurrent changes
  /// 3. Better for forms where users edit one field
  ///
  /// Parameters:
  /// - id: The ID of the post to update
  /// - title: New title (optional)
  /// - body: New body (optional)
  Future<ApiResponse<PostModel>> patchPost({
    required int id,
    String? title,
    String? body,
  }) async {
    try {
      // Build the update data with only provided fields
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (body != null) updateData['body'] = body;

      // Don't make request if no fields to update
      if (updateData.isEmpty) {
        return ApiResponse.failure(
          'No fields to update',
          statusCode: 400,
          errorType: 'ValidationException',
        );
      }

      final response = await _client.patch(
        ApiConfig.postByIdEndpoint(id),
        data: updateData,
      );

      if (response.statusCode == 200) {
        final updatedPost = PostModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        return ApiResponse.success(
          updatedPost,
          message: 'Post #$id partially updated',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.failure(
        'Failed to update post #$id',
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
  /// DELETE: Remove Post
  /// ========================================
  ///
  /// RESTful Endpoint: DELETE /posts/{id}
  ///
  /// This demonstrates:
  /// - Making DELETE requests
  /// - Handling deletion responses
  /// - Idempotency of DELETE
  ///
  /// Idempotency:
  /// DELETE should be idempotent, meaning calling it multiple times
  /// has the same effect as calling it once. The resource is deleted
  /// (or remains deleted if already deleted).
  ///
  /// HTTP Details:
  /// - Method: DELETE
  /// - URL: https://jsonplaceholder.typicode.com/posts/1
  /// - Response: Usually empty body with 200/204 status
  ///
  /// Parameters:
  /// - id: The ID of the post to delete
  Future<ApiResponse<void>> deletePost(int id) async {
    try {
      final response = await _client.delete(ApiConfig.postByIdEndpoint(id));

      // 200 OK or 204 No Content are both valid for DELETE
      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse(
          success: true,
          data: null, // DELETE typically doesn't return data
          message: 'Post #$id deleted successfully',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.failure(
        'Failed to delete post #$id',
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
  /// Advanced: Fetch with Pagination
  /// ========================================
  ///
  /// This demonstrates pagination using query parameters.
  ///
  /// Common pagination patterns:
  /// 1. Page-based: ?_page=2&_limit=10
  /// 2. Offset-based: ?_start=20&_limit=10
  /// 3. Cursor-based: ?after=cursor123&limit=10
  ///
  /// JSONPlaceholder uses the _page and _limit pattern.
  Future<ApiResponse<List<PostModel>>> getPostsPaginated({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.postsEndpoint,
        queryParameters: {'_page': page, '_limit': limit},
      );

      if (response.statusCode == 200) {
        final List<PostModel> posts = (response.data as List)
            .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Note: JSONPlaceholder returns total count in headers
        // In real APIs, pagination info might be in the response body
        final totalCount =
            int.tryParse(response.headers['x-total-count']?.first ?? '0') ?? 0;

        return ApiResponse(
          success: true,
          data: posts,
          message: 'Fetched page $page with ${posts.length} posts',
          statusCode: response.statusCode,
          pagination: PaginationInfo(
            currentPage: page,
            totalPages: (totalCount / limit).ceil(),
            totalItems: totalCount,
            itemsPerPage: limit,
            hasNextPage: page * limit < totalCount,
            hasPreviousPage: page > 1,
          ),
        );
      }

      return ApiResponse.failure(
        'Failed to fetch posts',
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
