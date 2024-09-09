import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/ai.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/dietary_preference/dietary_preference.dart';
import 'package:flutter_firebase_template/models/meal_plan_configuration.dart';
import 'package:flutter_firebase_template/models/message.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/models/user_data/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/typing_indicator.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/meal_plan_root.dart';
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
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:provider/provider.dart';

enum ConversationType { chat, mealPlan }

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({
    super.key,
  });

  @override
  _AiChatScreenState createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final List<Message> _messages = [];

  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final List<AnimationController> _animationControllers = [];
  bool _isTyping = false;
  ConversationType? conversationType;

  AppUser? user;

  List<String> _mealPlanResponses = [
    "Great! Now could you tell me how many meals would you like to create?",
    "Awesome! Next, how many meals would you like to prepare?",
    "Fantastic! How many meals are you thinking of creating?",
    "Perfect! How many meals would you like to make?",
    "Excellent! How many meals should we plan for?"
  ];

  List<DietaryPreference>? dietaryPreferences;
  int breakfasts = 0;
  int lunches = 0;
  int dinners = 0;
  int? numberOfPeople;
  bool specifiedNumberOfMeals = false;
  bool specifiedDietaryPreferences = false;
  bool specifiedNumberOfPeople = false;
  bool submitted = false;
  // Boolean will be sent to the backend cloud function to inidicate this is a new conversation.
  // Will be set to false after the first message is sent.
  bool isNewConversation = true;

  @override
  void initState() {
    super.initState();
    // Send initial welcome message
    _addWelcomeMessage();
  }

  Future<void> _addWelcomeMessage() async {
    final Message aiMessage = Message(
        role: 'system',
        textResponse: "Hello! How can I help you today?",
        responseType: 'text');

    AnimationController aiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    setState(() {
      _messages.insert(0, aiMessage);
      _animationControllers.insert(0, aiAnimationController);
    });

    aiAnimationController.forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<AppUser?>(context);

    print("Number of people: $specifiedNumberOfPeople");

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(10),
            itemCount:
                _messages.length + 1, // Include placeholder or typing indicator
            itemBuilder: (context, index) {
              if (_isTyping && index == 0) {
                return _buildTypingIndicator();
              } else if (!_isTyping && index == 0) {
                return _buildPlaceholder();
              }

              final message = _messages[_isTyping ? index - 1 : index - 1];
              return _buildAnimatedMessage(message,
                  _animationControllers[_isTyping ? index - 1 : index - 1]);
            },
          ),
        ),
        if (conversationType == ConversationType.chat) _buildMessageInput(),
      ],
    );
  }

  Widget _buildConversationTypeSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
            child: AppButton(
          onPressed: () async {
            _addMessage(Message(
                role: 'user', textResponse: "Meal Plan", responseType: 'text'));

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
                  textResponse:
                      _mealPlanResponses[DateTime.now().millisecond % 5],
                  responseType: 'text'));
            });
          },
          text: "Plan Meal",
          size: ButtonSize.small,
        )),
        const SizedBox(width: 20),
        Expanded(
            child: AppButton(
          backgroundGradient: AppGradients.greenGradient,
          onPressed: () {
            _addMessage(Message(
                role: 'user', textResponse: "Chat", responseType: 'text'));
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
                  textResponse:
                      "Sure! Let's chat. What can I help you with today?",
                  responseType: 'text'));
            });
          },
          text: "Chat",
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
              Row(),
              NumberInput(
                label: "Breakfasts",
                onChanged: (value) {
                  setState(() {
                    breakfasts = value;
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
                    lunches = value;
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
                    dinners = value;
                  });
                },
              ),
              SizedBox(
                height: AppPading.large * 2,
              ),
              AppButton(
                  onPressed: breakfasts == 0 && lunches == 0 && dinners == 0
                      ? null
                      : () async {
                          String message = "";

                          if (breakfasts > 0) {
                            message += "• $breakfasts Breakfasts\n";
                          }
                          if (lunches > 0) {
                            message += "• $lunches Lunches\n";
                          }
                          if (dinners > 0) {
                            message += "• $dinners Dinners";
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
                                textResponse:
                                    "Awesome! Before I put together your plan, is there anything else you'd like to mention? Feel free to be as detailed as you want—you can specify cooking time, difficulty level, no meat for breakfast, or anything else that comes to mind!",
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
              Row(),
              NumberInput(
                label: "People",
                minValue: 1,
                onChanged: (value) {
                  setState(() {
                    numberOfPeople = value;
                  });
                },
              ),
              SizedBox(
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

                    Future.delayed(const Duration(milliseconds: 2000), () {
                      setState(() {
                        _isTyping = false;
                      });

                      _addMessage(Message(
                          role: 'system',
                          textResponse:
                              "Perfect! Are you ready for me to start preparing? It can take around a minute or so, buy you are free to close your app and come back later :)",
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
                          AppCheckbox(
                            onChanged: (value) {
                              preference.activated = value;
                            },
                            label: preference.preference,
                            initialValue: preference.activated ?? false,
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
                child: Row(
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
              SizedBox(
                height: AppPading.large,
              ),
              AppButton(
                  onPressed: () async {
                    List<DietaryPreference>? activatedPreferences =
                        dietaryPreferences
                            ?.where(((e) => e.activated == true))
                            .toList();

                    String message = "";

                    if (activatedPreferences == null ||
                        activatedPreferences.isEmpty) {
                      message = "No dietary preferences";
                    } else {
                      for (DietaryPreference preference
                          in activatedPreferences) {
                        if (preference.activated == true) {
                          message += "• ${preference.preference}";
                          if (preference != dietaryPreferences!.last &&
                              activatedPreferences.length > 1) {
                            message += "\n";
                          }
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

  Widget _buildSubmitButton() {
    return AppButton(
      onPressed: () async {
        String planId =
            await UserService(uid: user!.uid).addMealPlan(MealPlanConfiguration(
          breakfasts: breakfasts,
          lunches: lunches,
          dinners: dinners,
          numberOfPeople: numberOfPeople!,
          dietaryPreferences: dietaryPreferences!
              .where((preference) => preference.activated == true)
              .map((preference) => preference.preference)
              .toList(),
        ));

        String message =
            """Please create recipes for $breakfasts breakfasts, $lunches lunches and $dinners dinners for $numberOfPeople people. It is important you follow these dietary preferences: 
        ${dietaryPreferences!.where((preference) => preference.activated == true).map((preference) => preference.preference).toList().join(", ")}""";

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
    print("specifiedNumberOfPeople == false");
    print(specifiedNumberOfPeople == false);
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
                      dietaryPreferences?.add(DietaryPreference(
                          preference: preference!, activated: true));
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
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (text) {
                _sendMessage(text);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              _sendMessage(_controller.text);
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    _addMessage(
        Message(role: 'user', textResponse: text, responseType: 'text'));

    _controller.clear();

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
