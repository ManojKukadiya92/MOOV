const functions = require("firebase-functions");
const admin = require("firebase-admin");
const algoliasearch = require("algoliasearch");
// const stripe = require("stripe")(functions.config().stripe.testkey);
const braintree = require("braintree");
admin.initializeApp(functions.config().firebase);

exports.businessPosted = functions.database.instance("moov4-4d3c4").ref("/businessPost/{postedItem}")
    .onCreate( async (snapshot, context) => {
      // Grab the current value of what was written to the Realtime Database.
      const data = snapshot.val();
      // const businessId = data.businessId;
      const postedItem = context.params.postedItem;
      console.log("here: ", data["businessId"]);
      const details = data["details"];
      const businessCode = data["businessId"];
      const moovTitle = data["title"];
      const moovOver = data["moovOver"];
      console.log("time: ", data["startTime"]);
      const startTime = admin.firestore.Timestamp.fromMillis(data["startTime"]);
      const unix = data["startTime"];
      const maxOccupancy = data["maxOccupancy"];
      const cost = data["cost"];
      // retrieve business info
      const db = admin.database();
      const ref = db.ref("users");
      // Attach an asynchronous callback to read the data at our posts reference
      ref.on("value", async (snapshot) => {
        // console.log("We did it! ", snapshot.val());
        const businessProfile = snapshot.val()[`${businessCode}`]["user"];
        const businessType = businessProfile["businessType"];
        console.log("latitude/longitude: ", businessProfile["businessLocation"]);
        const location = new admin.firestore.GeoPoint(businessProfile["businessLocation"]["_latitude"], businessProfile["businessLocation"]["_longitude"]);
        const businessLocation = location;
        const displayName = businessProfile["displayName"];
        const businessId = businessProfile["id"];
        const dorm = businessProfile["dorm"];
        const userRef = admin.firestore().collection("notreDame").doc("data").collection("users").doc(`${businessId}`);
        const doc = await userRef.get();
        const image = doc.data().header;
        // post that shit
        console.log("posting now!");
        admin.firestore().collection("notreDame").doc("data").collection("food").doc(`${postedItem}`).set({
          businessPost: true,
          moovOver: moovOver,
          privacy: "Public",
          push: "true",
          type: businessType,
          location: location,
          title: moovTitle,
          userId: businessId,
          address: dorm,
          description: details,
          startDate: startTime,
          unix: unix,
          maxOccupancy: maxOccupancy,
          paymentAmount: cost,
          image: image,
          statuses: {},
          stats: {},
          going: [],
          menu: {},
          goingCount: 0,
          checkInMap: {},
          tags: [],
          featured: false,
          isPartyOrBar: true,
          businessLocation: businessLocation,
          posterName: displayName,
          postId: postedItem,
        }, {merge: true});
      }, (errorObject) => {
        console.log("The read failed: " + errorObject.name);
      });
      return null;
    });

exports.sendUserDataToRealTimeDB = functions.firestore
    .document("{college}/data/users/{userId}")
    .onCreate( async (snap, context) => {
      const userId = context.params.userId;
      const college = context.params.college;
      const userRef = admin.firestore().collection(`${college}`).doc("data").collection("users").doc(`${userId}`);
      const doc = await userRef.get();
      // fields
      const isBusiness = doc.data().isBusiness;
      const businessType = doc.data().businessType;
      const displayName = doc.data().displayName;
      const email = doc.data().email;
      const photoUrl = doc.data().photoUrl;
      const businessCode = doc.data().businessCode;
      const dorm = doc.data().dorm;
      const id = doc.data().id;
      const businessLocation = doc.data().businessLocation;
      // realtime db
      const db = admin.database();
      const ref = db.ref("users");
      const usersRef = ref.child(businessCode);
      usersRef.set({
        user: {
          isBusiness: isBusiness,
          id: id,
          businessType: businessType,
          displayName: displayName,
          email: email,
          photoUrl: photoUrl,
          businessCode: businessCode,
          businessLocation: businessLocation,
          dorm: dorm,
        },
      });
    });

