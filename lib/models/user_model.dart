import 'package:json_annotation/json_annotation.dart';

/// ============================================================================
/// نموذج المستخدم - يوضح سيناريوهات تحليل JSON الأكثر تعقيداً
/// User Model - Demonstrating more complex JSON parsing scenarios
/// ============================================================================
///
/// المفاهيم الموضحة | Key Concepts Demonstrated:
/// 1. الحقول الاختيارية (nullable) - حقول قد تكون غير موجودة في API
///    Nullable fields - fields that might be missing from the API
/// 2. الكائنات المتداخلة - كلاس Address داخل User
///    Nested objects - Address class inside User
/// 3. أسماء مفاتيح JSON مخصصة باستخدام @JsonKey
///    Custom JSON key names using @JsonKey annotation
/// 4. القيم الافتراضية للحقول
///    Default values for fields

part 'user_model.g.dart';

/// ============================================================================
/// كلاس UserModel - نموذج يمثل مستخدم من REST API
/// A model class representing a user from a REST API
/// ============================================================================
///
/// هذا يوضح | This demonstrates:
/// - الكائنات المتداخلة (Address داخل User)
///   Nested objects (Address inside User)
/// - الحقول الاختيارية (nullable)
///   Nullable fields
/// - أسماء مفاتيح JSON مخصصة
///   Custom JSON key names
///
/// مثال JSON من JSONPlaceholder API:
/// Example JSON from JSONPlaceholder API:
/// ```json
/// {
///   "id": 1,
///   "name": "Leanne Graham",
///   "username": "Bret",
///   "email": "Sincere@april.biz",
///   "address": {
///     "street": "Kulas Light",
///     "suite": "Apt. 556",
///     "city": "Gwenborough",
///     "zipcode": "92998-3874"
///   },
///   "phone": "1-770-736-8031 x56442",
///   "website": "hildegard.org"
/// }
/// ```
@JsonSerializable()
class UserModel {
  /// معرف المستخدم الفريد
  /// Unique user identifier
  final int id;

  /// الاسم الكامل للمستخدم
  /// User's full name
  final String name;

  /// اسم المستخدم (فريد)
  /// User's username (unique)
  final String username;

  /// البريد الإلكتروني للمستخدم
  /// User's email address
  final String email;

  /// عنوان المستخدم (كائن متداخل)
  /// User's address (nested object)
  /// يوضح التعامل مع الكائنات المتداخلة في JSON
  /// Demonstrates handling of nested objects in JSON
  final Address? address;

  /// رقم هاتف المستخدم - اختياري لأنه قد لا يكون متوفراً
  /// User's phone number - Nullable because it might not be provided
  final String? phone;

  /// موقع المستخدم - اختياري لأنه قد لا يكون متوفراً
  /// User's website - Nullable because it might not be provided
  final String? website;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.address,
    this.phone,
    this.website,
  });

  /// Factory constructor لفك تسلسل JSON
  /// Factory constructor for JSON deserialization
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// تحويل هذا UserModel إلى خريطة JSON
  /// Converts this UserModel instance to a JSON map
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}

/// ============================================================================
/// نموذج العنوان - يوضح الكائنات المتداخلة في JSON
/// Address model - Demonstrating nested objects in JSON
/// ============================================================================
///
/// هذا الكلاس يوضح كيفية التعامل مع الكائنات داخل الكائنات
/// This class shows how to handle objects within objects
/// عندما يحتوي JSON على هياكل متداخلة، تنشئ كلاسات منفصلة لكل مستوى
/// When JSON has nested structures, you create separate classes for each level
@JsonSerializable()
class Address {
  /// اسم الشارع
  /// Street name
  final String street;

  /// رقم الشقة أو الجناح
  /// Apartment or suite number
  final String suite;

  /// اسم المدينة
  /// City name
  final String city;

  /// ملاحظة: في Dart، نستخدم @JsonKey لربط أسماء مفاتيح JSON مختلفة
  /// Note: In Dart, we can use @JsonKey to map different JSON key names
  /// هذا مفيد عندما تستخدم API أسماء snake_case لكن Dart يستخدم camelCase
  /// This is useful when API uses snake_case but Dart uses camelCase
  @JsonKey(name: 'zipcode')
  final String zipCode;

  Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  /// خاصية محسوبة للحصول على العنوان الكامل كنص
  /// Computed property to get full address string
  /// هذا مثال جيد على إضافة منطق العمل للنماذج
  /// This is a good example of adding business logic to models
  String get fullAddress => '$street, $suite, $city $zipCode';

  @override
  String toString() => fullAddress;
}
