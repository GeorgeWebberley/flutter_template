import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/meal_plan/meal_plan.dart';
import 'package:flutter_firebase_template/models/meal_plan_configuration.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';

class UserService {
  // user document reference
  final CollectionReference<Map<String, dynamic>> _usersRef =
      FirebaseFirestore.instance.collection('users');

  // Current user's ID
  final String? uid;

  UserService({this.uid});

  Future createUserDbEntry({
    required String email,
    required List<String> providers,
    String? name,
  }) async {
    return await _usersRef.doc(uid).set({
      'email': email,
      'providers': providers,
      'name': name,
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
  Future<void> updateUserData({
    required String key,
    required dynamic value,
  }) async {
    return await _usersRef.doc(uid).update({
      key: value,
    });
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

  /// userData from a snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> userSnapshot =
        snapshot.data()! as Map<String, dynamic>;
    userSnapshot['uid'] = snapshot.id;

    return UserData.fromJson(userSnapshot);
  }

  /// userData from a query
  UserData _userDataFromQuerySnapshot(QuerySnapshot snapshot) {
    Map<String, dynamic> userSnapshot =
        snapshot.docs.single.data() as Map<String, dynamic>;

    userSnapshot['uid'] = snapshot.docs.single.id;

    return UserData.fromJson(userSnapshot);
  }

  // Add Meal Plan
  Future<String> addMealPlan(MealPlanConfiguration mealPlan) async {
    DocumentReference<Map<String, dynamic>> document =
        await _usersRef.doc(uid).collection('mealPlans').add({
      'loading': true,
      'createdAt': FieldValue.serverTimestamp(),
      'mealPlanConfiguration': mealPlan.toJson(),
    });

    return document.id;
  }

  Stream<List<MealPlan>> getMealPlans() {
    return _usersRef.doc(uid).collection('mealPlans').snapshots().map(
        (snapshot) => snapshot.docs
            .map((document) => MealPlan.fromFirebase(document))
            .toList());
  }

  Stream<MealPlan> getMealPlan(String mealPlanId) {
    return _usersRef
        .doc(uid)
        .collection('mealPlans')
        .doc(mealPlanId)
        .snapshots()
        .map((snapshot) => MealPlan.fromFirebase(snapshot));
  }

  Future<void> deleteMealPlan(String mealPlanId) async {
    await _usersRef.doc(uid).collection('mealPlans').doc(mealPlanId).delete();
  }

  Future<void> setRefreshing({
    required String type,
    required String mealPlanId,
  }) async {
    try {
      await _usersRef.doc(uid).collection('mealPlans').doc(mealPlanId).update({
        type == 'breakfast'
            ? 'breakfastRefreshing'
            : type == 'lunch'
                ? 'lunchRefreshing'
                : 'dinnerRefreshing': true,
      });
    } catch (e) {
      debugPrint('Error in UserService: $e');
      throw Exception('Failed to send message');
    }
  }

  Future<void> setRecipeComplete({
    required String title,
    required String mealPlanId,
  }) async {
    try {
      // Get the meal plan document
      final docSnapshot = await _usersRef
          .doc(uid)
          .collection('mealPlans')
          .doc(mealPlanId)
          .get();

      // Extract the recipes array from the document
      List<dynamic> recipes = docSnapshot.data()?['recipes'] ?? [];

      // Find the recipe by title
      int recipeIndex = recipes.indexWhere((recipe) {
        return recipe['title'] == title;
      });

      if (recipeIndex == -1) {
        throw Exception('Recipe not found');
      }

      // Update the recipe to mark it as done
      recipes[recipeIndex]['completed'] = true;

      // Write the updated recipes array back to Firestore
      await _usersRef.doc(uid).collection('mealPlans').doc(mealPlanId).update({
        'recipes': recipes, // Replace the whole array with the updated version
      });
    } catch (e) {
      debugPrint('Error in UserService: $e');
      throw Exception('Failed to mark recipe as done');
    }
  }
}
