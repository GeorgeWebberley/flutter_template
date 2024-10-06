import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/recipe_screen.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/app_dialog.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/box_shadow.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';

class AccountFavourites extends StatefulWidget {
  const AccountFavourites({
    super.key,
    required this.userData,
    required this.backToRoot,
  });

  final UserData userData;
  final void Function() backToRoot;

  @override
  State<AccountFavourites> createState() => _AccountFavouritesState();
}

class _AccountFavouritesState extends State<AccountFavourites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: widget.backToRoot,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppPading.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppTitle(title: "Favourites"),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: UserService(uid: widget.userData.uid).getFavourites(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('An error occurred: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      List<Map<String, dynamic>> favourites = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: favourites.length,
                        itemBuilder: (context, index) {
                          Recipe recipe = favourites[index]['recipe'];
                          String mealPlanId = favourites[index]
                              ['mealPlanId']; // Extract mealPlanId

                          return Padding(
                            padding: const EdgeInsets.all(AppPading.small),
                            child: _buildRecipeCard(recipe, mealPlanId, context,
                                widget.userData.uid),
                          );
                        },
                      );
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('You have no favourites').h4(),
                          const SizedBox(height: AppPading.large),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppPading.page * 2),
                            child: AppButton(
                                onPressed: () {
                                  widget.backToRoot();
                                },
                                text: "Go back"),
                          )
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }

  Container _buildRecipeCard(
      Recipe recipe, String mealPlanId, BuildContext context, String uid) {
    bool loading = recipe.loading ?? false;
    Color loadingColor = Colors.grey;
    bool isFavourite = recipe.favourite ?? false;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [AppBoxShadow.small],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: loading
                      ? ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            loadingColor,
                            BlendMode.saturation,
                          ),
                          child: Image.network(
                            recipe.image ?? "",
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.network(
                          recipe.image ?? "",
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                top: AppPading.small,
                right: AppPading.small,
                child: InkWell(
                  onTap: () async {
                    _showConfirmDialog(
                        context: context,
                        mealPlanId: mealPlanId,
                        recipe: recipe,
                        uid: uid);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(AppPading.small),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: AppBorderRadius.small,
                      ),
                      child: isFavourite
                          ? const Icon(
                              Icons.favorite,
                              size: 25,
                              color: AppColors.danger,
                            )
                          : const Icon(
                              Icons.favorite_border,
                              size: 25,
                              color: Colors.black,
                            )),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: TextStyle(
                    color: loading ? loadingColor : AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  recipe.cookingTime,
                  style: TextStyle(
                    color: loading ? loadingColor : Colors.black,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppPading.extraSmall),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'View',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      SlideNavigator(
                          builder: (context, _, __) => RecipeScreen(
                                recipe: recipe,
                              )),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _showConfirmDialog({
    required BuildContext context,
    required String mealPlanId,
    required Recipe recipe,
    required String uid,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AppDialog(
          title: "Remove favourite",
          buttonText: "Confirm",
          content: const Text(
            'Are you sure you want to remove this meal from your favourites?',
            style: TextStyle(fontWeight: FontWeight.w600),
          ).h5(),
          onSave: () async {
            await UserService(uid: uid).setFavourite(
              recipe: recipe,
              mealPlanId: mealPlanId,
              value: false,
            );
            setState(() {});
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
