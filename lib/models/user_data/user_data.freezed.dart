// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserData _$UserDataFromJson(Map<String, dynamic> json) {
  return _UserData.fromJson(json);
}

/// @nodoc
mixin _$UserData {
  String get uid => throw _privateConstructorUsedError;
  set uid(String value) => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  set name(String? value) => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  set email(String value) => throw _privateConstructorUsedError;
  List<String>? get providers => throw _privateConstructorUsedError;
  set providers(List<String>? value) => throw _privateConstructorUsedError;
  List<DietaryPreference>? get dietaryPreferences =>
      throw _privateConstructorUsedError;
  set dietaryPreferences(List<DietaryPreference>? value) =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserDataCopyWith<UserData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDataCopyWith<$Res> {
  factory $UserDataCopyWith(UserData value, $Res Function(UserData) then) =
      _$UserDataCopyWithImpl<$Res, UserData>;
  @useResult
  $Res call(
      {String uid,
      String? name,
      String email,
      List<String>? providers,
      List<DietaryPreference>? dietaryPreferences});
}

/// @nodoc
class _$UserDataCopyWithImpl<$Res, $Val extends UserData>
    implements $UserDataCopyWith<$Res> {
  _$UserDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = freezed,
    Object? email = null,
    Object? providers = freezed,
    Object? dietaryPreferences = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      providers: freezed == providers
          ? _value.providers
          : providers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      dietaryPreferences: freezed == dietaryPreferences
          ? _value.dietaryPreferences
          : dietaryPreferences // ignore: cast_nullable_to_non_nullable
              as List<DietaryPreference>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserDataImplCopyWith<$Res>
    implements $UserDataCopyWith<$Res> {
  factory _$$UserDataImplCopyWith(
          _$UserDataImpl value, $Res Function(_$UserDataImpl) then) =
      __$$UserDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String? name,
      String email,
      List<String>? providers,
      List<DietaryPreference>? dietaryPreferences});
}

/// @nodoc
class __$$UserDataImplCopyWithImpl<$Res>
    extends _$UserDataCopyWithImpl<$Res, _$UserDataImpl>
    implements _$$UserDataImplCopyWith<$Res> {
  __$$UserDataImplCopyWithImpl(
      _$UserDataImpl _value, $Res Function(_$UserDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = freezed,
    Object? email = null,
    Object? providers = freezed,
    Object? dietaryPreferences = freezed,
  }) {
    return _then(_$UserDataImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      providers: freezed == providers
          ? _value.providers
          : providers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      dietaryPreferences: freezed == dietaryPreferences
          ? _value.dietaryPreferences
          : dietaryPreferences // ignore: cast_nullable_to_non_nullable
              as List<DietaryPreference>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDataImpl implements _UserData {
  _$UserDataImpl(
      {required this.uid,
      this.name,
      required this.email,
      this.providers,
      this.dietaryPreferences});

  factory _$UserDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDataImplFromJson(json);

  @override
  String uid;
  @override
  String? name;
  @override
  String email;
  @override
  List<String>? providers;
  @override
  List<DietaryPreference>? dietaryPreferences;

  @override
  String toString() {
    return 'UserData(uid: $uid, name: $name, email: $email, providers: $providers, dietaryPreferences: $dietaryPreferences)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDataImplCopyWith<_$UserDataImpl> get copyWith =>
      __$$UserDataImplCopyWithImpl<_$UserDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDataImplToJson(
      this,
    );
  }
}

abstract class _UserData implements UserData {
  factory _UserData(
      {required String uid,
      String? name,
      required String email,
      List<String>? providers,
      List<DietaryPreference>? dietaryPreferences}) = _$UserDataImpl;

  factory _UserData.fromJson(Map<String, dynamic> json) =
      _$UserDataImpl.fromJson;

  @override
  String get uid;
  set uid(String value);
  @override
  String? get name;
  set name(String? value);
  @override
  String get email;
  set email(String value);
  @override
  List<String>? get providers;
  set providers(List<String>? value);
  @override
  List<DietaryPreference>? get dietaryPreferences;
  set dietaryPreferences(List<DietaryPreference>? value);
  @override
  @JsonKey(ignore: true)
  _$$UserDataImplCopyWith<_$UserDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
