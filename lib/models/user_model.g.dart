// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************
//
// This file demonstrates the generated code for:
// 1. Nested objects (Address within User)
// 2. Nullable fields
// 3. Custom JSON key names (@JsonKey)

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'] as int,
    name: json['name'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    // Nested object handling:
    // We check if 'address' exists in JSON, then parse it as Address
    // If null, we keep it as null (nullable field)
    address: json['address'] == null
        ? null
        : Address.fromJson(json['address'] as Map<String, dynamic>),
    // Nullable string handling:
    // Uses '?' to safely cast - returns null if the field is null
    phone: json['phone'] as String?,
    website: json['website'] as String?,
  );
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) {
  return <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'username': instance.username,
    'email': instance.email,
    // For nested objects, we call their toJson method
    // The '?' handles the case where address is null
    'address': instance.address?.toJson(),
    'phone': instance.phone,
    'website': instance.website,
  };
}

Address _$AddressFromJson(Map<String, dynamic> json) {
  return Address(
    street: json['street'] as String,
    suite: json['suite'] as String,
    city: json['city'] as String,
    // Note: The JSON key is 'zipcode' but our Dart field is 'zipCode'
    // This mapping is defined using @JsonKey(name: 'zipcode')
    zipCode: json['zipcode'] as String,
  );
}

Map<String, dynamic> _$AddressToJson(Address instance) {
  return <String, dynamic>{
    'street': instance.street,
    'suite': instance.suite,
    'city': instance.city,
    // Important: We use the JSON key name 'zipcode' (not the Dart field name)
    // This ensures the API receives the correct key
    'zipcode': instance.zipCode,
  };
}
