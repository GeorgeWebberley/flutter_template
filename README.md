# flutter_firebase_template

This project is a starting point for a Flutter application. It makes user of a firebase backend and includes code for commonly used functionalities. 
- Signup with email, Apple or Google SSO.
- Storage for any assets (such as images, audio etc.)
- Two-step-verification for when signing up with email.
- Forgot password functionality.
- Account page with options for adding a profile picture, firstname, lastname and for changing the password.
- 'Friend' feature, for allowing users to make friend requests, accept incoming friend requests and delete friends.
- Push notifications.

The code can be modified to remove these functionalities if you so wish.

## Getting Started

There are a few things to setup in order to get this application working.

### Renaming the Project and adding a bundle identifier (optional)

Currently this project is called "flutter_template" and it uses the default bundle identifier of "com.example.flutter_firebase_template". You may wish to change this for your own project. To do so:
- Activate the [rename](https://pub.dev/packages/rename) package:
```
dart pub global activate rename
```
- Then run the following command with your chosen bundle identifier:
```
dart pub global run rename --bundleId <MY_BUNDLE_IDENTIFIER>
``` 
- Check inside `android -> app -> build.gradle` that the applicationId has been set.
- Check for iOS by opening the ios folder in xcode and checking the Bundle Identifier inside the `Runner`.
- Update the app name by using the following command:
```
flutter pub global run rename --appname <YOUR_APP_NAME></YOUR_APP_NAME>
```
- Check inside `android -> app -> src -> main -> AndroidManifest.xml` that the label has been set.
- Check in the `ios -> Runner -> Info.plist` that it has been set.

### Firebase Setup

Used as the backend database, authentication, email provider, storage provider and push notification provider. Also provides cloud functions.

- Navigate to the [firebase console](https://console.firebase.google.com) and create an account (if you don't have one already).
- Click `Add Project` and enter a name.
- You can choose to add google analytics or just skip it (the current template doesn't make use of it yet).
- After the project is created you can choose to add android, ios and web apps.

#### Android

- Click on the android icon under `Get started by adding Firebase to your app` (or `Add app` if you have already created an app on firebase, and select android).
- For the package name use the value you set above. You can get this value from your `android -> app -> build.gradle` under the 'applicationId' field.
- Click on 'Register App'.
- Download the `google-services.json` file and place this inside your `android -> app` directory (at the same level as `build.gradle`).
- Click on 'Next' and then update the `android -> build.gradle` file as shown (already done in this repo, but make sure it is as specified).
- Also update the `android -> app -> src -> build.gradle` file as shown (again this is already done in this repo, but make sure it is as specified).
- Click 'next' and then 'continue to console' to finish the setup.

#### iOS

Note: This requires XCode to be installed on your computer.
- Click on the iOS icon under `Get started by adding Firebase to your app` (or `Add app` if you have already created an app on firebase, and select Apple).
- Open the `ios` folder in Xcode. Click on `Runner` and then get the value of `Bundle Identifier` and insert it into the text box in firebase.
- Click 'Register App'.
- Download the `GoogleService-Info.plist` file and place this inside your Xcode file tree at the same level as `Info.plist`. Make sure the `Copy items if needed` is checked.
- Skip through the remaining stages and return to the console.

### Authentication

Our app can authenticate users through email and password, Google signin and Apple signin. It also has functionalities for changing the password and forgotten passwords. To enable authentication:
- In the Firebase console, click on the Authentication tab 
- Click 'Get started.

#### Email/Password

- Simply click on Email/Password and toggle to enable it.

#### Google

- Click on Google and enable it. Enter in your email address for the support email.
- Navigate to https://developers.google.com/android/guides/client-auth
- Copy the command for your OS for getting the debug certificate fingerprint and enter it in your terminal.
- The keystore password is `android`. You will will be shown two values (SHA1 and SHA256) which we need to copy to firebase.
- In the Firebase console left menu, click on `Project Settings`.
- In the `General` tab, scroll down to 'Your apps' and click on the 'Android' app.
- Click 'Add fingerprint' and paste in the SHA1 value (exluding the bit that says `SHA1:`)
- Repeat for the SHA256 value.


#### Apple

TODO: ADD FOR APPLE SSO


### Firestore Database

This app currently uses the Firebase Firestore as the database.

- In the firebase console, click on `Firestore Database`.
- Click on `Create database`.
- For now, you can start in Test mode. However it is important to change this to production mode before releasing the app. When in production mode you should set rules regarding what can and can't be accessed by users. I will not go into rules in this setup guide.
TODO: Mention rules in place for current setup.

### Storage

This app currently uses the Firebase Storage for storage of images (profile pictures).

- In the firebase console, click on `Storage`.
- Click on `Get started`.
- For now, you can start in Test mode. However it is important to change this to production mode before releasing the app. When in production mode you should set rules regarding what can and can't be accessed by users. I will not go into rules in this setup guide.
TODO: Mention rules in place for current setup.

### Functions

Cloud functions are currently used for certain functionalities such as processing friend requests. They are useful for any operations that you don't want a user to have access to doing (theoretically anything the flutter app can do is possible fpr the user to take advantage of). For example, if your app is accessing an API using a token it probably isn't safe to keep this token in the flutter app itself (since the user can then use this token, which you might be paying for, to access the API freely). Keeping this token as an environment variable only to be accessed by cloud functions prevents the user getting direct access to the token. 

In our app, it is important that we manage friend requests through cloud functions. The current data structure means that when a user requests another user to be their friend, the request is added to the friend's database entry. However we don't want users to be able to update other users' database entries, since this could then be a security risk. It is therefore handled in firebase functions.

Unfortunately, cloud functions are not included in the free plan. However you can enable them by upgrading your project to the Blaze plan. This is still very cheap, and in most cases free for just development. To enable functions:

TODO: CHECK THESE INSTRUCTIONS

- In the firebase console, click on `Functions`.
- Click on `Upgrade project`.
- Click on the Blaze plan.
- Set a budget (e.g. £10).
- Now in the Functions tab you can click on `Get started`.
- Run the command in your terminal as instructed:
```
npm install -g firebase-tools
```
- Run the command:
```
firebase init
```
- Select `Functions`
- Follow the instructions in the console. Choose an existing project and select the one you have created.
- Select javascript and install the dependencies needed.

#### Deploying Functions

As mentioned above, currently in this app we have some functions for managing friend requests. After setting up cloud functions as above, you can deploy the functions to the cloud using:

```
firebase deploy --only functions
```

If you want to add more cloud functions, simply add them to the `functions/index.js` file.

If you would like to use environment variables inside your functions (e.g. for API keys) then see the section further down on "Environment variables".

### Push Notifications

Push notifications are useful for several reasons. You can alert all users of an app, for example when there is a new update or a new cool feature you want them to try. You can also send personal notifications when certain events happen, for example if the user has received a friend request. The notification can then take the user to a specific page in the app for dealing with that notification. In our app they are used for friend requests and when friend requests are accepted.

#### iOS

For iOS you must explicitly enable "Push Notifications" and "Background Modes" within Xcode.

Open your project workspace file via Xcode `/{ios|macos}/Runner.xcworkspace`. Once open, follow the steps below:

- Select your project.
- Select the project target.
- Select the "Signing & Capabilities" tab.
- Click on the "+" button to add a capability.
- Search for "Push Notifications"

Next the "Background Modes" capability needs to be enabled, along with both the "Background fetch" and "Remote notifications" sub-modes. This can be added via the "Capability" option on the "Signing & Capabilities" tab:

- Click on the "+" button to add a capability.
- Search for "Background Modes".
- Add it and the check the boxes `Background fetch` and `Remote notifications`.

TBC - ENABLING PUSH NOTIFICATIONS IN APPLE DEVELOPER ACCOUNT https://firebase.flutter.dev/docs/messaging/apple-integration/

### Google SSO

TODO

## Customising

- Replace the `logo.png`, `splash.png` and `background.png` files in the assets/images folder.
- Choose a nice colour palette and update the colours inside `theme/colours.dart`.

## Environment variables
- Create files called `dotenv.development`, `dotenv.staging` and `dotenv.production` in the root of the project (I have already placed `dotenv.example` there as an example).
- Then you can populate the file inside `lib/shared/environment.dart` following the same format.
- Environment variables can then be accessed using `Environment.example.exampleField` in the code.
- If you have environment variables needed inside your cloud functions (e.g. API keys) then add a file called `.env` inside the `functions` directory. I have created one called `.example-env` as an example. However to use these you will need to add the package called `dotenv` to your firebase functions. 
   - First navigate to the functions directory:
   ```
   cd functions
   ```
   - Then install dotenv using NPM:
   ```
   npm install dotenv
   ```
- IMPORTANT: all environment variable files should already be put into `.gitignore`. However if not, make sure that you add them yourself so they are not committed to git.