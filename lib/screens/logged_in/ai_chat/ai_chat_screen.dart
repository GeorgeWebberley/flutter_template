import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/message.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/typing_indicator.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/typing_input.dart';
import 'package:flutter_firebase_template/widgets/meal_plan_settings/meal_plan_configuration_root.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/recipe_screen.dart';
import 'package:flutter_firebase_template/services/chat_service.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/fade_navigator.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/state/chat_state.dart';
import 'package:flutter_firebase_template/theme/box_shadow.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/simple_vito.dart';
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
  Widget build(BuildContext context) {
    user = Provider.of<AppUser?>(context);

    return Consumer<ChatState>(builder: (context, chatState, child) {
      if (chatState.conversationType == null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(),
            Padding(
              padding: const EdgeInsets.all(AppPading.page),
              child: SimpleVito(
                text: "Heya! How can I help you today?",
                child: Padding(
                  padding: const EdgeInsets.only(top: AppPading.large),
                  child: _buildConversationTypeSelector(chatState),
                ),
              ),
            ),
          ],
        );
      }
      return Stack(
        children: [
          Column(
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
          ),
          if (chatState.conversationType != null)
            Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                    child: Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        chatState.clearState();
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 30,
                        color: AppColors.danger,
                      ),
                    ),
                    if (chatState.conversationType == ConversationType.mealPlan)
                      // Go back one question
                      IconButton(
                        onPressed: () {
                          chatState.goBackOneQuestion();
                        },
                        icon: const Icon(
                          Icons.undo,
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ))),
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
            Navigator.push(
              context,
              FadeNavigator(
                  builder: (context, _, __) => MealPlanConfigurationRoot()),
            );
          },
          text: "Create Meal plan",
          size: ButtonSize.small,
        )),
        const SizedBox(width: 20),
        Expanded(
            child: AppButton(
          backgroundGradient: AppGradients.greenGradient,
          onPressed: () {
            chatState.setConversationType(ConversationType.chat);
            chatState.addMessage(
                Message(
                    role: 'system',
                    textResponse: _foodAssistantWelcome[
                        DateTime.now().millisecond % _welcomeMessages.length],
                    responseType: 'text'),
                this);
          },
          text: "Food Assistant",
          size: ButtonSize.small,
        )),
      ],
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
          : Container(),
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
              color: isUserMessage ? AppColors.primary : Colors.white,
              boxShadow: [AppBoxShadow.small],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft:
                      isUserMessage ? Radius.circular(20) : Radius.circular(0),
                  bottomRight:
                      isUserMessage ? Radius.circular(0) : Radius.circular(20)),
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
        style: TextStyle(
            color: message.role == 'user' ? Colors.white : Colors.black),
      );
    } else if (message.responseType == 'recipe' && message.recipes != null) {
      List<String> messages = [
        "Here you go! I will also add ${message.recipes!.length > 1 ? 'these recipes' : 'this recipe'} to the 'snacks' section in your profile :)",
        "Here are some recipes I found for you. I will also add ${message.recipes!.length > 1 ? 'these recipes' : 'this recipe'} to the 'snacks' section in your profile!",
        "I hope you enjoy! If you want to find ${message.recipes!.length > 1 ? 'them' : 'it'} again you can check the 'snacks' section in your profile.",
      ];
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          messages[DateTime.now().millisecond % messages.length],
          style: const TextStyle(color: Colors.black),
        ),
        const SizedBox(height: AppPading.large),
        ...message.recipes!
            .map((recipe) => Column(
                  children: [
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
                    const SizedBox(height: AppPading.large),
                  ],
                ))
            .toList(),
      ]);
    } else {
      return Container(); // If there's no content, return an empty container
    }
  }

  Widget _buildMessageInput(ChatState chatState) {
    return TypingInput(
        sendMessage: (String message) =>
            chatState.sendMessage(message, this, user!.uid));
  }
}
