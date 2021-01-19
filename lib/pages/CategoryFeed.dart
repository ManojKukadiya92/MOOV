import 'package:MOOV/helpers/demo_values.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/models/post_model.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/MoovMaker.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:MOOV/pages/edit_post.dart';
import 'package:MOOV/pages/leaderboard.dart';
import 'package:MOOV/pages/notification_feed.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/widgets/post_card.dart';
import 'package:MOOV/widgets/send_moov.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/services/database.dart';
import 'dart:math';

import 'package:MOOV/helpers/themes.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:MOOV/pages/home.dart';
import 'package:like_button/like_button.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';
import 'package:page_transition/page_transition.dart';

class CategoryFeed extends StatefulWidget {
  dynamic moovId;
  final String type;
  CategoryFeed({this.moovId, @required this.type});

  @override
  _CategoryFeedState createState() => _CategoryFeedState(moovId, type);
}

class _CategoryFeedState extends State<CategoryFeed>
    with SingleTickerProviderStateMixin {
  // TabController to control and switch tabs
  TabController _tabController;
  dynamic moovId;
  String type;
  var todayOnly = 0;
  String privacy;

  _CategoryFeedState(this.moovId, this.type);

  // Current Index of tab
  int _currentIndex = 0;

  String text = 'https://www.whatsthemoov.com';
  String subject = 'Check out MOOV. You get paid to download!';
  Map<int, Widget> map =
      new Map(); // Cupertino Segmented Control takes children in form of Map.
  List<Widget>
      childWidgets; //The Widgets that has to be loaded when a tab is selected.
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController =
        new TabController(vsync: this, length: 3, initialIndex: _currentIndex);
    _tabController.animation
      ..addListener(() {
        setState(() {
          _currentIndex = (_tabController.animation.value).round();
        });
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget getChildWidget() => childWidgets[selectedIndex];

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;
    final GoogleSignInAccount user = googleSignIn.currentUser;
    final strUserId = user.id;
    dynamic likeCount;

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
          //pinned: true,
          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.all(5.0),
              icon: Icon(Icons.insert_chart),
              color: Colors.white,
              splashColor: Color.fromRGBO(220, 180, 57, 1.0),
              onPressed: () {
                // Implement navigation to leaderboard page here...
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LeaderBoardPage()));
              },
            ),
            IconButton(
              padding: EdgeInsets.all(5.0),
              icon: Icon(Icons.notifications_active),
              color: Colors.white,
              splashColor: Color.fromRGBO(220, 180, 57, 1.0),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationFeed()));
              },
            )
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.all(15),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(type, style: GoogleFonts.robotoSlab(color: Colors.white))
              ],
            ),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height * 0.90,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 12.5),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TextThemes.ndBlue,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Sign In Button
                      new FlatButton(
                        color: _currentIndex == 0
                            ? Colors.blue[100]
                            : Colors.white,
                        onPressed: () {
                          _tabController.animateTo(0);
                          setState(() {
                            _currentIndex = (_tabController.animation.value)
                                .round(); //_tabController.animation.value returns double

                            _currentIndex = 0;
                          });
                        },
                        child: Text("Featured"),
                      ),
                      // Sign Up Button
                      new FlatButton(
                        color: _currentIndex == 1
                            ? Colors.blue[100]
                            : Colors.white,
                        onPressed: () {
                          _tabController.animateTo(1);
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                        child: Text("All"),
                      ),
                      FlatButton(
                        color: _currentIndex == 2
                            ? Colors.blue[100]
                            : Colors.white,
                        onPressed: () {
                          _tabController.animateTo(2);
                          setState(() {
                            _currentIndex = 2;
                          });
                        },
                        child: Text("Friends"),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: todayOnly == 0
                      ? RaisedButton(
                          onPressed: () {
                            setState(() {
                              todayOnly = 1;
                            });
                          },
                          color: TextThemes.ndBlue,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today,
                                    color: TextThemes.ndGold),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Today Only?',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        )
                      : RaisedButton(
                          onPressed: () {
                            setState(() {
                              todayOnly = 0;
                            });
                          },
                          color: Colors.green,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, color: TextThemes.ndGold),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Today Only!',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        )),
              Expanded(
                child: TabBarView(controller: _tabController,
                    // Restrict scroll by user
                    children: [
                      // Sign In View
                      Center(
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('food')
                                .where("type", isEqualTo: type)
                                // .where("featured", isEqualTo: true)
                                .orderBy("startDate")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data.docs.length == 0)
                                return Center(
                                  child: Text(
                                      "No featured MOOVs. \n\n Got a feature? Email MOOV@MOOV.com.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20)),
                                );

                              return ListView.builder(
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot course =
                                      snapshot.data.docs[index];
                                  Timestamp startDate = course["startDate"];
                                  privacy = course['privacy'];
                                  Map<String, dynamic> invitees =
                                      (snapshot.data.docs[index]['invitees']);

                                  int status = 0;
                                  List<dynamic> inviteesIds =
                                      invitees.keys.toList();

                                  List<dynamic> inviteesValues =
                                      invitees.values.toList();

                                  if (invitees != null) {
                                    for (int i = 0; i < invitees.length; i++) {
                                      if (inviteesIds[i] == currentUser.id) {
                                        if (inviteesValues[i] == 3) {
                                          status = 3;
                                        }
                                      }
                                    }
                                  }

                                  bool hide = false;

                                  if (startDate.millisecondsSinceEpoch <
                                      Timestamp.now().millisecondsSinceEpoch -
                                          3600000) {
                                    print("Expired. See ya later.");
                                    Database().deletePost(course['postId'],
                                        course['userId'], course['title']);
                                  }
                                  final now = DateTime.now();
                                  bool isToday = false;
                                  bool isTomorrow = false;

                                  final today =
                                      DateTime(now.year, now.month, now.day);
                                  final yesterday = DateTime(
                                      now.year, now.month, now.day - 1);
                                  final tomorrow = DateTime(
                                      now.year, now.month, now.day + 1);

                                  final dateToCheck = startDate.toDate();
                                  final aDate = DateTime(dateToCheck.year,
                                      dateToCheck.month, dateToCheck.day);

                                  if (aDate == today) {
                                    isToday = true;
                                  } else if (aDate == tomorrow) {
                                    isTomorrow = true;
                                  }
                                  if (isToday == false && todayOnly == 1) {
                                    hide = true;
                                  }
                                  if (privacy == "Friends Only") {
                                    hide = true;
                                  }

                                  if (course['featured'] != true) {
                                    hide = true;
                                  }

                                  return (hide == false)
                                      ? PostOnFeed(course)
                                      : Container();
                                },
                              );
                            }),
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('food')
                              .where("type", isEqualTo: type)
                              .orderBy("startDate")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data.docs.length == 0)
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Text("No MOOVs! Why not post one?",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 20)),
                                    ),
                                    FloatingActionButton.extended(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .topToBottom,
                                                  child: MoovMaker(
                                                      postModel: PostModel())));
                                        },
                                        label: const Text("Post the MOOV",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white))),
                                  ],
                                ),
                              );
                            return ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot course =
                                    snapshot.data.docs[index];
                                Timestamp startDate = course["startDate"];
                                privacy = course['privacy'];

                                bool isAmbassador;
                                bool isLiked1;
                                bool hide = false;

                                if (startDate.millisecondsSinceEpoch <
                                    Timestamp.now().millisecondsSinceEpoch -
                                        3600000) {
                                  print("Expired. See ya later.");
                                  Database().deletePost(course['postId'],
                                      course['userId'], course['title']);
                                }
                                final now = DateTime.now();
                                bool isToday = false;
                                bool isTomorrow = false;

                                final today =
                                    DateTime(now.year, now.month, now.day);
                                final yesterday =
                                    DateTime(now.year, now.month, now.day - 1);
                                final tomorrow =
                                    DateTime(now.year, now.month, now.day + 1);

                                final dateToCheck = startDate.toDate();
                                final aDate = DateTime(dateToCheck.year,
                                    dateToCheck.month, dateToCheck.day);

                                if (aDate == today) {
                                  isToday = true;
                                } else if (aDate == tomorrow) {
                                  isTomorrow = true;
                                }

                                if (privacy == "Friends Only") {
                                  hide = true;
                                }
                                if (isToday == false && todayOnly == 1)
                                  hide = true;

                                return (hide == false)
                                    ? PostOnFeed(course)
                                    : Container();
                              },
                            );
                          }),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('food')
                              .where("type", isEqualTo: type)
                              // .where('privacy', isEqualTo: 'Friends Only')
                              // .where('userId', whereIn: currentUser.friendArray)
                              .orderBy("startDate")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data.docs.length == 0)
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Text("No MOOVs! Why not post one?",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 20)),
                                    ),
                                    FloatingActionButton.extended(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .topToBottom,
                                                  child: MoovMaker(
                                                      postModel: PostModel())));
                                        },
                                        label: const Text("Post the MOOV",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white))),
                                  ],
                                ),
                              );
                            return ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot course =
                                    snapshot.data.docs[index];
                                Timestamp startDate = course["startDate"];
                                privacy = course["privacy"];
                                List<dynamic> friends = currentUser.friendArray;

                                var strUserPic = currentUser.photoUrl;

                                bool isAmbassador;
                                bool isLiked1;
                                bool hide = false;

                                // var y = startDate;
                                // var x = Timestamp.now();
                                // print(x.toDate());
                                // print(y.toDate());

                                if (startDate.millisecondsSinceEpoch <
                                    Timestamp.now().millisecondsSinceEpoch -
                                        3600000) {
                                  print("Expired. See ya later.");
                                  Database().deletePost(course['postId'],
                                      course['userId'], course['title']);
                                }
                                final now = DateTime.now();
                                bool isToday = false;
                                bool isTomorrow = false;

                                final today =
                                    DateTime(now.year, now.month, now.day);
                                final yesterday =
                                    DateTime(now.year, now.month, now.day - 1);
                                final tomorrow =
                                    DateTime(now.year, now.month, now.day + 1);

                                final dateToCheck = startDate.toDate();
                                final aDate = DateTime(dateToCheck.year,
                                    dateToCheck.month, dateToCheck.day);

                                if (aDate == today) {
                                  isToday = true;
                                } else if (aDate == tomorrow) {
                                  isTomorrow = true;
                                }

                                if (isToday == false && todayOnly == 1) {
                                  hide = true;
                                }
                                if (privacy != "Friends Only") {
                                  hide = true;
                                }

                                if (!currentUser.friendArray
                                    .contains(course['userId'])) {
                                  hide = true;
                                }
                                // // print(hide);

                                return (hide == false)
                                    ? PostOnFeed(course)
                                    : Container();
                              },
                            );
                          }),
                    ]),
              )
            ],
          ),
        ));
  }

  void showAlertDialog(BuildContext context, postId, userId) {
    showDialog(
      context: context,
      child: CupertinoAlertDialog(
        title: Text("Delete?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nMOOV to trash can?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Yeah", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);

              // Database().deletePost(postId, userId);
            },
          ),
          CupertinoDialogAction(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }
}

