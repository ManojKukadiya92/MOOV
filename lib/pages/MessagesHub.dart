import 'dart:io';
import 'dart:ui';
import 'package:MOOV/friendGroups/group_detail.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/add_users_post.dart';
import 'package:MOOV/widgets/camera.dart';
import 'package:MOOV/widgets/chat.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MessagesHub extends StatelessWidget {
  Container buildNoContent() {
    return Container(
      color: TextThemes.ndBlue,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.search),
            Text(
              "",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

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
        backgroundColor: Colors.white,
        body: StreamBuilder(
            stream: messagesRef
                .where('people', arrayContains: currentUser.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              if (snapshot.data.docs.length == 0) {
                return Container(
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.only(bottom: 50.0),
                        //   child: RaisedButton(
                        //     onPressed: () {
                        //       Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) =>
                        //                   SearchBarWithHeader()));
                        //     },
                        //     color: TextThemes.ndBlue,
                        //     child: Padding(
                        //       padding: const EdgeInsets.all(8.0),
                        //       child: Row(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           Icon(Icons.message, color: TextThemes.ndGold),
                        //           Padding(
                        //             padding: const EdgeInsets.all(8.0),
                        //             child: Text('Message People and Businesses',
                        //                 style: TextStyle(
                        //                     color: Colors.white,
                        //                     fontSize: isLargePhone ? 17 : 14)),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(8.0)),
                        //   ),
                        // ),
                        Text(
                          "Your direct messages will appear here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  )),
                );
              }

              return Container(
                // height: (snapshot.data.documents.length <= 3) ? 270 : 400,
                child: Column(
                  children: [
                    Expanded(
                        child: CustomScrollView(
                      slivers: [
                        // SliverToBoxAdapter(
                        //     child: Padding(
                        //   padding: const EdgeInsets.all(25.0),
                        //   child: RaisedButton(
                        //     onPressed: () {
                        //       Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) =>
                        //                   SearchBarWithHeader()));
                        //     },
                        //     color: TextThemes.ndBlue,
                        //     child: Padding(
                        //       padding: const EdgeInsets.all(8.0),
                        //       child: Row(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           Icon(Icons.people, color: TextThemes.ndGold),
                        //           Padding(
                        //             padding: const EdgeInsets.all(8.0),
                        //             child: Text('Message People and Businesses',
                        //                 style: TextStyle(
                        //                     color: Colors.white,
                        //                     fontSize: isLargePhone ? 17 : 14)),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(8.0)),
                        //   ),
                        // )),
                        SliverPadding(
                          padding: EdgeInsets.all(10),
                          sliver: SliverGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio: 1.5,
                            children: <Widget>[
                              StreamBuilder(
                                  stream: usersRef
                                      .where("friendArray",
                                          arrayContains: currentUser.id)
                                      .snapshots(),
                                  // ignore: missing_return
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return CircularProgressIndicator();

                                    for (int i = 0;
                                        i < snapshot.data.docs.length;
                                        i++) {
                                      DocumentSnapshot course4 =
                                          snapshot.data.docs[i];

                                      return Container(
                                          decoration: BoxDecoration(
                                            color: TextThemes.ndBlue,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MessageList()));
                                            },
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: new BackdropFilter(
                                                    filter:
                                                        new ImageFilter.blur(
                                                            sigmaX: 10.0,
                                                            sigmaY: 10.0),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Stack(children: [
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        4.0),
                                                                child: currentUser
                                                                            .friendArray
                                                                            .length >
                                                                        1
                                                                    ? CircleAvatar(
                                                                        radius:
                                                                            20.0,
                                                                        backgroundImage: NetworkImage(snapshot
                                                                            .data
                                                                            .docs[0]['photoUrl']),
                                                                      )
                                                                    : Container()),
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 4,
                                                                        left:
                                                                            25.0),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 20.0,
                                                                  backgroundImage:
                                                                      NetworkImage(
                                                                    snapshot.data
                                                                            .docs[1]
                                                                        [
                                                                        'photoUrl'],
                                                                  ),
                                                                )),
                                                          ]),
                                                          Text("People",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20)),
                                                          BackdropFilter(
                                                              filter: ImageFilter
                                                                  .blur(
                                                                      sigmaX:
                                                                          3.0,
                                                                      sigmaY:
                                                                          3.0),
                                                              child:
                                                                  new Container(
                                                                decoration: new BoxDecoration(
                                                                    color: Colors
                                                                        .yellow
                                                                        .withOpacity(
                                                                            0.2)),
                                                              )),
                                                        ]))),
                                          ));
                                    }
                                  }),
                              StreamBuilder(
                                  stream: groupsRef
                                      .where("members",
                                          arrayContains: currentUser.id)
                                      .snapshots(),
                                  // ignore: missing_return
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return CircularProgressIndicator();

                                    for (int i = 0;
                                        i < snapshot.data.docs.length;
                                        i++) {
                                      DocumentSnapshot course4 =
                                          snapshot.data.docs[i];

                                      return Container(
                                          decoration: BoxDecoration(
                                            color: TextThemes.ndBlue,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: new BackdropFilter(
                                                  filter: new ImageFilter.blur(
                                                      sigmaX: 10.0,
                                                      sigmaY: 10.0),
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Stack(children: [
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: currentUser
                                                                          .friendGroups
                                                                          .length >
                                                                      0
                                                                  ? Container(
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(15)),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          memCacheHeight:
                                                                              100,
                                                                          memCacheWidth:
                                                                              100,
                                                                          imageUrl:
                                                                              course4['groupPic'],
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          height: isLargePhone
                                                                              ? MediaQuery.of(context).size.height * 0.04
                                                                              : MediaQuery.of(context).size.height * 0.06,
                                                                          width: isLargePhone
                                                                              ? MediaQuery.of(context).size.width * 0.22
                                                                              : MediaQuery.of(context).size.width * 0.22,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container()),
                                                        ]),
                                                        Text("Friend Groups",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20)),
                                                      ]))));
                                    }
                                  }),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10),
                            child: Stack(children: [
                              SizedBox(
                                height: 250,
                                child: StreamBuilder(
                                    stream: messagesRef
                                        .where('people',
                                            arrayContains: currentUser.id)
                                        // .orderBy("unix")
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.data.docs == null ||
                                          !snapshot.hasData) {
                                        return Container();
                                      } else
                                        for (int i = 0;
                                            i < snapshot.data.docs.length;
                                            i++) {
                                          DocumentSnapshot course =
                                              snapshot.data.docs[i];
                                          List people = course['people'];
                                          people.removeWhere(
                                              (item) => item == currentUser.id);
                                          String otherPerson = people[0];
                                          return Container(
                                            height: 100,
                                            child: Chat(
                                              gid: "",
                                              directMessageId:
                                                  course['directMessageId'],
                                              otherPerson: otherPerson,
                                              isGroupChat: false,
                                            ),
                                          );
                                        }
                                      return circularProgress();
                                    }),
                              ),
                              Text(' Last Active Conversation',
                                  style: TextStyle(fontSize: 16)),
                            ]),
                            // Container(
                            //   decoration: BoxDecoration(
                            //       color: Colors.grey[100],
                            //       borderRadius: BorderRadius.circular(10.0)),
                            //   height: 150,
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Stack(children: [
                            //     StreamBuilder(
                            //         stream: messagesRef
                            //             .where('people',
                            //                 arrayContains: currentUser.id)
                            //             .orderBy("timestamp")
                            //             .snapshots(),
                            //         builder: (context, snapshot) {
                            //           if (!snapshot.hasData) return Container();
                            //           if (snapshot.data.docs.length == 0) {
                            //             return Container();
                            //           }
                            //           for (int i = 0;
                            //               i < snapshot.data.docs.length;
                            //               i++) {
                            //             DocumentSnapshot course =
                            //                 snapshot.data.docs[i];
                            //             List people = course['people'];
                            //             people.removeWhere(
                            //                 (item) => item == currentUser.id);
                            //             String otherPerson = people[0];
                            //             return Container(
                            //               height: 100,
                            //               child: Chat(
                            //                 gid: "",
                            //                 directMessageId:
                            //                     course['directMessageId'],
                            //                 otherPerson: otherPerson,
                            //                 isGroupChat: false,
                            //               ),
                            //             );
                            //           }
                            //           return Container();
                            //         }),
                            //     Text('Last Active Conversation',
                            //         style: TextStyle(fontSize: 18)),
                            //   ]),
                            // ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 10),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: TextThemes.ndBlue),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: new BackdropFilter(
                                        filter: new ImageFilter.blur(
                                            sigmaX: 10.0, sigmaY: 10.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Stack(children: [
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: CircleAvatar(
                                                        radius: 20.0,
                                                        child: Icon(
                                                            Icons.person,
                                                            color:
                                                                Colors.white),
                                                        backgroundColor:
                                                            TextThemes.ndGold,
                                                      ))
                                                ]),
                                                Text("Make A Friend",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20)),
                                                BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 3.0,
                                                        sigmaY: 3.0),
                                                    child: new Container(
                                                      decoration:
                                                          new BoxDecoration(
                                                              color: Colors
                                                                  .yellow
                                                                  .withOpacity(
                                                                      0.2)),
                                                    )),
                                              ]),
                                        )))),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              );
            }));
  }
}

