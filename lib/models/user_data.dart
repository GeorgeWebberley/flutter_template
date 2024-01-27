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
    String? firstName,
    String? lastName,
    String? username,
    required String email,
    List<String>? friendRequests,
    List<String>? friends,
    String? imageUrl,
    List<String>? providers,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
