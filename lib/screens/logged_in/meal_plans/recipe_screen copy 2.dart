import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/message.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/ai_chat_popup.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/ingredient_tile.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_title.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  bool _isChatMinimized = true;
  List<Message> _messages = [];
  String? _threadId;

  @override
  Widget build(BuildContext context) {
    print("widget.recipe.image");
    print(widget.recipe.image);
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.backgroundGradient,
      ),
      child: Scaffold(
        floatingActionButton: AnimatedContainer(
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 300),
            width: _isChatMinimized ? 60 : 300,
            height: _isChatMinimized ? 60 : 500,
            decoration: BoxDecoration(
              color: Colors.white,
              gradient:
                  _isChatMinimized ? AppGradients.buttonPrimaryGradient : null,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: _isChatMinimized
                ? IconButton(
                    icon: const Icon(
                      Icons.chat,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isChatMinimized = false;
                      });
                    },
                  )
                : Stack(
                    children: [
                      AiChatPopup(
                        recipe: widget.recipe,
                        messages: _messages,
                        threadId: _threadId,
                        setThreadId: (threadId) {
                          setState(() {
                            _threadId = threadId;
                          });
                        },
                      ),
                      Positioned(
                        top: AppPading.extraSmall,
                        right: AppPading.extraSmall,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _isChatMinimized = true;
                            });
                          },
                        ),
                      ),
                    ],
                  )),
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
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Image.network(widget.recipe.image ?? ""),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      color: Colors.white.withOpacity(0.6),
                      padding: const EdgeInsets.all(AppPading.small),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.recipe.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ).h3(),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppPading.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AppTitle(
                    //   title: widget.recipe.title,
                    //   subtitle: "Cooking time: ${widget.recipe.cookingTime}",
                    // ),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.timer_outlined),
                              SizedBox(
                                width: AppPading.small,
                              ),
                              Text(
                                widget.recipe.cookingTime,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ).h4(),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.directions_run),
                              SizedBox(
                                width: AppPading.small,
                              ),
                              Text(
                                "${widget.recipe.calories} calories",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ).h4(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: AppPading.large,
                    ),
                    // Text("Carbohydrate: ${widget.recipe.carbohydrates} grams")
                    //     .h5(),
                    // Text("Fats: ${widget.recipe.fat} grams").h5(),
                    // Text("Protein: ${widget.recipe.protein} grams").h5(),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     // SizedBox(
                    //     //   width: 250,
                    //     //   child: Image.asset("assets/images/food_example.png"),
                    //     // ),
                    //     SizedBox(
                    //       width: 350,
                    //       child: Image.network(widget.recipe.image ?? ""),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(
                      height: AppPading.large,
                    ),
                    AppBox(
                      child: Padding(
                        padding: const EdgeInsets.all(AppPading.page),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Ingredients").h4(),
                            const SizedBox(
                              height: AppPading.large,
                            ),
                            ...widget.recipe.ingredients
                                .map(
                                  (ingredient) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppPading.medium),
                                    child: IngredientTile(
                                      ingredient: ingredient,
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: AppPading.page,
                    ),
                    AppBox(
                      child: Padding(
                        padding: const EdgeInsets.all(AppPading.page),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Recipe").h4(),
                            const SizedBox(
                              height: AppPading.large,
                            ),
                            ...widget.recipe.instructions
                                .map(
                                  (ingredient) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppPading.medium),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('•').h5(),
                                        const SizedBox(width: AppPading.medium),
                                        Expanded(
                                          child: Text(
                                            ingredient,
                                            style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.8)),
                                          ).h5(),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
