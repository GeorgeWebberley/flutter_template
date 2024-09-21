import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/dietary_preference/dietary_preference.dart';
import 'package:flutter_firebase_template/models/meal_plan_configuration.dart';
import 'package:flutter_firebase_template/models/message.dart';
import 'package:flutter_firebase_template/models/recipe_stub.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/typing_indicator.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/typing_input.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/meal_plan_root.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/recipe_expandable_tile.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/recipe_screen.dart';
import 'package:flutter_firebase_template/services/chat_service.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_checkbox.dart';
import 'package:flutter_firebase_template/shared/app_dialog.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/fade_navigator.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/shared/number_input.dart';
import 'package:flutter_firebase_template/state/chat_state.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:provider/provider.dart';

enum ConversationType { chat, mealPlan }

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({
    super.key,
    required this.changeNavigationIndex,
  });

  final void Function(int) changeNavigationIndex;

  @override
  _AiChatScreenState createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  AppUser? user;

  @override
  void initState() {
    super.initState();
    // Send initial welcome message
    _addWelcomeMessage();
  }

  Future<void> _addWelcomeMessage() async {
    // Get a random message from the welcome messages list
    ChatState chatState = Provider.of<ChatState>(context, listen: false);

    final Message aiMessage = Message(
        role: 'system',
        textResponse: chatState.welcomeMessages[
            DateTime.now().millisecond % chatState.welcomeMessages.length],
        responseType: 'text');

    AnimationController aiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    setState(() {
      chatState.messages.insert(0, aiMessage);
      chatState.animationControllers.insert(0, aiAnimationController);
    });

    aiAnimationController.forward();
  }

  @override
  void dispose() {
    for (var controller in Provider.of<ChatState>(context, listen: false)
        .animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AppUser?>(context);

    return Consumer<ChatState>(builder: (context, chatState, _) {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(10),
              itemCount: chatState.messages.length +
                  1, // Include placeholder or typing indicator
              itemBuilder: (context, index) {
                if (chatState.isTyping && index == 0) {
                  return _buildTypingIndicator();
                } else if (!chatState.isTyping && index == 0) {
                  return _buildPlaceholder();
                }

                final message = chatState
                    .messages[chatState.isTyping ? index - 1 : index - 1];
                return _buildAnimatedMessage(
                    message,
                    chatState.animationControllers[
                        chatState.isTyping ? index - 1 : index - 1]);
              },
            ),
          ),
          if (chatState.conversationType == ConversationType.chat)
            _buildMessageInput(),
        ],
      );
    });
  }

  Widget _buildConversationTypeSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            child: AppButton(
          onPressed: () async {
            _addMessage(Message(
                role: 'user',
                textResponse: "Create Meals",
                responseType: 'text'));

            setState(() {
              conversationType = ConversationType.mealPlan;
              _isTyping = true;
            });

            Future.delayed(const Duration(milliseconds: 2000), () {
              setState(() {
                _isTyping = false;
              });
              _addMessage(Message(
                  role: 'system',
                  textResponse: _mealPlanResponses[
                      DateTime.now().millisecond % _mealPlanResponses.length],
                  responseType: 'text'));
            });
          },
          text: "Create Meals",
          size: ButtonSize.small,
        )),
        const SizedBox(width: 20),
        Expanded(
            child: AppButton(
          backgroundGradient: AppGradients.greenGradient,
          onPressed: () {
            _addMessage(Message(
                role: 'user',
                textResponse: "Food Assistant",
                responseType: 'text'));
            setState(() {
              conversationType = ConversationType.chat;
              _isTyping = true;
            });

            Future.delayed(const Duration(milliseconds: 2000), () {
              setState(() {
                _isTyping = false;
              });
              _addMessage(Message(
                  role: 'system',
                  textResponse: _foodAssistantWelcome[
                      DateTime.now().millisecond % _welcomeMessages.length],
                  responseType: 'text'));
            });
          },
          text: "Food Assistant",
          size: ButtonSize.small,
        )),
      ],
    );
  }

  Widget _buildMealPlanInput() {
    return Padding(
      padding: const EdgeInsets.all(AppPading.large),
      child: AppBox(
        child: Padding(
          padding: const EdgeInsets.all(AppPading.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(),
              NumberInput(
                label: "Breakfasts",
                onChanged: (value) {
                  setState(() {
                    numberOfBreakfasts = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppPading.large),
                child: Divider(
                  height: 0,
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
              NumberInput(
                label: "Lunches",
                onChanged: (value) {
                  setState(() {
                    numberOfLunches = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppPading.large),
                child: Divider(
                  height: 0,
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
              NumberInput(
                label: "Dinners",
                onChanged: (value) {
                  setState(() {
                    numberOfDinners = value;
                  });
                },
              ),
              const SizedBox(
                height: AppPading.large * 2,
              ),
              AppButton(
                  onPressed: numberOfBreakfasts == 0 &&
                          numberOfLunches == 0 &&
                          numberOfDinners == 0
                      ? null
                      : () async {
                          String message = "";

                          if (numberOfBreakfasts > 0) {
                            message += "• $numberOfBreakfasts Breakfasts\n";
                          }
                          if (numberOfLunches > 0) {
                            message += "• $numberOfLunches Lunches\n";
                          }
                          if (numberOfDinners > 0) {
                            message += "• $numberOfDinners Dinners";
                          }

                          _addMessage(Message(
                              role: "user",
                              responseType: "text",
                              textResponse: message.trim()));
                          setState(() {
                            specifiedNumberOfMeals = true;
                            _isTyping = true;
                          });

                          UserData? userData =
                              await UserService(uid: user!.uid).getUserData();

                          Future.delayed(const Duration(milliseconds: 1000),
                              () {
                            setState(() {
                              _isTyping = false;
                              dietaryPreferences =
                                  userData?.dietaryPreferences ?? [];
                            });
                            _addMessage(Message(
                                role: 'system',
                                textResponse: _dietaryPreferencesMessages[
                                    DateTime.now().millisecond %
                                        _dietaryPreferencesMessages.length],
                                responseType: 'text'));
                          });
                        },
                  text: "Save")
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeopleInput() {
    return Padding(
      padding: const EdgeInsets.all(AppPading.large),
      child: AppBox(
        child: Padding(
          padding: const EdgeInsets.all(AppPading.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(),
              NumberInput(
                label: "People",
                minValue: 1,
                onChanged: (value) {
                  setState(() {
                    numberOfPeople = value;
                  });
                },
              ),
              const SizedBox(
                height: AppPading.large * 2,
              ),
              AppButton(
                  onPressed: () async {
                    setState(() {
                      _isTyping = true;
                      specifiedNumberOfPeople = true;
                      numberOfPeople ??= 1;
                    });
                    _addMessage(Message(
                        role: "user",
                        responseType: "text",
                        textResponse:
                            "$numberOfPeople ${numberOfPeople == 1 ? "person" : "people"}"));
                    await Future.delayed(const Duration(milliseconds: 300));
                    _addMessage(Message(
                        role: 'system',
                        textResponse:
                            "I'll create some recommendations for you, and you can tell me your favourites.",
                        responseType: 'text'));

                    List<RecipeStub> recipes =
                        await _chatService.getRecipeStubs(
                            numberOfPeople: numberOfPeople!,
                            breakfasts: (numberOfBreakfasts * 1.5).ceil(),
                            lunches: (numberOfLunches * 1.5).ceil(),
                            dinners: (numberOfDinners * 1.5).ceil(),
                            snacks: 0,
                            dietaryPreferences: dietaryPreferences!
                                .map((preference) => preference.preference)
                                .toList());

                    setState(() {
                      _isTyping = false;
                      recipeStubs = recipes;
                    });

                    _addMessage(Message(
                        role: 'system',
                        textResponse:
                            "Here are your suggestions! Select the ones you think sound good and I'll add them to your plan.",
                        responseType: 'text'));

                    // Future.delayed(const Duration(milliseconds: 2000), () {
                    //   _addMessage(Message(
                    //       role: 'system',
                    //       textResponse:
                    //           "Perfect! Are you ready for me to start preparing? It can take around a minute or so, buy you are free to close your app and come back later :)",
                    //       responseType: 'text'));

                    //   _addMessage(Message(
                    //       role: 'system',
                    //       textResponse:
                    //           "Perfect! Are you ready for me to start preparing? It can take around a minute or so, buy you are free to close your app and come back later :)",
                    //       responseType: 'text'));
                    // });
                  },
                  text: "Save")
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDietaryPreferencesChat() {
    return Padding(
      padding: const EdgeInsets.all(AppPading.large),
      child: AppBox(
        child: Padding(
          padding: const EdgeInsets.all(AppPading.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(),
              ...dietaryPreferences!
                  .map((preference) => Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  preference.preference,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ).h5(),
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      dietaryPreferences?.remove(preference);
                                    });
                                  },
                                  icon: Icon(Icons.delete,
                                      color: AppColors.danger)),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: AppPading.large,
                                bottom: (preference == dietaryPreferences!.last)
                                    ? 0
                                    : AppPading.large),
                            child: preference != dietaryPreferences!.last
                                ? Divider(
                                    height: 0,
                                    color: Colors.black.withOpacity(0.1),
                                  )
                                : Container(),
                          ),
                        ],
                      ))
                  .toList(),
              TextButton(
                onPressed: () {
                  addPreferenceDialog(context);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Add",
                      style: TextStyle(color: AppColors.primary),
                    ),
                    SizedBox(
                      width: AppPading.small,
                    ),
                    Icon(
                      Icons.add,
                      color: AppColors.primary,
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: AppPading.large,
              ),
              AppButton(
                  onPressed: () async {
                    String message = "";

                    if (dietaryPreferences == null ||
                        dietaryPreferences!.isEmpty) {
                      message = "No dietary preferences";
                    } else {
                      for (DietaryPreference preference
                          in dietaryPreferences!) {
                        message += "• ${preference.preference}";
                        if (preference != dietaryPreferences!.last &&
                            dietaryPreferences!.length > 1) {
                          message += "\n";
                        }
                      }
                    }

                    _addMessage(Message(
                        role: "user",
                        responseType: "text",
                        textResponse: message.trim()));
                    setState(() {
                      _isTyping = true;
                      specifiedDietaryPreferences = true;
                    });

                    await UserService(uid: user!.uid).updateUserData(
                        key: "dietaryPreferences",
                        value: dietaryPreferences
                            ?.map(
                              (e) => e.toJson(),
                            )
                            .toList());

                    Future.delayed(const Duration(milliseconds: 1000), () {
                      setState(() {
                        _isTyping = false;
                      });
                      _addMessage(Message(
                          role: 'system',
                          textResponse:
                              "Thanks! Now lastly, how many people will you be needing food for?",
                          responseType: 'text'));
                    });
                  },
                  text: "Save")
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectRecipes() {
    if (recipeStubs == null) {
      // TODO: Something better
      return const Text("Something went wrong");
    }

    List<RecipeStub> breakfastRecipes =
        recipeStubs!.where((recipe) => recipe.mealType == "breakfast").toList();
    List<RecipeStub> lunchRecipes =
        recipeStubs!.where((recipe) => recipe.mealType == "lunch").toList();
    List<RecipeStub> dinnerRecipes =
        recipeStubs!.where((recipe) => recipe.mealType == "dinner").toList();
    // List<RecipeStub> snackRecipes =
    //     recipeStubs!.where((recipe) => recipe.mealType == "snack").toList();

    return Padding(
      padding: const EdgeInsets.all(AppPading.large),
      child: AppBox(
        child: Padding(
          padding: const EdgeInsets.all(AppPading.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(),
              if (breakfastRecipes.isNotEmpty)
                RecipeExpandableTile(
                  mealType: "Breakfast",
                  recipes: breakfastRecipes,
                  onChanged: ((recipes) => selectedBreakfastRecipes = recipes),
                ),
              if (lunchRecipes.isNotEmpty)
                RecipeExpandableTile(
                  mealType: "Lunch",
                  recipes: lunchRecipes,
                  onChanged: ((recipes) => selectedLunchRecipes = recipes),
                ),
              if (dinnerRecipes.isNotEmpty)
                RecipeExpandableTile(
                  mealType: "Dinner",
                  recipes: dinnerRecipes,
                  onChanged: ((recipes) => selectedDinnerRecipes = recipes),
                ),
              const SizedBox(
                height: AppPading.large,
              ),
              AppButton(
                  onPressed: () async {
                    if (selectedBreakfastRecipes.length < numberOfBreakfasts ||
                        selectedLunchRecipes.length < numberOfLunches ||
                        selectedDinnerRecipes.length < numberOfDinners) {
                      showDialog(
                        context: context,
                        builder: (context) => AppDialog(
                          buttonText: "Continue",
                          cancelButtonText: "Go back",
                          onCancel: () {
                            Navigator.pop(context);
                          },
                          title: "You selected...",
                          content: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      "${selectedBreakfastRecipes.length} breakfast${selectedBreakfastRecipes.length == 1 ? "" : "s"}\n",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text:
                                      "${selectedLunchRecipes.length} lunch${selectedLunchRecipes.length == 1 ? "" : "es"}\n",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text:
                                      "${selectedDinnerRecipes.length} dinner${selectedDinnerRecipes.length == 1 ? "" : "s"}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          onSave: () {
                            _makeMealPlan();
                            Navigator.pop(context);
                          },
                        ),
                      );
                    } else {
                      _makeMealPlan();
                    }
                  },
                  text: "Save")
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makeMealPlan() async {
    String planId =
        await UserService(uid: user!.uid).addMealPlan(MealPlanConfiguration(
      breakfasts: selectedBreakfastRecipes.length,
      lunches: selectedLunchRecipes.length,
      dinners: selectedDinnerRecipes.length,
      numberOfPeople: numberOfPeople!,
      dietaryPreferences: dietaryPreferences!
          .map((preference) => preference.preference)
          .toList(),
    ));

    _chatService.createMealPlan(
        mealPlanId: planId,
        breakfasts: selectedBreakfastRecipes.map((e) => e.title).toList(),
        lunches: selectedLunchRecipes.map((e) => e.title).toList(),
        dinners: selectedDinnerRecipes.map((e) => e.title).toList(),
        numberOfPeople: numberOfPeople ?? 1,
        dietaryPreferences: dietaryPreferences!
            .map((preference) => preference.preference)
            .toList());
    widget.changeNavigationIndex(0);
    Navigator.push(
      context,
      FadeNavigator(
          builder: (context, _, __) => MealPlanRoot(
                mealPlanId: planId,
              )),
    );
  }

  Widget _buildSubmitButton() {
    return AppButton(
      onPressed: () async {
        String planId =
            await UserService(uid: user!.uid).addMealPlan(MealPlanConfiguration(
          breakfasts: numberOfBreakfasts,
          lunches: numberOfLunches,
          dinners: numberOfDinners,
          numberOfPeople: numberOfPeople!,
          dietaryPreferences: dietaryPreferences!
              .map((preference) => preference.preference)
              .toList(),
        ));

        String message =
            """Please create recipes for $numberOfBreakfasts breakfasts, $numberOfLunches lunches and $numberOfDinners dinners for $numberOfPeople people. It is important you follow these dietary preferences: 
        ${dietaryPreferences!.map((preference) => preference.preference).toList().join(", ")}""";

        _chatService.sendMessage(message,
            mealPlanId: planId, isNewConversation: isNewConversation);

        Navigator.push(
          context,
          FadeNavigator(
              builder: (context, _, __) => MealPlanRoot(
                    mealPlanId: planId,
                  )),
        );
      },
      text: "Submit",
    );
  }

  Widget _buildTypingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: TypingIndicator(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: conversationType == null
          ? _buildConversationTypeSelector()
          : conversationType == ConversationType.mealPlan &&
                  specifiedNumberOfMeals == false
              ? _buildMealPlanInput()
              : conversationType == ConversationType.mealPlan &&
                      specifiedDietaryPreferences == false
                  ? _buildDietaryPreferencesChat()
                  : conversationType == ConversationType.mealPlan &&
                          specifiedNumberOfPeople == false
                      ? _buildPeopleInput()
                      : conversationType == ConversationType.mealPlan &&
                              selectedRecipeTitles == false
                          ? _buildSelectRecipes()
                          : conversationType == ConversationType.mealPlan &&
                                  submitted == false
                              ? _buildSubmitButton()
                              : Container(),
    );
  }

  void addPreferenceDialog(BuildContext context) {
    String? preference;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, dialogSetState) {
          return AppDialog(
              content: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      autocorrect: false,
                      decoration: textInputDecoration.copyWith(
                        errorStyle: const TextStyle(color: Colors.white),
                      ),
                      validator: (value) => value == null || value.length == 0
                          ? 'Enter preference'
                          : null,
                      onChanged: (value) {
                        dialogSetState(() {
                          preference = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              title: "Enter a new preference",
              onSave: () async {
                if (formKey.currentState!.validate() && preference != null) {
                  try {
                    await UserService(uid: user!.uid).updateUserData(
                        key: 'dietaryPreferences',
                        value: FieldValue.arrayUnion([
                          {"preference": preference, "activated": true}
                        ]));
                    setState(() {
                      dietaryPreferences
                          ?.add(DietaryPreference(preference: preference!));
                    });
                    Navigator.pop(context);
                  } catch (error) {
                    showToast(
                        context: context,
                        message: "Error adding preference",
                        color: AppColors.danger);
                  }
                }
              });
        });
      },
    );
  }

  Widget _buildAnimatedMessage(
      Message message, AnimationController animationController) {
    Animation<double> scaleAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack,
    );

    bool isUserMessage = message.role == 'user';

    return ScaleTransition(
      scale: scaleAnimation,
      child: Align(
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(
              right: isUserMessage ? 0 : 20.0, left: isUserMessage ? 20.0 : 0),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isUserMessage
                  ? const LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent])
                  : const LinearGradient(
                      colors: [Colors.green, Colors.lightGreen]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _buildMessageContent(message), // Ensure this is not empty
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(Message message) {
    if (message.responseType == 'text') {
      return Text(
        message.textResponse ?? '',
        style: const TextStyle(color: Colors.white),
      );
    } else if (message.responseType == 'recipe' && message.recipes != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: message.recipes!
            .map((recipe) => Column(
                  children: [
                    Text(
                      "Here is a recipe for a delicious ${recipe.title}. I hope you like it!",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: AppPading.large),
                    AppButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            SlideNavigator(
                                builder: (context, _, __) => RecipeScreen(
                                      recipe: recipe,
                                    )));
                      },
                      text: recipe.title,
                    ),
                  ],
                ))
            .toList(),
        // [
        //   Text(
        //     "Here is a recipe for a delicious ${message.recipe!.title}. I hope you like it!",
        //     style: const TextStyle(color: Colors.white),
        //   ),
        //   const SizedBox(height: AppPading.large),
        //   AppButton(
        //     onPressed: () {
        //       Navigator.push(
        //           context,
        //           SlideNavigator(
        //               builder: (context, _, __) => RecipeScreen(
        //                     recipe: message.recipe!,
        //                   )));
        //     },
        //     text: message.recipe?.title ?? 'Recipe',
        //   ),
        // ],
      );
    } else {
      return Container(); // If there's no content, return an empty container
    }
  }

  Widget _buildMessageInput() {
    return TypingInput(sendMessage: _sendMessage);
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    _addMessage(
        Message(role: 'user', textResponse: text, responseType: 'text'));

    _showTypingIndicator(); // Show typing indicator

    try {
      // Call the ChatService to send the message and get the AI response
      final Message? aiMessage = await _chatService.sendMessage(text,
          isNewConversation: isNewConversation);

      if (aiMessage != null) {
        _addMessage(aiMessage);
      }
    } catch (e) {
      setState(() {
        final errorMessage = Message(
            role: 'system',
            textResponse: 'Error: Could not get AI response.',
            responseType: 'text');
        _messages.insert(0, errorMessage);
        _animationControllers.insert(
            0,
            AnimationController(
              duration: const Duration(milliseconds: 300),
              vsync: this,
            ));
      });
    } finally {
      setState(() {
        isNewConversation = false;
        _isTyping = false;
      });
    }
  }

  void _addMessage(Message message) {
    AnimationController aiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    setState(() {
      _messages.insert(0, message);
      _animationControllers.insert(0, aiAnimationController);
    });

    aiAnimationController.forward();
  }

  void _showTypingIndicator() {
    setState(() {
      _isTyping = true;
    });
  }
}
