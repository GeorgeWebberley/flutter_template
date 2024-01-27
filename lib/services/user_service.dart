import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_firebase_template/models/user_data.dart';

class UserService {
  // user document reference
  final CollectionReference<Map<String, dynamic>> _usersRef =
      FirebaseFirestore.instance.collection('users');
  // user document reference
  final CollectionReference<Map<String, dynamic>> _usernamesRef =
      FirebaseFirestore.instance.collection('usernames');
  // Current user's ID
  final String? uid;

  UserService({this.uid});

  Future createUserDbEntry(
      {required String email,
      required List<String> providers,
      required String username,
      String? imageUrl,
      String? firstName,
      String? lastName}) async {
    return await _usersRef.doc(uid).set({
      'email': email,
      'providers': providers,
      'username': username,
      'imageUrl': imageUrl,
      'firstName': firstName,
      'lastName': lastName,
    });
  }

  /// Get the token from FirebaseMessaging.instance and store it in the DB
  Future _setupUserNotificationToken() async {
    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();
    // Save the initial token to the database
    // await _storeTokenInDatabase(token!);
    await updateUserData(key: "tokens", value: FieldValue.arrayUnion([token]));
    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) async =>
        await updateUserData(
            key: "tokens", value: FieldValue.arrayUnion([token])));
  }

  /// Takes a single key/value pair and updates the value in firestore
  Future updateUserData({
    required String key,
    required dynamic value,
  }) async {
    return await _usersRef.doc(uid).update({
      key: value,
    });
  }

  /// Checks if a username has already been taken. Returns a Stream of snapshots
  Stream<QuerySnapshot<Map<String, dynamic>>> checkUsername({
    required String username,
  }) {
    return _usernamesRef
        .where(FieldPath.documentId, isEqualTo: username)
        .snapshots();
  }

  /// Sets a userame in the usernames collection. Does not set the value in the users collection
  Future setUsername({
    required String username,
  }) async {
    try {
      await _usernamesRef.doc(username).set({'id': uid});
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  /// get the current user stream
  Stream<UserData> get userDataStream {
    return _usersRef
        .doc(uid)
        .snapshots()
        .map((snapshot) => _userDataFromSnapshot(snapshot));
  }

  /// Get the current user data and sets up the user notification token. Returns a [UserData]
  Future<UserData?> getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _usersRef.doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    // If the user exists, we can setup the user notification token
    await _setupUserNotificationToken();

    return _userDataFromSnapshot(snapshot);
  }

  /// Get the user data of any user (e.g. friend). Returns a stream of [UserData]
  Stream<UserData> friendData(String id) {
    return _usersRef
        .doc(id)
        .snapshots()
        .map((snapshot) => _userDataFromSnapshot(snapshot));
  }

  /// Returns a list of [UserData] using the provided list of IDs as a stream
  Stream<List<UserData>> getMultipleUsersByIdStream(List<String> idList) {
    return _usersRef
        .where(
          FieldPath.documentId,
          // 'whereIn' query requires non-empty list.
          // A hacky solution for providing a list when user has no friends
          whereIn: idList.isEmpty ? ['-1'] : idList,
        )
        .snapshots()
        .map((snapshot) {
      List<UserData> users = [];

      for (var userDocument in snapshot.docs) {
        users.add(_userDataFromSnapshot(userDocument));
      }

      return users;
    });
  }

  /// Returns a single of multiple [UserData] given a list of IDs
  Future<List<UserData>?> getMultipleUsersById(List<String> idList) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _usersRef
        .where(FieldPath.documentId, whereIn: idList.isEmpty ? ['-1'] : idList)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.map((document) {
      Map<String, dynamic> userSnapshot = document.data();
      userSnapshot['uid'] = document.id;

      return UserData.fromJson(userSnapshot);
    }).toList();
  }

  /// Gets a [UserData] object using a provided email
  Future<UserData?> findUserByEmail(String email) async {
    QuerySnapshot snapshot =
        await _usersRef.where('email', isEqualTo: email).get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return _userDataFromQuerySnapshot(snapshot);
  }

  /// Gets a [UserData] object using a provided username
  Future<UserData?> findUserByUsername(String username) async {
    QuerySnapshot snapshot =
        await _usersRef.where('username', isEqualTo: username).get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return _userDataFromQuerySnapshot(snapshot);
  }

  /// userData from a snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    print("Getting userdata from snapshot");
    Map<String, dynamic> userSnapshot =
        snapshot.data()! as Map<String, dynamic>;
    userSnapshot['uid'] = snapshot.id;

    print("sending back json");

    return UserData.fromJson(userSnapshot);
  }

  /// userData from a query
  UserData _userDataFromQuerySnapshot(QuerySnapshot snapshot) {
    Map<String, dynamic> userSnapshot =
        snapshot.docs.single.data() as Map<String, dynamic>;

    userSnapshot['uid'] = snapshot.docs.single.id;

    return UserData.fromJson(userSnapshot);
  }
}
