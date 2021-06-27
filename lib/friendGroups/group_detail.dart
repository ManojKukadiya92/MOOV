import 'dart:async';
import 'dart:ui';
import 'package:MOOV/friendGroups/groupCalendar.dart';
import 'package:MOOV/helpers/size_config.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/MessagesHub.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:MOOV/pages/notification_feed_group.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/widgets/add_users_post.dart';
import 'package:MOOV/widgets/set_moov.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:MOOV/services/database.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share/share.dart';
import '../friendGroups/edit_group.dart';
import 'package:MOOV/pages/home.dart';
import 'package:collection/collection.dart';

class GroupDetail extends StatefulWidget {
  final String gid;

  GroupDetail(this.gid);

  @override
  State<StatefulWidget> createState() {
    return _GroupDetailState(this.gid);
  }
}

class _GroupDetailState extends State<GroupDetail> {
  String gid, groupName, groupPic, nextMOOV;
  List<dynamic> members;

  bool member;
  final dbRef = FirebaseFirestore.instance;

  _GroupDetailState(this.gid);

  sendChat() {
    Database().sendChat(currentUser.displayName, chatController.text, gid);
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Leave the group?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nTime to MOOV on?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Yes get me out", style: TextStyle(color: Colors.red)),
            onPressed: () {
              leaveGroup();
              Navigator.of(context).pop(true);
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

  bool requestsent = false;
  TextEditingController chatController = TextEditingController();
  bool sendRequest = false;
  bool friends;

  var userRequests;
  final GoogleSignInAccount userMe = googleSignIn.currentUser;
  final strUserId = currentUser.id;
  final strPic = currentUser.photoUrl;
  final strUserName = currentUser.displayName;
  var profilePic;
  var otherDisplay;
  int id = 0;
  var iter = 1;
  int status = 0;

  void refreshData() {
    id++;
  }

  FutureOr onGoBack(dynamic value) {
    refreshData();
    setState(() {});
  }

  String firstNamer(String fullName) {
    List<String> tempList = fullName.split(" ");
    int start = 0;
    int end = tempList.length;
    if (end > 1) {
      end = 1;
    }
    final selectedWords = tempList.sublist(start, end);
    String firstName = selectedWords.join(" ");
    return firstName;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> voters = {};

    bool isLargePhone = Screen.diagonal(context) > 766;

    return StreamBuilder(
        stream: usersRef.where('friendGroups', arrayContains: gid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data == null) return Container();

          return StreamBuilder(
              stream: groupsRef.doc(gid).snapshots(),
              builder: (context, snapshot2) {
                if (!snapshot2.hasData) return CircularProgressIndicator();
                if (snapshot2.data == null) return Container();

                DocumentSnapshot course = snapshot2.data;

                groupName = course['groupName'];
                groupPic = course['groupPic'];
                members = course['members'];

                if ((members.contains(strUserId))) {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        backgroundColor: TextThemes.ndBlue,
                        flexibleSpace: FlexibleSpaceBar(
                          titlePadding: EdgeInsets.all(15),
                          title: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 210),
                            child: Text(
                              groupName,
                              style: TextStyle(
                                  fontSize: isLargePhone ? 24.0 : 22,
                                  color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          // Padding(
                          //   padding: const EdgeInsets.all(4.0),
                          //   child: FlatButton(
                          //       onPressed: () {
                          //         Database()
                          //             .leaveGroup(currentUser.id, displayName, gid);

                          //         Navigator.pop(
                          //           context,
                          //           MaterialPageRoute(builder: (context) => HomePage()),
                          //         );
                          //       },
                          //       child: Text(
                          //         "LEAVE",
                          //         style: TextStyle(color: Colors.red),
                          //       )),
                          // ),

                          FocusedMenuHolder(
                            menuWidth: MediaQuery.of(context).size.width * 0.50,
                            blurSize: 5.0,
                            menuItemExtent: 45,
                            menuBoxDecoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                            duration: Duration(milliseconds: 100),
                            animateMenuItems: true,
                            blurBackgroundColor: Colors.black54,
                            openWithTap:
                                true, // Open Focused-Menu on Tap rather than Long Press
                            menuOffset:
                                10.0, // Offset value to show menuItem from the selected item
                            bottomOffsetHeight:
                                80.0, // Offset height to consider, for showing the menu item ( for Suggestions bottom navigation bar), so that the popup menu will be shown on top of selected item.
                            menuItems: <FocusedMenuItem>[
                              // Add Each FocusedMenuItem  for Menu Options

                              FocusedMenuItem(
                                  title: Text("Add Friends"),
                                  trailingIcon: Icon(Icons.person_add),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.bottomToTop,
                                            child: SearchUsersGroup(
                                                gname:groupName,
                                                gid:gid,
                                                pic: groupPic,
                                                moov: nextMOOV,
                                                members: members)));
                                  }),

                              FocusedMenuItem(
                                  title: Text("Share"),
                                  trailingIcon: Icon(Icons.send),
                                  onPressed: () {
                                    Share.share("You found the Easter Egg! 🥚");
                                  }),
                              FocusedMenuItem(
                                  title: Text("Edit Group"),
                                  trailingIcon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditGroup(
                                                groupPic,
                                                groupName,
                                                members,
                                                gid)));
                                  }),
                              FocusedMenuItem(
                                  title: Text(
                                    "Leave Group",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  trailingIcon: Icon(
                                    Icons.directions_walk,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    showAlertDialog(context);
                                  }),
                            ],
                            onPressed: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, right: 5),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationFeedGroup(gid)));
                              },
                              child: Column(children: [
                                NotifIconGroup(
                                  iconData: Icons.notifications_active_outlined,
                                  gid: gid,
                                ),
                                Text(
                                  "GROUP",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                )
                              ]),
                            ),
                          )
                        ]),
                    body: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Container(
                        child: Column(
                          children: [
                            Stack(children: [
                              Container(
                                  height: 120,
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.network(
                                    groupPic,
                                    fit: BoxFit.cover,
                                    color: Colors.black26,
                                    colorBlendMode: BlendMode.darken,
                                  )),
                              Container(
                                  child: Column(children: [
                                Container(
                                  height: 120,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      itemCount: members.length,
                                      itemBuilder: (_, index) {
                                        DocumentSnapshot course =
                                            snapshot2.data;

                                        String name = firstNamer(snapshot
                                            .data.docs[index]['displayName']);

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              left: 3.0, right: 3),
                                          child: Container(
                                            width: 80,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15.0,
                                                          bottom: 10),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if (snapshot.data
                                                                  .docs[index]
                                                              ['id'] ==
                                                          strUserId) {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ProfilePageWithHeader()));
                                                      } else {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        OtherProfile(
                                                                          snapshot
                                                                              .data
                                                                              .docs[index]['id'],
                                                                        )));
                                                      }
                                                    },
                                                    child: CircleAvatar(
                                                      radius: 30,
                                                      backgroundColor:
                                                          TextThemes.ndGold,
                                                      child: CircleAvatar(
                                                        // backgroundImage: snapshot.data
                                                        //     .documents[index].data['photoUrl'],
                                                        backgroundImage:
                                                            NetworkImage(snapshot
                                                                    .data
                                                                    .docs[index]
                                                                ['photoUrl']),
                                                        radius: 27,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  alignment:
                                                      Alignment(0.0, 0.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20)),
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: <Color>[
                                                          Colors.black
                                                              .withAlpha(0),
                                                          Colors.black,
                                                          Colors.black12,
                                                        ],
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                        name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Solway',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            fontSize: 14.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                )
                              ])),
                            ]),
                            SizedBox(height: 15),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text("Manage your",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic)),
                                      Text("MOOVs",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 20,
                                              color: TextThemes.ndGold)),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 30.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Bounce(
                                          duration: Duration(milliseconds: 500),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SearchSetMOOV(
                                                          groupId: gid,
                                                          groupName:
                                                              groupName)),
                                            );
                                          },
                                          child: Icon(
                                            Icons.add_circle,
                                            color: TextThemes.ndGold,
                                            size: 30,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Bounce(
                                          duration: Duration(milliseconds: 500),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MessageDetail(
                                                          isGroupChat: true,
                                                          gid: gid,
                                                          members: members,
                                                          sendingPost: {})),
                                            );
                                          },
                                          child: Icon(
                                            Icons.chat_bubble,
                                            color: TextThemes.ndGold,
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Column(children: [
                              FutureBuilder(
                                  future: groupsRef
                                      .doc(gid)
                                      .collection('suggestedMOOVs')
                                      .get(),
                                  builder: (context, snapshotSuggest) {
                                    if (!snapshotSuggest.hasData) {
                                      return Container();
                                    }

                                    List<Event> data = [];
                                    Map eventsDataMap = {};

                                    for (int i = 0;
                                        i < snapshotSuggest.data.docs.length;
                                        i++) {
                                      Event moov = Event(
                                          snapshotSuggest.data.docs[i]['title'],
                                          snapshotSuggest.data.docs[i]
                                              ['postId'],
                                          snapshotSuggest.data.docs[i]['pic'],
                                          snapshotSuggest.data.docs[i]
                                              ['startDate']);

                                      data.add(moov);
                                      eventsDataMap = groupBy(data,
                                          (obj) => obj.startDate.toDate().day);
                                      eventsDataMap = groupBy(
                                          data,
                                          (obj) => DateTime(
                                              obj.startDate.toDate().year,
                                              obj.startDate.toDate().month,
                                              obj.startDate.toDate().day));
                                    }

                                    return SizedBox(
                                        height: MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: GroupCalendar(eventsDataMap,
                                            widget.gid, groupName, members));
                                  }),
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 20.0),
                              //   child: Text(
                              //     "NEXT MOOV",
                              //     textAlign: TextAlign.center,
                              //     style: TextStyle(
                              //         fontSize: 20,
                              //         fontWeight: FontWeight.bold),
                              //   ),
                              // ),
                              // Suggestions(gid),
                              // Padding(
                              //   padding: const EdgeInsets.all(20),
                              //   child: RaisedButton(
                              //     onPressed: () {
                              //       Navigator.push(
                              //               context,
                              //               PageTransition(
                              //                   type: PageTransitionType
                              //                       .bottomToTop,
                              //                   child: SearchSetMOOV(
                              //                       groupId: gid,
                              //                       groupName: snapshot2
                              //                           .data['groupName'])))
                              //           .then(onGoBack);
                              //     },
                              //     color: TextThemes.ndBlue,
                              //     child: Padding(
                              //       padding: const EdgeInsets.all(2.0),
                              //       child: Row(
                              //         mainAxisSize: MainAxisSize.min,
                              //         children: [
                              //           Icon(Icons.edit,
                              //               color: TextThemes.ndGold),
                              //           Padding(
                              //             padding: const EdgeInsets.all(8.0),
                              //             child: Text('Suggest a MOOV',
                              //                 style: TextStyle(
                              //                     color: Colors.white,
                              //                     fontSize: 20)),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //     shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(8.0)),
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 0.0),
                              //   child: Column(
                              //     children: [
                              //       Row(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.center,
                              //         children: [
                              //           Text("Talk about it ",
                              //               style: TextStyle(
                              //                   color: TextThemes.ndBlue,
                              //                   fontSize: 18,
                              //                   fontWeight: FontWeight.bold)),
                              //           Icon(Icons.arrow_drop_down,
                              //               color: TextThemes.ndBlue),
                              //         ],
                              //       ),
                              //       // SizedBox(height: 10),
                              //       // Padding(
                              //       //   padding: const EdgeInsets.all(8.0),
                              //       //   child: Container(
                              //       //     decoration: BoxDecoration(
                              //       //       border: Border.all(
                              //       //           color: TextThemes.ndBlue),
                              //       //       borderRadius:
                              //       //           BorderRadius.circular(10.0),
                              //       //     ),
                              //       //     child: Padding(
                              //       //       padding:
                              //       //           const EdgeInsets.all(2.0),
                              //       //       child: Chat(
                              //       //         directMessageId: " ",
                              //       //         gid: gid,
                              //       //         isGroupChat: true,
                              //       //         members: members,
                              //       //         sendingPost: {},
                              //       //       ),
                              //       //     ),
                              //       //   ),
                              //       // ),
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 50,
                              // )
                            ])
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Scaffold(
                      backgroundColor: Colors.white,
                      appBar: AppBar(
                          leading: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          backgroundColor: TextThemes.ndBlue,
                          flexibleSpace: FlexibleSpaceBar(
                            titlePadding: EdgeInsets.all(15),
                            title: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 210),
                              child: Text(
                                groupName,
                                style: TextStyle(
                                    fontSize: isLargePhone ? 30.0 : 22,
                                    color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            // Padding(
                            //   padding: const EdgeInsets.all(4.0),
                            //   child: FlatButton(
                            //       onPressed: () {
                            //         Database()
                            //             .leaveGroup(currentUser.id, displayName, gid);

                            //         Navigator.pop(
                            //           context,
                            //           MaterialPageRoute(builder: (context) => HomePage()),
                            //         );
                            //       },
                            //       child: Text(
                            //         "LEAVE",
                            //         style: TextStyle(color: Colors.red),
                            //       )),
                            // ),
                            // IconButton(
                            //   padding: EdgeInsets.all(5.0),
                            //   icon: Icon(Icons.person_add),
                            //   color: Colors.white,
                            //   splashColor: Color.fromRGBO(220, 180, 57, 1.0),
                            //   onPressed: () {
                            //     Navigator.push(
                            //         context,
                            //         PageTransition(
                            //             type: PageTransitionType.bottomToTop,
                            //             child: AddUsers(groupName, gid,
                            //                 groupPic, members, nextMOOV)));
                            //   },
                            // ),
                            FocusedMenuHolder(
                              menuWidth:
                                  MediaQuery.of(context).size.width * 0.50,
                              blurSize: 5.0,
                              menuItemExtent: 45,
                              menuBoxDecoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0))),
                              duration: Duration(milliseconds: 20),
                              animateMenuItems: true,
                              blurBackgroundColor: Colors.black54,
                              openWithTap:
                                  true, // Open Focused-Menu on Tap rather than Long Press
                              menuOffset:
                                  10.0, // Offset value to show menuItem from the selected item
                              bottomOffsetHeight:
                                  80.0, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
                              menuItems: <FocusedMenuItem>[
                                // Add Each FocusedMenuItem  for Menu Options

                                FocusedMenuItem(
                                    title: Text("Share"),
                                    trailingIcon: Icon(Icons.send),
                                    onPressed: () {
                                      Share.share(
                                          "You found the easter egg 🥚");
                                    }),
                                FocusedMenuItem(
                                    title: Text("Edit Group"),
                                    trailingIcon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EditGroup(
                                                  groupPic,
                                                  groupName,
                                                  members,
                                                  gid)));
                                    }),
                                FocusedMenuItem(
                                    title: Text(
                                      "Leave Group",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                    trailingIcon: Icon(
                                      Icons.directions_walk,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      showAlertDialog(context);
                                    }),
                              ],
                              onPressed: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ]),
                      body: Stack(children: [
                        Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            child: Image.network(groupPic, fit: BoxFit.cover)),
                        Container(
                            child: Column(children: [
                          Container(
                            height: 200,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: members.length,
                                itemBuilder: (_, index) {
                                  DocumentSnapshot course = snapshot2.data;

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8),
                                    child: Container(
                                      height: 200,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 30.0, bottom: 10),
                                            child: GestureDetector(
                                              onTap: () {
                                                if (course['id'] == strUserId) {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfilePageWithHeader()));
                                                } else {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              OtherProfile(
                                                                course['id'],
                                                              )));
                                                }
                                              },
                                              child: CircleAvatar(
                                                radius: 30,
                                                backgroundColor:
                                                    TextThemes.ndGold,
                                                child: CircleAvatar(
                                                  // backgroundImage: snapshot.data
                                                  //     .documents[index].data['photoUrl'],
                                                  backgroundImage: NetworkImage(
                                                      snapshot.data.docs[index]
                                                          ['photoUrl']),
                                                  radius: 26,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment(0.0, 0.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: <Color>[
                                                    Colors.black.withAlpha(0),
                                                    Colors.black,
                                                    Colors.black12,
                                                  ],
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  snapshot.data.docs[index]
                                                      ['displayName'],
                                                  style: TextStyle(
                                                      fontFamily: 'Solway',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          )
                        ])),
                      ]));
                }
              });
        });
  }

  buildNoContent() {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        height: isLargePhone
            ? SizeConfig.blockSizeVertical * 15
            : SizeConfig.blockSizeVertical * 18,
        child: Stack(alignment: Alignment.center, children: <Widget>[
          FractionallySizedBox(
            widthFactor: 1,
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'lib/assets/bouts.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              margin: EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 7.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              alignment: Alignment(0.0, 0.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withAlpha(15),
                      Colors.black,
                      Colors.black12,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    "No Upcoming MOOVs",
                    style: TextStyle(
                        fontFamily: 'Solway',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  leaveGroup() {
    if (members.length == 1) {
      Database()
          .leaveGroup(currentUser.id, groupName, gid, currentUser.displayName);
      Database().destroyGroup(gid, groupName);
    } else {
      Database()
          .leaveGroup(currentUser.id, groupName, gid, currentUser.displayName);
    }
    Navigator.pop(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
}

// class Suggestions extends StatefulWidget {
//   String groupId;
//   Map<String, dynamic> voters = {};

//   Suggestions(this.groupId);

//   @override
//   State<StatefulWidget> createState() {
//     return _SuggestionsState(this.groupId);
//   }
// }

// class _SuggestionsState extends State<Suggestions> {
//   changeScore(bool increment) {
//     increment //for status responder
//         ? usersRef
//             .doc(currentUser.id)
//             .update({"score": FieldValue.increment(20)})
//         : usersRef
//             .doc(currentUser.id)
//             .update({"score": FieldValue.increment(-20)});
//   }

//   bool positivePointAnimationYes = false;
//   bool negativePointAnimationYes = false;

//   bool positivePointAnimationNo = false;
//   bool negativePointAnimationNo = false;

//   PageController _controller;
//   String groupId;
//   Map<String, dynamic> voters = {};
//   int pageNumber = 0;

//   _SuggestionsState(this.groupId);

//   @override
//   void initState() {
//     super.initState();
//     _controller = PageController();
//   }

//   _onPageViewChange(int page) {
//     setState(() {
//       pageNumber = page;
//     });
//   }

//   Widget buildPageView(snapshot4, count) {
//     return PageView.builder(
//       physics: AlwaysScrollableScrollPhysics(),
//       controller: _controller,
//       onPageChanged: _onPageViewChange,
//       itemBuilder: (BuildContext context, int pos) {
//         DocumentSnapshot course = snapshot4.data.docs[pos];
//         String nextMOOV = course['nextMOOV'];
//         String suggestorId = course['suggestorId'];
//         int unix = course['unix'];

//         return (nextMOOV != null && nextMOOV.isNotEmpty)
//             ? Container(
//                 margin: EdgeInsets.all(5),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     NextMOOV(nextMOOV, suggestorId, groupId, unix)
//                   ],
//                 ),
//               )
//             : Container();
//       },
//       itemCount: count,
//     );
//   }

//   Widget buildSuggestionsIndicatorWithShapeAndBottomPos(
//       Shape shape, double bottomPos, count) {
//     return Positioned(
//       bottom: bottomPos,
//       left: 0,
//       right: 0,
//       child: WormIndicator(
//         length: count,
//         controller: _controller,
//         shape: shape,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isLargePhone = Screen.diagonal(context) > 766;

//     int status = 0;
//     final circleShape = Shape(
//       size: 8,
//       shape: DotShape.Circle,
//       spacing: 8,
//     );

//     return StreamBuilder(
//         stream: groupsRef.doc(groupId).collection("suggestedMOOVs").snapshots(),
//         // ignore: missing_return
//         builder: (context, snapshot4) {
//           if (!snapshot4.hasData || snapshot4.data == null) {
//             return Container();
//           }

//           if (snapshot4.data.docs.length == 0) {
//             return Padding(
//               padding: const EdgeInsets.only(top: 18.0),
//               child: Container(
//                 height: isLargePhone
//                     ? SizeConfig.blockSizeVertical * 15
//                     : SizeConfig.blockSizeVertical * 18,
//                 child: Stack(children: <Widget>[
//                   FractionallySizedBox(
//                     widthFactor: 1,
//                     child: Container(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.asset('lib/assets/motd.jpg',
//                             fit: BoxFit.cover),
//                       ),
//                       margin: EdgeInsets.only(
//                           left: 20, top: 0, right: 20, bottom: 7.5),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(10),
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 5,
//                             blurRadius: 7,
//                             offset: Offset(0, 3), // changes position of shadow
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Align(
//                     alignment: Alignment.center,
//                     child: Container(
//                       alignment: Alignment(0.0, 0.0),
//                       child: Container(
//                         child: Padding(
//                           padding: const EdgeInsets.all(4.0),
//                           child: Text(
//                             "YOUR MOOV",
//                             style: TextStyle(
//                                 fontFamily: 'Solway',
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                                 fontSize: 20.0),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ]),
//               ),
//             );
//           }
//           int count = snapshot4.data.docs.length;
//           for (int i = 0; i < count; i++) {
//             DocumentSnapshot course4 = snapshot4.data.docs[pageNumber];

//             voters = course4['voters'];
//             String suggestorName = course4['suggestorName'];
//             String suggestorId = course4['suggestorId'];
//             int unix = course4['unix'];

//             List<dynamic> votersIds = voters.keys.toList();
//             List<dynamic> votersValues = voters.values.toList();
//             int noVoteCount =
//                 votersValues.where((element) => element == 1).toList().length;
//             int yesVoteCount =
//                 votersValues.where((element) => element == 2).toList().length;
//             if (voters != null) {
//               for (int i = 0; i < votersValues.length; i++) {
//                 if (votersIds[i] == currentUser.id) {
//                   if (votersValues[i] == 1) {
//                     status = 1;
//                   }
//                 }
//                 if (votersIds[i] == currentUser.id) {
//                   if (votersValues[i] == 2) {
//                     status = 2;
//                   }
//                 }
//               }
//             }
//             //this is for getting the first name of the suggestor
//             String fullName = suggestorName;
//             List<String> tempList = fullName.split(" ");
//             int start = 0;
//             int end = tempList.length;
//             if (end > 1) {
//               end = 1;
//             }
//             final selectedWords = tempList.sublist(start, end);
//             String firstName = selectedWords.join(" ");

//             return Column(
//               children: [
//                 Container(
//                   height: 160,
//                   child: Stack(
//                     children: <Widget>[
//                       buildPageView(snapshot4, count),
//                       buildSuggestionsIndicatorWithShapeAndBottomPos(
//                           circleShape, 20, count),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 20.0, right: 20),
//                   child:
//                       Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//                     Text("Suggested by "),
//                     Text(suggestorName,
//                         style: TextStyle(
//                             color: Colors.blue[600],
//                             fontWeight: FontWeight.w500))
//                   ]),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: RichText(
//                     textScaleFactor: 1.2,
//                     text: TextSpan(style: TextThemes.mediumbody, children: [
//                       TextSpan(
//                           text: "Vote on ",
//                           style: TextStyle(fontWeight: FontWeight.w400)),
//                       TextSpan(
//                           text: firstName + "'s ",
//                           style: TextStyle(
//                               color: Colors.blue[600],
//                               fontWeight: FontWeight.w500)),
//                       TextSpan(
//                           text: "suggestion",
//                           style: TextStyle(fontWeight: FontWeight.w400)),
//                     ]),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 20.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Stack(children: [
//                           RaisedButton(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5),
//                                 side: BorderSide(color: Colors.black)),
//                             onPressed: () {
//                               if (voters != null && status != 1) {
//                                 positivePointAnimationNo = true;
//                                 if (status != 2) {
//                                   changeScore(true);
//                                 }

//                                 if (status == 2) {
//                                   //if youre switching statuses we dont double count
//                                   negativePointAnimationYes = true;
//                                   Timer(Duration(seconds: 2), () {
//                                     setState(() {
//                                       negativePointAnimationYes = false;
//                                     });
//                                   });
//                                 }

//                                 Timer(Duration(seconds: 2), () {
//                                   setState(() {
//                                     positivePointAnimationNo = false;
//                                   });
//                                 });

//                                 Database().addNoVote(
//                                     unix, currentUser.id, groupId, suggestorId);
//                                 status = 1;
//                               } else if (voters != null && status == 1) {
//                                 negativePointAnimationNo = true;
//                                 Timer(Duration(seconds: 2), () {
//                                   setState(() {
//                                     negativePointAnimationNo = false;
//                                   });
//                                 });
//                                 changeScore(false);
//                                 Database().removeNoVote(
//                                     unix, currentUser.id, groupId, suggestorId);
//                                 status = 0;
//                               }
//                             },
//                             color: (status == 1) ? Colors.red : Colors.white,
//                             padding: EdgeInsets.all(5.0),
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 3.0, right: 3),
//                               child: (status == 1)
//                                   ? Column(
//                                       children: [
//                                         Text('No',
//                                             style:
//                                                 TextStyle(color: Colors.white)),
//                                         Icon(Icons.thumb_down,
//                                             color: Colors.white, size: 30),
//                                       ],
//                                     )
//                                   : Column(
//                                       children: [
//                                         Text('No'),
//                                         Icon(Icons.thumb_down,
//                                             color: Colors.red, size: 30),
//                                       ],
//                                     ),
//                             ),
//                           ),
//                           TranslationAnimatedWidget(
//                               enabled: this
//                                   .positivePointAnimationNo, //update this boolean to forward/reverse the animation
//                               values: [
//                                 Offset(20, -20), // disabled value value
//                                 Offset(20, -20), //intermediate value
//                                 Offset(20, -40) //enabled value
//                               ],
//                               child: OpacityAnimatedWidget.tween(
//                                   opacityEnabled: 1, //define start value
//                                   opacityDisabled: 0, //and end value
//                                   enabled: positivePointAnimationNo,
//                                   child: PointAnimation(20, true))),
//                           TranslationAnimatedWidget(
//                               enabled: this
//                                   .negativePointAnimationNo, //update this boolean to forward/reverse the animation
//                               values: [
//                                 Offset(20, -20), // disabled value value
//                                 Offset(20, -20), //intermediate value
//                                 Offset(20, -40) //enabled value
//                               ],
//                               child: OpacityAnimatedWidget.tween(
//                                   opacityEnabled: 1, //define start value
//                                   opacityDisabled: 0, //and end value
//                                   enabled: negativePointAnimationNo,
//                                   child: PointAnimation(20, false))),
//                         ]),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Stack(children: [
//                           RaisedButton(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(5),
//                                 side: BorderSide(color: Colors.black)),
//                             onPressed: () {
//                               if (voters != null && status != 2) {
//                                 positivePointAnimationYes = true;
//                                 if (status != 1) {
//                                   changeScore(true);
//                                 }

//                                 if (status == 1) {
//                                   //if youre switching statuses we dont double count
//                                   negativePointAnimationNo = true;
//                                   Timer(Duration(seconds: 2), () {
//                                     setState(() {
//                                       negativePointAnimationNo = false;
//                                     });
//                                   });
//                                 }

//                                 Timer(Duration(seconds: 2), () {
//                                   setState(() {
//                                     positivePointAnimationYes = false;
//                                   });
//                                 });

//                                 Database().addYesVote(
//                                     unix, currentUser.id, groupId, suggestorId);
//                                 status = 2;
//                               } else if (voters != null && status == 2) {
//                                 negativePointAnimationYes = true;
//                                 Timer(Duration(seconds: 2), () {
//                                   setState(() {
//                                     negativePointAnimationYes = false;
//                                   });
//                                 });
//                                 changeScore(false);
//                                 Database().removeYesVote(
//                                     unix, currentUser.id, groupId, suggestorId);
//                                 status = 0;
//                               }
//                             },
//                             color: (status == 2) ? Colors.green : Colors.white,
//                             padding: EdgeInsets.all(5.0),
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 3.0, right: 3),
//                               child: (status == 2)
//                                   ? Column(
//                                       children: [
//                                         Text('Yes',
//                                             style:
//                                                 TextStyle(color: Colors.white)),
//                                         Icon(Icons.thumb_up,
//                                             color: Colors.white, size: 30),
//                                       ],
//                                     )
//                                   : Column(
//                                       children: [
//                                         Text('Yes',
//                                             style:
//                                                 TextStyle(color: Colors.black)),
//                                         Icon(Icons.thumb_up,
//                                             color: Colors.green, size: 30),
//                                       ],
//                                     ),
//                             ),
//                           ),
//                           TranslationAnimatedWidget(
//                               enabled: this
//                                   .positivePointAnimationYes, //update this boolean to forward/reverse the animation
//                               values: [
//                                 Offset(20, -20), // disabled value value
//                                 Offset(20, -20), //intermediate value
//                                 Offset(20, -40) //enabled value
//                               ],
//                               child: OpacityAnimatedWidget.tween(
//                                   opacityEnabled: 1, //define start value
//                                   opacityDisabled: 0, //and end value
//                                   enabled: positivePointAnimationYes,
//                                   child: PointAnimation(20, true))),
//                           TranslationAnimatedWidget(
//                               enabled: this
//                                   .negativePointAnimationYes, //update this boolean to forward/reverse the animation
//                               values: [
//                                 Offset(20, -20), // disabled value value
//                                 Offset(20, -20), //intermediate value
//                                 Offset(20, -40) //enabled value
//                               ],
//                               child: OpacityAnimatedWidget.tween(
//                                   opacityEnabled: 1, //define start value
//                                   opacityDisabled: 0, //and end value
//                                   enabled: negativePointAnimationYes,
//                                   child: PointAnimation(20, false))),
//                         ]),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Container(
//                       child: ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           physics: AlwaysScrollableScrollPhysics(),
//                           itemCount: noVoteCount,
//                           itemBuilder: (_, index) {
//                             voters.removeWhere((key, value) => value != 1);

//                             var w = voters.keys.toList();

//                             return StreamBuilder(
//                                 stream: usersRef.doc(w[index]).snapshots(),
//                                 builder: (context, snapshot3) {
//                                   if (!snapshot3.hasData ||
//                                       snapshot3.data == null)
//                                     return Container();

//                                   return Container(
//                                     height: 100,
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(left: 8.0),
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: <Widget>[
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                               top: 17.0,
//                                               bottom: 5,
//                                             ),
//                                             child: GestureDetector(
//                                               onTap: () {
//                                                 if (snapshot3.data['id'] ==
//                                                     currentUser.id) {
//                                                   Navigator.of(context).push(
//                                                       MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               ProfilePageWithHeader()));
//                                                 } else {
//                                                   Navigator.of(context).push(
//                                                       MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               OtherProfile(
//                                                                 snapshot3
//                                                                     .data['id'],
//                                                               )));
//                                                 }
//                                               },
//                                               child: CircleAvatar(
//                                                 radius: 24,
//                                                 backgroundColor:
//                                                     TextThemes.ndBlue,
//                                                 child: CircleAvatar(
//                                                   backgroundImage: NetworkImage(
//                                                       snapshot3
//                                                           .data['photoUrl']),
//                                                   radius: 22,
//                                                   backgroundColor:
//                                                       TextThemes.ndBlue,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.all(0.0),
//                                             child: Center(
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 5.0),
//                                                 child: RichText(
//                                                   textScaleFactor: .75,
//                                                   text: TextSpan(
//                                                       style:
//                                                           TextThemes.mediumbody,
//                                                       children: [
//                                                         TextSpan(
//                                                             text: snapshot3
//                                                                 .data[
//                                                                     'displayName']
//                                                                 .toString(),
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w500)),
//                                                       ]),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 });
//                           }),
//                       decoration: BoxDecoration(
//                           color: Colors.red[100],
//                           border: Border.all(
//                             color: Colors.red[200],
//                           ),
//                           borderRadius: BorderRadius.all(Radius.circular(20))),
//                       height: 100,
//                       width: MediaQuery.of(context).size.width * .45,
//                     ),
//                     Container(
//                       child: ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           physics: AlwaysScrollableScrollPhysics(),
//                           itemCount: yesVoteCount,
//                           itemBuilder: (_, index) {
//                             voters = course4['voters'];
//                             voters.removeWhere((key, value) => value != 2);

