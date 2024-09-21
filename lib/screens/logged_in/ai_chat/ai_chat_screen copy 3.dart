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
  final ChatService _chatService = ChatService();

  final List<String> _mealPlanResponses = [
    "Great! Now could you tell me how many meals would you like to create?",
    "Awesome! Next, how many meals would you like to prepare?",
    "Fantastic! How many meals are you thinking of creating?",
    "Perfect! How many meals would you like to make?",
    "Excellent! How many meals should we plan for?"
  ];

  final List<String> _welcomeMessages = [
    "Hi there! Chef Michael at your service for all things culinary. Would you like to create a meal plan, or do you have any food-related questions? How can I assist today?",
    "Greetings! Chef Michael here, ready to help with all your cooking needs. Are you looking to craft a meal plan, or do you have some food questions I can answer?",
    "Hello! Chef Michael checking in to assist with your culinary adventures. Need help with a meal plan, or do you have some general food inquiries?",
    "Hi! It's Chef Michael, here to support you with your cooking and meal planning. What can I help you with today? Ready to create a meal plan, or do you have some food questions?",
    "Hey there! Chef Michael here, ready to lend a hand with anything culinary. Would you like to start on a meal plan, or do you have any food questions I can answer?"
  ];

  final List<String> _foodAssistantWelcome = [
    "Great! Feel free to ask me any questions about food or diets. I can also create an individual meal for you, complete with a recipe and ingredients list tailored to your preferences. Just let me know what you need!",
    "Awesome! You can ask me anything about food or diets right here. I’m also happy to create an individual meal for you, including a recipe and ingredients list based on what you like. Just ask away!",
    "Cool! I’m here to answer any food or diet questions you have. If you’d like, I can also create an individual meal for you, complete with a recipe and ingredients list to match your preferences. Just tell me what you need!",
    "Fantastic! Ask me any food or diet questions you’ve got. I can also help by creating an individual meal, along with the recipe and ingredients you’ll need based on your tastes. Just ask!",
    "Great! You can ask me anything related to food or diets. Plus, I can create an individual meal for you, with a recipe and ingredients list tailored to your preferences. Just let me know what you’re looking for!"
  ];

  final List<String> _dietaryPreferencesMessages = [
    "Great! Before I finalise your plan, is there anything else you’d like to add? Feel free to be as detailed as you like - preferred cooking methods, portion sizes, low-carb options, or anything else that’s on your mind!",
    "Awesome! Is there anything you’d like to specify about your meals? Don’t hesitate to be specific - ingredient preferences, dietary requirements, spice levels, family-friendly recipes, or any other preferences you have!",
    "Fantastic! Is there anything you'd like to include in your meals? You can get as detailed as you want - dietary requirements, prep time limits, favorite cuisines, dairy-free options, or anything else!",
    "Perfect! Before I build your plan, is there anything you’d like to share that can help me create your meals? Feel free to go into as much detail as you’d like - dietary requirements,  preferred cooking tools , or anything else you’re thinking of!",
    "Excellent! Is there anything else you’d like to add that will help me create meals perfect for you? You can be as detailed as you want - dietary requirements, specific ingredients to include or avoid, quick weekday dinners, or any other preferences you have in mind!",
  ];

  @override
  void initState() {
    super.initState();
    // Send initial welcome message
    _addWelcomeMessage();
  }

  Future<void> _addWelcomeMessage() async {
    // Get a random message from the welcome messages list
    ChatState chatState = Provider.of<ChatState>(context, listen: false);

    if (chatState.messages.isEmpty) {
      chatState.addMessage(
          Message(
              role: 'system',
              textResponse: _welcomeMessages[
                  DateTime.now().millisecond % _welcomeMessages.length],
              responseType: 'text'),
          this);
    }
  }

  // @override
  // void dispose() {
  //   for (var controller in Provider.of<ChatState>(context, listen: false)
  //       .animationControllers) {
  //     controller.dispose();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AppUser?>(context);

    return Consumer<ChatState>(builder: (context, chatState, child) {
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
                  return _buildPlaceholder(chatState);
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
            _buildMessageInput(chatState),
        ],
      );
    });
  }

  Widget _buildConversationTypeSelector(ChatState chatState) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            child: AppButton(
          onPressed: () async {
            // We don't notify listeners here, since they will be notified when the message is added
            chatState.setConversationType(ConversationType.mealPlan);
            chatState.setTyping(true);

            chatState.addMessage(
                Message(
                    role: 'user',
                    textResponse: "Create Meals",
                    responseType: 'text'),
                this);

            Future.delayed(const Duration(milliseconds: 2000), () {
              // We don't notify listeners here, since they will be notified when the message is added
              chatState.setTyping(false);
              chatState.addMessage(
                  Message(
                      role: 'system',
                      textResponse: _mealPlanResponses[
                          DateTime.now().millisecond %
                              _mealPlanResponses.length],
                      responseType: 'text'),
                  this);
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
            // We don't notify listeners here, since they will be notified when the message is added
            chatState.setConversationType(ConversationType.chat);
            chatState.setTyping(true);
            chatState.addMessage(
                Message(
                    role: 'user',
                    textResponse: "Food Assistant",
                    responseType: 'text'),
                this);

            Future.delayed(const Duration(milliseconds: 2000), () {
              chatState.setTyping(false);

              chatState.addMessage(
                  Message(
                      role: 'system',
                      textResponse: _foodAssistantWelcome[
                          DateTime.now().millisecond % _welcomeMessages.length],
                      responseType: 'text'),
                  this);
            });
          },
          text: "Food Assistant",
          size: ButtonSize.small,
        )),
      ],
    );
  }

  Widget _buildMealPlanInput(ChatState chatState) {
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
                    chatState.numberOfBreakfasts = value;
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
                    chatState.numberOfLunches = value;
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
                    chatState.numberOfDinners = value;
                  });
                },
              ),
              const SizedBox(
                height: AppPading.large * 2,
              ),
              AppButton(
                  onPressed: chatState.numberOfBreakfasts == 0 &&
                          chatState.numberOfLunches == 0 &&
                          chatState.numberOfDinners == 0
                      ? null
                      : () async {
                          String message = "";

                          if (chatState.numberOfBreakfasts > 0) {
                            message +=
                                "• ${chatState.numberOfBreakfasts} Breakfasts\n";
                          }
                          if (chatState.numberOfLunches > 0) {
                            message +=
                                "• ${chatState.numberOfLunches} Lunches\n";
                          }
                          if (chatState.numberOfDinners > 0) {
                            message += "• ${chatState.numberOfDinners} Dinners";
                          }

                          chatState.setTyping(true);
                          chatState.addMessage(
                              Message(
                                  role: "user",
                                  responseType: "text",
                                  textResponse: message.trim()),
                              this);

                          setState(() {
                            chatState.specifiedNumberOfMeals = true;
                          });

                          UserData? userData =
                              await UserService(uid: user!.uid).getUserData();

                          Future.delayed(const Duration(milliseconds: 1000),
                              () {
                            chatState.setTyping(false);

                            setState(() {
                              chatState.dietaryPreferences =
                                  userData?.dietaryPreferences ?? [];
                            });
                            chatState.addMessage(
                                Message(
                                    role: 'system',
                                    textResponse: _dietaryPreferencesMessages[
                                        DateTime.now().millisecond %
                                            _dietaryPreferencesMessages.length],
                                    responseType: 'text'),
                                this);
                          });
                        },
                  text: "Save")
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeopleInput(ChatState chatState) {
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
                    chatState.numberOfPeople = value;
                  });
                },
              ),
              const SizedBox(
                height: AppPading.large * 2,
              ),
              AppButton(
                  onPressed: () async {
                    chatState.setTyping(true);
                    setState(() {
                      chatState.specifiedNumberOfPeople = true;
                      chatState.numberOfPeople ??= 1;
                    });
                    chatState.addMessage(
                        Message(
                            role: "user",
                            responseType: "text",
                            textResponse:
                                "${chatState.numberOfPeople} ${chatState.numberOfPeople == 1 ? "person" : "people"}"),
                        this);
                    await Future.delayed(const Duration(milliseconds: 300));

                    chatState.addMessage(
                        Message(
                            role: 'system',
                            textResponse:
                                "I'll create some recommendations for you, and you can tell me your favourites.",
                            responseType: 'text'),
                        this);

                    List<RecipeStub> recipes =
                        await _chatService.getRecipeStubs(
                            numberOfPeople: chatState.numberOfPeople!,
                            breakfasts:
                                (chatState.numberOfBreakfasts * 1.5).ceil(),
                            lunches: (chatState.numberOfLunches * 1.5).ceil(),
                            dinners: (chatState.numberOfDinners * 1.5).ceil(),
                            snacks: 0,
                            dietaryPreferences: chatState.dietaryPreferences!
                                .map((preference) => preference.preference)
                                .toList());

                    chatState.setTyping(false);

                    chatState.recipeStubs = recipes;

                    chatState.addMessage(
                        Message(
                            role: 'system',
                            textResponse:
                                "Here are your suggestions! Select the ones you think sound good and I'll add them to your plan.",
                            responseType: 'text'),
                        this);
                  },
                  text: "Save")
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDietaryPreferencesChat(ChatState chatState) {
    return Padding(
      padding: const EdgeInsets.all(AppPading.large),
      child: AppBox(
        child: Padding(
          padding: const EdgeInsets.all(AppPading.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(),
              ...chatState.dietaryPreferences!
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
                                      chatState.dietaryPreferences
                                          ?.remove(preference);
                                    });
                                  },
                                  icon: Icon(Icons.delete,
                                      color: AppColors.danger)),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: AppPading.large,
                                bottom: (preference ==
                                        chatState.dietaryPreferences!.last)
                                    ? 0
                                    : AppPading.large),
                            child:
                                preference != chatState.dietaryPreferences!.last
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
                  addPreferenceDialog(context, chatState);
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

                    if (chatState.dietaryPreferences == null ||
                        chatState.dietaryPreferences!.isEmpty) {
                      message = "No dietary preferences";
                    } else {
                      for (DietaryPreference preference
                          in chatState.dietaryPreferences!) {
                        message += "• ${preference.preference}";
                        if (preference != chatState.dietaryPreferences!.last &&
                            chatState.dietaryPreferences!.length > 1) {
                          message += "\n";
                        }
                      }
                    }

                    chatState.setTyping(true);
                    chatState.specifiedDietaryPreferences = true;

                    chatState.addMessage(
                        Message(
                            role: "user",
                            responseType: "text",
                            textResponse: message.trim()),
                        this);

                    await UserService(uid: user!.uid).updateUserData(
                        key: "dietaryPreferences",
                        value: chatState.dietaryPreferences
                            ?.map(
                              (e) => e.toJson(),
                            )
                            .toList());

                    Future.delayed(const Duration(milliseconds: 1000), () {
                      chatState.setTyping(false);

                      chatState.addMessage(
                          Message(
                              role: 'system',
                              textResponse:
                                  "Thanks! Now lastly, how many people will you be needing food for?",
                              responseType: 'text'),
                          this);
                    });
                  },
                  text: "Save")
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectRecipes(ChatState chatState) {
    if (chatState.recipeStubs == null) {
      // TODO: Something better
      return const Text("Something went wrong");
    }

    List<RecipeStub> breakfastRecipes = chatState.recipeStubs!
        .where((recipe) => recipe.mealType == "breakfast")
        .toList();
    List<RecipeStub> lunchRecipes = chatState.recipeStubs!
        .where((recipe) => recipe.mealType == "lunch")
        .toList();
    List<RecipeStub> dinnerRecipes = chatState.recipeStubs!
        .where((recipe) => recipe.mealType == "dinner")
        .toList();
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
                  onChanged: ((recipes) =>
                      chatState.selectedBreakfastRecipes = recipes),
                ),
              if (lunchRecipes.isNotEmpty)
                RecipeExpandableTile(
                  mealType: "Lunch",
                  recipes: lunchRecipes,
                  onChanged: ((recipes) =>
                      chatState.selectedLunchRecipes = recipes),
                ),
              if (dinnerRecipes.isNotEmpty)
                RecipeExpandableTile(
                  mealType: "Dinner",
                  recipes: dinnerRecipes,
                  onChanged: ((recipes) =>
                      chatState.selectedDinnerRecipes = recipes),
                ),
              const SizedBox(
                height: AppPading.large,
              ),
              AppButton(
                  onPressed: () async {
                    if (chatState.selectedBreakfastRecipes.length <
                            chatState.numberOfBreakfasts ||
                        chatState.selectedLunchRecipes.length <
                            chatState.numberOfLunches ||
                        chatState.selectedDinnerRecipes.length <
                            chatState.numberOfDinners) {
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
                                      "${chatState.selectedBreakfastRecipes.length} breakfast${chatState.selectedBreakfastRecipes.length == 1 ? "" : "s"}\n",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text:
                                      "${chatState.selectedLunchRecipes.length} lunch${chatState.selectedLunchRecipes.length == 1 ? "" : "es"}\n",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text:
                                      "${chatState.selectedDinnerRecipes.length} dinner${chatState.selectedDinnerRecipes.length == 1 ? "" : "s"}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          onSave: () {
                            _makeMealPlan(chatState);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    } else {
                      _makeMealPlan(chatState);
                    }
                  },
                  text: "Save")
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makeMealPlan(ChatState chatState) async {
    String planId =
        await UserService(uid: user!.uid).addMealPlan(MealPlanConfiguration(
      breakfasts: chatState.selectedBreakfastRecipes.length,
      lunches: chatState.selectedLunchRecipes.length,
      dinners: chatState.selectedDinnerRecipes.length,
      numberOfPeople: chatState.numberOfPeople!,
      dietaryPreferences: chatState.dietaryPreferences!
          .map((preference) => preference.preference)
          .toList(),
    ));

    _chatService.createMealPlan(
        mealPlanId: planId,
        breakfasts:
            chatState.selectedBreakfastRecipes.map((e) => e.title).toList(),
        lunches: chatState.selectedLunchRecipes.map((e) => e.title).toList(),
        dinners: chatState.selectedDinnerRecipes.map((e) => e.title).toList(),
        numberOfPeople: chatState.numberOfPeople ?? 1,
        dietaryPreferences: chatState.dietaryPreferences!
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

  Widget _buildSubmitButton(ChatState chatState) {
    return AppButton(
      onPressed: () async {
        String planId =
            await UserService(uid: user!.uid).addMealPlan(MealPlanConfiguration(
          breakfasts: chatState.numberOfBreakfasts,
          lunches: chatState.numberOfLunches,
          dinners: chatState.numberOfDinners,
          numberOfPeople: chatState.numberOfPeople!,
          dietaryPreferences: chatState.dietaryPreferences!
              .map((preference) => preference.preference)
              .toList(),
        ));

        String message =
            """Please create recipes for ${chatState.numberOfBreakfasts} breakfasts, ${chatState.numberOfLunches} lunches and ${chatState.numberOfDinners} dinners for ${chatState.numberOfPeople} people. It is important you follow these dietary preferences: 
        ${chatState.dietaryPreferences!.map((preference) => preference.preference).toList().join(", ")}""";

        _chatService.sendMessage(message,
            mealPlanId: planId, isNewConversation: chatState.isNewConversation);

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

  Widget _buildPlaceholder(ChatState chatState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: chatState.conversationType == null
          ? _buildConversationTypeSelector(chatState)
          : chatState.conversationType == ConversationType.mealPlan &&
                  chatState.specifiedNumberOfMeals == false
              ? _buildMealPlanInput(chatState)
              : chatState.conversationType == ConversationType.mealPlan &&
                      chatState.specifiedDietaryPreferences == false
                  ? _buildDietaryPreferencesChat(chatState)
                  : chatState.conversationType == ConversationType.mealPlan &&
                          chatState.specifiedNumberOfPeople == false
                      ? _buildPeopleInput(chatState)
                      : chatState.conversationType ==
                                  ConversationType.mealPlan &&
                              chatState.selectedRecipeTitles == false
                          ? _buildSelectRecipes(chatState)
                          : chatState.conversationType ==
                                      ConversationType.mealPlan &&
                                  chatState.submitted == false
                              ? _buildSubmitButton(chatState)
                              : Container(),
    );
  }

  void addPreferenceDialog(BuildContext context, ChatState chatState) {
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
                      chatState.dietaryPreferences
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
            child: _buildMessageContent(message),
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
      );
    } else {
      return Container(); // If there's no content, return an empty container
    }
  }

  Widget _buildMessageInput(ChatState chatState) {
    return TypingInput(
        sendMessage: (String message) => chatState.sendMessage(message, this));
  }
}
