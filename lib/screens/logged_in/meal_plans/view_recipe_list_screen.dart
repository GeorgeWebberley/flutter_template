import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/recipe_screen.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/detail_tile.dart';

class ViewRecipeListScreen extends StatefulWidget {
  const ViewRecipeListScreen({
    super.key,
    required this.recipes,
    required this.title,
  });

  final List<Recipe> recipes;
  final String title;

  @override
  State<ViewRecipeListScreen> createState() => _ViewRecipeListScreenState();
}

class _ViewRecipeListScreenState extends State<ViewRecipeListScreen> {
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
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
        body: Padding(
          padding: const EdgeInsets.all(AppPading.page),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTitle(title: widget.title),
              ...widget.recipes
                  .map((recipe) => Padding(
                        padding: const EdgeInsets.only(bottom: AppPading.large),
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
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