//                             var w = voters.keys.toList();

//                             return StreamBuilder(
//                                 stream: usersRef.doc(w[index]).snapshots(),
//                                 builder: (context, snapshot3) {
//                                   if (!snapshot3.hasData ||
//                                       snapshot3.data == null)
//                                     return Container();

//                                   return Container(
//                                     height: 100,
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(left: 8.0),
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: <Widget>[
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                                 top: 17.0, bottom: 5),
//                                             child: GestureDetector(
//                                               onTap: () {
//                                                 if (snapshot3.data['id'] ==
//                                                     currentUser.id) {
//                                                   Navigator.of(context).push(
//                                                       MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               ProfilePageWithHeader()));
//                                                 } else {
//                                                   Navigator.of(context).push(
//                                                       MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               OtherProfile(
//                                                                 snapshot3
//                                                                     .data['id'],
//                                                               )));
//                                                 }
//                                               },
//                                               child: CircleAvatar(
//                                                 radius: 24,
//                                                 backgroundColor:
//                                                     TextThemes.ndBlue,
//                                                 child: CircleAvatar(
//                                                   backgroundImage: NetworkImage(
//                                                       snapshot3
//                                                           .data['photoUrl']),
//                                                   radius: 22,
//                                                   backgroundColor:
//                                                       TextThemes.ndBlue,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.all(0.0),
//                                             child: Center(
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 5.0),
//                                                 child: RichText(
//                                                   textScaleFactor: .75,
//                                                   text: TextSpan(
//                                                       style:
//                                                           TextThemes.mediumbody,
//                                                       children: [
//                                                         TextSpan(
//                                                             text: snapshot3
//                                                                 .data[
//                                                                     'displayName']
//                                                                 .toString(),
//                                                             style: TextStyle(
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w500)),
//                                                       ]),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 });
//                           }),
//                       decoration: BoxDecoration(
//                           color: Colors.green[100],
//                           border: Border.all(
//                             color: Colors.green[200],
//                           ),
//                           borderRadius: BorderRadius.all(Radius.circular(20))),
//                       height: 100,
//                       width: MediaQuery.of(context).size.width * .45,
//                     )
//                   ],
//                 ),
//               ],
//             );
//           }
//         });
//   }
// }
