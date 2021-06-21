import 'package:MOOV/friendGroups/group_detail.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationFeedGroup extends StatefulWidget {
  String groupId;

  NotificationFeedGroup(this.groupId);

  @override
  State<StatefulWidget> createState() {
    return _NotificationFeedGroupState(this.groupId);
  }
}

class _NotificationFeedGroupState extends State<NotificationFeedGroup> {
  String docId, groupId;
  List<String> docIds;
  bool gotNotifs = true;
  _NotificationFeedGroupState(this.groupId);
  @override
  getNotificationFeed() async {
    QuerySnapshot snapshot = await notificationFeedRef
        .doc(groupId)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<NotificationFeedItem> feedItems = [];
    List<String> docIds = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(NotificationFeedItem.fromDocument(doc));
      docIds.add(doc.id);
    });

    return feedItems;
  }

  getIds() async {
    QuerySnapshot snapshot = await notificationFeedRef
        .doc(groupId)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<NotificationFeedItem> feedItems = [];
    List<String> docIds = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(NotificationFeedItem.fromDocument(doc));
      docIds.add(doc.id);
    });

    return docIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          backgroundColor: TextThemes.ndBlue,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.all(5),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Image.asset(
                    'lib/assets/moovblue.png',
                    fit: BoxFit.cover,
                    height: 50.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
            child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                  future: getIds(),
                  builder: (context, snapshot2) {
                    if (!snapshot2.hasData) {
                      return circularProgress();
                    }

                    return FutureBuilder(
                      future: getNotificationFeed(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return circularProgress();
                        }
                        if (snapshot.data.length == 0) {
                          gotNotifs = false;
                          return Container(
                              child: Center(
                                  child: Text(
                            "You're all up to date on notifications!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: TextThemes.ndBlue, fontSize: 25),
                          )));
                        }

                        return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            List<String> docIds = [];
                            snapshot2.data.forEach((doc) {
                              docIds.add(doc);
                            });
                            final item = snapshot.data[index];
                            List<NotificationFeedItem> feedItems = [];

                            snapshot.data.forEach((doc) {
                              feedItems.add(doc);
                            });

                            if (feedItems.isNotEmpty) {
                              gotNotifs = true;
                            }

                            return Dismissible(

                                // Each Dismissible must contain a Key. Keys allow Flutter to
                                // uniquely identify widgets.
                                key: Key(item.toString()),
                                // Provide a function that tells the app
                                // what to do after an item has been swiped away.
                                onDismissed: (direction) {
                                  notificationFeedRef
                                      .doc(groupId)
                                      .collection('feedItems')
                                      .doc(docIds[index])
                                      .delete();

                                  if (feedItems.contains(docId)) {
                                    //_personList is list of person shown in ListView
                                    setState(() {
                                      feedItems.remove(docId);
                                    });
                                  }

                                  // Remove the item from the data source.

                                  // Then show a snackbar.
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      duration: Duration(milliseconds: 1500),
                                      backgroundColor: TextThemes.ndBlue,
                                      content: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text("See ya notification."),
                                      )));
                                },
                                // Show a red background as the item is swiped away.
                                background: Container(
                                  color: Colors.red,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(CupertinoIcons.trash,
                                            color: Colors.white, size: 45),
                                      ),
                                    ],
                                  ),
                                ),
                                child: snapshot.hasData
                                    ? snapshot.data[index]
                                    : Text(
                                        'No Notifications',
                                      ));
                          },
                        );
                      },
                    );
                  }),
            ),
            // gotNotifs == true
            //     ? Padding(
            //         padding: const EdgeInsets.all(28.0),
            //         child: GestureDetector(
            //           onTap: () => showAlertDialog(context),
            //           child: Container(
            //             decoration: BoxDecoration(
            //                 color: Colors.white,
            //                 border: Border.all(color: Colors.red, width: 3),
            //                 borderRadius: BorderRadius.circular(10.0)),
            //             child: Padding(
            //               padding: const EdgeInsets.all(12.0),
            //               child: Text(
            //                 "CLEAR NOTIFICATIONS",
            //                 style: TextStyle(color: Colors.red),
            //               ),
            //             ),
            //           ),
            //         ),
            //       )
            //     : Container()
          ],
        )));
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Clear?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nCleanin' up?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Clear", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(true);
              notificationFeedRef
                  .doc(groupId)
                  .collection('feedItems')
                  .get()
                  .then((snapshot) {
                for (DocumentSnapshot ds in snapshot.docs) {
                  ds.reference.delete();
                }
              });
              setState(() {
                gotNotifs = false;
              });
            },
          ),
          CupertinoDialogAction(
            child: Text("Nah, my bad"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class NotificationFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type; // 'going', 'follow', 'friendgroup'
  final String previewImg;
  final String postId;
  final String userProfilePic;
  final String userEmail;
  final String groupId;
  final String groupPic;
  final String groupName;
  final bool push;

  //for redirecting to PostDetail
  final String title;
  final String description;
  final String ownerProPic;
  final String ownerName;
  final String ownerEmail;
  final dynamic address, moovId;
  final List<String> members;

  final Timestamp timestamp;

  NotificationFeedItem(
      {this.title,
      this.description,
      this.username,
      this.userEmail,
      this.groupId,
      this.groupPic,
      this.groupName,
      this.push,
      this.userId,
      this.type,
      this.previewImg,
      this.postId,
      this.userProfilePic,
      this.timestamp,
      this.ownerProPic,
      this.ownerName,
      this.ownerEmail,
      this.address,
      this.moovId,
      this.members});

  factory NotificationFeedItem.fromDocument(DocumentSnapshot doc) {
    return NotificationFeedItem(
        username: doc.data()['username'],
        userEmail: doc.data()['userEmail'],
        userId: doc.data()['userId'],
        type: doc.data()['type'],
        postId: doc.data()['postId'],
        userProfilePic: doc.data()['userProfilePic'],
        timestamp: doc.data()['timestamp'],
        title: doc.data()['title'],
        description: doc.data()['description'],
        ownerProPic: doc.data()['ownerProPic'],
        ownerName: doc.data()['ownerName'],
        ownerEmail: doc.data()['ownerEmail'],
        address: doc.data()['address'],
        moovId: doc.data()['moovId'],
        previewImg: doc.data()['previewImg'],
        members: doc.data()['members'],
        groupId: doc.data()['groupId'],
        groupPic: doc.data()['groupPic'],
        groupName: doc.data()['groupName'],
        push: doc.data()['push']);
  }

  showPost(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PostDetail(postId)));
  }

  showGroup(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GroupDetail(groupId)));
    print(groupId);
  }

  configureMediaPreview(context) {
    if (type == 'going') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: previewImg != null
                        ? CachedNetworkImageProvider(previewImg)
                        : AssetImage("lib/assets/otherbutton1.png"),
                  ),
                ),
              )),
        ),
      );
    } else if (type == 'friendGroup') {
      mediaPreview = GestureDetector(
        onTap: () => showGroup(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: previewImg != null
                        ? CachedNetworkImageProvider(previewImg)
                        : AssetImage("lib/assets/otherbutton1.png"),
                  ),
                ),
              )),
        ),
      );
    } else if (type == 'invite') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: previewImg != null
                        ? CachedNetworkImageProvider(previewImg)
                        : AssetImage("lib/assets/otherbutton1.png"),
                  ),
                ),
              )),
        ),
      );
    } else if (type == 'suggestion') {
      mediaPreview = GestureDetector(
        onTap: () => showGroup(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: previewImg != null
                        ? CachedNetworkImageProvider(previewImg)
                        : AssetImage("lib/assets/otherbutton1.png"),
                  ),
                ),
              )),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (type == 'going') {
      activityItemText = "is going to ";
    } else if (type == 'request') {
      activityItemText = "sent you a friend request";
    } else if (type == 'accept') {
      activityItemText = "accepted your friend request";
    } else if (type == 'friendGroup') {
      activityItemText = 'has added you to ';
    } else if (type == 'invite') {
      activityItemText = 'has invited you all to ';
    } else if (type == 'askToJoin') {
      activityItemText = 'wants to join your group, ';
    } else if (type == 'suggestion') {
      activityItemText = 'suggested ';
    } else if (type == 'deleted') {
      activityItemText = 'has been canceled';
    } else {
      activityItemText = "Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () {
              (type == 'request' || type == 'accept' || type == 'askToJoin')
                  ? showProfile(context)
                  : (type == 'suggestion' || type == 'friendGroup')
                      ? showGroup(context)
                      : showPost(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: isLargePhone ? 13.5 : 12,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: username,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' $activityItemText',
                        ),
                      ]),
                ),
                title != null
                    ? RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            text: type == 'friendGroup' ? groupName : title,
                            style: TextStyle(
                                color: TextThemes.ndBlue,
                                fontWeight: FontWeight.bold)))
                    : Container()
              ],
            ),
          ),
          leading: GestureDetector(
            onTap: () => showProfile(context),
            child: CircleAvatar(
              backgroundImage: userProfilePic != null
                  ? CachedNetworkImageProvider(userProfilePic)
                  : AssetImage("lib/assets/otherbutton1.png"),
            ),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }

  showProfile(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => OtherProfile(userId)));
  }
}

class NotifIconGroup extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onTap;
  int notificationCount;
  String gid;

  NotifIconGroup({
    Key key,
    this.onTap,
    this.gid,
    @required this.iconData,
    this.notificationCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount user = googleSignIn.currentUser;

    return StreamBuilder(
        stream:
            notificationFeedRef.doc(gid).collection('feedItems').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return CircularProgressIndicator();
          if (!snapshot.hasData) return CircularProgressIndicator();
          int notifs = snapshot.data.docs.length;

          return InkWell(
            onTap: onTap,
            child: Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(iconData, color: Colors.white),
                  notifs != 0
                      ? Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            alignment: Alignment.center,
                            child: Text("$notifs",
                                style: TextStyle(color: Colors.white)),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          );
        });
  }
}
