require("dotenv").config();
const functions = require("firebase-functions");
// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");

admin.initializeApp();
admin.firestore().settings({ignoreUndefinedProperties:true});

// After updating this document, re-deploy functions using the following command:
//
// firebase deploy --only functions

exports.makeFriendRequest = functions.https.onCall((data, context) => {
  const requester = data.requester;
  const friend = data.friend;

  // TODO: Add safety check so we return early if user is
  // already a friend or request already has been sent


  // Add the requester to the friends 'friendRequests'
  admin.firestore().collection("users")
    .doc(friend)
    .update({
      friendRequests: admin.firestore.FieldValue.arrayUnion(requester),
    });

  sendFriendRequestNotification(friend, requester);
});



exports.syncFriends = functions.firestore
  .document("/users/{documentId}")
  .onWrite((event, context) => {
    const after = event.after.data();
    const before = event.before.data();
    const currentUserId = context.params.documentId;

    // We only want to update if the friends list is updated
    if (after.friends == before.friends) {
      return null;
    }

    // i.e. friend is added
    if (before.friends == null ||
      (after.friends != null &&
        after.friends.length > before.friends.length)) {
      const friendId = before.friends == null ? after.friends[0] :
        after.friends.filter(
          (x) => !before.friends.includes(x))[0];

      // Add the current user to the friends 'friends'
      admin.firestore().collection("users")
        .doc(friendId)
        .update({
          friends: admin.firestore.FieldValue
            .arrayUnion(currentUserId),
        });
      // Remove them from the 'friendRequests'
      admin.firestore().collection("users")
        .doc(friendId)
        .update({
          friendRequests: admin.firestore.FieldValue
            .arrayRemove(currentUserId),
        });
    } else if (after.friends == null ||
      (before.friends != null &&
        after.friends.length < before.friends.length)) {
      // i.e. friend has been removed
      const friendId = after.friends == null ? before.friends[0] :
        before.friends.filter(
          (x) => !after.friends.includes(x))[0];
      // remove the current user from the friend's 'friends'
      admin.firestore().collection("users")
        .doc(friendId)
        .update({
          friends: admin.firestore.FieldValue
            .arrayRemove(currentUserId),
        });
    }
});



async function sendFriendRequestNotification(userId, requesterId) {
  // Get the user's details
  const user = await admin.firestore().collection("users").doc(userId).get();
  const requester = await admin.firestore().collection("users").doc(requesterId).get();

  await admin.messaging().sendMulticast({
    tokens: user.data().tokens,
    data: {
      type: "friendRequest",
      friendId: requesterId
    },
    notification: {
      title: "New friend invite",
      body: requester.data().username + " would like to be your friend!",
      imageUrl: requester.data().imageUrl,
    },
  });
}
