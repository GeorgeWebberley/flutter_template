import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/dietary_preference/dietary_preference.dart';
import 'package:flutter_firebase_template/models/message.dart';
import 'package:flutter_firebase_template/models/recipe_stub.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/ai_chat_screen.dart';
import 'package:flutter_firebase_template/services/chat_service.dart';

class ChatState extends ChangeNotifier {
  ConversationType? _conversationType;
  ConversationType? get conversationType => _conversationType;
  final List<Message> _messages = [];
  final List<AnimationController> _animationControllers = [];
  bool _isTyping = false;
  bool isNewConversation = true;

  final ChatService _chatService = ChatService();

  List<Message> get messages => List.unmodifiable(_messages);
  List<AnimationController> get animationControllers => _animationControllers;
  bool get isTyping => _isTyping;

  bool specifiedNumberOfMeals = false;
  bool specifiedDietaryPreferences = false;
  bool specifiedNumberOfPeople = false;
  bool selectedRecipeTitles = false;
  bool submitted = false;
  List<DietaryPreference>? dietaryPreferences;
  List<RecipeStub>? recipeStubs;
  int numberOfBreakfasts = 0;
  int numberOfLunches = 0;
  int numberOfDinners = 0;
  List<RecipeStub> selectedBreakfastRecipes = [];
  List<RecipeStub> selectedLunchRecipes = [];
  List<RecipeStub> selectedDinnerRecipes = [];
  int? numberOfPeople;

  void setConversationType(ConversationType? type) {
    _conversationType = type;
  }

  void addMessage(Message message, TickerProvider vsync) {
    AnimationController animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );

    _messages.insert(0, message);
    _animationControllers.insert(0, animationController);

    animationController.forward();

    notifyListeners();
  }

  Future<void> sendMessage(
      String text, TickerProvider vsync, String uid) async {
    if (text.isEmpty) return;

    final Message userMessage =
        Message(role: 'user', textResponse: text, responseType: 'text');

    addMessage(userMessage, vsync);

    _isTyping = true;
    notifyListeners();

    try {
      final Message? aiMessage = await _chatService.sendMessage(text, uid,
          isNewConversation: isNewConversation);
      if (aiMessage != null) {
        addMessage(aiMessage, vsync);
      }
    } catch (e) {
      // Handle error
      final errorMessage = Message(
          role: 'system',
          textResponse: 'Error: Could not get AI response.',
          responseType: 'text');

      addMessage(errorMessage, vsync);
    } finally {
      _isTyping = false;
      isNewConversation = false;
      notifyListeners();
    }
  }

  void setTyping(bool newValue) {
    _isTyping = newValue;
  }

  void disposeAnimationControllers() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    _animationControllers.clear();
  }

  @override
  void dispose() {
    disposeAnimationControllers();
    super.dispose();
  }

  void clearState() {
    _conversationType = null;
    _messages.clear();
    disposeAnimationControllers();
    _isTyping = false;
    isNewConversation = true;
    specifiedNumberOfMeals = false;
    specifiedDietaryPreferences = false;
    specifiedNumberOfPeople = false;
    selectedRecipeTitles = false;
    submitted = false;
    dietaryPreferences = [];
    recipeStubs = null;
    numberOfBreakfasts = 0;
    numberOfLunches = 0;
    numberOfDinners = 0;
    selectedBreakfastRecipes.clear();
    selectedLunchRecipes.clear();
    selectedDinnerRecipes.clear();
    numberOfPeople = null;
    notifyListeners();
  }

  void goBackOneQuestion() {
    if (specifiedNumberOfPeople) {
      specifiedNumberOfPeople = false;
    } else if (specifiedDietaryPreferences) {
      specifiedDietaryPreferences = false;
    } else if (specifiedNumberOfMeals) {
      specifiedNumberOfMeals = false;
    } else if (conversationType != null) {
      setConversationType(null);
    }

    // Remove AI message
    if (_animationControllers.isNotEmpty) {
      _animationControllers[0].dispose();
      _animationControllers.removeAt(0);
    }
    if (_messages.isNotEmpty) {
      _messages.removeAt(0);
    }
    // Remove user message
    if (_animationControllers.isNotEmpty) {
      _animationControllers[0].dispose();
      _animationControllers.removeAt(0);
    }
    if (_messages.isNotEmpty) {
      _messages.removeAt(0);
    }

    notifyListeners();
  }
}
