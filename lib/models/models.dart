/// This file exports all models for easy importing
///
/// Using barrel files (index/export files) is a best practice:
///
/// Benefits:
/// 1. Single import statement for all models
/// 2. Easier to refactor and reorganize
/// 3. Better encapsulation - you control what's publicly available
/// 4. Cleaner import statements in other files
///
/// Usage:
/// Instead of:
///   import 'package:api_learn/models/post_model.dart';
///   import 'package:api_learn/models/user_model.dart';
///   import 'package:api_learn/models/api_response.dart';
///
/// You can use:
///   import 'package:api_learn/models/models.dart';

export 'post_model.dart';
export 'user_model.dart';
export 'api_response.dart';
export 'file_upload_response.dart';