class PostOnFeed extends StatelessWidget {
  DocumentSnapshot course;

  PostOnFeed(this.course);

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    String privacy;
    Timestamp startDate = course["startDate"];
    privacy = course['privacy'];
    Map<String, dynamic> invitees = course['invitees'];
    int status = 0;
    List<dynamic> inviteesIds = invitees.keys.toList();

    List<dynamic> inviteesValues = invitees.values.toList();

    if (invitees != null) {
      for (int i = 0; i < invitees.length; i++) {
        if (inviteesIds[i] == currentUser.id) {
          if (inviteesValues[i] == 3) {
            status = 3;
          }
        }
      }
    }

    var strUserPic = currentUser.photoUrl;

    if (startDate.millisecondsSinceEpoch <
        Timestamp.now().millisecondsSinceEpoch - 3600000) {
      print("Expired. See ya later.");
      Database()
          .deletePost(course['postId'], course['userId'], course['title']);
    }
    final now = DateTime.now();
    bool isToday = false;
    bool isTomorrow = false;

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final dateToCheck = startDate.toDate();
    final aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);

    if (aDate == today) {
      isToday = true;
    } else if (aDate == tomorrow) {
      isTomorrow = true;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(overflow: Overflow.visible, children: [
        Card(
            color: Colors.white,
            shadowColor: Colors.grey[200],
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              splashColor: Colors.white,
              highlightColor: Colors.white,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PostDetail(course.id)));
              },
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    child: Row(children: <Widget>[
                      Expanded(
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 0.0, right: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    border: Border.all(
                                      color: Color(0xff000000),
                                      width: 1,
                                    )),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(course['image'],
                                      fit: BoxFit.cover,
                                      height: 120,
                                      width: 50),
                                ),
                              ))),
                      Expanded(
                          child: Column(children: <Widget>[
                        Padding(padding: const EdgeInsets.all(8.0)),
                        SizedBox(
                          width: 165,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0, right: 4),
                            child: AutoSizeText(course['title'].toString(),
                                minFontSize: 17,
                                style: TextStyle(
                                    color: Colors.blue[900],
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10, top: 10, bottom: 5),
                          child: Text(
                            course['description'].toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.black),
                          ),
                        ),
                        Padding(padding: const EdgeInsets.all(5.0)),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Icon(Icons.timer,
                                      color: TextThemes.ndGold, size: 20),
                                ),
                                Text('WHEN: ',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    DateFormat('MMMd')
                                        .add_jm()
                                        .format(course['startDate'].toDate()),
                                    style: TextStyle(
                                      fontSize: 12.0,
                                    )),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 0.0),
                                    child: Icon(Icons.place,
                                        color: TextThemes.ndGold, size: 20),
                                  ),
                                  Text(' WHERE: ',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: isLargePhone ? 115 : 90,
                                    child: Text(course['address'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.0,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]))
                    ]),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(
                  //       horizontal: 1.0),
                  //   child: Container(
                  //     height: 1.0,
                  //     width: 500.0,
                  //     color: Colors.grey[300],
                  //   ),
                  // ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(course['userId'])
                          .snapshots(),
                      builder: (context, snapshot2) {
                        var userYear;
                        var userDorm;
                        bool isLargePhone = Screen.diagonal(context) > 766;

                        if (snapshot2.hasError)
                          return CircularProgressIndicator();
                        if (!snapshot2.hasData)
                          return CircularProgressIndicator();
                        else
                          userDorm = snapshot2.data['dorm'];
                        strUserPic = snapshot2.data['photoUrl'];
                        bool isAmbassador = snapshot2.data['isAmbassador'];
                        userYear = snapshot2.data['year'];

                        return Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 10, 4, 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (course['userId'] ==
                                            currentUser.id) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfilePageWithHeader()));
                                        } else {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OtherProfile(
                                                        course['userId'],
                                                      )));
                                        }
                                      },
                                      child: CircleAvatar(
                                        radius: 22.0,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                strUserPic),
                                        backgroundColor: Colors.transparent,
                                      ),
                                    )),
                                Container(
                                  width: isLargePhone ? 120 : 95,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (course['userId'] == currentUser.id) {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilePageWithHeader()));
                                      } else {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OtherProfile(
                                                      course['userId'],
                                                    )));
                                      }
                                    },
                                    child: Column(
                                      //  mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2.0),
                                          child: Text(course['userName'],
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: TextThemes.ndBlue,
                                                  decoration:
                                                      TextDecoration.none)),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2.0),
                                          child: Text(
                                              userYear + " in " + userDorm,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: TextThemes.ndBlue,
                                                  decoration:
                                                      TextDecoration.none)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            course['userId'] == currentUser.id
                                ? RaisedButton(
                                    color: Colors.red,
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditPost(course['postId']))),

                                    // showAlertDialog(context, postId, userId),
                                    child: Text(
                                      "Edit",
                                      style: TextStyle(color: Colors.white),
                                    ))
                                : Text(''),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 6.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  type: PageTransitionType
                                                      .bottomToTop,
                                                  child: SendMOOV(
                                                    course['userId'],
                                                    course['image'],
                                                    course['postId'],
                                                    course['startDate'],
                                                    course['title'],
                                                    course['profilePic'],
                                                    course['userName'],
                                                  )));
                                        },
                                        child: Icon(Icons.send_rounded,
                                            color: Colors.blue[500], size: 30),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 0.0),
                                      child: Text(
                                        'Send',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    children: [
                                      IconButton(
                                        icon: (status == 3)
                                            ? new Icon(Icons.directions_run,
                                                color: Colors.green)
                                            : new Icon(Icons.directions_walk),
                                        color: Colors.red,
                                        iconSize: 30.0,
                                        splashColor: (status == 3)
                                            ? Colors.red
                                            : Colors.green,
                                        //splashRadius: 7.0,
                                        highlightColor: Colors.green,
                                        onPressed: () {
                                          if (invitees != null && status != 3) {
                                            Database().addGoingGood(
                                                currentUser.id,
                                                course['userId'],
                                                course.id,
                                                course['title'],
                                                course['image']);
                                            status = 3;
                                          } else if (invitees != null &&
                                              status == 3) {
                                            Database().removeGoingGood(
                                                currentUser.id,
                                                course['userId'],
                                                course.id,
                                                course['title'],
                                                course['image']);
                                            status = 0;
                                          }
                                        },
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 11.0),
                                          child: status == 3
                                              ? Text("Going!",
                                                  style:
                                                      TextStyle(fontSize: 12))
                                              : Text("Going?",
                                                  style:
                                                      TextStyle(fontSize: 12)))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ));
                      }),
                ],
              ),
            )),
        isToday == true
            ? Positioned(
                top: -7,
                right: 0,
                child: Container(
                  height: 30,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink[400], Colors.purple[300]],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Text(
                    "Today!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              )
            : isTomorrow == true
                ? Positioned(
                    top: -7,
                    right: 0,
                    child: Container(
                      height: 30,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.pink[400], Colors.purple[300]],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Text(
                        "Tomorrow!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )
                : Text(""),
      ]),
    );
  }
}