exports.brainTree = functions.firestore
    .document("{college}/data/users/{userId}/payments/{paymentMethodItem}")
    .onCreate(async (snapshot, context) => {
      const paymentMethod = context.params.paymentMethodItem;
      const user = context.params.userId;
      const college = context.params.college;
      // get updated payment information
      const paymentRef = admin.firestore().collection(`${college}`).doc("data").collection("users").doc(`${user}`).collection("payments").doc(`${paymentMethod}`);
      const userRef = admin.firestore().collection(`${college}`).doc("data").collection("users").doc(`${user}`);
      const doc = await paymentRef.get();
      const userDoc = await userRef.get();
      const amountCharged = doc.data().amount;
      let custId = userDoc.data().braintree_customer_id;
      const userDisplayName = userDoc.data().displayName;
      const userEmail = userDoc.data().email;

      const gateway = new braintree.BraintreeGateway({
        environment: braintree.Environment.Sandbox,
        merchantId: "63hmws26h3ncb2m4",
        publicKey: "4w8d3g69x27qrtv2",
        privateKey: "d6e6441e1b10e2126f5e8a4e534a981b",
      });
      if (!custId) {
        gateway.customer.create({
          firstName: userDisplayName,
          email: userEmail,
        }, (err, result) => {
          result.success;
          // true
          custId = result.customer.id;
          // e.g. 494019
        });
      } else {
        gateway.customer.find(custId, function(err, customer) {
          custId = customer.id;
        });
      }
      gateway.clientToken.generate({
        customerId: custId,
      }, (err, response) => {
        // pass clientToken to your front-end
        const cToken = response.clientToken;
        admin.firestore().collection(`${college}`).doc("data").collection("users").doc(`${user}`).collection("payments").doc(`${paymentMethod}`).set({
          clientToken: cToken,
          status: "processing",
          customer_transaction_id: custId,
        }, {merge: true});
        admin.firestore().collection(`${college}`).doc("data").collection("users").doc(`${user}`).set({
          braintree_customer_id: custId,
        }, {merge: true});
      });
      const nonce = await doc.data().nonce;

      // payment method logic
      gateway.paymentMethod.create({
        customerId: custId,
        paymentMethodNonce: nonce,
      }, (err, result) => { });
      const devData = await doc.data().deviceData;
      // console.log("payment nonceee: ", nonce);
      // create transaction
      gateway.transaction.sale({
        amount: amountCharged,
        // paymentMethodNonce: nonce,
        customerId: custId,
        deviceData: devData,
        options: {
          submitForSettlement: true,
          storeInVaultOnSuccess: true,
        },
      }, (err, result) => {
        console.log(result);
        admin.firestore().collection(`${college}`).doc("data").collection("users").doc(`${user}`).collection("payments").doc(`${paymentMethod}`).set({
          status: "success",
        }, {merge: true});
      });
    });

const ALGOLIA_APP_ID = "CUWBHO409I";
const ALGOLIA_ADMIN_KEY = "53390b64ddeba1e1f32e81485ebf9492";
const ALGOLIA_INDEX_NAME = "users";
const ALGOLIA_INDEX_NAME2 = "events";
const ALGOLIA_INDEX_NAME3 = "groups";
const ALGOLIA_INDEX_NAME4 = "communityGroups";

exports.createPost = functions.firestore
    .document("{college}/data/users/{userId}")
    .onCreate( async (snap, context) => {
      const newValue = snap.data();
      newValue.objectID = snap.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME);
      index.saveObject(newValue);
      console.log("Finished");
    });

exports.updatePost = functions.firestore
    .document("{college}/data/users/{userId}")
    .onUpdate( async (snap, context) => {
      const afterUpdate = snap.after.data();
      afterUpdate.objectID = snap.after.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME);
      index.saveObject(afterUpdate);
    });

exports.deletePost = functions.firestore
    .document("{college}/data/users/{userId}")
    .onDelete( async (snap, context) => {
      const oldID = snap.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME);
      index.deleteObject(oldID);
    });

exports.createEvent = functions.firestore
    .document("{college}/data/food/{eventId}")
    .onCreate( async (snap, context) => {
      const newValue = snap.data();
      newValue.objectID = snap.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME2);
      index.saveObject(newValue);
      console.log("Finished");
    });

exports.updateEvent = functions.firestore
    .document("{college}/data/food/{eventId}")
    .onUpdate( async (snap, context) => {
      const afterUpdate = snap.after.data();
      afterUpdate.objectID = snap.after.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME2);
      index.saveObject(afterUpdate);
    });

exports.deleteEvent = functions.firestore
    .document("{college}/data/food/{eventId}")
    .onDelete( async (snap, context) => {
      const oldID = snap.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME2);
      index.deleteObject(oldID);
    });

