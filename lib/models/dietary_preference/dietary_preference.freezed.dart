// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dietary_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DietaryPreference _$DietaryPreferenceFromJson(Map<String, dynamic> json) {
  return _DietaryPreference.fromJson(json);
}

/// @nodoc
mixin _$DietaryPreference {
  String get preference => throw _privateConstructorUsedError;
  set preference(String value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DietaryPreferenceCopyWith<DietaryPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DietaryPreferenceCopyWith<$Res> {
  factory $DietaryPreferenceCopyWith(
          DietaryPreference value, $Res Function(DietaryPreference) then) =
      _$DietaryPreferenceCopyWithImpl<$Res, DietaryPreference>;
  @useResult
  $Res call({String preference});
}

/// @nodoc
class _$DietaryPreferenceCopyWithImpl<$Res, $Val extends DietaryPreference>
    implements $DietaryPreferenceCopyWith<$Res> {
  _$DietaryPreferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preference = null,
  }) {
    return _then(_value.copyWith(
      preference: null == preference
          ? _value.preference
          : preference // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DietaryPreferenceImplCopyWith<$Res>
    implements $DietaryPreferenceCopyWith<$Res> {
  factory _$$DietaryPreferenceImplCopyWith(_$DietaryPreferenceImpl value,
          $Res Function(_$DietaryPreferenceImpl) then) =
      __$$DietaryPreferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String preference});
}

/// @nodoc
class __$$DietaryPreferenceImplCopyWithImpl<$Res>
    extends _$DietaryPreferenceCopyWithImpl<$Res, _$DietaryPreferenceImpl>
    implements _$$DietaryPreferenceImplCopyWith<$Res> {
  __$$DietaryPreferenceImplCopyWithImpl(_$DietaryPreferenceImpl _value,
      $Res Function(_$DietaryPreferenceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preference = null,
  }) {
    return _then(_$DietaryPreferenceImpl(
      preference: null == preference
          ? _value.preference
          : preference // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DietaryPreferenceImpl implements _DietaryPreference {
  _$DietaryPreferenceImpl({required this.preference});

  factory _$DietaryPreferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$DietaryPreferenceImplFromJson(json);

  @override
  String preference;

  @override
  String toString() {
    return 'DietaryPreference(preference: $preference)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DietaryPreferenceImplCopyWith<_$DietaryPreferenceImpl> get copyWith =>
      __$$DietaryPreferenceImplCopyWithImpl<_$DietaryPreferenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DietaryPreferenceImplToJson(
      this,
    );
  }
}

abstract class _DietaryPreference implements DietaryPreference {
  factory _DietaryPreference({required String preference}) =
      _$DietaryPreferenceImpl;

  factory _DietaryPreference.fromJson(Map<String, dynamic> json) =
      _$DietaryPreferenceImpl.fromJson;

  @override
  String get preference;
  set preference(String value);
  @override
  @JsonKey(ignore: true)
  _$$DietaryPreferenceImplCopyWith<_$DietaryPreferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
