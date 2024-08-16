require("dotenv").config();
const functions = require("firebase-functions");
// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");

admin.initializeApp();
admin.firestore().settings({ignoreUndefinedProperties:true});

// After updating this document, re-deploy functions using the following command:
//
// firebase deploy --only functions

