import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/message.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/ai_chat_popup.dart';
import 'package:flutter_firebase_template/screens/logged_in/subscription/subscription_screen.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/state/app_state.dart';
import 'package:flutter_firebase_template/widgets/meal_plan_display/ingredient_tile.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:provider/provider.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({
    super.key,
    required this.recipe,
  });

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
    return StreamBuilder<UserData>(
        stream:
            UserService(uid: Provider.of<AppUser?>(context, listen: false)?.uid)
                .userDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (snapshot.hasData) {
            UserData? userData = snapshot.data;

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
                      gradient: _isChatMinimized
                          ? AppGradients.buttonPrimaryGradient
                          : null,
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
                              AppState appState =
                                  Provider.of<AppState>(context, listen: false);
                              if (userData == null ||
                                  (userData.isSubscribed != true &&
                                      (userData.freeTrialCredits ?? 0) >
                                          appState.freeTrialCreditCap)) {
                                Navigator.push(
                                  context,
                                  SlideNavigator(
                                    builder: (context, _, __) =>
                                        SubscriptionScreen(
                                      userData: userData!,
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  _isChatMinimized = false;
                                });
                              }
                            },
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: AppBorderRadius.small,
                                child: AiChatPopup(
                                  userData: userData!,
                                  recipe: widget.recipe,
                                  messages: _messages,
                                  threadId: _threadId,
                                  setThreadId: (threadId) {
                                    setState(() {
                                      _threadId = threadId;
                                    });
                                  },
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                left: 0,
                                // right: AppPading.extraSmall,
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient:
                                          AppGradients.buttonPrimaryGradient,
                                      borderRadius: BorderRadius.only(
                                        topLeft: AppBorderRadius.small.topLeft,
                                        topRight:
                                            AppBorderRadius.small.topRight,
                                      )),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: 35,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isChatMinimized = true;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: widget.recipe.image == null
                          ? Colors.black
                          : Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    iconSize: 24,
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                extendBodyBehindAppBar: true,
                body: GestureDetector(
                  onTap: () {
                    // If keyboard is open and chat is not minimized, remove focus
                    if (MediaQuery.of(context).viewInsets.bottom != 0) {
                      FocusScope.of(context).unfocus();
                    } else if (!_isChatMinimized) {
                      // If chat is open and not minimized, minimize it
                      setState(() {
                        _isChatMinimized = true;
                      });
                    }
                  },
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            if (widget.recipe.image != null)
                              Stack(
                                children: [
                                  Image.network(widget.recipe.image!),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Container(
                                      color: Colors.white.withOpacity(0.8),
                                      padding: const EdgeInsets.all(
                                          AppPading.extraSmall),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              widget.recipe.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ).h3(),
                                          ),
                                          // if (widget.addFavourite != null)
                                          //   IconButton(
                                          //     onPressed: () {
                                          //       widget.addFavourite!();
                                          //       // Add to favourites
                                          //     },
                                          //     icon: Icon(
                                          //       Icons.favorite_border,
                                          //       size: 30,
                                          //     ),
                                          //   ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                            else
                              SafeArea(
                                bottom: false,
                                child: Text(
                                  widget.recipe.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).h3(),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(AppPading.page),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.timer_outlined),
                                            const SizedBox(
                                              width: AppPading.small,
                                            ),
                                            Flexible(
                                              child: Text(
                                                widget.recipe.cookingTime,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ).h5(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.directions_run),
                                            const SizedBox(
                                              width: AppPading.small,
                                            ),
                                            Text(
                                              "${widget.recipe.calories} calories",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ).h5(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
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
                                  const SizedBox(
                                    height: AppPading.large,
                                  ),
                                  AppBox(
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              AppPading.page),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text("Ingredients").h4(),
                                              const SizedBox(
                                                height: AppPading.large,
                                              ),
                                              ...widget.recipe.ingredients
                                                  .map(
                                                    (ingredient) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: AppPading
                                                                  .medium),
                                                      child: IngredientTile(
                                                        ingredient: ingredient,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: AppPading.small,
                                          right: AppPading.small,
                                          child: IconButton(
                                            onPressed: () {
                                              showNutritionalInfo(
                                                  widget.recipe);
                                            },
                                            icon: Icon(Icons.info),
                                            color: AppColors.primary,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppPading.page,
                                  ),
                                  AppBox(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(AppPading.page),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Recipe").h4(),
                                          const SizedBox(
                                            height: AppPading.large,
                                          ),
                                          ...widget.recipe.instructions
                                              .map(
                                                (ingredient) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom:
                                                              AppPading.medium),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text('•').h5(),
                                                      const SizedBox(
                                                          width:
                                                              AppPading.medium),
                                                      Expanded(
                                                        child: Text(
                                                          ingredient,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.8)),
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
                      if (!_isChatMinimized)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.4),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }
        });
  }

  void showNutritionalInfo(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GestureDetector(
        onVerticalDragUpdate: (details) {
          // If dragging down, close the keyboard
          if (details.primaryDelta! > 0) {
            Navigator.pop(context);
          }
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  "Nutritional Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),

                // Nutritional Details with Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (recipe.calories != null)
                      _buildNutrientInfo(Icons.local_fire_department,
                          "Calories", recipe.calories, "kcal"),
                    if (recipe.protein != null)
                      _buildNutrientInfo(
                          Icons.fitness_center, "Protein", recipe.protein, "g"),
                    if (recipe.carbohydrates != null)
                      _buildNutrientInfo(
                          Icons.rice_bowl, "Carbs", recipe.carbohydrates, "g"),
                    if (recipe.fat != null)
                      _buildNutrientInfo(
                          Icons.water_drop, "Fat", recipe.fat, "g"),
                  ],
                ),
                // Close Button
                // ElevatedButton(
                //   onPressed: () => Navigator.pop(context),
                //   child: Text("Close"),
                //   style: ElevatedButton.styleFrom(
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
    // showModalBottomSheet(
    //     context: context,
    //     builder: (context) => Container(
    //           decoration: BoxDecoration(
    //             color: Colors.white,
    //             borderRadius: AppBorderRadius.medium,
    //           ),

    //         ));
  }

  // Helper Widget to Build Each Nutrient Block
  Widget _buildNutrientInfo(
      IconData icon, String label, int? value, String unit) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blueAccent),
        SizedBox(height: 8),
        Text(
          '$value $unit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