exports.createGroup = functions.firestore
    .document("{college}/data/friendGroups/{groupId}")
    .onCreate( async (snap, context) => {
      const newValue = snap.data();
      newValue.objectID = snap.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME3);
      index.saveObject(newValue);
      console.log("Finished");
    });

exports.updateGroup = functions.firestore
    .document("{college}/data/friendGroups/{groupId}")
    .onUpdate( async (snap, context) => {
      const afterUpdate = snap.after.data();
      afterUpdate.objectID = snap.after.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME3);
      index.saveObject(afterUpdate);
    });

exports.deleteGroup = functions.firestore
    .document("{college}/data/friendGroups/{groupId}")
    .onDelete( async (snap, context) => {
      const oldID = snap.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME3);
      index.deleteObject(oldID);
    });

exports.createCommunityGroup = functions.firestore
    .document("{college}/data/communityGroups/{groupId}")
    .onCreate( async (snap, context) => {
      const newValue = snap.data();
      newValue.objectID = snap.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME4);
      index.saveObject(newValue);
      console.log("Finished");
    });

exports.updateCommunityGroup = functions.firestore
    .document("{college}/data/communityGroups/{groupId}")
    .onUpdate( async (snap, context) => {
      const afterUpdate = snap.after.data();
      afterUpdate.objectID = snap.after.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME4);
      index.saveObject(afterUpdate);
    });

exports.deleteCommunityGroup = functions.firestore
    .document("{college}/data/communityGroups/{groupId}")
    .onDelete( async (snap, context) => {
      const oldID = snap.id;
      const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
      const index = client.initIndex(ALGOLIA_INDEX_NAME4);
      index.deleteObject(oldID);
    });

