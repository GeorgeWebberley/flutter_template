import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/meal_plan/meal_plan.dart';
import 'package:flutter_firebase_template/models/meal_plan_configuration.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:rxdart/rxdart.dart';

class UserService {
  // user document reference
  final CollectionReference<Map<String, dynamic>> _usersRef =
      FirebaseFirestore.instance.collection('users');

  // Current user's ID
  final String? uid;

  UserService({this.uid});

  Future createUserDbEntry({
    required AppUser appUser,
    String? name,
  }) async {
    return await _usersRef.doc(uid).set({
      'email': appUser.email,
      'providers': appUser.providers,
      'name': name ?? appUser.name,
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

  /// Takes a a full map and updates the database
  Future<void> updateMultipleUserData(Map<Object, Object?> object) async {
    return await _usersRef.doc(uid).update(object);
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

  Stream<List<Recipe>> getSnacks() {
    return _usersRef
        .doc(uid)
        .collection('snacks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((document) {
              Map<String, dynamic> data = document.data();
              data['id'] = document.id;
              return Recipe.fromJson(data);
            }).toList());
  }

  Stream<List<Recipe>> getRecipes(String mealPlanId) {
    return _usersRef
        .doc(uid)
        .collection('mealPlans')
        .doc(mealPlanId)
        .collection('recipes')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data();
              data['id'] = doc.id;

              return Recipe.fromJson(data);
            }).toList());
  }

  Future<void> refreshSingleRecipe({
    required String recipeId,
    required String mealPlanId,
    required MealPlanConfiguration? mealPlanConfiguration,
    required List<String> existingTitles,
    required String mealType,
  }) async {
    try {
      await _usersRef
          .doc(uid)
          .collection('mealPlans')
          .doc(mealPlanId)
          .collection("recipes")
          .doc(recipeId)
          .update({
        'loading': true,
      });

      // Prepare the data to be sent to the Cloud Function
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'refreshSingleRecipe',
          options: HttpsCallableOptions(timeout: const Duration(minutes: 2)));

      Map<String, dynamic> body = {
        'mealPlanId': mealPlanId,
        'mealPlanConfiguration': mealPlanConfiguration?.toJson(),
        'recipeId': recipeId,
        'existingTitles': existingTitles,
        'mealType': mealType,
      };

      // We don't wait for the promise, since it will take a long time
      callable.call(body);
    } catch (e) {
      debugPrint('Error in ChatService: $e');
      throw Exception('Failed to send message');
    }
  }

  Stream<MealPlan> getMealPlan(String mealPlanId) {
    return _usersRef
        .doc(uid)
        .collection('mealPlans')
        .doc(mealPlanId)
        .snapshots()
        .map((snapshot) => MealPlan.fromFirebase(snapshot));
  }

  Stream<MealPlanWithRecipes> getMealPlanWithRecipes(String mealPlanId) {
    final mealPlanStream =
        _usersRef.doc(uid).collection('mealPlans').doc(mealPlanId).snapshots();
    final recipesStream = _usersRef
        .doc(uid)
        .collection('mealPlans')
        .doc(mealPlanId)
        .collection('recipes')
        .snapshots();

    return Rx.combineLatest2(mealPlanStream, recipesStream,
        (mealPlanSnap, recipesSnap) {
      final mealPlan = MealPlan.fromFirebase(mealPlanSnap);

      final recipes = recipesSnap.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        return Recipe.fromJson(data);
      }).toList();

      return MealPlanWithRecipes(mealPlan, recipes);
    });
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
    required String recipeId,
    required String mealPlanId,
  }) async {
    try {
      // Write the updated recipes array back to Firestore
      await _usersRef
          .doc(uid)
          .collection('mealPlans')
          .doc(mealPlanId)
          .collection('recipes')
          .doc(recipeId)
          .update({
        'completed': true,
      });
    } catch (e) {
      debugPrint('Error in UserService: $e');
      throw Exception('Failed to mark recipe as done');
    }
  }

  Future<List<Map<String, dynamic>>> addSnacks({
    required List snacks,
  }) async {
    try {
      CollectionReference snacksCollection =
          _usersRef.doc(uid).collection('snacks');

      List<Map<String, dynamic>> snackDocsWithIds = [];

      for (var snack in snacks) {
        // Add snack to Firestore and get the reference with generated ID
        DocumentReference docRef = await snacksCollection.add(snack);

        // Add the document data along with the Firestore document ID
        snackDocsWithIds.add({
          ...snack, // Include the original snack data
          'id': docRef.id // Add the generated document ID
        });
      }

      return snackDocsWithIds; // Return the list with the IDs
    } catch (e) {
      debugPrint('Error in UserService: $e');
      throw Exception('Failed to delete recipe');
    }
  }

  Future<void> deleteRecipe({
    required String recipeId,
    required String mealPlanId,
  }) async {
    try {
      await _usersRef
          .doc(uid)
          .collection('mealPlans')
          .doc(mealPlanId)
          .collection('recipes')
          .doc(recipeId)
          .delete();
    } catch (e) {
      debugPrint('Error in UserService: $e');
      throw Exception('Failed to delete recipe');
    }
  }

  Future<void> deleteSnack({
    required String recipeId,
  }) async {
    try {
      await _usersRef.doc(uid).collection('snacks').doc(recipeId).delete();
    } catch (e) {
      debugPrint('Error in UserService: $e');
      throw Exception('Failed to delete recipe');
    }
  }

  Future<void> setFavourite({
    required Recipe recipe,
    required String mealPlanId,
    required bool value,
  }) async {
    try {
      DocumentReference recipeRef = _usersRef
          .doc(uid)
          .collection('mealPlans')
          .doc(mealPlanId)
          .collection('recipes')
          .doc(recipe.id);

      if (value) {
        await recipeRef.update({
          'favourite': true,
        });
        await _usersRef.doc(uid).update({
          'favourites': FieldValue.arrayUnion([recipeRef]),
        });
      } else {
        await recipeRef.update({
          'favourite': false,
        });
        await _usersRef.doc(uid).update({
          'favourites': FieldValue.arrayRemove([recipeRef]),
        });
      }
    } catch (e) {
      debugPrint('Error in UserService: $e');
      throw Exception('Failed to update favourite status');
    }
  }

  Future<List<Map<String, dynamic>>> getFavourites() async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    // Cast the favourites to List<DocumentReference>
    List<DocumentReference> favourites =
        (userSnapshot.data() as Map)['favourites'] != null
            ? (userSnapshot.data() as Map)['favourites']
                .map<DocumentReference>((ref) => ref as DocumentReference)
                .toList()
            : [];

    List<Map<String, dynamic>> favouriteRecipes = [];

    for (DocumentReference ref in favourites) {
      DocumentSnapshot recipeSnapshot = await ref.get();
      Map<String, dynamic>? recipeData =
          recipeSnapshot.data() as Map<String, dynamic>?;

      if (recipeData == null) {
        await _usersRef.doc(uid).update({
          'favourites': FieldValue.arrayRemove([ref]),
        });
        continue;
      }

      recipeData['id'] = recipeSnapshot.id;

      Recipe recipe = Recipe.fromJson(recipeData);

      // Extract mealPlanId from the reference
      String mealPlanId = getMealPlanId(ref);

      favouriteRecipes.add({
        'recipe': recipe,
        'mealPlanId': mealPlanId,
      });
    }

    return favouriteRecipes;
  }

  String getMealPlanId(DocumentReference reference) {
    List<String> pathSegments = reference.path.split('/');
    if (pathSegments.length >= 4) {
      return pathSegments[3]; // Extract mealPlanId from the path
    } else {
      throw Exception('Invalid DocumentReference path');
    }
  }
}
