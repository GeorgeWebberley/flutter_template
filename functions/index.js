require("dotenv").config();
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const OpenAI = require("openai");
const { parse } = require("dotenv");
const { NovitaSDK, TaskStatus } = require("novita-sdk");
const axios = require('axios');


admin.initializeApp();
admin.firestore().settings({ignoreUndefinedProperties:true});

const bucket = admin.storage().bucket();

const openai = new OpenAI({ key: process.env.OPENAI_API_KEY });
const novitaClient = new NovitaSDK(process.env.NOVITA_API_KEY);

const generalAiAssistantId = "asst_wNFWDodhq6vuUYHS3HlOZBSv";
const recipeAiAssistantId = "asst_pxquMj2BqU0kjkB18dp5H68l";
const recipeListAiAssistantId = "asst_9OK4fq0HyQoOk4rQ7vS8s2v2";
const refreshRecipeAiAssistantId = "asst_LGfISDuP0aG7YF0x739YGBHh";
const recipeHelpAiAssistantId = "asst_vi2XNfwlTHrMZAXLwKPGjbW8";

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


// Sends a message to the Recipe Help AI model.
// Currently we are not storing this conversation in the database.
// To decide on whether we want to or not. Could even be done frontend when the conversation ends.
exports.sendMessageRecipeHelp = functions.runWith({ timeoutSeconds: 120 }).https.onCall(async (data, context) => {
  const userId = context.auth.uid;
  if(!userId){
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
  }
  
  let threadId = data.threadId;
  const recipeJson = data.recipeJson;
  
  try {
    let userMessage = "";
    // If the thread doesn't exist, create a new one.
    if (!threadId) {
      const thread = await openai.beta.threads.create(
        {messages: [
          {
            "role": "assistant",
            "content": "Hello! Chef Michael at your service. Need any help with " + recipeJson?.title + "?",
          }
        ]}
      );
      threadId = thread.id;
      if(recipeJson != null){
        userMessage = JSON.stringify(recipeJson) + "\n";
      }
    }

    userMessage += data.message;

    await openai.beta.threads.messages.create(threadId, {
      role: "user",
      content: userMessage,
    });

    const run = await openai.beta.threads.runs.createAndPoll(threadId, {
      assistant_id: recipeHelpAiAssistantId, 
    });

    if (run.status === 'completed') {
      const messages = await openai.beta.threads.messages.list(run.thread_id);
      // Return only the latest message from the assistant
      const latestMessage = messages.data.find(msg => msg.role === 'assistant');
      // TODO: Decide whether we want to store the conversation in the database

      return { status: 'success', message: latestMessage, threadId: threadId };
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


exports.generateRecipes = functions.runWith({ timeoutSeconds: 120 }).https.onCall(async (data, context) => {
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
  let recipes;
  try {
    recipes = await Promise.all(recipeRequests);
  } catch (error) {
    console.error('Error with recipe requests:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate recipes');
  }

  // Update the meal plan document in Firestore
  try {
    // Start a batch
    const batch = admin.firestore().batch();

    // Add each recipe to the 'recipes' subcollection
    recipes.forEach((recipe) => {
      const recipeDocRef = newMealPlanDocRef.collection('recipes').doc(); // Auto-generate a new recipe ID
      batch.set(recipeDocRef, recipe); // Add the recipe to the batch
    });

    // Update the meal plan document itself to mark loading as false (if necessary)
    batch.update(newMealPlanDocRef, {
      loading: false
    });

    // Commit the batch
    await batch.commit();
    // await newMealPlanDocRef.update({
    //   recipes: recipes,
    //   loading: false,
    // });
    console.log("Meal plan updated successfully");
    sendMealPlanNotification(userId, mealPlanId);

  } catch (dbError) {
    console.error('Error updating Firestore document:', dbError);
    throw new functions.https.HttpsError('internal', 'Failed to update the meal plan');
  }
});

exports.refreshSingleRecipe = functions.https.onCall(async (data, context) => {
  const { mealPlanId, mealPlanConfiguration, recipeId, existingTitles, mealType } = data;

  const userId = context.auth.uid;

  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated to refresh the recipe.');
  }
  const recipeDocRef = admin.firestore().collection('users').doc(userId).collection('mealPlans').doc(mealPlanId).collection('recipes').doc(recipeId);
  
  const numberOfPeople = mealPlanConfiguration?.numberOfPeople ?? 1;
  const preferences = mealPlanConfiguration?.dietaryPreferences ?? [];


  const thread = await openai.beta.threads.create();
  const threadId = thread.id;

  const userMessage = `
  Number of people: ${numberOfPeople}
  Number of breakfasts: ${mealType === 'breakfast' ? 1 : 0}
  Number of lunches: ${mealType === 'lunch' ? 1 : 0}
  Number of dinners: ${mealType === 'dinner' ? 1 : 0}
  Dietary preferences: ${preferences.join(', ')}
  Recipes to NOT make: ${existingTitles.join(', ')}
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
  

    // Wait for all API calls to complete in parallel
    let recipe;
    try {
      recipe = await generateRecipe(recipesToCreate[0], mealType, preferences, numberOfPeople)
    } catch (error) {
      console.error('Error with recipe requests:', error);
      await recipeDocRef.update({ loading: false });
      throw new functions.https.HttpsError('internal', 'Failed to generate recipes');
    }

    // Update the meal plan document in Firestore
    try {
      recipeDocRef.set({ loading: false, ...recipe });
      console.log("Meal plan updated successfully");
    } catch (dbError) {
      console.error('Error updating Firestore document:', dbError);
      await recipeDocRef.update({ loading: false });
      throw new functions.https.HttpsError('internal', 'Failed to update the meal plan');
    }
  } else {
    await recipeDocRef.update({ loading: false });
  }
});


exports.refreshMultipleRecipes = functions.https.onCall(async (data, context) => {
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
      let recipes;
      try {
        recipes = await Promise.all(recipeRequests);
      } catch (error) {
        console.error('Error with recipe requests:', error);
        await newMealPlanDocRef.update({ [refreshKey]: false });
        throw new functions.https.HttpsError('internal', 'Failed to generate recipes');
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
    // Run both functions in parallel using Promise.all
    const [image, recipe] = await Promise.all([
      generateImage(recipeTitle),
      generateRecipeJson(recipeTitle, mealType, dietaryPreferences, numberOfPeople),
    ]);

    if(image && recipe){
      recipe.image = image;
    }

    console.log("Combined Recipe with Images:", recipe);
    return recipe;
  } catch (error) {
    console.error('Error generating recipe:', error);
    return null;
  }
}
// Function to generate recipe by calling AI API
async function generateRecipeJson(recipeTitle, mealType, dietaryPreferences, numberOfPeople) {
  try {
    const thread = await openai.beta.threads.create();
    const threadId = thread.id;

    console.log("generateRecipe 3");


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
      let finalRecipe;

      if (latestMessage && latestMessage['content'] && latestMessage['content'].length > 0) {
        // console.log("generateRecipes test 2");
    
        const contentList = latestMessage['content'];
        const contentObject = contentList.length > 0 ? contentList[0] : null;
        // console.log("generateRecipes test 3", contentObject);
    
        if (contentObject && contentObject['type'] === 'text') {
          const textValue = contentObject['text']['value'];
    
          try {
            const parsedJson = JSON.parse(textValue);
            // console.log("generateRecipes test 4", parsedJson);
    
            // Check if the parsed JSON has a "properties" key
            finalRecipe = parsedJson;
            if (parsedJson.hasOwnProperty('properties')) {
              // console.log("generateRecipes test 5 - properties found, flattening");
              finalRecipe = parsedJson.properties; // Flatten the object by extracting "properties"
              return finalRecipe;
            }
          } catch (parseError) {
            console.error('Error parsing recipe JSON:', parseError);
          }
        }
      }
      return finalRecipe;
    } else {
      console.error('OpenAI run did not complete', run);
      return null;
    }
  } catch (error) {
    console.error('Error generating recipe:', error);
    return null;
  }
}

async function generateImage(recipeTitle) {
  const imageParams = {
    request: {
      model_name: "flat2DAnimerge_v30_72593.safetensors",
      prompt: recipeTitle,
      width: 512,
      height: 384,
      sampler_name: "Euler a",
      negative_prompt: "nsfw,person,girl",
      guidance_scale: 7,
      steps: 20,
      image_num: 1,
      seed: -1,
    },
  };
  
  console.log("generateRecipe 1");
  const imageResponse = await novitaClient.txt2ImgV3(imageParams);
  console.log("generateRecipe 2", imageResponse);
  
  if (imageResponse && imageResponse.task_id) {
    console.log("task_id:", imageResponse.task_id);
  
    let isCompleted = false;
    const timeoutLimit = 30000; // 30 seconds in milliseconds
    const intervalDelay = 1000; // 1 second delay between checks
    const startTime = Date.now();
  
    // Start checking the task progress using a loop with timeout
    while (!isCompleted) {
      console.log("checking progress");
  
      try {
        const progressRes = await novitaClient.progressV3({
          task_id: imageResponse.task_id,
        });
  
        if (progressRes.task.status === TaskStatus.SUCCEED) {
          console.log("finished!", progressRes.images);
          isCompleted = true; // Break the loop when done
  
          // Assuming progressRes.images is an array of image URLs
          if(progressRes.images[0]['image_url']){
            const imageUrls = await uploadImageToCloudStorage(progressRes.images[0]['image_url']);
            console.log("Image URLs:", imageUrls);
            return imageUrls;
          }
        } else if (progressRes.task.status === TaskStatus.FAILED) {
          console.warn("failed!", progressRes.task.reason);
          isCompleted = true; // Stop the loop on failure
        } else if (progressRes.task.status === TaskStatus.QUEUED) {
          console.log("queueing");
        }
      } catch (err) {
        console.error("progress error:", err);
        isCompleted = true; // Stop the loop in case of error
      }
  
      // Check if the timeout limit has been exceeded
      const elapsedTime = Date.now() - startTime;
      if (elapsedTime > timeoutLimit) {
        console.error("Timed out after 20 seconds");
        isCompleted = true;
      }
  
      // Delay before the next check (1 second)
      if (!isCompleted) {
        await new Promise((resolve) => setTimeout(resolve, intervalDelay));
      }
    }
  }
}

async function uploadImageToCloudStorage(imageUrl) {
  // Fetch the image from the URL
  const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
  const imageBuffer = Buffer.from(response.data);
  const fileName = `images/generated-image-${Date.now()}.png`;
  const file = bucket.file(fileName);

  await file.save(imageBuffer, {
    metadata: {
      contentType: 'image/png', 
    },
    public: true, 
  });

  return `https://storage.googleapis.com/${bucket.name}/${fileName}`;
}


async function sendMealPlanNotification(userId, mealplanId) {
   // Get the user's details
   const user = await admin.firestore().collection("users").doc(userId).get();

   if (!user.exists) {
     functions.logger.error(`User with ID ${userId} not found.`);
     return;
   }
 
   const tokens = user.data().tokens;
 
   if (!tokens || tokens.length === 0) {
     functions.logger.warn(`No tokens found for user with ID ${userId}.`);
     return;
   }

  var notification = {
    title: "Your meal plan is ready!",
    body: "Click to go to your recipes.",
  };

  try {
    await admin.messaging().sendEachForMulticast({
      tokens: user.data().tokens,
      data: {
        type: "mealplanReady",
        mealplanId: mealplanId
      },
      notification: notification,
    });
  } catch (error) {
    functions.logger.error("Error sending friend request notification:", error);
  }
}