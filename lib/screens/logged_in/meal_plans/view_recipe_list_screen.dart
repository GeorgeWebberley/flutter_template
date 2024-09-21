import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/meal_plan/meal_plan.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/recipe_screen.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/box_shadow.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:provider/provider.dart';

class ViewRecipeListScreen extends StatefulWidget {
  const ViewRecipeListScreen({
    super.key,
    required this.mealType,
    required this.title,
    required this.mealPlan,
  });

  final String mealType;
  final String title;
  final MealPlan mealPlan;

  @override
  State<ViewRecipeListScreen> createState() => _ViewRecipeListScreenState();
}

class _ViewRecipeListScreenState extends State<ViewRecipeListScreen> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  PageController pageController = PageController();
  List<Recipe> selected = [];
  List<Recipe> completedRecipes = [];
  List<Recipe> nonCompletedRecipes = [];
  String? mode;

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: StreamBuilder<List<Recipe>>(
            stream: UserService(uid: user.uid).getRecipes(widget.mealPlan.id),
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
                List<Recipe> recipes = snapshot.data!
                    .where((recipe) => recipe.mealType == widget.mealType)
                    .toList();

                completedRecipes = recipes
                    .where((element) => element.completed == true)
                    .toList();

                nonCompletedRecipes = recipes
                    .where((element) => element.completed != true)
                    .toList();

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPading.page),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTitle(title: widget.title),
                        AnimatedList(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          key: _listKey,
                          initialItemCount: nonCompletedRecipes.length,
                          itemBuilder: (context, index, animation) {
                            final recipe = nonCompletedRecipes[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      index != nonCompletedRecipes.length - 1
                                          ? AppPading.large
                                          : 0),
                              child: _buildDismissableRecipeTile(
                                  recipe, context, user.uid, index, recipes),
                            );
                          },
                        ),
                        if (completedRecipes.isNotEmpty)
                          _buildCompletedRecipes(
                              context, completedRecipes, user.uid, recipes),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: Text('No recipes found'),
                );
              }
            }),
      ),
    );
  }

  Widget _buildDismissableRecipeTile(Recipe recipe, BuildContext context,
      String uid, int index, List<Recipe> allRecipes) {
    return Dismissible(
      key: Key(recipe.title),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        _removeRecipe(
            index: index, recipe: recipe, uid: uid, allRecipes: allRecipes);
        return true;
      },
      child: _buildRecipeCard(recipe, context, uid, allRecipes),
    );
  }

  Container _buildRecipeCard(Recipe recipe, BuildContext context, String uid,
      List<Recipe> allRecipes) {
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
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: loading
                      ? ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            loadingColor, // Applying a grey filter
                            BlendMode
                                .saturation, // Saturation blend mode to achieve the black and white effect
                          ),
                          child: Image.network(
                            recipe.image ?? "", // replace with your image URL
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.network(
                          recipe.image ?? "", // replace with your image URL
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                top: AppPading.small,
                right: AppPading.small,
                child: InkWell(
                  onTap: () async {
                    await UserService(uid: uid).setFavourite(
                      recipe: recipe,
                      mealPlanId: widget.mealPlan.id,
                      value: !isFavourite,
                    );
                  },
                  child: Container(
                      padding: const EdgeInsets.all(AppPading.small),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: AppBorderRadius.small,
                      ),
                      child: isFavourite
                          ? Icon(
                              Icons.favorite,
                              size: 25,
                              color: AppColors.danger,
                            )
                          : Icon(
                              Icons.favorite_border,
                              size: 25,
                              color: Colors.black,
                            )),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              color: Colors.white,
            ),
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
                SizedBox(height: AppPading.extraSmall),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.restaurant,
                        color: Colors.white,
                      ),
                      label: Text(
                        'View',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: mode != null || loading
                          ? null
                          : () {
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
                    OutlinedButton.icon(
                      icon: loading
                          ? Container(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: loadingColor,
                              ))
                          : Icon(
                              Icons.swap_horiz,
                              color: AppColors.primary,
                            ),
                      label: Text(loading ? "Swapping" : 'Swap',
                          style: TextStyle(
                              color:
                                  loading ? loadingColor : AppColors.primary)),
                      onPressed: mode != null || loading
                          ? null
                          : () {
                              UserService(uid: uid).refreshSingleRecipe(
                                recipeId: recipe.id!,
                                mealPlanId: widget.mealPlan.id,
                                mealType: recipe.mealType,
                                mealPlanConfiguration:
                                    widget.mealPlan.mealPlanConfiguration,
                                existingTitles: allRecipes
                                    .map(
                                      (e) => e.title,
                                    )
                                    .toList(),
                              );
                            },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: loading ? loadingColor : AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await UserService(uid: uid).deleteRecipe(
                          recipeId: recipe.id,
                          mealPlanId: widget.mealPlan.id,
                        );
                      },
                      color: AppColors.danger,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _removeRecipe(
      {required int index,
      required Recipe recipe,
      required String uid,
      required List<Recipe> allRecipes}) async {
    UserService(uid: uid).setRecipeComplete(
        recipeId: recipe.id!, mealPlanId: widget.mealPlan.id);
    // setState(() {
    completedRecipes.add(recipe); // Mark recipe as completed
    Recipe removedRecipe = nonCompletedRecipes.removeAt(index);
    // Trigger animated removal from list
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => _buildRemovedTile(
          recipe: removedRecipe,
          animation: animation,
          uid: uid,
          allRecipes: allRecipes),
      duration: const Duration(milliseconds: 300),
    );
    // });
  }

  // Widget for animated removal
  Widget _buildRemovedTile(
      {required Recipe recipe,
      required Animation<double> animation,
      required String uid,
      required List<Recipe> allRecipes}) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut, // You can change this to any curve you like
    );
    return SizeTransition(
      sizeFactor: curvedAnimation,
      axisAlignment: 0.0,
      child: Opacity(
        opacity: 0,
        child: _buildRecipeCard(recipe, context, uid, allRecipes),
      ),
    );
  }

  _buildCompletedRecipes(BuildContext context, List<Recipe> completedRecipes,
      String uid, List<Recipe> allRecipes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Completed Meals', style: TextStyle(fontSize: 20)).h4(),
        const SizedBox(height: AppPading.medium),
        ...completedRecipes.map((recipe) => Padding(
            padding: const EdgeInsets.only(bottom: AppPading.large),
            child: Opacity(
              opacity: 0.5,
              child: _buildRecipeCard(
                  recipe, context, Provider.of<AppUser>(context).uid, []),
            ))),
      ],
    );
  }
}
