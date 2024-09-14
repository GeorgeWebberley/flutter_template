import 'package:freezed_annotation/freezed_annotation.dart';

part 'dietary_preference.freezed.dart';
part 'dietary_preference.g.dart';

// If updating, run:
// flutter pub run build_runner build --delete-conflicting-outputs
// Seems overkill having a model for just a String value. However this will be
// useful if we need to add more properties in the future (such as "activated").
@unfreezed
class DietaryPreference with _$DietaryPreference {
  factory DietaryPreference({
    required String preference,
    // bool? activated,
  }) = _DietaryPreference;

  factory DietaryPreference.fromJson(Map<String, dynamic> json) =>
      _$DietaryPreferenceFromJson(json);
}
