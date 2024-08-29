require("dotenv").config();
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const OpenAI = require("openai");

admin.initializeApp();
admin.firestore().settings({ignoreUndefinedProperties:true});

const openai = new OpenAI({ key: process.env.OPENAI_API_KEY });

// After updating this document, re-deploy functions using the following command:
//
// firebase deploy --only functions
exports.sendMessage = functions.https.onCall(async (data, context) => {
  const userId = context.auth.uid;
  const userDocRef = admin.firestore().collection('users').doc(userId);
  const userDoc = await userDocRef.get();
  
  let threadId = userDoc.data()?.threadId;



  // Will be true if the message being sent is the final in the meal planning.
  // Used to create an entry in the database with "loading" set to true.
  const mealPlanId = data.mealPlanId;
  
  let newMealPlanDocRef;

  if(mealPlanId){
    // Get the mealPlan subcollection of the user
    newMealPlanDocRef = userDocRef.collection('mealPlans').doc(mealPlanId);
  }

  try {
    // If the thread doesn't exist, create a new one
    if (!threadId) {
      const thread = await openai.beta.threads.create();
      threadId = thread.id;

      // Save the new thread ID in Firestore
      await userDocRef.update({ threadId: threadId });
    }

    const userMessage = data.message;

    await openai.beta.threads.messages.create(threadId, {
      role: "user",
      content: userMessage,
    });

    const run = await openai.beta.threads.runs.createAndPoll(threadId, {
      // assistant_id: "asst_wNFWDodhq6vuUYHS3HlOZBSv", 
      // assistant_id: "asst_TG7N4oOCZeuyih4rDE1bpyat", 
      assistant_id: "asst_wNFWDodhq6vuUYHS3HlOZBSv", 
    });

    if (run.status === 'completed') {
      const messages = await openai.beta.threads.messages.list(run.thread_id);
      
      // Return only the latest message from the assistant
      const latestMessage = messages.data.find(msg => msg.role === 'assistant');

      if (mealPlanId && latestMessage['content'][0]) {
          // Extract the first content object
          const contentList = latestMessage['content'];
          console.log("latestMessage:", latestMessage);

          const contentObject = contentList.length > 0 ? contentList[0] : null;

          console.log("Content object:", contentObject);

          let parsedRecipes = [];
          let totalIngredients;

          if (contentObject && contentObject['type'] === 'text') {
              const textValue = contentObject['text']['value'];
              console.log()
              
              try {
                  const parsedJson = JSON.parse(textValue);
                  console.log("Parsed JSON:", parsedJson);

                  const responseType = parsedJson['response_type'];

                  if (responseType === 'recipe' && Array.isArray(parsedJson['recipes'])) {
                      parsedRecipes = parsedJson['recipes'];
                  } else if (responseType === 'recipe' && typeof parsedJson['recipe'] === 'object') {
                      parsedRecipes = [parsedJson['recipe']];
                  }
                  totalIngredients = parsedJson['total_ingredients'];

              } catch (error) {
                  console.error("Error parsing response JSON:", error);
              }
          }

          // If recipes were parsed successfully, update the meal plan document with recipes
          if (parsedRecipes.length > 0 && newMealPlanDocRef) {
            console.log("Parsed recipes:", parsedRecipes);
            console.log("Total ingredients:", totalIngredients);
              await newMealPlanDocRef.update({
                  recipes: parsedRecipes,
                  totalIngredients: totalIngredients,
                  loading: false,  // Optionally, set loading to false since the recipes are now added
              });
          }
      }

      return { status: 'success', message: latestMessage };
    } else {
      return { status: run.status };
    }
  } catch (error) {
    console.error("Error handling message:", error);
    throw new functions.https.HttpsError('failed-precondition', 'Failed to send message.');
  }
});

