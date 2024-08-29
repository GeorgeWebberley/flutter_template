// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dietary_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DietaryPreferenceImpl _$$DietaryPreferenceImplFromJson(
        Map<String, dynamic> json) =>
    _$DietaryPreferenceImpl(
      preference: json['preference'] as String,
      activated: json['activated'] as bool?,
    );

Map<String, dynamic> _$$DietaryPreferenceImplToJson(
        _$DietaryPreferenceImpl instance) =>
    <String, dynamic>{
      'preference': instance.preference,
      'activated': instance.activated,
    };