exports.onCreateActivityFeedItem = functions.firestore
    .document("{college}/data/notificationFeed/{userId}/feedItems/{activityFeedItem}")
    .onCreate(async (snapshot, context) => {
      console.log("Activity Feed Item Created", snapshot.data());

      // 1) Get user connected to the feed
      const userId = context.params.userId;
      const college = context.params.college;

      const userRef = admin.firestore().doc(`${college}/data/users/${userId}`);
      const doc = await userRef.get();

      // 2) check if they have a notification token
      const androidNotificationToken = doc.data().androidNotificationToken;
      const createdActivityFeedItem = snapshot.data();
      const pushSettings = doc.data().pushSettings;
      if (androidNotificationToken) {
        if (pushSettings.going == true && createdActivityFeedItem.type == "going") {
          sendNotification(androidNotificationToken, createdActivityFeedItem);
        } else if (pushSettings.friendPosts == true && createdActivityFeedItem.type == "created" && createdActivityFeedItem.userId != "107290090512658207959") {
          sendNotification(androidNotificationToken, createdActivityFeedItem);
        } else if (pushSettings.suggestions == true && createdActivityFeedItem.type == "suggestion") {
          sendNotification(androidNotificationToken, createdActivityFeedItem);
        } else if (createdActivityFeedItem.type != "suggestion" && createdActivityFeedItem.type != "created" && createdActivityFeedItem.type != "going") {
          sendNotification(androidNotificationToken, createdActivityFeedItem);
        }
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
        let title;
        let post;
        let id;

        // 3) switch body value based off of notification type
        switch (activityFeedItem.type) {
          case "invite":
            title = `${activityFeedItem.username}`;
            body = `invited you to ${activityFeedItem.title}`;
            post = "post";
            id = `${activityFeedItem.postId}`;
            break;
          case "sent":
            title = `${activityFeedItem.username}`;
            body = `sent you ${activityFeedItem.title}`;
            post = "post";
            id = `${activityFeedItem.postId}`;
            break;
          case "edit":
            title = `${activityFeedItem.username}`;
            body = "has been updated with a new start time";
            post = "post";
            id = `${activityFeedItem.postId}`;
            break;
          case "going":
            title = `${activityFeedItem.title}`;
            body = `${activityFeedItem.username} is going!`;
            post = "post";
            break;
          case "friendGroup":
            title = `${activityFeedItem.username}`;
            body = `added you to the Friend Group, ${activityFeedItem.groupName}`;
            post = "group";
            id = `${activityFeedItem.groupId}`;
            break;
          case "suggestion":
            title = `${activityFeedItem.groupName}`;
            body = `${activityFeedItem.username} suggested ${activityFeedItem.title}`;
            post = "group";
            id = `${activityFeedItem.groupId}`;
            break;
          case "comment":
            title = `${activityFeedItem.title}`;
            body = `${activityFeedItem.username} commented: "${activityFeedItem.message}"`;
            post = "post";
            id = `${activityFeedItem.postId}`;
            break;
          case "request":
            title = `${activityFeedItem.username}`;
            body = "sent you a friend request";
            post = "user";
            id = `${activityFeedItem.id}`;
            break;
          case "created":
            title = `${activityFeedItem.username}`;
            body = `just posted ${activityFeedItem.title}`;
            post = "post";
            break;
          case "deleted":
            title = `${activityFeedItem.username} `;
            body = "has been canceled";
            break;
          case "accept":
            title = `${activityFeedItem.username} `;
            body = "accepted your friend request";
            post = "user";
            id = `${activityFeedItem.id}`;
            break;
          default:
            break;
        }

        // 4) Create message for push notification
        const message = {
          notification: {title, body},
          token: androidNotificationToken,
          data: {recipient: userId, page: post, link: id},
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

exports.onCreateGroupFeedItem = functions.firestore
    .document("{college}/data/notificationFeed/{groupId}/feedItems/{activityFeedItem}")
    .onCreate(async (snapshot, context) => {
      console.log("Activity Feed Item Created", snapshot.data());

      // 1) Get user connected to the feed
      const groupId = context.params.groupId;
      const college = context.params.college;

      const groupRef = admin.firestore().doc(`${college}/data/friendGroups/${groupId}`);
      const doc = await groupRef.get();
      const name = doc.data().groupName;
      let userId;

      // 2) check if they have a notification token
      const members = doc.data().members;
      const createdActivityFeedItem = snapshot.data();
      for (let i = 0; i < members.length; i++) {
        const userRef = admin.firestore().doc(`${college}/data/users/${members[i]}`);
        const userdoc = await userRef.get();
        userId = userdoc.data().id;
        if (userdoc.data().androidNotificationToken && userdoc.data().pushSettings["suggestions"] == true) {
          sendNotification(userdoc.data().androidNotificationToken, createdActivityFeedItem);
        } else {
          console.log("No token for user, cannot send notification");
        }
      }
      /**
       * Adds two numbers together.
       * @param {string} androidNotificationToken The first number.
       * @param {string} activityFeedItem The second number.
       * @return {void} The sum of the two numbers.
       */
      function sendNotification(androidNotificationToken, activityFeedItem) {
        let body;
        let title;
        let id;
        let post;

        // 3) switch body value based off of notification type
        switch (activityFeedItem.type) {
          case "invite":
            title = `${name}`;
            body = `${activityFeedItem.username} has invited you all to ${activityFeedItem.title}`;
            post = "post";
            id = `${activityFeedItem.postId}`;
            break;
          case "suggestion":
            title = `${activityFeedItem.groupName}`;
            body = `${activityFeedItem.username} suggested ${activityFeedItem.title}`;
            id = `${activityFeedItem.groupId}`;
            break;
          case "canceled":
            title = `${activityFeedItem.title}`;
            body = "has been canceled";
            break;
          case "sent":
            title = `${activityFeedItem.username}`;
            body = `sent ${activityFeedItem.title} to your friend group`;
            break;
          case "askToJoin":
            title = `${activityFeedItem.groupName}`;
            body = `${activityFeedItem.username} requested to join`;
            break;
          case "chat":
            title = `${activityFeedItem.groupName}`;
            body = `${activityFeedItem.username}: ${activityFeedItem.title}`;
            post = "chat";
            id = `${activityFeedItem.groupId}`;
            break;
          default:
            break;
        }

        // 4) Create message for push notification
        const message = {
          notification: {title, body},
          token: androidNotificationToken,
          data: {recipient: userId, click_action: "FLUTTER_NOTIFICATION_CLICK", link: id, page: post},
        };

        // 5) Send message with admin.messaging()
        if (activityFeedItem.userId != userId) {
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
      }
    });

exports.groupChat = functions.firestore
    .document("{college}/data/friendGroups/{groupId}/chat/{activityFeedItem}")
    .onCreate(async (snapshot, context) => {
      console.log("Activity Feed Item Created", snapshot.data());

      // 1) Get user connected to the feed
      const groupId = context.params.groupId;
      const college = context.params.college;

      const groupRef = admin.firestore().doc(`${college}/data/friendGroups/${groupId}`);
      const doc = await groupRef.get();
      const groupName = doc.data().groupName;
      let userId;

      // 2) check if they have a notification token
      const members = doc.data().members;
      const createdActivityFeedItem = snapshot.data();
      const senderId = createdActivityFeedItem.userId;
      for (let i = 0; i < members.length; i++) {
        const userRef = admin.firestore().doc(`${college}/data/users/${members[i]}`);
        const userdoc = await userRef.get();
        userId = userdoc.data().id;
        console.log("sender id:", senderId);
        console.log("user id: ", userId);
        if (userdoc.data().androidNotificationToken && userdoc.data().pushSettings["suggestions"] == true && userId != senderId) {
          sendNotification(userdoc.data().androidNotificationToken, createdActivityFeedItem, groupName);
        } else {
          console.log("No token for user, cannot send notification");
        }
      }
      /**
       * Adds two numbers together.
       * @param {string} androidNotificationToken The first number.
       * @param {string} activityFeedItem The second number.
       * @param {string} groupName The second number.
       * @return {void} The sum of the two numbers.
       */
      function sendNotification(androidNotificationToken, activityFeedItem, groupName) {
        const body = `${activityFeedItem.displayName}: "${activityFeedItem.comment}"`;
        const title = `${groupName}`;
        // 4) Create message for push notification
        const message = {
          notification: {title, body},
          token: androidNotificationToken,
          data: {recipient: userId, page: "group", click_action: "FLUTTER_NOTIFICATION_CLICK", link: groupId},
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

exports.directMessage = functions.firestore
    .document("{college}/data/directMessages/{chatId}/chat/{activityFeedItem}")
    .onCreate(async (snapshot, context) => {
      console.log("Activity Feed Item Created", snapshot.data());

      // 1) Get user connected to the feed
      const chatId = context.params.chatId;
      const college = context.params.college;

      const chatRef = admin.firestore().doc(`${college}/data/directMessages/${chatId}`);
      const doc = await chatRef.get();
      const chatters = doc.data().people;
      let receiverId;

      // 2) check if they have a notification token
      const createdActivityFeedItem = snapshot.data();
      const senderId = createdActivityFeedItem.userId;
      for (let i = 0; i < chatters.length; i++) {
        const userRef = admin.firestore().doc(`${college}/data/users/${chatters[i]}`);
        const userDoc = await userRef.get();
        receiverId = userDoc.data().id;
        console.log("sender id:", senderId);
        console.log("receiver id: ", receiverId);
        if (userDoc.data().androidNotificationToken && receiverId != senderId) {
          sendNotification(userDoc.data().androidNotificationToken, createdActivityFeedItem);
        } else {
          console.log("No token for user, cannot send notification");
        }
      }
      /**
       * Adds two numbers together.
       * @param {string} androidNotificationToken The first number.
       * @param {string} activityFeedItem The second number.
       * @param {string} groupName The second number.
       * @return {void} The sum of the two numbers.
       */
      function sendNotification(androidNotificationToken, activityFeedItem) {
        let body = `${activityFeedItem.comment}`;
        const title = `${activityFeedItem.displayName}`;
        // 4) Create message for push notification
        if (activityFeedItem.isMoovInChat == true) {
          body = `sent you ${activityFeedItem.moovInChatTitle}`;
        }
        const message = {
          notification: {title, body},
          token: androidNotificationToken,
          data: {recipient: receiverId, page: "chat", click_action: "FLUTTER_NOTIFICATION_CLICK", link: chatId},
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

exports.resetScore = functions.pubsub.schedule("55 23 * * 0").timeZone("America/New_York")
    .onRun(async (context) => {
      const querySnapshot = admin
          .firestore().collection("notreDame").doc("data")
          .collection("users").get()
          .then((snapshot) => {
            snapshot.docs.forEach(async (doc) => {
              const data = doc.data();
              admin.firestore().collection("notreDame").doc("data").collection("users").doc(`${data.id}`).set({
                score: 0,
              }, {merge: true});
              console.log("Scores wiped!");
            });
            console.log(querySnapshot);
          });
    });

exports.resetLimits = functions.pubsub.schedule("0 0 * * *")
    .onRun(async (context) => {
      const querySnapshot = admin
          .firestore().collection("notreDame").doc("data")
          .collection("users").get()
          .then((snapshot) => {
            snapshot.docs.forEach(async (doc) => {
              const data = doc.data();
              if (data != null) {
                admin.firestore().collection("notreDame").doc("data").collection("users").doc(`${data.id}`).set({
                  postLimit: 3,
                  sendLimit: 5,
                  groupLimit: 2,
                  suggestLimit: 5,
                }, {merge: true});
                console.log("Limits reset!");
              }
            });
            console.log(querySnapshot);
          });
    });

exports.editPostNotif = functions.firestore
    .document("{college}/data/food/{postId}")
    .onUpdate(async (snapshot, context) => {
      const postId = context.params.postId;
      const college = context.params.college;
      const postRef = admin.firestore().doc(`${college}/data/food/${postId}`);
      const doc = await postRef.get();
      let userId;
      const oldTime = snapshot.before.startDate.toDate();
      console.log("old time: ", oldTime);
      const newTime = snapshot.after.startDate.toDate();

      // 2) check if they have a notification token
      const going = doc.data().going;
      const createdActivityFeedItem = snapshot.data();
      console.log("created: ", createdActivityFeedItem);
      const senderId = createdActivityFeedItem.userId;
      for (let i = 0; i < going.length; i++) {
        const userRef = admin.firestore().doc(`${college}/data/users/${going[i]}`);
        const userdoc = await userRef.get();
        userId = userdoc.data().id;
        console.log("sender id:", senderId);
        console.log("user id: ", userId);
        if (userdoc.data().androidNotificationToken && userId != senderId && oldTime != newTime) {
          sendNotification(userdoc.data().androidNotificationToken, createdActivityFeedItem, newTime);
        } else {
          console.log("No token for user, cannot send notification");
        }
      }
      /**
       * Adds two numbers together.
       * @param {string} androidNotificationToken The first number.
       * @param {string} activityFeedItem The second number.
       * @param {string} newTime The second number.
       * @return {void} The sum of the two numbers.
       */
      function sendNotification(androidNotificationToken, activityFeedItem, newTime) {
        const body = `was updated to ${newTime}`;
        const title = `${activityFeedItem.title}`;
        const post = `${activityFeedItem.postId}`;
        // 4) Create message for push notification
        const message = {
          notification: {title, body},
          token: androidNotificationToken,
          data: {recipient: userId, page: "post", link: post, click_action: "FLUTTER_NOTIFICATION_CLICK"},
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

exports.scheduledFunction = functions.pubsub.schedule("* * * * *")
    .onRun(async (context) => {
      const now = admin.firestore.Timestamp.now();
      const querySnapshot = admin
          .firestore().collection("notreDame").doc("data")
          .collection("food")
          .where("startDate", ">=", now).get()
          .then((snapshot) => {
            snapshot.docs.forEach(async (doc) => {
              // doc is a DocumentSnapshot with actual data
              const data = doc.data();
              data.going.forEach(async (goingUser) => {
                const user = admin.firestore().collection("notreDame").doc("data").collection("users").doc(`${goingUser}`);
                const getUser = await user.get();
                const notifToken = getUser.data().androidNotificationToken;
                const message = {
                  notification: {title: data.title, body: "starts in one hour, don't flake!"},
                  token: notifToken,
                  data: {recipient: user.id, click_action: "FLUTTER_NOTIFICATION_CLICK"},
                };
                if (data.startDate.toDate().getDate() == now.toDate().getDate() && data.startDate.toDate().getMonth() == now.toDate().getMonth() && data.startDate.toDate().getFullYear() == now.toDate().getFullYear()) {
                  if ((data.startDate.toDate().getMinutes() - 60 == now.toDate().getMinutes()) && data.scheduled != "true") {
                    admin.firestore().collection("notreDame").doc("data").collection("food").doc(`${data.postId}`).set({
                      scheduled: "true",
                    }, {merge: true});
                    admin
                        .messaging()
                        .send(message)
                        .then((response) => {
                          // Response is a message ID string
                          console.log("Successfully sent message!", response, querySnapshot);
                        })
                        .catch((error) => {
                          console.log("Error sending message", error);
                        });
                  }
                  // else if ((data.startDate.toDate().getHours() + 1 == now.toDate().getHours()) && data.scheduled != "true") {
                  //   console.log("deleting post!");
                  //   // admin.firestore().collection("notreDame").doc("data").collection("food").doc(`${data.postId}`).collection("comments").delete();
                  //   // admin.firestore().collection("notreDame").doc("data").collection("food").doc(`${data.postId}`).delete();
                  // }
                  console.log(querySnapshot, message);
                }
              });
            });
          })
          .catch((error) => {
            console.log("Error Alvin: ", error);
          });
    });
