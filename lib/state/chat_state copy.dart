import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/dietary_preference/dietary_preference.dart';
import 'package:flutter_firebase_template/models/message.dart';
import 'package:flutter_firebase_template/models/recipe_stub.dart';
import 'package:flutter_firebase_template/screens/logged_in/ai_chat/ai_chat_screen.dart';
import 'package:flutter_firebase_template/services/chat_service.dart';

class ChatState with ChangeNotifier {
  final List<Message> messages = [];

  final ChatService chatService = ChatService();
  final List<AnimationController> animationControllers = [];
  bool isTyping = false;
  ConversationType? conversationType;
  final List<String> mealPlanResponses = [
    "Great! Now could you tell me how many meals would you like to create?",
    "Awesome! Next, how many meals would you like to prepare?",
    "Fantastic! How many meals are you thinking of creating?",
    "Perfect! How many meals would you like to make?",
    "Excellent! How many meals should we plan for?"
  ];

  final List<String> welcomeMessages = [
    "Hi there! Chef Michael at your service for all things culinary. Would you like to create a meal plan, or do you have any food-related questions? How can I assist today?",
    "Greetings! Chef Michael here, ready to help with all your cooking needs. Are you looking to craft a meal plan, or do you have some food questions I can answer?",
    "Hello! Chef Michael checking in to assist with your culinary adventures. Need help with a meal plan, or do you have some general food inquiries?",
    "Hi! It's Chef Michael, here to support you with your cooking and meal planning. What can I help you with today? Ready to create a meal plan, or do you have some food questions?",
    "Hey there! Chef Michael here, ready to lend a hand with anything culinary. Would you like to start on a meal plan, or do you have any food questions I can answer?"
  ];

  final List<String> foodAssistantWelcome = [
    "Great! Feel free to ask me any questions about food or diets. I can also create an individual meal for you, complete with a recipe and ingredients list tailored to your preferences. Just let me know what you need!",
    "Awesome! You can ask me anything about food or diets right here. I’m also happy to create an individual meal for you, including a recipe and ingredients list based on what you like. Just ask away!",
    "Cool! I’m here to answer any food or diet questions you have. If you’d like, I can also create an individual meal for you, complete with a recipe and ingredients list to match your preferences. Just tell me what you need!",
    "Fantastic! Ask me any food or diet questions you’ve got. I can also help by creating an individual meal, along with the recipe and ingredients you’ll need based on your tastes. Just ask!",
    "Great! You can ask me anything related to food or diets. Plus, I can create an individual meal for you, with a recipe and ingredients list tailored to your preferences. Just let me know what you’re looking for!"
  ];

  final List<String> dietaryPreferencesMessages = [
    "Great! Before I finalise your plan, is there anything else you’d like to add? Feel free to be as detailed as you like - preferred cooking methods, portion sizes, low-carb options, or anything else that’s on your mind!",
    "Awesome! Is there anything you’d like to specify about your meals? Don’t hesitate to be specific - ingredient preferences, dietary requirements, spice levels, family-friendly recipes, or any other preferences you have!",
    "Fantastic! Is there anything you'd like to include in your meals? You can get as detailed as you want - dietary requirements, prep time limits, favorite cuisines, dairy-free options, or anything else!",
    "Perfect! Before I build your plan, is there anything you’d like to share that can help me create your meals? Feel free to go into as much detail as you’d like - dietary requirements,  preferred cooking tools , or anything else you’re thinking of!",
    "Excellent! Is there anything else you’d like to add that will help me create meals perfect for you? You can be as detailed as you want - dietary requirements, specific ingredients to include or avoid, quick weekday dinners, or any other preferences you have in mind!",
  ];

  List<DietaryPreference>? dietaryPreferences;
  List<RecipeStub>? recipeStubs;
  int numberOfBreakfasts = 0;
  int numberOfLunches = 0;
  int numberOfDinners = 0;
  List<RecipeStub> selectedBreakfastRecipes = [];
  List<RecipeStub> selectedLunchRecipes = [];
  List<RecipeStub> selectedDinnerRecipes = [];
  int? numberOfPeople;
  bool specifiedNumberOfMeals = false;
  bool specifiedDietaryPreferences = false;
  bool specifiedNumberOfPeople = false;
  bool selectedRecipeTitles = false;
  bool submitted = false;

  // Boolean will be sent to the backend cloud function to inidicate this is a new conversation.
  // Will be set to false after the first message is sent.
  bool isNewConversation = true;
}
