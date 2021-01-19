const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onCreateActivityFeedItem = functions.firestore
    .document("/notificationFeed/{userId}/feedItems/{activityFeedItem}")
    .onCreate(async (snapshot, context) => {
      console.log("Activity Feed Item Created", snapshot.data());

      // 1) Get user connected to the feed
      const userId = context.params.userId;

      const userRef = admin.firestore().doc(`users/${userId}`);
      const doc = await userRef.get();

      // 2) check if they have a notification token
      const androidNotificationToken = doc.data().androidNotificationToken;
      const createdActivityFeedItem = snapshot.data();
      if (androidNotificationToken) {
        sendNotification(androidNotificationToken, createdActivityFeedItem);
      } else {
        console.log("No token for user, cannot send notification");
      }

      /**
       * Adds two numbers together.
       * @param {string} androidNotificationToken The first number.
       * @param {string} activityFeedItem The second number.
       * @return {void} The sum of the two numbers.
       */
      function sendNotification(androidNotificationToken, activityFeedItem) {
        let body;

        // 3) switch body value based off of notification type
        switch (activityFeedItem.type) {
          case "invite":
            body = `${activityFeedItem.username} invited you to ${activityFeedItem.title}`;
            break;
          case "going":
            body = `${activityFeedItem.username} is going to ${activityFeedItem.title}`;
            break;
          case "friendGroup":
            body = `${activityFeedItem.username} added you to their friend group, ${activityFeedItem.groupName}`;
            break;
          case "request":
            body = `${activityFeedItem.username} sent you a friend request`;
            break;
          case "accept":
            body = `${activityFeedItem.username} accepted your friend request`;
            break;
          default:
            break;
        }

        // 4) Create message for push notification
        const message = {
          notification: {body},
          token: androidNotificationToken,
          data: {recipient: userId},
        };

        // 5) Send message with admin.messaging()
        admin
            .messaging()
            .send(message)
            .then((response) => {
              // Response is a message ID string
              console.log("Successfully sent message!", response);
            })
            .catch((error) => {
              console.log("Error sending message", error);
            });
      }
    });

functions.pubsub.schedule("* * * * *").onRun(async () => {
  const now = admin.firestore.Timestamp.now().toMillis;
  const querySnapshot = await admin
      .firestore()
      .collection("food")
      .where("startDateTimestamp", "<", now)
      .get();

  const batch = admin.firestore().batch();

  querySnapshot.forEach((docSnapshot) => {
    batch.delete(docSnapshot.ref);
  });

  await batch.commit();
});

exports.scheduledFunction = functions.pubsub.schedule("every 5 minutes")
    .onRun(async (context) => {
      const now = admin.firestore.Timestamp.now().toMillis;

      const querySnapshot = await admin
          .firestore()
          .collection("food")
          .where("startDateTimestamp", "<", now)
          .get();

      const batch = admin.firestore().batch();

      querySnapshot.forEach((docSnapshot) => {
        batch.delete(docSnapshot.ref);
      });

      await batch.commit(); return null;
    });
