import 'package:MOOV/helpers/demo_values.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/ProfilePage.dart';
import 'package:MOOV/pages/leaderboard.dart';
import 'package:MOOV/pages/notification_feed.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/widgets/post_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/services/database.dart';

import 'package:MOOV/helpers/themes.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:MOOV/pages/home.dart';
import 'package:share/share.dart';

class CategoryFeed extends StatefulWidget {
  List<dynamic> likedArray;
  dynamic moovId;
  final String type;
  CategoryFeed({this.likedArray, this.moovId, @required this.type});

  @override
  _CategoryFeedState createState() =>
      _CategoryFeedState(likedArray, moovId, type);
}

class _CategoryFeedState extends State<CategoryFeed>
    with SingleTickerProviderStateMixin {
  // TabController to control and switch tabs
  TabController _tabController;
  List<dynamic> likedArray;
  dynamic moovId;
  String type;

  _CategoryFeedState(this.likedArray, this.moovId, this.type);

  // Current Index of tab
  int _currentIndex = 0;

  String text = 'https://www.whatsthemoov.com';
  String subject = 'Check out MOOV. You get paid to download!';
  Map<int, Widget> map =
      new Map(); // Cupertino Segmented Control takes children in form of Map.
  List<Widget>
      childWidgets; //The Widgets that has to be loaded when a tab is selected.
  int selectedIndex = 0;

  bool _isPressed;

  @override
  void initState() {
    super.initState();
    _tabController =
        new TabController(vsync: this, length: 2, initialIndex: _currentIndex);
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
    final strUserName = user.displayName;
    final strUserPic = user.photoUrl;
    dynamic likeCount;

    return Scaffold(
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LeaderBoardPage()));
                    print('Leaderboards clicked');
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
                    Text(type, style: GoogleFonts.robotoSlab(
                      color: Colors.white
                    ))
                  ],
                ),
              ),
            ),
        body: Container(
          height: MediaQuery.of(context).size.height * 0.90,
          child: Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.grey,
                        offset: new Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Sign In Button
                      new FlatButton(
                        color: _currentIndex == 0 ? Colors.blue : Colors.white,
                        onPressed: () {
                          _tabController.animateTo(0);
                          setState(() {
                            _currentIndex = 0;
                          });
                        },
                        child: new Text("Featured"),
                      ),
                      // Sign Up Button
                      new FlatButton(
                        color: _currentIndex == 1 ? Colors.blue : Colors.white,
                        onPressed: () {
                          _tabController.animateTo(1);
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                        child: new Text("All"),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(controller: _tabController,
                    // Restrict scroll by user
                    children: [
                      // Sign In View
                      Center(
                        child: StreamBuilder(
                            stream: Firestore.instance
                                .collection('food')
                                .where("type", isEqualTo: type)
                                .where("featured", isEqualTo: true)
                                .orderBy("startDate")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return Text('No featured MOOVs!');
                              return ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot course =
                                      snapshot.data.documents[index];
                                  List<dynamic> likedArray = course["liked"];
                                  List<String> uidArray = List<String>();
                                  if (likedArray != null) {
                                    likeCount = likedArray.length;
                                    for (int i = 0; i < likeCount; i++) {
                                      var id = likedArray[i]["uid"];
                                      uidArray.add(id);
                                    }
                                  } else {
                                    likeCount = 0;
                                  }

                                  if (uidArray != null &&
                                      uidArray.contains(strUserId)) {
                                    _isPressed = true;
                                  } else {
                                    _isPressed = false;
                                  }

                                  return Card(
                                    color: Colors.white,
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PostDetail(
                                                        course['image'],
                                                        course['title'],
                                                        course['description'],
                                                        course['startDate'],
                                                        course['location'],
                                                        course['address'],
                                                        course['userId'],
                                                        likedArray,
                                                        course.documentID)));
                                      },
                                      onDoubleTap: () {
                                        setState(() {
                                          List<dynamic> likedArray =
                                              course["liked"];
                                          List<String> uidArray =
                                              List<String>();
                                          if (likedArray != null) {
                                            likeCount = likedArray.length;
                                            for (int i = 0;
                                                i < likeCount;
                                                i++) {
                                              var id = likedArray[i]["uid"];
                                              uidArray.add(id);
                                            }
                                          }

                                          if (uidArray != null &&
                                              uidArray.contains(strUserId)) {
                                            Database().removeGoing(
                                                course["userId"],
                                                course["image"],
                                                strUserId,
                                                course.documentID,
                                                strUserName,
                                                strUserPic,
                                                course["startDate"],
                                                course["title"],
                                                course["description"],
                                                course["location"],
                                                course["address"],
                                                course["profilePic"],
                                                course["userName"],
                                                course["userEmail"],
                                                likedArray);
                                          } else {
                                            Database().addGoing(
                                                course["userId"],
                                                course["image"],
                                                strUserId,
                                                course.documentID,
                                                strUserName,
                                                strUserPic,
                                                course["startDate"],
                                                course["title"],
                                                course["description"],
                                                course["location"],
                                                course["address"],
                                                course["profilePic"],
                                                course["userName"],
                                                course["userEmail"],
                                                likedArray);
                                          }
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          ListTile(
                                            title: Row(children: <Widget>[
                                              Expanded(
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5.0,
                                                              right: 5,
                                                              bottom: 5),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                          color:
                                                              Color(0xff000000),
                                                          width: 1,
                                                        )),
                                                        /*child: Image.asset(
                                        'lib/assets/filmbutton1.png',
                                        fit: BoxFit.cover,
                                        height: 130,
                                        width: 50),*/
                                                        child: Image.network(
                                                            course['image'],
                                                            fit: BoxFit.cover,
                                                            height: 130,
                                                            width: 50),
                                                      ))),
                                              Expanded(
                                                  child:
                                                      Column(children: <Widget>[
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0)),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: Text(
                                                        course['title']
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue[900],
                                                            fontSize: 20.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center)),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Text(
                                                    course['description']
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black
                                                            .withOpacity(0.6)),
                                                  ),
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0)),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 4.0),
                                                          child: Icon(
                                                              Icons.timer,
                                                              color: TextThemes
                                                                  .ndGold,
                                                              size: 20),
                                                        ),
                                                        Text('WHEN: ',
                                                            style: TextStyle(
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(
                                                            DateFormat('MMMd')
                                                                .add_jm()
                                                                .format(course[
                                                                        'startDate']
                                                                    .toDate()),
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                            )),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 4.0),
                                                          child: Icon(
                                                              Icons.place,
                                                              color: TextThemes
                                                                  .ndGold,
                                                              size: 20),
                                                        ),
                                                        Text('WHERE: ',
                                                            style: TextStyle(
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(course['address'],
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                            )),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ]))
                                            ]),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 1.0),
                                            child: Container(
                                              height: 1.0,
                                              width: 500.0,
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                          Container(
                                              child: Row(
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          12, 10, 4, 10),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if (course['userId'] ==
                                                          strUserId) {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ProfilePage()));
                                                      } else {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        OtherProfile(
                                                                          course[
                                                                              'profilePic'],
                                                                          course[
                                                                              'userName'],
                                                                          course[
                                                                              'userId'],
                                                                        )));
                                                      }
                                                    },
                                                    child: CircleAvatar(
                                                      radius: 22.0,
                                                      backgroundImage:
                                                          NetworkImage(course[
                                                              'profilePic']),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                    ),
                                                  )),
                                              Container(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (course['userId'] ==
                                                        strUserId) {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ProfilePage()));
                                                    } else {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OtherProfile(
                                                                    course[
                                                                        'profilePic'],
                                                                    course[
                                                                        'userName'],
                                                                    course[
                                                                        'userId'],
                                                                  )));
                                                    }
                                                  },
                                                  child: Column(
                                                    //  mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 2.0),
                                                        child: Text(
                                                            course['userName'],
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color:
                                                                    TextThemes
                                                                        .ndBlue,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none)),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 2.0),
                                                        child: Text(
                                                            course['userEmail'],
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    TextThemes
                                                                        .ndBlue,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              Container(
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 50.0,
                                                              bottom: 10.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Share.share(
                                                            "MOOV",
                                                            subject:
                                                                'Update the coordinate!',
                                                          );
                                                        },
                                                        child: Icon(
                                                            Icons.send_rounded,
                                                            color: Colors
                                                                .blue[500],
                                                            size: 30),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 50.0,
                                                              bottom: 20.0),
                                                      child: Text(
                                                        'Send',
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Column(
                                                  //  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: IconButton(
                                                        icon: (_isPressed)
                                                            ? new Icon(
                                                                Icons
                                                                    .directions_run,
                                                                color: Colors
                                                                    .green)
                                                            : new Icon(Icons
                                                                .directions_walk),
                                                        color: Colors.red,
                                                        iconSize: 30.0,
                                                        splashColor:
                                                            Colors.green,
                                                        //splashRadius: 7.0,
                                                        highlightColor:
                                                            Colors.green,
                                                        onPressed: () {
                                                          setState(() {
                                                            List<dynamic>
                                                                likedArray =
                                                                course["liked"];
                                                            List<String>
                                                                uidArray =
                                                                List<String>();
                                                            if (likedArray !=
                                                                null) {
                                                              likeCount =
                                                                  likedArray
                                                                      .length;
                                                              for (int i = 0;
                                                                  i < likeCount;
                                                                  i++) {
                                                                var id =
                                                                    likedArray[
                                                                            i]
                                                                        ["uid"];
                                                                uidArray
                                                                    .add(id);
                                                              }
                                                            }

                                                            if (uidArray !=
                                                                    null &&
                                                                uidArray.contains(
                                                                    strUserId)) {
                                                              Database().removeGoing(
                                                                  course[
                                                                      "userId"],
                                                                  course[
                                                                      "image"],
                                                                  strUserId,
                                                                  course
                                                                      .documentID,
                                                                  strUserName,
                                                                  strUserPic,
                                                                  course[
                                                                      "startDate"],
                                                                  course[
                                                                      "title"],
                                                                  course[
                                                                      "description"],
                                                                  course[
                                                                      "location"],
                                                                  course[
                                                                      "address"],
                                                                  course[
                                                                      "profilePic"],
                                                                  course[
                                                                      "userName"],
                                                                  course[
                                                                      "userEmail"],
                                                                  likedArray);
                                                            } else {
                                                              Database().addGoing(
                                                                  course[
                                                                      "userId"],
                                                                  course[
                                                                      "image"],
                                                                  strUserId,
                                                                  course
                                                                      .documentID,
                                                                  strUserName,
                                                                  strUserPic,
                                                                  course[
                                                                      "startDate"],
                                                                  course[
                                                                      "title"],
                                                                  course[
                                                                      "description"],
                                                                  course[
                                                                      "location"],
                                                                  course[
                                                                      "address"],
                                                                  course[
                                                                      "profilePic"],
                                                                  course[
                                                                      "userName"],
                                                                  course[
                                                                      "userEmail"],
                                                                  likedArray);
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0,
                                                              bottom: 4.0),
                                                      child: Text(
                                                        'Going?',
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          0, 0, 30.0, 10),
                                                      child: Text('$likeCount',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: TextThemes
                                                                  .ndBlue,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )),
                                          /*ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        FlatButton(
                          textColor: const Color(0xFF6200EE),
                          onPressed: () {
                            // Perform some action
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text("WHO'S GOING?",
                                  style: TextStyle(
                                      color: Colors.blue[500],
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left)),
                        ),
                        FlatButton(
                          textColor: const Color(0xFF6200EE),
                          onPressed: () {
                            // Perform some action
                          },
                          child: IconButton(
                            icon: (_isPressed)
                                ? new Icon(Icons.favorite)
                                : new Icon(Icons.favorite_border),
                            color: Colors.pink,
                            iconSize: 24.0,
                            splashColor: Colors.pink,
                            splashRadius: 7.0,
                            highlightColor: Colors.pink,
                            onPressed: () {
                              // Perform action
                              setState(() {
                                List<dynamic> likedArray = course["liked"];
                                if (likedArray != null && likedArray.contains(strUserId)) {
                                  Database().removeGoing(strUserId, course.documentID);
                                } else {
                                  Database().addLike(strUserId, course.documentID);
                                }
                                */ /*if (_isPressed) {
                                  Database().removeGoing(strUserId, course.documentID);
                                } else {
                                  Database().addLike(strUserId, course.documentID);
                                }*/ /*
                              });
                            },
                          ),
                        )
                      ],
                    ),*/
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      ),
                      // Sign Up View
                      Center(
                        child: StreamBuilder(
                            stream: Firestore.instance
                                .collection('food')
                                .where("type", isEqualTo: type)
                                .orderBy("startDate")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return Text('No MOOVs!');
                              return ListView.builder(
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot course =
                                      snapshot.data.documents[index];
                                  List<dynamic> likedArray = course["liked"];
                                  List<String> uidArray = List<String>();
                                  if (likedArray != null) {
                                    likeCount = likedArray.length;
                                    for (int i = 0; i < likeCount; i++) {
                                      var id = likedArray[i]["uid"];
                                      uidArray.add(id);
                                    }
                                  } else {
                                    likeCount = 0;
                                  }

                                  if (uidArray != null &&
                                      uidArray.contains(strUserId)) {
                                    _isPressed = true;
                                  } else {
                                    _isPressed = false;
                                  }

                                  return Card(
                                    color: Colors.white,
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PostDetail(
                                                        course['image'],
                                                        course['title'],
                                                        course['description'],
                                                        course['startDate'],
                                                        course['location'],
                                                        course['address'],
                                                        course['userId'],
                                                        likedArray,
                                                        course.documentID)));
                                      },
                                      onDoubleTap: () {
                                        setState(() {
                                          List<dynamic> likedArray =
                                              course["liked"];
                                          List<String> uidArray =
                                              List<String>();
                                          if (likedArray != null) {
                                            likeCount = likedArray.length;
                                            for (int i = 0;
                                                i < likeCount;
                                                i++) {
                                              var id = likedArray[i]["uid"];
                                              uidArray.add(id);
                                            }
                                          }

                                          if (uidArray != null &&
                                              uidArray.contains(strUserId)) {
                                            Database().removeGoing(
                                                course["userId"],
                                                course["image"],
                                                strUserId,
                                                course.documentID,
                                                strUserName,
                                                strUserPic,
                                                course["startDate"],
                                                course["title"],
                                                course["description"],
                                                course["location"],
                                                course["address"],
                                                course["profilePic"],
                                                course["userName"],
                                                course["userEmail"],
                                                likedArray);
                                          } else {
                                            Database().addGoing(
                                                course["userId"],
                                                course["image"],
                                                strUserId,
                                                course.documentID,
                                                strUserName,
                                                strUserPic,
                                                course["startDate"],
                                                course["title"],
                                                course["description"],
                                                course["location"],
                                                course["address"],
                                                course["profilePic"],
                                                course["userName"],
                                                course["userEmail"],
                                                likedArray);
                                          }
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          ListTile(
                                            title: Row(children: <Widget>[
                                              Expanded(
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5.0,
                                                              right: 5,
                                                              bottom: 5),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                          color:
                                                              Color(0xff000000),
                                                          width: 1,
                                                        )),
                                                        /*child: Image.asset(
                                        'lib/assets/filmbutton1.png',
                                        fit: BoxFit.cover,
                                        height: 130,
                                        width: 50),*/
                                                        child: Image.network(
                                                            course['image'],
                                                            fit: BoxFit.cover,
                                                            height: 130,
                                                            width: 50),
                                                      ))),
                                              Expanded(
                                                  child:
                                                      Column(children: <Widget>[
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0)),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: Text(
                                                        course['title']
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue[900],
                                                            fontSize: 20.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center)),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Text(
                                                    course['description']
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.black
                                                            .withOpacity(0.6)),
                                                  ),
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0)),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 4.0),
                                                          child: Icon(
                                                              Icons.timer,
                                                              color: TextThemes
                                                                  .ndGold,
                                                              size: 20),
                                                        ),
                                                        Text('WHEN: ',
                                                            style: TextStyle(
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(
                                                            DateFormat('MMMd')
                                                                .add_jm()
                                                                .format(course[
                                                                        'startDate']
                                                                    .toDate()),
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                            )),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 4.0),
                                                          child: Icon(
                                                              Icons.place,
                                                              color: TextThemes
                                                                  .ndGold,
                                                              size: 20),
                                                        ),
                                                        Text('WHERE: ',
                                                            style: TextStyle(
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(course['address'],
                                                            style: TextStyle(
                                                              fontSize: 12.0,
                                                            )),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ]))
                                            ]),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 1.0),
                                            child: Container(
                                              height: 1.0,
                                              width: 500.0,
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                          Container(
                                              child: Row(
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          12, 10, 4, 10),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if (course['userId'] ==
                                                          strUserId) {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ProfilePage()));
                                                      } else {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        OtherProfile(
                                                                          course[
                                                                              'profilePic'],
                                                                          course[
                                                                              'userName'],
                                                                          course[
                                                                              'userId'],
                                                                        )));
                                                      }
                                                    },
                                                    child: CircleAvatar(
                                                      radius: 22.0,
                                                      backgroundImage:
                                                          NetworkImage(course[
                                                              'profilePic']),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                    ),
                                                  )),
                                              Container(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (course['userId'] ==
                                                        strUserId) {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ProfilePage()));
                                                    } else {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  OtherProfile(
                                                                    course[
                                                                        'profilePic'],
                                                                    course[
                                                                        'userName'],
                                                                    course[
                                                                        'userId'],
                                                                  )));
                                                    }
                                                  },
                                                  child: Column(
                                                    //  mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 2.0),
                                                        child: Text(
                                                            course['userName'],
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color:
                                                                    TextThemes
                                                                        .ndBlue,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none)),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 2.0),
                                                        child: Text(
                                                            course['userEmail'],
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    TextThemes
                                                                        .ndBlue,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              Container(
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 50.0,
                                                              bottom: 10.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Share.share(
                                                            "MOOV",
                                                            subject:
                                                                'Update the coordinate!',
                                                          );
                                                        },
                                                        child: Icon(
                                                            Icons.send_rounded,
                                                            color: Colors
                                                                .blue[500],
                                                            size: 30),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 50.0,
                                                              bottom: 20.0),
                                                      child: Text(
                                                        'Send',
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Column(
                                                  //  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: IconButton(
                                                        icon: (_isPressed)
                                                            ? new Icon(
                                                                Icons
                                                                    .directions_run,
                                                                color: Colors
                                                                    .green)
                                                            : new Icon(Icons
                                                                .directions_walk),
                                                        color: Colors.red,
                                                        iconSize: 30.0,
                                                        splashColor:
                                                            Colors.green,
                                                        //splashRadius: 7.0,
                                                        highlightColor:
                                                            Colors.green,
                                                        onPressed: () {
                                                          setState(() {
                                                            List<dynamic>
                                                                likedArray =
                                                                course["liked"];
                                                            List<String>
                                                                uidArray =
                                                                List<String>();
                                                            if (likedArray !=
                                                                null) {
                                                              likeCount =
                                                                  likedArray
                                                                      .length;
                                                              for (int i = 0;
                                                                  i < likeCount;
                                                                  i++) {
                                                                var id =
                                                                    likedArray[
                                                                            i]
                                                                        ["uid"];
                                                                uidArray
                                                                    .add(id);
                                                              }
                                                            }

                                                            if (uidArray !=
                                                                    null &&
                                                                uidArray.contains(
                                                                    strUserId)) {
                                                              Database().removeGoing(
                                                                  course[
                                                                      "userId"],
                                                                  course[
                                                                      "image"],
                                                                  strUserId,
                                                                  course
                                                                      .documentID,
                                                                  strUserName,
                                                                  strUserPic,
                                                                  course[
                                                                      "startDate"],
                                                                  course[
                                                                      "title"],
                                                                  course[
                                                                      "description"],
                                                                  course[
                                                                      "location"],
                                                                  course[
                                                                      "address"],
                                                                  course[
                                                                      "profilePic"],
                                                                  course[
                                                                      "userName"],
                                                                  course[
                                                                      "userEmail"],
                                                                  likedArray);
                                                            } else {
                                                              Database().addGoing(
                                                                  course[
                                                                      "userId"],
                                                                  course[
                                                                      "image"],
                                                                  strUserId,
                                                                  course
                                                                      .documentID,
                                                                  strUserName,
                                                                  strUserPic,
                                                                  course[
                                                                      "startDate"],
                                                                  course[
                                                                      "title"],
                                                                  course[
                                                                      "description"],
                                                                  course[
                                                                      "location"],
                                                                  course[
                                                                      "address"],
                                                                  course[
                                                                      "profilePic"],
                                                                  course[
                                                                      "userName"],
                                                                  course[
                                                                      "userEmail"],
                                                                  likedArray);
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0,
                                                              bottom: 4.0),
                                                      child: Text(
                                                        'Going?',
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          0, 0, 30.0, 10),
                                                      child: Text('$likeCount',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: TextThemes
                                                                  .ndBlue,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )),
                                          /*ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        FlatButton(
                          textColor: const Color(0xFF6200EE),
                          onPressed: () {
                            // Perform some action
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text("WHO'S GOING?",
                                  style: TextStyle(
                                      color: Colors.blue[500],
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left)),
                        ),
                        FlatButton(
                          textColor: const Color(0xFF6200EE),
                          onPressed: () {
                            // Perform some action
                          },
                          child: IconButton(
                            icon: (_isPressed)
                                ? new Icon(Icons.favorite)
                                : new Icon(Icons.favorite_border),
                            color: Colors.pink,
                            iconSize: 24.0,
                            splashColor: Colors.pink,
                            splashRadius: 7.0,
                            highlightColor: Colors.pink,
                            onPressed: () {
                              // Perform action
                              setState(() {
                                List<dynamic> likedArray = course["liked"];
                                if (likedArray != null && likedArray.contains(strUserId)) {
                                  Database().removeGoing(strUserId, course.documentID);
                                } else {
                                  Database().addLike(strUserId, course.documentID);
                                }
                                */ /*if (_isPressed) {
                                  Database().removeGoing(strUserId, course.documentID);
                                } else {
                                  Database().addLike(strUserId, course.documentID);
                                }*/ /*
                              });
                            },
                          ),
                        )
                      ],
                    ),*/
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      ),
                    ]),
              )
            ],
          ),
        ));
  }
}