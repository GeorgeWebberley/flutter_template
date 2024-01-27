import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FriendService {
  final functions = FirebaseFunctions.instance;

  final String? uid;

  // user document reference
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  FriendService({this.uid});

  Future<void> requestFriend(String friendId) async {
    final callable = functions.httpsCallable('makeFriendRequest');
    // Currently I am not waiting for a response due to long wait time of cold boot
    // in cloud function.
    await callable.call(<String, dynamic>{
      'requester': uid,
      'friend': friendId,
    });
  }

  Future<void> acceptFriendRequest(String friendId) async {
    return await usersRef.doc(uid).update({
      'friends': FieldValue.arrayUnion([friendId]),
      'friendRequests': FieldValue.arrayRemove([friendId]),
    });
  }

  Future<void> rejectFriendRequest(String friendId) async {
    return await usersRef.doc(uid).update({
      'friendRequests': FieldValue.arrayRemove([friendId]),
    });
  }

  Future<void> removeFriend(String friendId) async {
    return await usersRef.doc(uid).update({
      'friends': FieldValue.arrayRemove([friendId]),
    });
  }
}
