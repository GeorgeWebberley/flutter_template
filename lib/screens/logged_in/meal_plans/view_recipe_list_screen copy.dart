import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/recipe_screen.dart';
import 'package:flutter_firebase_template/services/chat_service.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
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
  PageController pageController = PageController();
  List<Recipe> selected = [];
  String? mode;

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
                child: mode == 'refresh'
                    ? const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                backgroundColor: selected.isEmpty
                    ? Colors.grey
                    : mode == 'refresh'
                        ? AppColors.primary
                        : AppColors.danger,
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
                              icon: Icon(Icons.close))
                          //  TextButton(
                          //     onPressed: () {
                          //       setState(() {
                          //         mode = null;
                          //         selected = [];
                          //       });
                          //     },
                          //     child: const Text('Cancel'),
                          //   )
                          : PopupMenuButton<String>(
                              // onSelected: (String result) {
                              //   // Handle the selected option
                              //   print(
                              //       result); // Or perform an action based on the selected item
                              // },
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
                                  child: Text('Delete recipes'),
                                  onTap: () {
                                    setState(() {
                                      mode = 'delete';
                                    });
                                  },
                                ),
                              ],
                              icon: Icon(Icons.more_vert_outlined),
                            ),
                    )
                  ],
                ),
                ...widget.recipes
                    .map((recipe) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppPading.large),
                          child: _builtRecipeSelectTile(recipe, context),
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _builtRecipeSelectTile(Recipe recipe, BuildContext context) {
    return Row(
      children: [
        if (mode != null)
          Checkbox(
              activeColor: AppColors.primary,
              value: selected.contains(recipe),
              onChanged: (value) {
                setState(() {
                  if (selected.contains(recipe)) {
                    selected.remove(recipe);
                  } else {
                    selected.add(recipe);
                  }
                });
              }),
        Flexible(
          child: AppBox(
              child: DetailTile(
            title: recipe.title,
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
          )),
        ),
      ],
    );
  }
}
