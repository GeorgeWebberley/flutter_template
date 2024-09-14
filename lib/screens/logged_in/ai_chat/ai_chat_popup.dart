import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/message.dart';
import 'package:flutter_firebase_template/models/recipe.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/typing_indicator.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/typing_input.dart';
import 'package:flutter_firebase_template/screens/logged_in/meal_plans/recipe_screen.dart';
import 'package:flutter_firebase_template/services/chat_service.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:provider/provider.dart';

class AiChatPopup extends StatefulWidget {
  const AiChatPopup({
    super.key,
    required this.recipe,
    this.messages,
    this.threadId,
    this.setThreadId,
  });

  final Recipe recipe;
  final List<Message>? messages;
  final String? threadId;
  final Function(String?)? setThreadId;

  @override
  _AiChatPopupState createState() => _AiChatPopupState();
}

class _AiChatPopupState extends State<AiChatPopup>
    with TickerProviderStateMixin {
  late List<Message> _messages;

  final ChatService _chatService = ChatService();
  late final List<AnimationController> _animationControllers;
  bool _isTyping = false;

  AppUser? user;

  late String? threadId;

  @override
  void initState() {
    super.initState();
    _messages = widget.messages ?? [];
    print("Setting threadId: ${widget.threadId}");
    threadId = widget.threadId;
    _animationControllers = List.generate(_messages.length,
        (index) => AnimationController(vsync: this, value: 1));
    // Send initial welcome message if no messages are present
    if (_messages.isEmpty) _addWelcomeMessage();
  }

  Future<void> _addWelcomeMessage() async {
    List<String> welcomeMessages = [
      "Hello! Chef Michael at your service. Need any help with ${widget.recipe.title}?",
      "Hey there! How can I help with the ${widget.recipe.title} recipe?",
    ];
    setState(() {
      _isTyping = true;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isTyping = false;
    });

    _addMessage(Message(
        role: 'system',
        textResponse: welcomeMessages[
            DateTime.now().millisecond % welcomeMessages.length],
        responseType: 'text'));
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
                // Return the typing indicator
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: TypingIndicator(),
                  ),
                );
              } else if (!_isTyping && index == 0) {
                // Return a placeholder
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(),
                );
              }

              // Safely access the message and animation controller
              final messageIndex = _isTyping ? index - 1 : index - 1;
              final message = _messages[messageIndex];

              if (messageIndex < _animationControllers.length) {
                final animationController = _animationControllers[messageIndex];

                return _buildAnimatedMessage(message, animationController);
              }

              // In case there's no corresponding AnimationController, return a basic message
              return _buildMessageContent(message);
            },
          ),
        ),
        TypingInput(sendMessage: _sendMessage),
      ],
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
      );
    } else {
      return Container();
    }
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    _addMessage(
        Message(role: 'user', textResponse: text, responseType: 'text'));

    _showTypingIndicator(); // Show typing indicator

    try {
      print("threadId: $threadId");
      // Call the ChatService to send the message and get the AI response
      final Map<String, dynamic>? aiMessage =
          await _chatService.sendSimpleMessage(
        text,
        threadId: threadId,
        recipe: threadId == null ? widget.recipe : null,
      );

      if (aiMessage != null) {
        _addMessage(Message(
            role: 'system',
            textResponse: aiMessage['message'],
            responseType: 'text'));
        setState(() {
          threadId = aiMessage['threadId'];
          _isTyping = false;
        });
        print("Setting threadId: $threadId");
        widget.setThreadId?.call(threadId);
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
        _isTyping = false;
      });
    }
  }

  void _addMessage(Message message) {
    AnimationController animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    setState(() {
      _messages.insert(0, message);
      _animationControllers.insert(0, animationController);
    });

    animationController.forward();
  }

  void _showTypingIndicator() {
    setState(() {
      _isTyping = true;
    });
  }
}
