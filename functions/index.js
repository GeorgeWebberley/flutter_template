require("dotenv").config();
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const OpenAI = require("openai");
const { parse } = require("dotenv");

admin.initializeApp();
admin.firestore().settings({ignoreUndefinedProperties:true});

const openai = new OpenAI({ key: process.env.OPENAI_API_KEY });

// After updating this document, re-deploy functions using the following command:
//
// firebase deploy --only functions
exports.sendMessage = functions.runWith({ timeoutSeconds: 120 }).https.onCall(async (data, context) => {
  const userId = context.auth.uid;
  const userDocRef = admin.firestore().collection('users').doc(userId);
  const userDoc = await userDocRef.get();
  
  let threadId = userDoc.data()?.threadId;

  // Will be true if the message being sent is the final in the meal planning.
  // Used to create an entry in the database with "loading" set to true.
  const mealPlanId = data.mealPlanId;
  const isNewConversation = data.isNewConversation;
  
  let newMealPlanDocRef;

  if(mealPlanId){
    // Get the mealPlan subcollection of the user
    newMealPlanDocRef = userDocRef.collection('mealPlans').doc(mealPlanId);
  }

  try {
    // If the thread doesn't exist, create a new one.
    if (!threadId || isNewConversation) {
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

    console.log("Submitted message")

    const run = await openai.beta.threads.runs.createAndPoll(threadId, {
      // assistant_id: "asst_wNFWDodhq6vuUYHS3HlOZBSv", 
      // assistant_id: "asst_TG7N4oOCZeuyih4rDE1bpyat", 
      assistant_id: "asst_wNFWDodhq6vuUYHS3HlOZBSv", 
    });

    console.log("run.status");
    console.log(run.status);
    

    if (run.status === 'completed') {
      console.log("test 1");

      const messages = await openai.beta.threads.messages.list(run.thread_id);
      console.log("test 2", messages);


      
      // Return only the latest message from the assistant
      const latestMessage = messages.data.find(msg => msg.role === 'assistant');

      console.log("test 3", latestMessage);

      if (mealPlanId && latestMessage['content'][0]) {

          // Extract the first content object
          const contentList = latestMessage['content'];

          const contentObject = contentList.length > 0 ? contentList[0] : null;
          console.log("test 4", contentObject);


          let parsedRecipes = [];

          if (contentObject && contentObject['type'] === 'text') {

              const textValue = contentObject['text']['value'];
              
              try {
                  console.log("textValue");
                  console.log(textValue);
                  const parsedJson = JSON.parse(textValue);

                  const responseType = parsedJson['response_type'];

                  if (responseType === 'recipe' && Array.isArray(parsedJson['recipes'])) {
                      parsedRecipes = parsedJson['recipes'];
                  } else if (responseType === 'recipe' && typeof parsedJson['recipe'] === 'object') {
                      parsedRecipes = [parsedJson['recipe']];
                  }

              } catch (error) {
                  console.error("Error parsing response JSON:", error);
              }
          }

          // If recipes were parsed successfully, update the meal plan document with recipes
          if (parsedRecipes.length > 0 && newMealPlanDocRef) {
              await newMealPlanDocRef.update({
                  recipes: parsedRecipes,
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



// TODO: The above function seems to fail often times when producing may recipes (10 plus). To get round this another option is to call 2 different AI models.
// - The first one returns list of recipe names
// - The second one returns a single recipe for each name. Can be called in parallel to save time (only billed on number of tokens).
// Difficulties may be when trying to do this as well as accounting for the fact that user has diet preferences.
// Keep the above function for the general "chat" functionality and for being able to generate recipes on the fly.