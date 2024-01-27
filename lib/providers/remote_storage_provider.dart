import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class RemoteStorageProvider {
  Reference imageStorageRef = FirebaseStorage.instance.ref('profile-pictures');

  Future<String?> uploadImageToFirebase(
      {required BuildContext context,
      required XFile file,
      String? oldFile}) async {
    try {
      // If there is an existing file, use refFromUrl to get the name. This is so
      // we can overwrite it.
      final String fileName = oldFile != null
          ? FirebaseStorage.instance.refFromURL(oldFile).name
          : basename(file.path);

      final TaskSnapshot snapshot =
          await imageStorageRef.child(fileName).putFile(File(file.path));
      // Return the URL so that it can be saved in the database
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (error) {
      debugPrint(error.toString());
      return error.toString();
    }
  }
}
