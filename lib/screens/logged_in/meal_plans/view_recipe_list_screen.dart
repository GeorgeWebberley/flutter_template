import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/recipe_screen.dart';
import 'package:flutter_firebase_template/services/chat_service.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/box_shadow.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/detail_tile.dart';
import 'package:provider/provider.dart';

class ViewRecipeListScreen extends StatefulWidget {
  const ViewRecipeListScreen({
    super.key,
    required this.recipes,
    required this.title,
    required this.mealPlanId,
  });

  final List<Recipe> recipes;
  final String title;
  final String mealPlanId;

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
  void initState() {
    completedRecipes =
        widget.recipes.where((element) => element.completed == true).toList();

    nonCompletedRecipes =
        widget.recipes.where((element) => element.completed != true).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ChatService _chatService = ChatService();
    AppUser? user = Provider.of<AppUser?>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        floatingActionButton: mode != null
            ? FloatingActionButton(
                onPressed: selected.isEmpty
                    ? null
                    : () async {
                        if (mode == 'refresh') {
                          _chatService.refreshRecipes(
                            recipesToRefresh: selected
                                .map(
                                  (e) => e.title,
                                )
                                .toList(),
                            type: selected[0].mealType,
                            mealPlanId: widget.mealPlanId,
                          );
                          await UserService(uid: user!.uid).setRefreshing(
                              type: selected[0].mealType,
                              mealPlanId: widget.mealPlanId);

                          Navigator.pop(context);
                        } else if (mode == 'delete') {
                          // TODO: delete recipes
                        }
                      },
                backgroundColor: selected.isEmpty
                    ? Colors.grey
                    : mode == 'refresh'
                        ? AppColors.primary
                        : AppColors.danger,
                child: mode == 'refresh'
                    ? const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
              )
            : null,
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppPading.page),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppTitle(title: widget.title),
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppPading.large),
                      child: mode != null
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  mode = null;
                                  selected = [];
                                });
                              },
                              icon: const Icon(Icons.close))
                          : PopupMenuButton<String>(
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'refresh',
                                  child: const Text('Refresh recipes'),
                                  onTap: () {
                                    setState(() {
                                      mode = 'refresh';
                                    });
                                  },
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: const Text('Delete recipes'),
                                  onTap: () {
                                    setState(() {
                                      mode = 'delete';
                                    });
                                  },
                                ),
                              ],
                              icon: const Icon(Icons.more_vert_outlined),
                            ),
                    )
                  ],
                ),
                AnimatedList(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  key: _listKey,
                  initialItemCount: nonCompletedRecipes.length,
                  itemBuilder: (context, index, animation) {
                    final recipe = nonCompletedRecipes[index];
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: index != nonCompletedRecipes.length - 1
                              ? AppPading.large
                              : 0),
                      child: _builtRecipeSelectTile(
                          recipe, context, user!.uid, index),
                    );
                  },
                ),
                if (completedRecipes.isNotEmpty)
                  _buildCompletedRecipes(context, completedRecipes),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _builtRecipeSelectTile(
      Recipe recipe, BuildContext context, String uid, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [AppBoxShadow.small],
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(
                recipe.image ?? "", // replace with your image URL
                fit: BoxFit.cover,
              ),
            ),
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
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  recipe.cookingTime,
                  style: TextStyle(
                    color: Colors.black,
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
                      onPressed: mode != null
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                SlideNavigator(
                                    builder: (context, _, __) =>
                                        RecipeScreen(recipe: recipe)),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // OutlinedButton.icon(
                    //   icon: Icon(
                    //     Icons.swap_horiz,
                    //     color: AppColors.primary,
                    //   ),
                    //   label: Text('Swap',
                    //       style: TextStyle(color: AppColors.primary)),
                    //   onPressed: () {},
                    //   style: OutlinedButton.styleFrom(
                    //     side: BorderSide(color: AppColors.primary),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    // ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.favorite_border),
                          onPressed: () {},
                          color: Colors.black,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {},
                          color: AppColors.danger,
                        ),
                      ],
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
  // Row _builtRecipeSelectTile(
  //     Recipe recipe, BuildContext context, String uid, int index) {
  //   return Row(
  //     children: [
  //       if (mode != null)
  //         Checkbox(
  //             activeColor: AppColors.primary,
  //             value: selected.contains(recipe),
  //             onChanged: (value) {
  //               setState(() {
  //                 if (selected.contains(recipe)) {
  //                   selected.remove(recipe);
  //                 } else {
  //                   selected.add(recipe);
  //                 }
  //               });
  //             }),
  //       Flexible(
  //         child: Dismissible(
  //           key: Key(recipe.title),
  //           direction: DismissDirection.startToEnd,
  //           confirmDismiss: (direction) async {
  //             _removeRecipe(index: index, recipe: recipe, uid: uid);
  //             return true;
  //           },
  //           background: Container(
  //             alignment: Alignment.centerLeft,
  //             padding: const EdgeInsets.symmetric(horizontal: AppPading.medium),
  //             child: const Icon(Icons.done, color: AppColors.green),
  //           ),
  //           child: AppBox(
  //             child: DetailTile(
  //               title: recipe.title,
  //               onPressed: mode != null
  //                   ? null
  //                   : () {
  //                       Navigator.push(
  //                         context,
  //                         SlideNavigator(
  //                             builder: (context, _, __) =>
  //                                 RecipeScreen(recipe: recipe)),
  //                       );
  //                     },
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void _removeRecipe(
      {required int index, required Recipe recipe, required String uid}) async {
    UserService(uid: uid)
        .setRecipeComplete(title: recipe.title, mealPlanId: widget.mealPlanId);
    setState(() {
      completedRecipes.add(recipe); // Mark recipe as completed
      Recipe removedRecipe = nonCompletedRecipes.removeAt(index);
      // Trigger animated removal from list
      _listKey.currentState!.removeItem(
        index,
        (context, animation) => _buildRemovedTile(removedRecipe, animation),
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  // Widget for animated removal
  Widget _buildRemovedTile(Recipe recipe, Animation<double> animation) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut, // You can change this to any curve you like
    );
    return SizeTransition(
      sizeFactor: curvedAnimation,
      axisAlignment: 0.0,
      child: Opacity(
        opacity: 0,
        child: AppBox(
          child: DetailTile(
            title: recipe.title,
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

_buildCompletedRecipes(BuildContext context, List<Recipe> completedRecipes) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Completed Meals', style: TextStyle(fontSize: 20)).h4(),
      const SizedBox(height: AppPading.medium),
      ...completedRecipes.map((recipe) => Padding(
          padding: const EdgeInsets.only(bottom: AppPading.large),
          child: Opacity(
            opacity: 0.5,
            child: AppBox(
                child: DetailTile(
              title: recipe.title,
              onPressed: () {
                Navigator.push(
                  context,
                  SlideNavigator(
                      builder: (context, _, __) =>
                          RecipeScreen(recipe: recipe)),
                );
              },
            )),
          ))),
    ],
  );
}
