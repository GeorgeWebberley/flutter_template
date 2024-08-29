import 'package:freezed_annotation/freezed_annotation.dart';

part 'dietary_preference.freezed.dart';
part 'dietary_preference.g.dart';

// If updating, run:
// flutter pub run build_runner build --delete-conflicting-outputs
@unfreezed
class DietaryPreference with _$DietaryPreference {
  factory DietaryPreference({
    required String preference,
    bool? activated,
  }) = _DietaryPreference;

  factory DietaryPreference.fromJson(Map<String, dynamic> json) =>
      _$DietaryPreferenceFromJson(json);

  // Map<String, dynamic> toJson(DietaryPreference preference) {
  //   return {
  //     "preference": preference.preference,
  //     "activated": preference.activated
  //   };
  // }
}