class MessageList extends StatelessWidget {
  MessageList({Key key}) : super(key: key);

  EasyRefreshController _controller;

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            padding: EdgeInsets.only(),
            icon: Icon(Icons.add),
            color: Colors.white,
            splashColor: Color.fromRGBO(220, 180, 57, 1.0),
            onPressed: () async {
              Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: SearchUsersMessage(true),
                  ));
            },
          ),
        ],
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
      body: StreamBuilder(
          stream: messagesRef //featured
              .where("people", arrayContains: currentUser.id)
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data.docs.length == 0)
              return SearchUsersMessage(false);

            return EasyRefresh(
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 1), () {
                  // _controller.resetLoadState();
                });
              },
              onLoad: () async {
                await Future.delayed(Duration(seconds: 1), () {
                  // setState(() {
                  //   // refreshData();
                  //   setState(() {});
                  // });
                  _controller.finishLoad();
                });
              },
              enableControlFinishRefresh: false,
              enableControlFinishLoad: true,
              controller: _controller,
              header: BezierCircleHeader(
                  color: TextThemes.ndGold, backgroundColor: TextThemes.ndBlue),
              footer: BezierBounceFooter(backgroundColor: Colors.white),
              bottomBouncing: false,
              child: ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  //adding da button

                  DocumentSnapshot course = snapshot.data.docs[index];
                  List people = course['people'];
                  people.removeWhere((item) => item == currentUser.id);
                  String otherPerson = people[0];
                  int timestamp = course['timestamp'];
                  bool isGroupChat = course['isGroupChat'];
                  String gid = course['gid'];

                  var now = new DateTime.now();
                  var format = new DateFormat('HH:mm a');
                  var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
                  var diff = now.difference(date);
                  String timeAgo = '';

                  timeAgo = 'a moment ago';

                  if (diff.inMinutes >= 2 && diff.inMinutes <= 60) {
                    timeAgo = (diff.inMinutes).toString() + ' minutes ago';
                  }
                  if (diff.inMinutes >= 60 && diff.inMinutes <= 119) {
                    timeAgo = '1 hour ago';
                  }
                  if (diff.inMinutes >= 120) {
                    timeAgo =
                        (diff.inMinutes / 60).round().toString() + ' hours ago';
                  }
                  if (1440 <= diff.inMinutes && diff.inMinutes <= 2880) {
                    timeAgo =
                        (diff.inMinutes / 1440).round().toString() + ' day ago';
                  }
                  if (diff.inMinutes >= 2880) {
                    timeAgo = (diff.inMinutes / 1440).round().toString() +
                        ' days ago';
                  }
                  if (diff.inMinutes >= 10080) {
                    timeAgo = 'long ass time ago';
                  }

                  return (isGroupChat == false)
                      ? StreamBuilder(
                          stream: usersRef.doc(otherPerson).snapshots(),
                          builder: (context, snapshot) {
                            // print(index);
                            if (!snapshot.hasData || snapshot.data == null) {
                              return circularProgress();
                            }
                            return GestureDetector(
                              onTap: () {
                                if (currentUser.id != course['sender']) {
                                  Database().setMessagesSeen(
                                      course['directMessageId']);
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MessageDetail(
                                            directMessageId:
                                                course['directMessageId'],
                                            otherPerson: otherPerson,
                                            isGroupChat: false,
                                            members: [],
                                            sendingPost: {})));
                              },
                              child: Container(
                                height: 100,
                                child: Row(
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            top: 0, left: 15.0, right: 10),
                                        child: CircleAvatar(
                                          radius: 30.0,
                                          backgroundImage: NetworkImage(
                                            snapshot.data['photoUrl'],
                                          ),
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(top: 30),
                                        child: Column(children: <Widget>[
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .46,
                                            child: course['seen'] == true ||
                                                    currentUser.id ==
                                                        course['sender']
                                                ? Text(
                                                    snapshot
                                                        .data['displayName'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            Colors.grey[700]))
                                                : Text(
                                                    snapshot
                                                        .data['displayName'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .46,
                                            child: course['seen'] == true ||
                                                    currentUser.id ==
                                                        course['sender']
                                                ? Text(course['lastMessage'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            Colors.grey[700]))
                                                : Text(course['lastMessage'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                          )
                                        ])),
                                    Spacer(),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: Text(
                                          timeAgo,
                                          style: TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          })
                      : StreamBuilder(
                          stream: groupsRef.doc(gid).snapshots(),
                          builder: (context, snapshot) {
                            // print(index);
                            if (!snapshot.hasData || snapshot.data == null) {
                              return circularProgress();
                            }
                            return GestureDetector(
                              onTap: () {
                                print(otherPerson);
                                if (currentUser.id != course['sender']) {
                                  Database().setMessagesSeen(gid);
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MessageDetail(
                                            directMessageId: " ",
                                            otherPerson: " ",
                                            isGroupChat: true,
                                            gid: gid,
                                            members: snapshot.data['members'],
                                            sendingPost: {})));
                              },
                              child: Container(
                                height: 100,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 0, left: 0.0, right: 0),
                                      child: SizedBox(
                                        width: isLargePhone
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.24
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.24,
                                        height: isLargePhone
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.07
                                            : MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.1,
                                        child: Container(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              memCacheHeight: 100,
                                              memCacheWidth: 100,
                                              imageUrl:
                                                  snapshot.data['groupPic'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          margin: EdgeInsets.only(
                                              left: 10,
                                              top: 0,
                                              right: 10,
                                              bottom: 0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 7,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(top: 30),
                                        child: Column(children: <Widget>[
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .46,
                                            child: course['seen'] == true ||
                                                    currentUser.id ==
                                                        course['sender']
                                                ? Text(
                                                    snapshot.data['groupName'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            Colors.grey[700]))
                                                : Text(
                                                    snapshot.data['groupName'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .46,
                                            child: course['seen'] == true ||
                                                    currentUser.id ==
                                                        course['sender']
                                                ? Text(course['lastMessage'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            Colors.grey[700]))
                                                : Text(course['lastMessage'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                          )
                                        ])),
                                    Spacer(),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15.0),
                                        child: Text(
                                          timeAgo,
                                          style: TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                },
              ),
            );
          }),
    );
  }
}

class MessageDetail extends StatefulWidget {
  final String otherPerson, directMessageId, gid;
  final bool isGroupChat, isClubChat;
  final List<dynamic> members;
  final Map<String, String> sendingPost;

  MessageDetail(
      {this.directMessageId = " ",
      this.otherPerson = " ",
      this.isGroupChat = false,
      this.isClubChat = false,
      this.gid = " ",
      this.members,
      this.sendingPost});

  @override
  _MessageDetailState createState() => _MessageDetailState();
}

class _MessageDetailState extends State<MessageDetail> {
  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

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
                  onTap: widget.isGroupChat
                      ? () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => GroupDetail(widget.gid)));
                        }
                      : () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  OtherProfile(widget.otherPerson)));
                        },
                  child: (widget.isGroupChat == false &&
                          widget.isClubChat == false)
                      ? StreamBuilder(
                          stream: usersRef.doc(widget.otherPerson).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              return circularProgress();
                            }

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20.0,
                                    backgroundImage:
                                        NetworkImage(snapshot.data['photoUrl']),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      snapshot.data['displayName'],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            );
                          })
                      : (widget.isClubChat) //club chats
                          ? StreamBuilder(
                              stream: clubsRef.doc(widget.gid).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return circularProgress();
                                }

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      // Container(
                                      //   child: ClipRRect(
                                      //     borderRadius:
                                      //         BorderRadius.all(Radius.circular(15)),
                                      //     child: CachedNetworkImage(
                                      // memCacheHeight: 100,
                                      // memCacheWidth: 100,
                                      //       imageUrl: snapshot.data['groupPic'],
                                      //       fit: BoxFit.cover,
                                      //       height: isLargePhone
                                      //           ? MediaQuery.of(context)
                                      //                   .size
                                      //                   .height *
                                      //               0.04
                                      //           : MediaQuery.of(context)
                                      //                   .size
                                      //                   .height *
                                      //               0.06,
                                      //       width:
                                      //           MediaQuery.of(context).size.width *
                                      //               0.15,
                                      //     ),
                                      //   ),
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          snapshot.data['clubName'],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              })
                          : StreamBuilder(
                              stream: groupsRef.doc(widget.gid).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return circularProgress();
                                }

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          child: CachedNetworkImage(
                                            memCacheHeight: 100,
                                            memCacheWidth: 100,
                                            imageUrl: snapshot.data['groupPic'],
                                            fit: BoxFit.cover,
                                            height: isLargePhone
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.04
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.06,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.15,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          snapshot.data['groupName'],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              })),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              widget.isGroupChat
                  ? Chat(
                      gid: widget.gid,
                      isGroupChat: true,
                      directMessageId: " ",
                      members: widget.members,
                      sendingPost: widget.sendingPost)
                  : Chat(
                      isGroupChat: false,
                      directMessageId: widget.directMessageId,
                      otherPerson: widget.otherPerson,
                      sendingPost: widget.sendingPost),
              SizedBox(height: 20),
              MessageScreenshot()
            ],
          ),
        ),
      ),
    );
  }
}

