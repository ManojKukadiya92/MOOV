import 'dart:async';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/widgets/sundayWrapup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class Database {
  final dbRef = FirebaseFirestore.instance;
  var postPic;
  String ownerId;
  dynamic startDate;
  var title;
  bool featured;
  String postId;
  String previewImg;

  final GoogleSignInAccount user = googleSignIn.currentUser;
  final strUserId = googleSignIn.currentUser.id;
  final strUserName = googleSignIn.currentUser.displayName;
  final strPic = googleSignIn.currentUser.photoUrl;

  FutureOr inviteesNotification(postId, previewImg, title, statuses) {
    if (statuses.length > 0) {
      for (int i = 0; i < statuses.length; i++) {
        notificationFeedRef
            .doc(statuses[i])
            .collection('feedItems')
            .doc('invite ' + postId)
            .set({
          "seen": false,
          "type": "invite",
          "postId": postId,
          "previewImg": previewImg,
          "title": title,
          "username": currentUser.displayName,
          "userId": currentUser.id,
          "userProfilePic": currentUser.photoUrl,
          "timestamp": DateTime.now()
        });
      }
    }
  }

  canceledNotification(String postId, String title, List<dynamic> going) {
    for (var i = 0; i < going.length; i++) {
      if (going[i] != currentUser.id) {
        notificationFeedRef
            .doc(going[i])
            .collection("feedItems")
            .doc('canceled ' + postId)
            .set({
          "seen": false,
          "type": "deleted",
          "username": title,
          "userId": currentUser.id,
          "userEmail": currentUser.email,
          "postId": postId,
          "userProfilePic": currentUser.photoUrl,
          "timestamp": DateTime.now()
        });
      }
    }
  }

  setNotifsSeen() {
    notificationFeedRef
        .doc(currentUser.id)
        .collection('feedItems')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.set({"seen": true}, SetOptions(merge: true));
      }
    });
  }

  setMessagesSeen(dmId) {
    messagesRef.doc(dmId).collection('chat').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({"seen": true});
      }
    });
    messagesRef.doc(dmId).update({"seen": true});
  }

  editPostNotification(String postId, String title, List<dynamic> going) {
    for (var i = 0; i < going.length; i++) {
      if (going[i] != currentUser.id) {
        notificationFeedRef
            .doc(going[i])
            .collection("feedItems")
            .doc('edit ' + DateTime.now().toString())
            .set({
          "seen": false,
          "type": "edit",
          "username": title,
          "userId": currentUser.id,
          "userEmail": currentUser.email,
          "postId": postId,
          "userProfilePic": currentUser.photoUrl,
          "timestamp": DateTime.now()
        });
      }
    }
  }

  void createPost(
      {title,
      description,
      type,
      privacy,
      address,
      DateTime startDate,
      String startDateSimpleString,
      int unix,
      statuses,
      String clubId,
      int maxOccupancy,
      int paymentAmount,
      imageUrl,
      userId,
      postId,
      posterName,
      bool push,
      GeoPoint location,
      int goingCount,
      bool moovOver}) {
    bool isPartyOrBar = false;
    if (type == "Parties" || type == "Bars & Restaurants") {
      isPartyOrBar = true;
    }

    archiveRef.doc(postId).set({
      'title': title,
      'type': type,
      'businessPost': false,
      'privacy': privacy,
      'description': description,
      'address': address,
      'startDate': startDate,
      'unix': unix,
      'statuses': {for (var v in statuses) v: -1},
      'clubId': clubId,
      'maxOccupancy': maxOccupancy,
      'paymentAmount': paymentAmount,
      'image': imageUrl,
      'userId': userId,
      "featured": false,
      "postId": postId,
      "posterName": posterName,
      "push": push,
      "goingCount": 0,
      "location": location,
      "going": [],
      "isPartyOrBar": isPartyOrBar,
      "stats": {},
      "moovOver": moovOver,
      "tags": []
    });

    postsRef.doc(postId).set({
      'title': title,
      'type': type,
      'businessPost': false,
      'privacy': privacy,
      'description': description,
      'address': address,
      'startDate': startDate,
      'startDateSimpleString': startDateSimpleString,
      'unix': unix,
      'clubId': clubId,
      'statuses': {for (var v in statuses) v: -1},
      'maxOccupancy': maxOccupancy,
      'paymentAmount': paymentAmount,
      'image': imageUrl,
      'userId': userId,
      "featured": false,
      "postId": postId,
      "posterName": posterName,
      "push": push,
      "goingCount": 0,
      "location": location,
      "going": [],
      "isPartyOrBar": isPartyOrBar,
      "stats": {},
      "moovOver": moovOver,
      "tags": []
    }).then(inviteesNotification(postId, imageUrl, title, statuses));

    if (privacy == 'Public' || privacy == 'Friends Only') {
      var peepsToAlert;
      currentUser.isBusiness == true
          ? peepsToAlert = currentUser.followers
          : peepsToAlert = currentUser.friendArray;
      friendCreatedNotification(postId, title, imageUrl, peepsToAlert);
    }
    usersRef.doc(currentUser.id).get().then((value) {
      if (value['postLimit'] >= 1) {
        print(value['postLimit']);
        usersRef
            .doc(currentUser.id)
            .update({"postLimit": FieldValue.increment(-1)});
        usersRef
            .doc(currentUser.id)
            .update({"score": FieldValue.increment(100)});
      }
    });
  }

  void createBusinessPost(
      {title,
      description,
      type,
      privacy,
      address,
      DateTime startDate,
      String startDateSimpleString,
      int unix,
      statuses,
      int maxOccupancy,
      int paymentAmount,
      imageUrl,
      userId,
      postId,
      posterName,
      String recurringType,
      bool push,
      int goingCount,
      bool moovOver,
      Map mobileOrderMenu,
      bool noArchive = false}) {
    bool isPartyOrBar = false;
    if (type == "Parties" || type == "Bars & Restaurants") {
      isPartyOrBar = true;
    }

    if (!noArchive) {
      archiveRef.doc(postId).set({
        'title': title,
        'type': type,
        "businessPost": true,
        "location": currentUser.businessLocation,
        "checkInMap": {},
        'privacy': privacy,
        'description': description,
        'address': address,
        'startDate': startDate,
        'startDateSimpleString': startDateSimpleString,
        'unix': unix,
        'statuses': {for (var v in statuses) v: -1},
        'maxOccupancy': maxOccupancy,
        'paymentAmount': paymentAmount,
        'image': imageUrl,
        'userId': userId,
        "featured": false,
        "postId": postId,
        "posterName": posterName,
        "push": push,
        "goingCount": 0,
        "going": [],
        "isPartyOrBar": isPartyOrBar,
        "stats": {},
        "moovOver": moovOver,
        "tags": [],
        "recurringType": recurringType,
        "mobileOrderMenu": mobileOrderMenu
      });
    }

    postsRef.doc(postId).set({
      'title': title,
      'type': type,
      "businessPost": true,
      "location": currentUser.businessLocation,
      "checkInMap": {},
      'privacy': privacy,
      'description': description,
      'address': address,
      'startDate': startDate,
      'startDateSimpleString': startDateSimpleString,
      'unix': unix,
      'statuses': {for (var v in statuses) v: -1},
      'maxOccupancy': maxOccupancy,
      'paymentAmount': paymentAmount,
      'image': imageUrl,
      'userId': userId,
      "featured": false,
      "postId": postId,
      "posterName": posterName,
      "push": push,
      "goingCount": 0,
      "going": [],
      "isPartyOrBar": isPartyOrBar,
      "stats": {},
      "moovOver": moovOver,
      "recurringType": recurringType,
      "mobileOrderMenu": mobileOrderMenu,
      "tags": []
    }).then(inviteesNotification(postId, imageUrl, title, statuses));

    if (privacy == 'Public' || privacy == 'Friends Only') {
      List peepsToAlert = currentUser.followers;

      friendCreatedNotification(postId, title, imageUrl, peepsToAlert);
    }
  }

  Future<void> addNotGoing(String userId, String postId,
      List<dynamic> goingList, String title) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref = dbRef.doc('notreDame/data/food/$postId');
      // final DocumentReference ref2 = dbRef.doc('notreDame/data/users/$userId');
      // transaction.update(ref2, {'score': FieldValue.increment(10)});

      // addGoingToNotificationFeed(
      //     userId,
      //     postId
      //     );
      postsRef.doc(postId).set({
        "statuses": {userId: 1}
      }, SetOptions(merge: true));

      String serialUser = userId;
      transaction.update(ref, {
        'going': FieldValue.arrayRemove([serialUser]),

        // 'notGoing': FieldValue.arrayUnion([serialUser]),
        // 'notGoingCounter': FieldValue.increment(1)
      });
      messagesRef //sending a status update in chats where this moov is sent
          .where("people", arrayContains: currentUser.id)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          print(ds.id);
          if (ds.data()['livePosts'] != null &&
              ds.data()['livePosts'].contains(postId)) {
            messagesRef
                .doc(ds.id)
                .collection("chat")
                .doc(DateTime.now().millisecondsSinceEpoch.toString() +
                    " " +
                    currentUser.id)
                .set({
              "seen": false,
              "displayName": currentUser.displayName,
              "comment": "is not going to " + title,
              "timestamp": 0,
              "avatarUrl": postId, // just doing this to conserve data writes
              "userId": currentUser.id,
              "chatId": DateTime.now().millisecondsSinceEpoch.toString() +
                  " " +
                  currentUser.id,
              "gid": ds.data()['gid'],
              "millis": DateTime.now().millisecondsSinceEpoch.toString(),
              "directMessageId": "",
              "isGroupChat": ds.data()['isGroupChat'],
              "postId": "notxxx " + title,
              "realPostId": postId,
              "hasExpired": false
            });
          }
        }
      });
    });
  }

  Future<void> removeNotGoing(userId, postId) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref = dbRef.doc('notreDame/data/food/$postId');
      // final DocumentReference ref2 = dbRef.doc('notreDame/data/users/$userId');
      // var checkZero;
      // ref2.get().then((snap) => {
      //       if (snap.data()['score'] == 0) {checkZero = "true"}
      //     });
      // if (checkZero != "true") {
      //   transaction.update(ref2, {'score': FieldValue.increment(-10)});
      // }
      // addGoingToNotificationFeed(
      //     userId,
      //     postId
      //     );
      postsRef.doc(postId).set({
        "statuses": {user.id: FieldValue.delete()}
      }, SetOptions(merge: true));

      // String serialUser = userId;
      // transaction.update(ref, {
      //   // 'notGoing': FieldValue.arrayRemove([serialUser]),
      //   // 'notGoingCounter': FieldValue.increment(-1)
      // });
    });
  }

  Future<void> addUndecided(String userId, String postId,
      List<dynamic> goingList, String title) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref = dbRef.doc('notreDame/data/food/$postId');
      // final DocumentReference ref2 = dbRef.doc('notreDame/data/users/$userId');
      // transaction.update(ref2, {'score': FieldValue.increment(10)});

      if (goingList.contains(userId)) {
        transaction.update(ref, {'goingCount': FieldValue.increment(-1)});
      }

      postsRef.doc(postId).set({
        "statuses": {userId: 2}
      }, SetOptions(merge: true));

      String serialUser = userId;

      transaction.update(ref, {
        'going': FieldValue.arrayRemove([serialUser]),
      });

      messagesRef //sending a status update in chats where this moov is sent
          .where("people", arrayContains: currentUser.id)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          print(ds);
          if (ds.data()['livePosts'] != null &&
              ds.data()['livePosts'].contains(postId)) {
            messagesRef
                .doc(ds.id)
                .collection("chat")
                .doc(DateTime.now().millisecondsSinceEpoch.toString() +
                    " " +
                    currentUser.id)
                .set({
              "seen": false,
              "displayName": currentUser.displayName,
              "comment": "is undecided about " + title,
              "timestamp": 0,
              "avatarUrl": postId, // just doing this to conserve data writes
              "userId": currentUser.id,
              "chatId": DateTime.now().millisecondsSinceEpoch.toString() +
                  " " +
                  currentUser.id,
              "gid": ds.data()['gid'],
              "millis": DateTime.now().millisecondsSinceEpoch.toString(),
              "directMessageId": "",
              "isGroupChat": ds.data()['isGroupChat'],
              "postId": "undecidedxxx " + title,
              "realPostId": postId,
              "hasExpired": false
            });
          }
        }
      });
    });
  }

  Future<void> removeUndecided(userId, postId) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref = dbRef.doc('notreDame/data/food/$postId');
      // final DocumentReference ref2 = dbRef.doc('notreDame/data/users/$userId');
      // var checkZero;
      // ref2.get().then((snap) => {
      //       if (snap.data()['score'] == 0) {checkZero = "true"}
      //     });
      // if (checkZero != "true") {
      //   transaction.update(ref2, {'score': FieldValue.increment(-10)});
      // }
      postsRef.doc(postId).set({
        "statuses": {user.id: FieldValue.delete()}
      }, SetOptions(merge: true));

      // String serialUser = userId;
      // transaction.update(ref, {
      //   // 'undecided': FieldValue.arrayRemove([serialUser]),
      //   // 'undecidedCounter': FieldValue.increment(-1)
      // });
    });
  }

  Future<void> addGoingGood(
      userId, ownerId, postId, title, pic, bool push) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref = dbRef.doc('notreDame/data/food/$postId');
      // final DocumentReference ref2 = dbRef.doc('notreDame/data/users/$userId');
      // transaction.update(ref2, {'score': FieldValue.increment(500)});
      transaction.update(ref, {'goingCount': FieldValue.increment(1)});

      await postsRef.doc(postId).set({
        "statuses": {userId: 3},
      }, SetOptions(merge: true));

      ///NOTIF FUNCTION BELOW
      bool isNotPostOwner = strUserId != ownerId;
      if (isNotPostOwner) {
        notificationFeedRef
            .doc(ownerId)
            .collection('feedItems')
            .doc(postId + ' from ' + currentUser.id)
            .set({
          "seen": false,
          "type": "going",
          "postId": postId,
          "previewImg": pic,
          "push": push,
          "title": title,
          "username": currentUser.displayName,
          "userId": currentUser.id,
          "userProfilePic": currentUser.photoUrl,
          "timestamp": DateTime.now()
        });
      }

      String serialUser = userId;
      transaction.update(ref, {
        'going': FieldValue.arrayUnion([serialUser]),
        // 'goingCounter': FieldValue.increment(1)
      });

      messagesRef //sending a status update in chats where this moov is sent
          .where("people", arrayContains: currentUser.id)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          if (ds.data()['livePosts'] != null &&
              ds.data()['livePosts'].contains(postId)) {
            messagesRef
                .doc(ds.id)
                .collection("chat")
                .doc(DateTime.now().millisecondsSinceEpoch.toString() +
                    " " +
                    currentUser.id)
                .set({
              "seen": false,
              "displayName": currentUser.displayName,
              "comment": "is going to " + title,
              "timestamp": 0,
              "avatarUrl": postId, // just doing this to conserve data writes
              "userId": currentUser.id,
              "chatId": DateTime.now().millisecondsSinceEpoch.toString() +
                  " " +
                  currentUser.id,
              "gid": ds.data()['gid'],
              "millis": DateTime.now().millisecondsSinceEpoch.toString(),
              "directMessageId": "",
              "isGroupChat": ds.data()['isGroupChat'],
              "postId": "goingxxx " + title,
              "realPostId": postId,
              "hasExpired": false
            });
          }
        }
      });

      //add to various moov stats
      if (currentUser.gender == 'Male') {
        postsRef.doc(postId).set({
          "stats": {"maleCount": FieldValue.increment(1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.gender == 'Female') {
        postsRef.doc(postId).set({
          "stats": {"femaleCount": FieldValue.increment(1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.gender == 'Other') {
        postsRef.doc(postId).set({
          "stats": {"otherGenderCount": FieldValue.increment(1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.gender == 'Male' && currentUser.isSingle == true) {
        postsRef.doc(postId).set({
          "stats": {"singleMaleCount": FieldValue.increment(1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.gender == 'Female' && currentUser.isSingle == true) {
        postsRef.doc(postId).set({
          "stats": {"singleFemaleCount": FieldValue.increment(1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.gender == 'Other' && currentUser.isSingle == true) {
        postsRef.doc(postId).set({
          "stats": {"singleOtherCount": FieldValue.increment(1)},
        }, SetOptions(merge: true));
      }

      if (currentUser.race == 'Black') {
        postsRef.doc(postId).set({
          "stats": {"blackCount": FieldValue.increment(1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.race == 'Latino') {
        postsRef.doc(postId).set({
          "stats": {"latinoCount": FieldValue.increment(1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.race == 'Asian') {
        postsRef.doc(postId).set({
          "stats": {"asianCount": FieldValue.increment(1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.race == 'White') {
        postsRef.doc(postId).set({
          "stats": {"whiteCount": FieldValue.increment(1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.race == 'Other') {
        postsRef.doc(postId).set({
          "stats": {"otherRaceCount": FieldValue.increment(1)},
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> removeGoingGood(userId, ownerId, postId, title, pic) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref = dbRef.doc('notreDame/data/food/$postId');
      // final DocumentReference ref2 = dbRef.doc('notreDame/data/users/$userId');
      transaction.update(ref, {'goingCount': FieldValue.increment(-1)});

      // transaction.update(ref2, {'score': FieldValue.increment(-50)});
      // notificationFeedRef
      //     .doc(ownerId)
      //     .collection("feedItems")
      //     .doc(postId + ' from ' + currentUser.id)
      //     .get()
      //     .then((doc) {
      //   if (doc.exists) {
      //     doc.reference.delete();
      //   }
      // });

      // addGoingToNotificationFeed(
      //     userId,
      //     postId
      //     );

      postsRef.doc(postId).set({
        "statuses": {user.id: FieldValue.delete()}
      }, SetOptions(merge: true));

      String serialUser = userId;
      transaction.update(ref, {
        'going': FieldValue.arrayRemove([serialUser]),
        // 'goingCounter': FieldValue.increment(-5)
      });
      //add to various moov stats
      if (currentUser.gender == 'Male') {
        postsRef.doc(postId).set({
          "stats": {"maleCount": FieldValue.increment(-1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.gender == 'Female') {
        postsRef.doc(postId).set({
          "stats": {"femaleCount": FieldValue.increment(-1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.gender == 'Other') {
        postsRef.doc(postId).set({
          "stats": {"otherGenderCount": FieldValue.increment(-1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.gender == 'Male' && currentUser.isSingle == true) {
        postsRef.doc(postId).set({
          "stats": {"singleMaleCount": FieldValue.increment(-1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.gender == 'Female' && currentUser.isSingle == true) {
        postsRef.doc(postId).set({
          "stats": {"singleFemaleCount": FieldValue.increment(-1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.gender == 'Other' && currentUser.isSingle == true) {
        postsRef.doc(postId).set({
          "stats": {"singleOtherCount": FieldValue.increment(-1)},
        }, SetOptions(merge: true));
      }

      if (currentUser.race == 'Black') {
        postsRef.doc(postId).set({
          "stats": {"blackCount": FieldValue.increment(-1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.race == 'Latino') {
        postsRef.doc(postId).set({
          "stats": {"latinoCount": FieldValue.increment(-1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.race == 'Asian') {
        postsRef.doc(postId).set({
          "stats": {"asianCount": FieldValue.increment(-1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.race == 'White') {
        postsRef.doc(postId).set({
          "stats": {"whiteCount": FieldValue.increment(-1)},
        }, SetOptions(merge: true));
      }
      if (currentUser.race == 'Other') {
        postsRef.doc(postId).set({
          "stats": {"otherRaceCount": FieldValue.increment(-1)},
        }, SetOptions(merge: true));
      }
    });
  }

  // Future<void> removeLike(userId, postId) async {
  //   return dbRef.runTransaction((transaction) async {
  //     final DocumentReference ref = dbRef.doc('food/$postId');
  //     final DocumentReference ref2 = dbRef.doc('users/$userId');
  //     transaction.update(ref2, {'score': FieldValue.increment(-2)});

  //     // addGoingToNotificationFeed(
  //     //     userId,
  //     //     postId
  //     //     );
  //     Map<String, dynamic> serializedMessage = {
  //       "uid": userId,
  //     };
  //     String serialUser = userId;
  //     transaction.update(ref, {
  //       'liked': FieldValue.arrayRemove([serializedMessage]),
  //       'liker': FieldValue.arrayRemove([serialUser]),
  //       'likeCounter': FieldValue.increment(-1)
  //     });
  //     transaction.update(ref2, {
  //       'likedMoovs': FieldValue.arrayRemove([postId])
  //     });
  //   });
  // }

  Future<void> goingPushSetting(newValue) async {
    return dbRef.runTransaction((transaction) async {
      usersRef.doc(currentUser.id).set({
        "pushSettings": {"going": newValue}
      }, SetOptions(merge: true));
    });
  }

  Future<void> hourPushSetting(newValue) async {
    return dbRef.runTransaction((transaction) async {
      usersRef.doc(currentUser.id).set({
        "pushSettings": {"hourBefore": newValue}
      }, SetOptions(merge: true));
    });
  }

  Future<void> suggestionsPushSetting(newValue) async {
    return dbRef.runTransaction((transaction) async {
      usersRef.doc(currentUser.id).set({
        "pushSettings": {"suggestions": newValue}
      }, SetOptions(merge: true));
    });
  }

  addedToGroup(
    String addee,
    String groupName,
    String groupId,
    String groupPic,
  ) {
    notificationFeedRef
        .doc(addee)
        .collection("feedItems")
        .doc('added to ' + groupId)
        .set({
      "seen": false,
      "type": "friendGroup",
      "username": currentUser.displayName,
      "userId": currentUser.id,
      "userProfilePic": currentUser.photoUrl,
      "previewImg": groupPic,
      "groupId": groupId,
      "groupName": groupName,
      "timestamp": DateTime.now()
    });
  }

  askToJoinGroup(
    String asker,
    String askerPic,
    String askerId,
    String groupName,
    String groupId,
  ) {
    notificationFeedRef
        .doc(groupId)
        .collection("feedItems")
        .doc('asked to join ' + groupId)
        .set({
      "seen": false,
      "type": "askToJoin",
      "title": groupName,
      "username": currentUser.displayName,
      "userId": currentUser.id,
      "userProfilePic": currentUser.photoUrl,
      "previewImg": askerPic,
      "groupId": groupId,
      "groupName": groupName,
      "timestamp": DateTime.now()
    });
  }

  friendRequestNotification(
      String ownerId, String senderProPic, String ownerName, String sender) {
    notificationFeedRef
        .doc(ownerId)
        .collection("feedItems")
        .doc('request ' + sender)
        .set({
      "seen": false,
      "type": "request",
      "username": currentUser.displayName,
      "userId": currentUser.id,
      "userProfilePic": currentUser.photoUrl,
      "timestamp": DateTime.now(),
      "ownerName": ownerName,
    });
  }

  followBusiness(String businessId, String senderProPic, String businessName,
      String sender) {
    notificationFeedRef
        .doc(businessId)
        .collection("feedItems")
        .doc('businessFollow ' + sender)
        .set({
      "seen": false,
      "type": "businessFollow",
      "username": currentUser.displayName,
      "userId": currentUser.id,
      "userProfilePic": currentUser.photoUrl,
      "timestamp": DateTime.now(),
      "ownerName": businessName,
    });

    usersRef.doc(businessId).set({
      'followers': FieldValue.arrayUnion([currentUser.id]),
    }, SetOptions(merge: true));
  }

  unfollowBusiness(String businessId, String sender) {
    usersRef.doc(businessId).set({
      'followers': FieldValue.arrayRemove([currentUser.id]),
    }, SetOptions(merge: true));
  }

  // sendMOOVNotification(
  //   String ownerId,
  //   String previewImg,
  //   dynamic moovId,
  //   startDate,
  //   String title,
  //   String ownerProPic,
  //   String ownerName,
  // ) {
  //   notificationFeedRef
  //       .doc(ownerId)
  //       .collection("feedItems")
  //       .doc('sent ' + moovId)
  //       .set({
  //     "seen": false,
  //     "type": "chat",
  //     "username": currentUser.displayName,
  //     "userId": currentUser.id,
  //     "userProfilePic": currentUser.photoUrl,
  //     "previewImg": previewImg,
  //     "postId": moovId,
  //     "timestamp": timestamp,
  //     "startDate": startDate,
  //     "title": title,
  //     "ownerProPic": ownerProPic,
  //     "ownerName": ownerName,

  //   });

  //   usersRef.doc(currentUser.id).get().then((value) {
  //     if (value['sendLimit'] >= 0) {
  //       usersRef
  //           .doc(currentUser.id)
  //           .update({"sendLimit": FieldValue.increment(-1)});
  //       usersRef
  //           .doc(currentUser.id)
  //           .update({"score": FieldValue.increment(50)});
  //     }
  //   });
  // }

  friendAcceptNotification(
      String ownerId, String ownerProPic, String ownerName, String sender) {
    notificationFeedRef
        .doc(ownerId)
        .collection("feedItems")
        .doc('accept ' + sender)
        .set({
      "seen": false,
      "type": "accept",
      "username": currentUser.displayName,
      "userId": currentUser.id,
      "userEmail": currentUser.email,
      "userProfilePic": currentUser.photoUrl,
      "timestamp": DateTime.now(),
      "ownerProPic": ownerProPic,
      "ownerName": ownerName,
    });
  }

  commentNotification(String ownerId, String message, String postId,
      DateTime timestamp, String previewImg) {
    var title;
    postsRef.doc(postId).get().then((snap) => {
          title = snap.data()['title'],
          notificationFeedRef
              .doc(ownerId)
              .collection("feedItems")
              .doc(currentUser.id + timestamp.toString())
              .set({
            "seen": false,
            "type": "comment",
            "username": currentUser.displayName,
            "userId": currentUser.id,
            "title": title,
            "userEmail": currentUser.email,
            "userProfilePic": currentUser.photoUrl,
            "timestamp": timestamp,
            "previewImg": previewImg,
            "postId": postId,
            "message": message,
          })
        });
  }

  friendCreatedNotification(String postId, String title, String previewImg,
      List<dynamic> friendArray) {
    for (var i = 0; i < friendArray.length; i++) {
      notificationFeedRef
          .doc(friendArray[i])
          .collection("feedItems")
          .doc('created ' + postId)
          .set({
        "seen": false,
        "type": "created",
        "username": currentUser.displayName,
        "userId": currentUser.id,
        "userEmail": currentUser.email,
        "previewImg": previewImg,
        "postId": postId,
        "title": title,
        "userProfilePic": currentUser.photoUrl,
        "timestamp": DateTime.now()
      });
    }
  }

  deletePost(String postId, String ownerId, String title, Map statuses,
      String posterName) {
    postsRef.doc(postId).get().then((value) {
      if (value['statuses'].entries.length >= 10) {
        giveBadge(ownerId, "moovMaker");
      }

      List<String> statusesList = statuses.keys.toList();

      //this is saving the moov to sunday wrapup for going list people
      if (statuses != null &&
          statuses.length != 0 &&
          statuses[currentUser.id] >= 3)
      // for (int i = 0; i < statuses.length; i++) {
      {
        String who;
        nextSunday().then((value2) {
          wrapupRef.doc(currentUser.id).collection('wrapUp').doc(value2).set({
            "goingMOOVs": FieldValue.arrayUnion([
              {"pic": value['image'], "title": value['title'], "postId": postId}
            ]),
          }, SetOptions(merge: true));
          print("YAY");
        });
      }
    });
    String filePath = 'images/$ownerId$title';

    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(filePath);

    ///this is for deleting related notifications
    FirebaseFirestore.instance
        .collectionGroup("feedItems")
        .where("postId", isEqualTo: postId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    //deleting livePasses
    FirebaseFirestore.instance
        .collectionGroup("livePasses")
        .where("postId", isEqualTo: postId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    //expiring moovs that appear in chats
    FirebaseFirestore.instance
        .collectionGroup("chat")
        .where("realPostId", isEqualTo: postId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({"hasExpired": true});

        print(ds.data()['hasExpired']);
      }
    });

    FirebaseFirestore.instance

        ///this is for deleted related suggested moovs
        .collectionGroup("suggestedMOOVs")
        .where("postId", isEqualTo: postId)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });

    postsRef.doc(postId).get().then((doc) {
      if (doc.exists) {
        // _storage.ref().child(filePath).delete();
        // ref.delete();

        doc.reference.delete();
      }
    });
    postsRef.doc(postId).collection('comments').get().then((doc) {
      for (DocumentSnapshot ds in doc.docs) {
        ds.reference.delete();
      }
    });

    groupsRef.where("nextMOOV", isEqualTo: postId).get().then((doc) {
      final DocumentReference ref =
          dbRef.doc('notreDame/data/friendGroups/$doc');

      if (doc.docs.isNotEmpty) {
        return dbRef.runTransaction((transaction) async {
          transaction.update(ref, {
            'nextMOOV': FieldValue.arrayRemove([postId]),
          });
        });
      }
    });
  }

  Future<void> sendFriendRequest(String senderId, String receiverId,
      String senderName, String senderPic) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref =
          dbRef.doc('notreDame/data/users/$receiverId');
      String serializedMessage = senderId;
      transaction.update(ref, {
        'friendRequests': FieldValue.arrayUnion([serializedMessage]),
      });
    });
  }

  int lastDigit(int number) {
    return (number).abs() % 10;
  }

  Future<void> acceptFriendRequest(String senderId, String receiverId,
      String otherName, String otherPic) async {
    return dbRef.runTransaction((transaction) async {
      //adding to sunday wrapup for receiver
      nextSunday().then((value) {
        wrapupRef.doc(currentUser.id).collection('wrapUp').doc(value).set({
          "newFriends": FieldValue.arrayUnion([
            {"pic": otherPic, "id": senderId, "name": otherName}
          ]),
        }, SetOptions(merge: true));
      });

      //adding to sunday wrapup for sender
      nextSunday().then((value) {
        wrapupRef.doc(senderId).collection('wrapUp').doc(value).set({
          "newFriends": FieldValue.arrayUnion([
            {
              "pic": currentUser.photoUrl,
              "id": currentUser.id,
              "name": currentUser.displayName
            }
          ]),
        }, SetOptions(merge: true));
      });

      usersRef.doc(receiverId).get().then((value) {
        if (value['friendArray'] != null &&
            lastDigit(value['friendArray'].length) == 9) {
          Database().giveBadge(receiverId, "friends10");
        }
      });
      usersRef.doc(senderId).get().then((value) {
        if (value['friendArray'] != null &&
            lastDigit(value['friendArray'].length) == 9) {
          Database().giveBadge(senderId, "friends10");
        }
      });

      final DocumentReference ref =
          dbRef.doc('notreDame/data/users/$receiverId');
      final DocumentReference ref2 =
          dbRef.doc('notreDame/data/users/$senderId');
      String serializedMessage = senderId;
      String serializedMessage2 = receiverId;
      String serializedMessage3 = senderId;
      String serializedMessage4 = receiverId;
      transaction.update(ref, {
        'friendRequests': FieldValue.arrayRemove([serializedMessage3]),
      });
      transaction.update(ref2, {
        'friendRequests': FieldValue.arrayRemove([serializedMessage4]),
      });
      transaction.update(ref, {
        'friendArray': FieldValue.arrayUnion([serializedMessage]),
      });
      transaction.update(ref2, {
        'friendArray': FieldValue.arrayUnion([serializedMessage2]),
      });
      usersRef.doc(currentUser.id).get().then((value) {
        if (value['sendLimit'] >= 0) {
          usersRef
              .doc(currentUser.id)
              .update({"sendLimit": FieldValue.increment(-1)});
          usersRef
              .doc(currentUser.id)
              .update({"score": FieldValue.increment(50)});
        }
      });
    });
  }

  Future<void> rejectFriendRequest(
      String senderId, String receiverId, String strName, String strPic) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref =
          dbRef.doc('notreDame/data/users/$receiverId');
      final DocumentReference ref2 =
          dbRef.doc('notreDame/data/users/$senderId');
      String serializedMessage = senderId;
      String serializedMessage2 = receiverId;
      transaction.update(ref, {
        'friendRequests': FieldValue.arrayRemove([serializedMessage]),
      });
      transaction.update(ref2, {
        'friendRequests': FieldValue.arrayRemove([serializedMessage2]),
      });
    });
  }

  Future<void> unfriend(String senderId, String receiverId) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref =
          dbRef.doc('notreDame/data/users/$receiverId');
      final DocumentReference ref2 =
          dbRef.doc('notreDame/data/users/$senderId');
      String serializedMessage3 = senderId;
      String serializedMessage4 = receiverId;
      transaction.update(ref, {
        'friendArray': FieldValue.arrayRemove([serializedMessage3]),
      });
      transaction.update(ref2, {
        'friendArray': FieldValue.arrayRemove([serializedMessage4]),
      });
    });
  }

  Future<QuerySnapshot> checkStatus(String senderId, String receiverId) {
    return usersRef
        .where('id', isEqualTo: receiverId)
        .where('friendRequests', arrayContains: senderId)
        .get();
  }

  Future<QuerySnapshot> checkFriends(String senderId, String receiverId) {
    return usersRef
        .where('id', isEqualTo: receiverId)
        .where('friendArray', arrayContains: senderId)
        .get();
  }

  Future<void> leaveGroup(id, gname, gid, displayName) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref = dbRef.doc('notreDame/data/users/$id');
      final DocumentReference ref2 =
          dbRef.doc('notreDame/data/friendGroups/$gid');
      transaction.update(ref, {
        'friendGroups': FieldValue.arrayRemove([gid]),
      });
      transaction.update(ref2, {
        'members': FieldValue.arrayRemove([id]),
        'memberNames': FieldValue.arrayRemove([displayName]),
      });
    });
  }

  Future<void> destroyGroup(gid, groupName) async {
    String filePath = "images/group" + groupName;

    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(filePath);

    groupsRef.doc(gid).get().then((doc) {
      if (doc.exists) {
        // _storage.ref().child(filePath).delete();
        ref.delete();

        doc.reference.delete();
      }
    });

    // return dbRef.runTransaction((transaction) async {
    //   dbRef.doc('notreDame/data/friendGroups/$gid').delete();
    // });
  }

  Future<void> sendChat(user, message, gid) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref =
          dbRef.doc('notreDame/data/friendGroups/$gid');
      final Map<String, dynamic> chat = {
        'sender': user,
        'message': message,
        'timestamp': DateTime.now()
      };
      transaction.update(ref, {
        'chat': chat,
      });
    });
  }

  Future<void> addUserToGroup(id, gname, gid, displayName) async {
    usersRef.doc(currentUser.id).get().then((value) {
      if (value['groupLimit'] >= 1) {
        usersRef
            .doc(currentUser.id)
            .update({"groupLimit": FieldValue.increment(-1)});
        usersRef
            .doc(currentUser.id)
            .update({"score": FieldValue.increment(75)});
      }
      groupsRef.doc(gid).set({
        "members": FieldValue.arrayUnion([id]),
        "memberNames": FieldValue.arrayUnion([displayName])
      }, SetOptions(merge: true));
      usersRef.doc(id).set({
        "friendGroups": FieldValue.arrayUnion([gid])
      }, SetOptions(merge: true));
    });
  }

  Future<void> setMOOV(gid, moovId) async {
    return dbRef.runTransaction((transaction) async {
      final DocumentReference ref =
          dbRef.doc('notreDame/data/friendGroups/$gid');
      transaction.update(ref, {
        'nextMOOV': moovId,
      });
    });
  }

  Future<void> suggestMOOV(gid, postId, groupName) async {
    usersRef.doc(currentUser.id).get().then((value) {
      if (value['suggestLimit'] >= 1) {
        usersRef
            .doc(currentUser.id)
            .update({"suggestLimit": FieldValue.increment(-1)});
        usersRef
            .doc(currentUser.id)
            .update({"score": FieldValue.increment(30)});
      }
    });

    return dbRef.runTransaction((transaction) async {
      // final DocumentReference ref2 = dbRef.doc('notreDame/data/users/$userId');
      // transaction.update(ref2, {'score': FieldValue.increment(30)});

      postsRef.doc(postId).get().then((value) {
        groupsRef.doc(gid).collection("suggestedMOOVs").doc(postId).set({
          "postId": postId,
          "pic": value['image'],
          "startDate": value['startDate'],
          "title": value['title']
        });
        bool push = true;

        notificationFeedRef
            .doc(gid)
            .collection('feedItems')
            .doc('suggest ' + postId)
            .set({
          "seen": false,
          "type": "suggestion",
          "push": push,
          "postId": postId,
          "previewImg": value['image'],
          "title": value['title'],
          "groupId": gid,
          "groupName": groupName,
          "username": currentUser.displayName,
          "userId": currentUser.id,
          "userProfilePic": currentUser.photoUrl,
          "timestamp": DateTime.now()
        });
      });
    });
  }

  Future<void> addNoVote(unix, userId, gid, suggestorId) async {
    return dbRef.runTransaction((transaction) async {
      groupsRef
          .doc(gid)
          .collection('suggestedMOOVs')
          .doc(unix.toString() + " from " + suggestorId)
          .set({
        "voters": {userId: 1}
      }, SetOptions(merge: true));
    });
  }

  Future<void> removeNoVote(unix, userId, gid, suggestorId) async {
    return dbRef.runTransaction((transaction) async {
      groupsRef
          .doc(gid)
          .collection('suggestedMOOVs')
          .doc(unix.toString() + " from " + suggestorId)
          .set({
        "voters": {userId: FieldValue.delete()}
      }, SetOptions(merge: true));
    });
  }

  Future<void> addYesVote(unix, userId, gid, suggestorId) async {
    return dbRef.runTransaction((transaction) async {
      groupsRef
          .doc(gid)
          .collection('suggestedMOOVs')
          .doc(unix.toString() + " from " + suggestorId)
          .set({
        "voters": {userId: 2}
      }, SetOptions(merge: true));
    });
  }

  Future<void> removeYesVote(unix, userId, gid, suggestorId) async {
    return dbRef.runTransaction((transaction) async {
      groupsRef
          .doc(gid)
          .collection('suggestedMOOVs')
          .doc(unix.toString() + " from " + suggestorId)
          .set({
        "voters": {userId: FieldValue.delete()}
      }, SetOptions(merge: true));
    });
  }

  giveBadge(String userId, String type) {
    usersRef.doc(userId).set({
      "badges": {
        type: FieldValue.arrayUnion([Timestamp.now()])
      }
    }, SetOptions(merge: true));
    notificationFeedRef
        .doc(userId)
        .collection('feedItems')
        .doc('badge ' + type)
        .set({
      "seen": false,
      "type": type == "natties" ? "natties" : "badge",
      "title": type == "friends10"
          ? "10 Friends"
          : type == "leaderboardWin"
              ? "Leaderboard Win"
              : type == "natties"
                  ? "a Natty!"
                  : type == "moovMaker"
                      ? "MOOV Maker"
                      : type == "mountain"
                          ? "MOOV Mountain"
                          : "",
      // "username": currentUser.displayName,
      "userId": userId,
      "userProfilePic": "badge",
      "timestamp": DateTime.now()
    });
  }

  updateAllDocs() async {
    var snapshots = usersRef.snapshots();
    try {
      await snapshots.forEach((snapshot) async {
        List<DocumentSnapshot> documents = snapshot.docs;

        for (var document in documents) {
          await document.reference.set({
            // "moovMoney": 0,
            // "race": "White",
            // "isSingle": false
            // "badges": [],
            // "isBusiness": false
            // "groupLimit": 2
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  updatePoll() async {
    var snapshots = FirebaseFirestore.instance
        .collection('notreDame')
        .doc('data')
        .collection('poll')
        .snapshots();
    try {
      await snapshots.forEach((snapshot) async {
        List<DocumentSnapshot> documents = snapshot.docs;

        for (var document in documents) {
          await document.reference.set({
            "choice1": "",
            "choice2": "",
            "question": "",
            "voters": {"107290090512658207959": 1}
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  funnyScreenshot({user, timestamp, venmo, imageUrl}) {
    FirebaseFirestore.instance.collection("screenshots").doc().set({
      "user": user,
      "timestamp": timestamp,
      "venmo": venmo,
      "imageUrl": imageUrl
    });
  }

  Future<void> chatReaction(String userId, String directMessageId,
      String chatId, int reactionChoice, bool undoing) async {
    return dbRef.runTransaction((transaction) async {
      undoing
          ? // taking the reaction off
          messagesRef.doc(directMessageId).collection('chat').doc(chatId).set({
              "reactions": {userId: 0}
            }, SetOptions(merge: true))
          : messagesRef
              .doc(directMessageId)
              .collection('chat')
              .doc(chatId)
              .set({
              "reactions": {userId: reactionChoice}
            }, SetOptions(merge: true));
    });
  }
}
