import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/providers/remote_storage_provider.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/constants.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:image_picker/image_picker.dart';

class UserAvatar extends StatefulWidget {
  const UserAvatar({Key? key, required this.user}) : super(key: key);

  final UserData user;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _openChangeImageDialog();
      },
      child: Stack(
        children: [
          CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(
                  widget.user.imageUrl ?? placeholderNetworkImage)),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              child: const Icon(
                Icons.edit,
                size: 15,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _openChangeImageDialog() {
    final _formKey = GlobalKey<FormState>();
    bool loading = false;
    String? errorMessage;
    String oldImage = widget.user.imageUrl ?? placeholderNetworkImage;
    File? imagePreview;
    XFile? newImage;

    showDialog<void>(
      context: context,
      builder: (context) =>
          AlertDialog(content: StatefulBuilder(builder: (context, setState) {
        return SizedBox(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                    radius: 100,
                    backgroundImage: imagePreview != null
                        ?
                        // Known error in flutter atm - need to cast to ImageProvider
                        // See https://stackoverflow.com/questions/66561177/the-argument-type-object-cant-be-assigned-to-the-parameter-type-imageprovide
                        FileImage(imagePreview!) as ImageProvider
                        : NetworkImage(oldImage)),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        onPressed: loading
                            ? null
                            : () async {
                                try {
                                  setState(() {
                                    errorMessage = null;
                                  });
                                  // Pick an image
                                  final XFile? image = await _picker.pickImage(
                                      source: ImageSource.gallery);
                                  // If image exists, set a preview
                                  if (image != null) {
                                    setState(() {
                                      newImage = image;
                                      imagePreview = File(image.path);
                                    });
                                  }
                                } catch (error) {
                                  setState(() {
                                    errorMessage = 'Something went wrong';
                                  });
                                  debugPrint(error.toString());
                                }
                              },
                        text: 'New',
                        color: AppColors.quaternary,
                        size: ButtonSize.medium,
                      ),
                    ),
                    const SizedBox(
                      width: AppPading.medium,
                    ),
                    Expanded(
                      child: AppButton(
                        onPressed: newImage != null
                            ? () async {
                                try {
                                  setState(() {
                                    errorMessage = null;
                                    loading = true;
                                  });
                                  String? url = await RemoteStorageProvider()
                                      .uploadImageToFirebase(
                                          context: context,
                                          file: newImage!,
                                          oldFile: widget.user.imageUrl);
                                  if (url != null) {
                                    await UserService(uid: widget.user.uid)
                                        .updateUserData(
                                            key: 'imageUrl', value: url);
                                  }
                                  setState(() {
                                    loading = false;
                                  });
                                  showToast(
                                      context: context,
                                      message: 'Saved succesfully!');

                                  Navigator.pop(context);
                                } catch (error) {
                                  setState(() {
                                    errorMessage = 'Problem uploading image';
                                  });
                                  debugPrint(error.toString());
                                }
                              }
                            : null,
                        loading: loading,
                        text: 'Upload',
                        color: AppColors.secondary,
                        size: ButtonSize.medium,
                      ),
                    ),
                  ],
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppPading.small),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: AppColors.danger),
                    ).h4(),
                  )
              ],
            ),
          ),
        );
      })),
    );
  }
}
