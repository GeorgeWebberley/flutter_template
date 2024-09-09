require("dotenv").config();
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const OpenAI = require("openai");
const { parse } = require("dotenv");

admin.initializeApp();
admin.firestore().settings({ignoreUndefinedProperties:true});

const openai = new OpenAI({ key: process.env.OPENAI_API_KEY });

const generalAiAssistantId = "asst_wNFWDodhq6vuUYHS3HlOZBSv";
const recipeAiAssistantId = "asst_pxquMj2BqU0kjkB18dp5H68l";
const recipeListAiAssistantId = "asst_9OK4fq0HyQoOk4rQ7vS8s2v2";
const refreshRecipeAiAssistantId = "asst_LGfISDuP0aG7YF0x739YGBHh";

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

    console.log("sendMessage Submitted message")

    const run = await openai.beta.threads.runs.createAndPoll(threadId, {
      assistant_id: generalAiAssistantId, 
    });

    console.log("sendMessage run.status");
    console.log(run.status);
    

    if (run.status === 'completed') {
      console.log("sendMessage test 1");

      const messages = await openai.beta.threads.messages.list(run.thread_id);
      console.log("sendMessage test 2", messages);


      
      // Return only the latest message from the assistant
      const latestMessage = messages.data.find(msg => msg.role === 'assistant');

      console.log("sendMessage test 3", latestMessage);

      if (mealPlanId && latestMessage['content'][0]) {

          // Extract the first content object
          const contentList = latestMessage['content'];

          const contentObject = contentList.length > 0 ? contentList[0] : null;
          console.log("sendMessage test 4", contentObject);


          let parsedRecipes = [];

          if (contentObject && contentObject['type'] === 'text') {

              const textValue = contentObject['text']['value'];
              
              try {
                  console.log("sendMessage textValue");
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
exports.getRecipeList = functions.runWith({ timeoutSeconds: 120 }).https.onCall(async (data, context) => {
  const userId = context.auth.uid;
  // TODO: Also to check for user subscription status
  if (!userId) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
  }

  const numberOfPeople = data.numberOfPeople ?? 0;
  const breakfasts = data.breakfasts ?? 0;
  const lunches = data.lunches ?? 0;
  const dinners = data.dinners ?? 0;
  const snacks = data.snacks ?? 0;
  const dietaryPreferences = data.dietaryPreferences?.length 
      ? data.dietaryPreferences 
      : ["none"];

  try {

    const thread = await openai.beta.threads.create();
    const threadId = thread.id;

    const userMessage = `
    Number of people: ${numberOfPeople}
    Number of breakfasts: ${breakfasts}
    Number of lunches: ${lunches}
    Number of dinners: ${dinners}
    Number of snacks: ${snacks}
    Dietary preferences: ${dietaryPreferences.join(', ')}
    `;

    await openai.beta.threads.messages.create(threadId, {
      role: "user",
      content: userMessage,
    });

    // console.log("getRecipeList Submitted message")

    const run = await openai.beta.threads.runs.createAndPoll(threadId, {
      assistant_id: recipeListAiAssistantId, 
    });

    // console.log("getRecipeList run.status");
    // console.log(run.status);

    if (run.status === 'completed') {
      // console.log("getRecipeList test 1");

      const messages = await openai.beta.threads.messages.list(run.thread_id);
      // console.log("getRecipeList test 2", messages);
      
      // Return only the latest message from the assistant
      const latestMessage = messages.data.find(msg => msg.role === 'assistant');

      // For now just return response. To decide whether these recipes should be saved to the database.
      return { status: 'success', message: latestMessage };
    } else {
      return { status: run.status };
    }
  } catch (error) {
    console.error("Error handling message:", error);
    throw new functions.https.HttpsError('failed-precondition', 'Failed to send message.');
  }
});


exports.generateRecipes = functions.https.onCall(async (data, context) => {
  const { breakfasts, lunches, dinners, dietaryPreferences, numberOfPeople, mealPlanId } = data;

  const userId = context.auth.uid;
  const userDocRef = admin.firestore().collection('users').doc(userId);
  const newMealPlanDocRef = userDocRef.collection('mealPlans').doc(mealPlanId);

  // Create an array of recipe requests for each meal type
  const recipeRequests = [];

  // Push breakfast recipe requests
  if (breakfasts && breakfasts.length > 0) {
    breakfasts.forEach(breakfast => {
      recipeRequests.push(generateRecipe(breakfast, 'breakfast', dietaryPreferences, numberOfPeople));
    });
  }

  // Push lunch recipe requests
  if (lunches && lunches.length > 0) {
    lunches.forEach(lunch => {
      recipeRequests.push(generateRecipe(lunch, 'lunch', dietaryPreferences, numberOfPeople));
    });
  }

  // Push dinner recipe requests
  if (dinners && dinners.length > 0) {
    dinners.forEach(dinner => {
      recipeRequests.push(generateRecipe(dinner, 'dinner', dietaryPreferences, numberOfPeople));
    });
  }

  // Wait for all API calls to complete in parallel
  let results;
  try {
    results = await Promise.all(recipeRequests);
  } catch (error) {
    console.error('Error with recipe requests:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate recipes');
  }

  // console.log('Recipe results:', results);

  // Initialize an array to store parsed recipes
  let recipes = [];

  for (let i = 0; i < results.length; i++) {
    // console.log("generateRecipes test 1", results[i]);
  
    if (results[i] && results[i]['content'] && results[i]['content'].length > 0) {
      // console.log("generateRecipes test 2");
  
      const contentList = results[i]['content'];
      const contentObject = contentList.length > 0 ? contentList[0] : null;
      // console.log("generateRecipes test 3", contentObject);
  
      if (contentObject && contentObject['type'] === 'text') {
        const textValue = contentObject['text']['value'];
  
        try {
          const parsedJson = JSON.parse(textValue);
          // console.log("generateRecipes test 4", parsedJson);
  
          // Check if the parsed JSON has a "properties" key
          let finalRecipe = parsedJson;
          if (parsedJson.hasOwnProperty('properties')) {
            // console.log("generateRecipes test 5 - properties found, flattening");
            finalRecipe = parsedJson.properties; // Flatten the object by extracting "properties"
          }
  
          recipes.push(finalRecipe); // Push the flattened recipe to the final array
        } catch (parseError) {
          console.error('Error parsing recipe JSON:', parseError);
          continue; // Skip this recipe if parsing fails
        }
      }
    }
  }
  
  // console.log("generateRecipes test 5", recipes);


  // Update the meal plan document in Firestore
  try {
    await newMealPlanDocRef.update({
      recipes: recipes,
      loading: false,
    });
    console.log("Meal plan updated successfully");
  } catch (dbError) {
    console.error('Error updating Firestore document:', dbError);
    throw new functions.https.HttpsError('internal', 'Failed to update the meal plan');
  }
});


exports.refreshRecipe = functions.https.onCall(async (data, context) => {
  const { mealPlanId, type, recipesToRefresh } = data;

  const userId = context.auth.uid;

  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated to refresh the recipe.');
  }
  const userDocRef = admin.firestore().collection('users').doc(userId);
  const newMealPlanDocRef = userDocRef.collection('mealPlans').doc(mealPlanId);
  const mealPlanDoc = await newMealPlanDocRef.get();

  const mealPlanData = mealPlanDoc.data();
  const titles = mealPlanData?.recipes?.map(recipe => recipe.title) ?? [];

  const numberOfPeople = mealPlanData?.mealPlanConfiguration?.numberOfPeople ?? 1;
  const preferences = mealPlanData?.mealPlanConfiguration?.dietaryPreferences ?? [];


  if (mealPlanDoc.exists) {
    const refreshKey = type === 'breakfast' ? 'breakfastRefreshing' : 
    type === 'lunch' ? 'lunchRefreshing' :
    'dinnerRefreshing';

    const thread = await openai.beta.threads.create();
    const threadId = thread.id;

    const userMessage = `
    Number of people: ${numberOfPeople}
    Number of breakfasts: ${type === 'breakfast' ? recipesToRefresh.length : 0}
    Number of lunches: ${type === 'lunch' ? recipesToRefresh.length : 0}
    Number of dinners: ${type === 'dinner' ? recipesToRefresh.length : 0}
    Dietary preferences: ${preferences.join(', ')}
    Recipes to NOT make: ${titles.join(', ')}
    `;

    await openai.beta.threads.messages.create(threadId, {
      role: "user",
      content: userMessage,
    });

    // console.log("getRecipeList Submitted message")

    const run = await openai.beta.threads.runs.createAndPoll(threadId, {
      assistant_id: recipeListAiAssistantId, 
    });

    if (run.status === 'completed') {
      // console.log("getRecipeList test 1");

      const messages = await openai.beta.threads.messages.list(run.thread_id);
      // console.log("getRecipeList test 2", messages);
      
      // Return only the latest message from the assistant
      const latestMessage = messages.data.find(msg => msg.role === 'assistant');


      const responseData = JSON.parse(latestMessage.content[0].text.value);
      const recipesToCreate = responseData.recipes.map(recipe => recipe.title);
      const recipeRequests = [];

      // Push breakfast recipe requests
      if (recipesToCreate.length > 0) {
        recipesToCreate.forEach(recipe => {
          console.log("Recipe to create", recipe);
          recipeRequests.push(generateRecipe(recipe, type, preferences, numberOfPeople));
        });
      }

      // Wait for all API calls to complete in parallel
      let results;
      try {
        results = await Promise.all(recipeRequests);
      } catch (error) {
        console.error('Error with recipe requests:', error);
        await newMealPlanDocRef.update({ [refreshKey]: false });
        throw new functions.https.HttpsError('internal', 'Failed to generate recipes');
      }

      let recipes = [];

      for (let i = 0; i < results.length; i++) {
        // console.log("generateRecipes test 1", results[i]);
      
        if (results[i] && results[i]['content'] && results[i]['content'].length > 0) {
          // console.log("generateRecipes test 2");
      
          const contentList = results[i]['content'];
          const contentObject = contentList.length > 0 ? contentList[0] : null;
          // console.log("generateRecipes test 3", contentObject);
      
          if (contentObject && contentObject['type'] === 'text') {
            const textValue = contentObject['text']['value'];
      
            try {
              const parsedJson = JSON.parse(textValue);
              // console.log("generateRecipes test 4", parsedJson);
      
              // Check if the parsed JSON has a "properties" key
              let finalRecipe = parsedJson;
              if (parsedJson.hasOwnProperty('properties')) {
                // console.log("generateRecipes test 5 - properties found, flattening");
                finalRecipe = parsedJson.properties; // Flatten the object by extracting "properties"
              }
      
              recipes.push(finalRecipe); // Push the flattened recipe to the final array
            } catch (parseError) {
              console.error('Error parsing recipe JSON:', parseError);
              await newMealPlanDocRef.update({
                [refreshKey]: false,
              });
            }
          }
        }
      }
      
      // Update the meal plan document in Firestore
      try {
        // Re-Retrieve the current array of recipes. We do this again here since the openAI API
        // call can be slow and the arrays may have changed in the database (if the user is 
        // simultaneously refreshing multiple meal types). If this turns out to be inefficient 
        // in firebase then we might want to think about other ways to handle this.
        const docSnapshot = await newMealPlanDocRef.get();
        const currentRecipes = docSnapshot.data().recipes || [];

        // Filter out the recipes that need to be deleted based on their titles
        const updatedRecipes = currentRecipes.filter(
          recipe => !recipesToRefresh.includes(recipe.title)
        );

        // Add the new recipes to the updated list
        updatedRecipes.push(...recipes);

        // Update the document with the new list of recipes
        await newMealPlanDocRef.update({
          recipes: updatedRecipes,
          [refreshKey]: false,  // Set refreshKey if applicable
        });
        console.log("Meal plan updated successfully");
      } catch (dbError) {
        console.error('Error updating Firestore document:', dbError);
        await newMealPlanDocRef.update({
          [refreshKey]: false,
        });
        throw new functions.https.HttpsError('internal', 'Failed to update the meal plan');
      }
    } else {
      await newMealPlanDocRef.update({ [refreshKey]: false });
    }
  } else {
    console.log('No meal plan found');
  }
});


// Function to generate recipe by calling AI API
async function generateRecipe(recipeTitle, mealType, dietaryPreferences, numberOfPeople) {
  try {
    const thread = await openai.beta.threads.create();
    const threadId = thread.id;

    const userMessage = `
    Recipe title: ${recipeTitle},
    Meal type: ${mealType},
    Number of people: ${numberOfPeople},
    Dietary preferences: ${dietaryPreferences.join(', ')}
    `;

    await openai.beta.threads.messages.create(threadId, {
      role: "user",
      content: userMessage,
    });

    console.log("Message submitted to OpenAI");

    const run = await openai.beta.threads.runs.createAndPoll(threadId, {
      assistant_id: recipeAiAssistantId, 
    });

    console.log("OpenAI run status:", run.status);

    if (run.status === 'completed') {
      const messages = await openai.beta.threads.messages.list(run.thread_id);
      const latestMessage = messages.data.find(msg => msg.role === 'assistant');
      return latestMessage || null; // Return the message or null if not found
    } else {
      console.error('OpenAI run did not complete', run);
      return null;
    }
  } catch (error) {
    console.error('Error generating recipe:', error);
    return null;
  }
}