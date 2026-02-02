import 'package:dio/dio.dart';
import '../../models/models.dart';
import '../config/api_config.dart';
import '../exceptions/api_exceptions.dart';
import '../network/dio_client.dart';

/// ============================================================================
/// User API Service: Demonstrates Nested Objects & Complex Parsing
/// ============================================================================
///
/// This service extends the patterns from PostApiService to show:
/// - Handling nested JSON objects (User -> Address)
/// - Nullable field handling
/// - More complex data transformations
/// ============================================================================

class UserApiService {
  final DioClient _client;

  UserApiService(this._client);

  /// Fetch all users from the API
  ///
  /// This demonstrates parsing complex nested JSON structures.
  /// The User model contains an Address model inside it.
  Future<ApiResponse<List<UserModel>>> getAllUsers() async {
    try {
      final response = await _client.get(ApiConfig.usersEndpoint);

      if (response.statusCode == 200) {
        final List<UserModel> users = (response.data as List)
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return ApiResponse.success(
          users,
          message: 'Successfully fetched ${users.length} users',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.failure(
        'Failed to fetch users',
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

  /// Fetch a single user by ID
  Future<ApiResponse<UserModel>> getUserById(int id) async {
    try {
      final response = await _client.get(ApiConfig.userByIdEndpoint(id));

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);

        return ApiResponse.success(
          user,
          message: 'Successfully fetched user #$id',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode == 404) {
        return ApiResponse.failure(
          'User with ID $id not found',
          statusCode: 404,
        );
      }

      return ApiResponse.failure(
        'Failed to fetch user #$id',
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
