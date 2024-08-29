import 'package:flutter_firebase_template/models/dietary_preference/dietary_preference.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_data.freezed.dart';
part 'user_data.g.dart';

// If updating, run:
// flutter pub run build_runner build --delete-conflicting-outputs

/// Whilst [Appuser] is the direct implementation of a firebase user, this model
/// contains additional information that can be used by the app and stored in firestore.
@unfreezed
class UserData with _$UserData {
  factory UserData({
    required String uid,
    String? name,
    required String email,
    List<String>? providers,
    List<DietaryPreference>? dietaryPreferences,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