class MessageScreenshot extends StatefulWidget {
  MessageScreenshot({Key key}) : super(key: key);

  @override
  _MessageScreenshotState createState() => _MessageScreenshotState();
}

class _MessageScreenshotState extends State<MessageScreenshot> {
  File _image;
  final picker = ImagePicker();

  void openCamera(context) async {
    final image = await CustomCamera.openCamera();
    setState(() {
      _image = image;
      //  fileName = p.basename(_image.path);
    });
  }

  void openGallery(context) async {
    final image = await CustomCamera.openGallery();
    setState(() {
      _image = image;
    });
  }

  Future handleTakePhoto() async {
    Navigator.pop(context);
    final file = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      if (_image != null) {
        _image = File(file.path);
      }
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    final file = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      if (_image != null) {
        _image = File(file.path);
      }
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Don't Flop",
            style: TextStyle(color: Colors.white),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                "Photo with Camera",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                openCamera(context);
                Navigator.of(context).pop();
              },
            ),
            SimpleDialogOption(
              //    child: Text("Image from Gallery", style: TextStyle(color: Colors.white),), onPressed: handleChooseFromGallery),
              //    child: Text("Image from Gallery", style: TextStyle(color: Colors.white),), onPressed: () => openGallery(context)),
              child: Text(
                "Image from Gallery",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                openGallery(context);
                Navigator.of(context).pop();
              },
            ),
            SimpleDialogOption(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context, true),
            )
          ],
        );
      },
    );
  }

  bool isUploading = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Text(
            "Welcome to MOOV DM's.",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            "\nHave a funny conversation? Get someone's number? Screenshot it (phone number's blurred), and submit it here for a chance to get featured and win \$20!",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          isUploading
              ? linearProgress()
              : Column(
                  children: [
                    _image != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 18.0),
                            child:
                                Stack(alignment: Alignment.center, children: [
                              Container(
                                height: 125,
                                width: MediaQuery.of(context).size.width * .8,
                                child: Center(
                                    child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.file(_image,
                                              fit: BoxFit.cover),
                                        ))),
                              ),
                              GestureDetector(
                                  onTap: () => selectImage(context),
                                  child: Icon(Icons.camera_alt))
                            ]),
                          )
                        : RaisedButton(
                            color: TextThemes.ndBlue,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Upload Screenshot',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            onPressed: () => selectImage(context)),
                    _image == null
                        ? Container()
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 75.0),
                            child: RaisedButton(
                              onPressed: () async {
                                if (_image != null) {
                                  setState(() {
                                    isUploading = true;
                                  });

                                  firebase_storage.Reference ref =
                                      firebase_storage.FirebaseStorage.instance
                                          .ref()
                                          .child("images/" +
                                              currentUser.id +
                                              "/" +
                                              DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString());

                                  firebase_storage.UploadTask uploadTask;

                                  uploadTask = ref.putFile(_image);

                                  firebase_storage.TaskSnapshot taskSnapshot =
                                      await uploadTask;
                                  if (uploadTask.snapshot.state ==
                                      firebase_storage.TaskState.success) {
                                    print("added to Firebase Storage");
                                    final String downloadUrl =
                                        await taskSnapshot.ref.getDownloadURL();
                                    Database().funnyScreenshot(
                                      user: currentUser.displayName,
                                      timestamp:
                                          DateTime.now().millisecondsSinceEpoch,
                                      venmo: currentUser.venmoUsername,
                                      imageUrl: downloadUrl,
                                    );

                                    setState(() {
                                      isUploading = false;
                                    });
                                  }
                                }
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80.0)),
                              padding: EdgeInsets.all(0.0),
                              child: Ink(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        TextThemes.ndBlue,
                                        Color(0xff64B6FF)
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30.0)),
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth: 300.0, minHeight: 50.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Submit",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                )
        ],
      ),
    );
  }
}
