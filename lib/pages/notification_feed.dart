import 'dart:ffi';

import 'package:MOOV/main.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/NewSearch.dart';
import 'package:MOOV/pages/ProfilePage.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/friend_requests.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:http/http.dart';
import 'group_detail.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationFeed extends StatefulWidget {
  @override
  _NotificationFeedState createState() => _NotificationFeedState();
}

class _NotificationFeedState extends State<NotificationFeed>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _currentIndex = 0;
  Map<int, Widget> map = new Map();
  List<Widget> childWidgets;
  int selectedIndex = 0;

  Widget getChildWidget() => childWidgets[selectedIndex];

  int groupCount;
  int notificationCount = 0;
  EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();

    _tabController =
        new TabController(vsync: this, length: 2, initialIndex: _currentIndex);
    _tabController.animation
      ..addListener(() {
        setState(() {
          _currentIndex = (_tabController.animation.value).round();
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  String docId;
  List<String> docIds;

  getNotificationFeed() async {
    QuerySnapshot snapshot = await notificationFeedRef
        .doc(currentUser.id)
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
        .doc(currentUser.id)
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
  
  getGroupFeed(int groupCount) async {
    QuerySnapshot snapshot = await notificationFeedRef
        .doc(currentUser.friendGroups[groupCount - 1])
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

  getGroupIds(int groupCount) async {
    QuerySnapshot snapshot = await notificationFeedRef
        .doc(currentUser.friendGroups[groupCount - 1])
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
    if (currentUser.friendGroups.length != 0 ||
        currentUser.friendGroups.length != 0) {
      groupCount = currentUser.friendGroups.length;
    }
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: currentUser.isBusiness
            ? AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                ),
                backgroundColor: TextThemes.ndBlue,
              )
            : AppBar(
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
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Sign In Button
                  Stack(children: [
                    FlatButton(
                      splashColor: Colors.white,
                      color: Colors.white,
                      onPressed: () {
                        _tabController.animateTo(0);
                        setState(() {
                          _currentIndex = (_tabController.animation.value)
                              .round(); //_tabController.animation.value returns double

                          _currentIndex = 0;
                        });
                      },
                      child: _currentIndex == 0
                          ? GradientText(
                              'Personal',
                              16.5,
                              gradient: LinearGradient(colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade900,
                              ]),
                            )
                          : Text(
                              "Personal",
                              style: TextStyle(fontSize: 16.5),
                            ),
                    ),
                    // Positioned(
                    //   top: 8,
                    //   right: 0,
                    //   child: Container(
                    //     padding:
                    //         EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    //     decoration: BoxDecoration(
                    //         shape: BoxShape.circle, color: Colors.red),
                    //     alignment: Alignment.center,
                    //     child: Text(" ", style: TextStyle(color: Colors.white)),
                    //   ),
                    // )
                  ]),
                  // Sign Up Button
                  Stack(children: [
                    FlatButton(
                      splashColor: Colors.white,
                      color: Colors.white,
                      onPressed: () {
                        _tabController.animateTo(1);
                        setState(() {
                          _currentIndex =
                              (_tabController.animation.value).round();

                          _currentIndex = 1;
                        });
                      },
                      child: _currentIndex == 1
                          ? GradientText(
                              "Friend Groups",
                                16.5,
                              gradient: LinearGradient(colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade900,
                              ]),
                            )
                          : Text(
                              "Friend Groups",
                              style: TextStyle(fontSize: 16.5),
                            ),
                    ),
                  ]),
                ],
              ),
              // currentUser.friendRequests.length != 0
              //     ? GestureDetector(
              //         onTap: () => {
              //               Navigator.push(
              //                   context,
              //                   MaterialPageRoute(
              //                       builder: (context) =>
              //                           FriendRequests(id: currentUser.id)))
              //             },
              //         child: Container(
              //           decoration: BoxDecoration(
              //               border:
              //                   Border.all(color: Colors.black, width: .25)),
              //           height: 50,
              //           child: Padding(
              //               padding: EdgeInsets.only(left: 20),
              //               child: Text(
              //                 'Friend Requests (' +
              //                     currentUser.friendRequests.length.toString() +
              //                     ')',
              //               )),
              //           alignment: Alignment.centerLeft,
              //         ))
              //     : Container(),
              SingleChildScrollView(
                child: Container(
                  height: _currentIndex == 0
                      ? MediaQuery.of(context).size.height * .65
                      : MediaQuery.of(context).size.height * .8,
                  child: TabBarView(controller: _tabController, children: [
                    FutureBuilder(
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
                                return Container(
                                    child: Center(
                                        child: Text(
                                  "Up to date on your notifications.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: TextThemes.ndBlue, fontSize: 25),
                                )));
                              }

                              return EasyRefresh(
                                onRefresh: () async {
                                  await Future.delayed(Duration(seconds: 1),
                                      () {
                                    _controller.resetLoadState();
                                  });
                                },
                                onLoad: () async {
                                  await Future.delayed(Duration(seconds: 1),
                                      () {
                                    _controller.finishLoad();
                                  });
                                },
                                enableControlFinishRefresh: false,
                                enableControlFinishLoad: true,
                                controller: _controller,
                                header: BezierCircleHeader(
                                    color: TextThemes.ndGold,
                                    backgroundColor: TextThemes.ndBlue),
                                footer: BezierBounceFooter(
                                    backgroundColor: Colors.white),
                                bottomBouncing: false,
                                child: ListView.builder(
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

                                    return Dismissible(

                                        // Each Dismissible must contain a Key. Keys allow Flutter to
                                        // uniquely identify widgets.
                                        key: Key(item.toString()),
                                        // Provide a function that tells the app
                                        // what to do after an item has been swiped away.
                                        onDismissed: (direction) {
                                          notificationFeedRef
                                              .doc(currentUser.id)
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
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  duration: Duration(
                                                      milliseconds: 1500),
                                                  backgroundColor:
                                                      TextThemes.ndBlue,
                                                  content: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: Text(
                                                        "See ya notification."),
                                                  )));
                                        },
                                        // Show a red background as the item is swiped away.
                                        background: Container(
                                          color: Colors.red,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: Icon(
                                                    CupertinoIcons.trash,
                                                    color: Colors.white,
                                                    size: 45),
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
                                ),
                              );
                            },
                          );
                        }),
                    SingleChildScrollView(
                      child: Container(
                          height: _currentIndex == 0
                              ? MediaQuery.of(context).size.height * .65
                              : MediaQuery.of(context).size.height * .8,
                          child: EasyRefresh(
                            onRefresh: () async {
                              await Future.delayed(Duration(seconds: 1), () {
                                _controller.resetLoadState();
                              });
                            },
                            onLoad: () async {
                              await Future.delayed(Duration(seconds: 1), () {
                                _controller.finishLoad();
                              });
                            },
                            enableControlFinishRefresh: false,
                            enableControlFinishLoad: true,
                            controller: _controller,
                            header: BezierCircleHeader(
                                color: TextThemes.ndGold,
                                backgroundColor: TextThemes.ndBlue),
                            footer: BezierBounceFooter(
                                backgroundColor: Colors.white),
                            bottomBouncing: false,
                            child: ListView.builder(
                                itemCount: currentUser.friendGroups.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: 200,
                                    child: StreamBuilder(
                                        stream: groupsRef
                                            .doc(
                                                currentUser.friendGroups[index])
                                            .snapshots(),
                                        // ignore: missing_return
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError)
                                            return CircularProgressIndicator();
                                          if (!snapshot.hasData)
                                            return CircularProgressIndicator();
                                          String groupName =
                                              snapshot.data['groupName'];
                                          List members =
                                              snapshot.data['members'];
                                          String groupId =
                                              snapshot.data['groupId'];
                                          for (int i = 0;
                                              i < members.length;
                                              i++) {
                                            return StreamBuilder(
                                                stream: usersRef
                                                    .where('friendGroups',
                                                        arrayContains: groupId)
                                                    .snapshots(),
                                                builder: (context, snapshot7) {
                                                  if (snapshot7.hasError)
                                                    return CircularProgressIndicator();
                                                  if (!snapshot7.hasData)
                                                    return CircularProgressIndicator();
                                                  return Column(
                                                    children: [
                                                      SizedBox(height: 10),
                                                      Stack(children: [
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                "—— $groupName ——",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                              ),
                                                            ]),
                                                        Positioned(
                                                          // bottom: isLargePhone ? 80 : 70,
                                                          right: 10,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Stack(children: [
                                                                Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            0.0),
                                                                    child: members.length >
                                                                            1
                                                                        ? CircleAvatar(
                                                                            radius:
                                                                                10.0,
                                                                            backgroundImage:
                                                                                NetworkImage(
                                                                              snapshot7.data.docs[1]['photoUrl'],
                                                                            ),
                                                                          )
                                                                        : Container()),
                                                                Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top: 0,
                                                                        left:
                                                                            20.0),
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius:
                                                                          10.0,
                                                                      backgroundImage:
                                                                          NetworkImage(
                                                                        snapshot7
                                                                            .data
                                                                            .docs[0]['photoUrl'],
                                                                      ),
                                                                    )),
                                                                members.length >
                                                                        2
                                                                    ? Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                0,
                                                                            left:
                                                                                40.0),
                                                                        child:
                                                                            CircleAvatar(
                                                                          radius:
                                                                              10.0,
                                                                          backgroundImage:
                                                                              NetworkImage(
                                                                            snapshot7.data.docs[2]['photoUrl'],
                                                                          ),
                                                                        ))
                                                                    : Container(),
                                                              ])
                                                            ],
                                                          ),
                                                        ),
                                                      ]),
                                                      FutureBuilder(
                                                          future: getGroupIds(
                                                              index + 1),
                                                          builder: (context,
                                                              snapshot2) {
                                                            if (!snapshot2
                                                                .hasData) {
                                                              return circularProgress();
                                                            }

                                                            return FutureBuilder(
                                                              future:
                                                                  getGroupFeed(
                                                                      index +
                                                                          1),
                                                              builder: (context,
                                                                  snapshot) {
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return circularProgress();
                                                                }
                                                                if (snapshot
                                                                        .data
                                                                        .length ==
                                                                    0) {
                                                                  return Container(
                                                                      child: Center(
                                                                          child: Text(
                                                                    "\n\n\nUp to date.",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        color: TextThemes
                                                                            .ndBlue,
                                                                        fontSize:
                                                                            18),
                                                                  )));
                                                                }

                                                                return Container(
                                                                  height: 170,
                                                                  child: ListView
                                                                      .builder(
                                                                    itemCount:
                                                                        snapshot
                                                                            .data
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      List<String>
                                                                          docIds =
                                                                          [];
                                                                      snapshot2
                                                                          .data
                                                                          .forEach(
                                                                              (doc) {
                                                                        docIds.add(
                                                                            doc);
                                                                      });
                                                                      final item =
                                                                          snapshot
                                                                              .data[index];
                                                                      List<NotificationFeedItem>
                                                                          feedItems =
                                                                          [];

                                                                      snapshot
                                                                          .data
                                                                          .forEach(
                                                                              (doc) {
                                                                        feedItems
                                                                            .add(doc);
                                                                      });

                                                                      return Dismissible(

                                                                          // Each Dismissible must contain a Key. Keys allow Flutter to
                                                                          // uniquely identify widgets.
                                                                          key: Key(item
                                                                              .toString()),
                                                                          // Provide a function that tells the app
                                                                          // what to do after an item has been swiped away.
                                                                          onDismissed:
                                                                              (direction) {
                                                                            notificationFeedRef.doc(currentUser.friendGroups[groupCount]).collection('feedItems').doc(docIds[index]).delete();

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
                                                                          background:
                                                                              Container(
                                                                            color:
                                                                                Colors.red,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(right: 8.0),
                                                                                  child: Icon(CupertinoIcons.trash, color: Colors.white, size: 45),
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
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          }),
                                                    ],
                                                  );
                                                });
                                          }
                                        }),
                                  );
                                }),
                          )),
                    ),
                  ]),
                ),
              ),
              _currentIndex == 0
                  ? Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: GestureDetector(
                        onTap: () => showAlertDialog(context),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.red, width: 3),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "CLEAR NOTIFICATIONS",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ));
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Clear Notifications?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nCleaning up?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Clear", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(true);
              notificationFeedRef
                  .doc(currentUser.id)
                  .collection('feedItems')
                  .get()
                  .then((snapshot) {
                for (DocumentSnapshot ds in snapshot.docs) {
                  ds.reference.delete();
                }
              });
            },
          ),
          CupertinoDialogAction(
            child: Text("Nevermind"),
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
  final String message;

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
      this.message,
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
      message: doc.data()['message'],
    );
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
                        : Container(),
                  ),
                ),
              )),
        ),
      );
    } else if (type == 'invite' || type == 'sent') {
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
    } else if (type == 'askToJoin') {
      mediaPreview = null;
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
      activityItemText = " is going to ";
    } else if (type == 'request') {
      activityItemText = " sent you a friend request.";
    } else if (type == 'accept') {
      activityItemText = " accepted your friend request.";
    } else if (type == 'friendGroup') {
      activityItemText = ' has added you to ';
    } else if (type == 'edit') {
      activityItemText = ' updated the start time of ';
    } else if (type == 'invite') {
      activityItemText = ' has invited you to ';
    } else if (type == 'suggestion') {
      activityItemText = ' suggested ';
    } else if (type == 'askToJoin') {
      activityItemText = ' wants to join!';
    } else if (type == 'sent') {
      activityItemText = ' sent you ';
    } else if (type == 'businessFollow') {
      activityItemText = ' is following you.';
    } else if (type == 'created') {
      activityItemText = ' just posted ';
    } else if (type == 'comment') {
      activityItemText = ' commented: ';
    } else if (type == 'deleted') {
      activityItemText = ' has been canceled';
    } else if (type == 'badge') {
      activityItemText = 'You have earned the badge, ';
    } else if (type == 'natties') {
      activityItemText = 'You have earned ';
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
              (type == 'request' ||
                      type == 'accept' ||
                      type == 'askToJoin' ||
                      type == 'businessFollow')
                  ? showProfile(context)
                  : (type == 'suggestion' || type == 'friendGroup')
                      ? showGroup(context)
                      : type == 'badge' || type == 'natties'
                          ? null
                          : showPost(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  overflow: TextOverflow.visible,
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: isLargePhone ? 13.5 : 12,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: username ?? "",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '$activityItemText',
                        ),
                        title != null || groupName != null
                            ? TextSpan(
                                text: type == 'askToJoin'
                                    ? ""
                                    : type == 'friendGroup'
                                        ? groupName
                                        : title,
                                style: TextStyle(
                                    color: TextThemes.ndBlue,
                                    fontWeight: FontWeight.bold))
                            : message != null
                                ? TextSpan(
                                    text: '\"$message\"',
                                  )
                                : TextSpan(text: "")
                      ]),
                ),
              ],
            ),
          ),
          leading: GestureDetector(
            onTap: userProfilePic == 'badge'
                ? () => null
                : () => showProfile(context),
            child: CircleAvatar(
              backgroundImage: userProfilePic == 'badge'
                  ? AssetImage("lib/assets/trophy2.png")
                  : userProfilePic != null
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

  showOwnProfile(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ProfilePageWithHeader()));
  }
}
