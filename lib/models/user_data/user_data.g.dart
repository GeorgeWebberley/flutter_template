// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDataImpl _$$UserDataImplFromJson(Map<String, dynamic> json) =>
    _$UserDataImpl(
      uid: json['uid'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      providers: (json['providers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dietaryPreferences: (json['dietaryPreferences'] as List<dynamic>?)
          ?.map((e) => DietaryPreference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$UserDataImplToJson(_$UserDataImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'providers': instance.providers,
      'dietaryPreferences': instance.dietaryPreferences,
    };
