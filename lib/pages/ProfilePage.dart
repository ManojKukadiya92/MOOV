import 'dart:async';
import 'dart:io';

import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/models/user.dart';
import 'package:MOOV/pages/Friends_List.dart';
import 'package:MOOV/pages/MOOVSPage.dart';
import 'package:MOOV/pages/MessagesHub.dart';
import 'package:MOOV/pages/SettingsPage.dart';
import 'package:MOOV/pages/contactsPage.dart';
import 'package:MOOV/pages/friend_groups.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/leaderboard.dart';
import 'package:MOOV/pages/edit_profile.dart';
import 'package:MOOV/pages/notification_feed.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/widgets/contacts_button.dart';
import 'package:MOOV/widgets/photo_pick.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:MOOV/widgets/trending_segment.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  User user;
  ProfilePage({Key key, this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey _settingsKey = GlobalKey();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool bigHeight = true;

    var strUserPic = currentUser.photoUrl;
    var userYear = currentUser.year;
    var userDorm = currentUser.dorm;
    var userBio;
    var userHeader = currentUser.header;
    var userFriends = currentUser.friendArray;
    // var userMoovs = currentUser.likedMoovs;
    var userGroups = currentUser.friendGroups;
    // var userFriendsLength = "0";
    int verifiedStatus = currentUser.verifiedStatus;

    return (currentUser.isBusiness == false)
        ? StreamBuilder(
            stream: usersRef.doc(currentUser.id).snapshots(),
            builder: (context, snapshot) {
              bool isLargePhone = Screen.diagonal(context) > 766;

              if (!snapshot.hasData ) return CircularProgressIndicator();
              userBio = snapshot.data['bio'];
              int score = snapshot.data['score'];
              userDorm = snapshot.data['dorm'];
              userHeader = snapshot.data['header'];
              strUserPic = snapshot.data['photoUrl'];
              verifiedStatus = snapshot.data['verifiedStatus'];
              userFriends = snapshot.data['friendArray'];
              // userMoovs = snapshot.data['likedMoovs'];
              userGroups = snapshot.data['friendGroups'];
              String venmo = snapshot.data['venmoUsername'];
              bool showDorm = snapshot.data['privacySettings']['showDorm'];

              return Scaffold(
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Stack(children: [
                    Container(
                      height: 130,
                      child: GestureDetector(
                        onTap: () {},
                        child: Stack(children: <Widget>[
                          FractionallySizedBox(
                            widthFactor: isLargePhone ? 1.17 : 1.34,
                            child: Container(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditProfile()));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: userHeader == ""
                                      ? Image.asset('lib/assets/header.jpg',
                                          fit: BoxFit.cover)
                                      : Image.network(
                                          userHeader,
                                          fit: BoxFit.fitWidth,
                                        ),
                                ),
                              ),
                              margin: EdgeInsets.only(
                                  left: 20, top: 0, right: 20, bottom: 7.5),
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
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 30.0, bottom: 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProfile()));
                              },
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: TextThemes.ndGold,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: TextThemes.ndBlue,
                                  child: CircleAvatar(
                                    backgroundImage: (strUserPic == null)
                                        ? AssetImage('images/user-avatar.png')
                                        : NetworkImage(strUserPic),
                                    // backgroundImage: NetworkImage(currentUser.photoUrl),
                                    radius: 50,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 35.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                  height: bigHeight ? 24 : 18,
                                  child: GestureDetector(
                                      onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingsPage())),
                                      child: Icon(Icons.settings))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentUser.displayName != ""
                                      ? currentUser.displayName
                                      : "Username not found",
                                  style: TextThemes.extraBold,
                                ),
                                verifiedStatus == 3
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          left: 5,
                                          top: 2.5,
                                        ),
                                        child: Icon(
                                          Icons.store,
                                          size: 25,
                                          color: TextThemes.ndGold,
                                        ),
                                      )
                                    : verifiedStatus == 2
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                                left: 5, top: 5),
                                            child: Image.asset(
                                                'lib/assets/verif2.png',
                                                height: 20),
                                          )
                                        : verifiedStatus == 1
                                            ? Padding(
                                                padding: EdgeInsets.only(
                                                    left: 2.5, top: 0),
                                                child: Image.asset(
                                                    'lib/assets/verif.png',
                                                    height: 30),
                                              )
                                            : Text("")
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 2.0, bottom: 14.0, left: 30, right: 30),
                            child: showDorm == false
                                ? Text(
                                    "Top secret year and dorm",
                                    style: TextStyle(fontSize: 15),
                                  )
                                : Text(
                                    userYear != "" && userDorm != ""
                                        ? userYear + ' in ' + userDorm
                                        : "",
                                    style: TextStyle(fontSize: 15),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LeaderBoardPage()));
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        score.toString(),
                                        style: TextThemes.extraBold,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          '       Score       ',
                                          style: TextThemes.bodyText1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => FriendsList(
                                                id: currentUser.id)));
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        userFriends.length == null ||
                                                userFriends.length == 0
                                            ? "0"
                                            : userFriends.length.toString(),
                                        style: TextThemes.extraBold,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: userFriends.length == 1
                                            ? Text(
                                                '     Friend     ',
                                                style: TextThemes.bodyText1,
                                              )
                                            : Text(
                                                '     Friends     ',
                                                style: TextThemes.bodyText1,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FriendGroupsPage()));
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        userGroups.length == null ||
                                                userGroups.length == 0
                                            ? "0"
                                            : userGroups.length.toString(),
                                        style: TextThemes.extraBold,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: userGroups.length == 1
                                            ? Text(
                                                'Friend Group',
                                                style: TextThemes.bodyText1,
                                              )
                                            : Text(
                                                'Friend Groups',
                                                style: TextThemes.bodyText1,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          venmo != null && venmo != ""
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('lib/assets/venmo-icon.png',
                                          height: 35),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "@" + venmo,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(""),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfile()));
                            },
                            child: Card(
                              margin: EdgeInsets.only(
                                  left: 15, right: 15, bottom: 20, top: 10),
                              color: TextThemes.ndBlue,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, bottom: 2, top: 8),
                                    child: RichText(
                                      textScaleFactor: 1.75,
                                      text: TextSpan(
                                          style: TextThemes.mediumbody,
                                          children: [
                                            TextSpan(
                                                text: "",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w200,
                                                    color: TextThemes.ndGold)),
                                          ]),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, bottom: 35),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: RichText(
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 1.3,
                                          text: TextSpan(
                                              style: TextThemes.mediumbody,
                                              children: [
                                                TextSpan(
                                                    text: "\"" + userBio + "\"",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontStyle:
                                                            FontStyle.italic)),
                                              ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          PopularityBadges(currentUser.id),

                          StreamBuilder(
                              stream: postsRef
                                  .where('userId', isEqualTo: currentUser.id)
                                  // .orderBy("goingCount", descending: true)
                                  // .limit(6)
                                  // .orderBy("goingCount")
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data.docs.length == 0)
                                  return Text('');
                                return Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: Container(
                                    height: (snapshot.data.docs.length <= 3 &&
                                            isLargePhone)
                                        ? 210
                                        : (snapshot.data.docs.length >= 3 &&
                                                isLargePhone)
                                            ? 345
                                            : (snapshot.data.docs.length <= 3 &&
                                                    !isLargePhone)
                                                ? 175
                                                : (snapshot.data.docs.length >=
                                                            3 &&
                                                        !isLargePhone)
                                                    ? 310
                                                    : 350,
                                    child: Column(
                                      children: [
                                        Text("Your Posts"),
                                        Divider(
                                          color: TextThemes.ndBlue,
                                          height: 20,
                                          thickness: 2,
                                          indent: 20,
                                          endIndent: 20,
                                        ),
                                        Expanded(
                                            child: CustomScrollView(
                                          // physics:
                                          //     NeverScrollableScrollPhysics(),
                                          slivers: [
                                            SliverGrid(
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                        (BuildContext context,
                                                            int index) {
                                                  DocumentSnapshot course =
                                                      snapshot.data.docs[index];

                                                  return PostOnTrending(course);
                                                },
                                                        childCount: snapshot
                                                            .data.docs.length),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                )),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                          StreamBuilder(
                              stream: postsRef
                                  .where('going', arrayContains: currentUser.id)
                                  // .orderBy("startDate")
                                  // .limit(6)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data.docs.length == 0)
                                  return Text('');
                                return Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: Container(
                                    height: (snapshot.data.docs.length <= 3 &&
                                            isLargePhone)
                                        ? 210
                                        : (snapshot.data.docs.length >= 3 &&
                                                isLargePhone)
                                            ? 345
                                            : (snapshot.data.docs.length <= 3 &&
                                                    !isLargePhone)
                                                ? 160
                                                : (snapshot.data.docs.length >=
                                                            3 &&
                                                        !isLargePhone)
                                                    ? 310
                                                    : 350,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5.0),
                                              child: Text("Upcoming MOOVs"),
                                            ),
                                            Icon(
                                              Icons.directions_run,
                                              color: Colors.green,
                                            )
                                          ],
                                        ),
                                        Divider(
                                          color: TextThemes.ndBlue,
                                          height: 20,
                                          thickness: 2,
                                          indent: 20,
                                          endIndent: 20,
                                        ),
                                        Expanded(
                                            child: CustomScrollView(
                                          // physics:
                                          //     NeverScrollableScrollPhysics(),
                                          slivers: [
                                            SliverGrid(
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                        (BuildContext context,
                                                            int index) {
                                                  DocumentSnapshot course =
                                                      snapshot.data.docs[index];

                                                  return PostOnTrending(course);
                                                },
                                                        childCount: snapshot
                                                            .data.docs.length),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                )),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                          //             GestureDetector(
                          //               onTap: (){
                          //                     Navigator.push(
                          //                         context,
                          //                         MaterialPageRoute(
                          //                             builder: (context) => MessageList()));
                          //               },
                          //               child: Container(
                          //   child:
                          //   Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Padding(
                          //         padding: const EdgeInsets.only(left: 8.0),
                          //         child: Icon(
                          //           Icons.message,
                          //           color: Colors.white,
                          //           size: 20,
                          //         ),
                          //       ),
                          //       Expanded(
                          //         child: Center(
                          //           child: Padding(
                          //             padding: const EdgeInsets.only(right: 15.0),
                          //             child: Text(
                          //               "Messages",
                          //               style: TextStyle(
                          //                   fontSize: isLargePhone ? 18 : 16,
                          //                   color: Colors.white),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          //   width: MediaQuery.of(context).size.width * .4,
                          //   height: 50,
                          //   decoration: BoxDecoration(
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.withOpacity(0.5),
                          //         spreadRadius: 5,
                          //         blurRadius: 7,
                          //         offset: Offset(0, 3), // changes position of shadow
                          //       ),
                          //     ],
                          //     borderRadius: BorderRadius.only(
                          //         topLeft: Radius.circular(10),
                          //         topRight: Radius.circular(10),
                          //         bottomLeft: Radius.circular(10),
                          //         bottomRight: Radius.circular(10)),
                          //     gradient: LinearGradient(
                          //       colors: [Colors.amber[300], Colors.amber[200]],
                          //       begin: Alignment.centerLeft,
                          //       end: Alignment.centerRight,
                          //     ),
                          //   ),
                          // )),
                          //             Padding(
                          //               padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                          //               child: SeeContactsButton(),
                          //             ),
                        ],
                      ),
                    )
                  ]),
                ),
              );
            })
        : StreamBuilder(
            stream: usersRef.doc(currentUser.id).snapshots(),
            builder: (context, snapshot) {
              bool isLargePhone = Screen.diagonal(context) > 766;

              if (!snapshot.hasData) return CircularProgressIndicator();
              userBio = snapshot.data['bio'];
              int score = snapshot.data['score'];
              String dorm = snapshot.data['dorm'];
              userHeader = snapshot.data['header'];
              strUserPic = snapshot.data['photoUrl'];
              verifiedStatus = snapshot.data['verifiedStatus'];
              List followers = snapshot.data['followers'];
              // userMoovs = snapshot.data['likedMoovs'];
              String venmo = snapshot.data['venmoUsername'];

              return Scaffold(
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Stack(children: [
                    Container(
                      height: 130,
                      child: GestureDetector(
                        onTap: () {},
                        child: Stack(children: <Widget>[
                          FractionallySizedBox(
                            widthFactor: isLargePhone ? 1.17 : 1.34,
                            child: Container(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditProfile()));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: userHeader == ""
                                      ? Image.asset('lib/assets/tux.jpg',
                                          fit: BoxFit.cover)
                                      : Image.network(
                                          userHeader,
                                          fit: BoxFit.fitWidth,
                                        ),
                                ),
                              ),
                              margin: EdgeInsets.only(
                                  left: 20, top: 0, right: 20, bottom: 7.5),
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
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 30.0, bottom: 0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditProfile()));
                              },
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.blue,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: TextThemes.ndBlue,
                                  child: CircleAvatar(
                                    backgroundImage: (strUserPic == null)
                                        ? AssetImage('images/user-avatar.png')
                                        : NetworkImage(strUserPic),
                                    // backgroundImage: NetworkImage(currentUser.photoUrl),
                                    radius: 50,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 35.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                  height: bigHeight ? 18 : 18,
                                  child: GestureDetector(
                                      onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingsPage())),
                                      child: Icon(Icons.settings))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentUser.displayName != ""
                                      ? currentUser.displayName
                                      : "Username not found",
                                  style: TextThemes.extraBold,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 5,
                                    top: 2.5,
                                  ),
                                  child: Icon(
                                    Icons.store,
                                    size: 25,
                                    color: Colors.blue,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 12.0, bottom: 14.0, left: 50, right: 50),
                            child: SizedBox(
                              width: 200,
                              child: Text(
                                dorm,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LeaderBoardPage()));
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        score.toString(),
                                        style: TextThemes.extraBold,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          '       Score       ',
                                          style: TextThemes.bodyText1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => FollowersList(
                                                id: currentUser.id)));
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        followers.length == null ||
                                                followers.length == 0
                                            ? "0"
                                            : followers.length.toString(),
                                        style: TextThemes.extraBold,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: followers.length == 1
                                            ? Text(
                                                '     Follower     ',
                                                style: TextThemes.bodyText1,
                                              )
                                            : Text(
                                                '     Followers     ',
                                                style: TextThemes.bodyText1,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          venmo != null && venmo != ""
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('lib/assets/venmo-icon.png',
                                          height: 35),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "@" + venmo,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(""),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfile()));
                            },
                            child: Card(
                              margin: EdgeInsets.only(
                                  left: 15, right: 15, bottom: 20, top: 10),
                              color: TextThemes.ndBlue,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, bottom: 2, top: 8),
                                    child: RichText(
                                      textScaleFactor: 1.75,
                                      text: TextSpan(
                                          style: TextThemes.mediumbody,
                                          children: [
                                            TextSpan(
                                                text: "",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w200,
                                                    color: TextThemes.ndGold)),
                                          ]),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, bottom: 35),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: RichText(
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 1.3,
                                          text: TextSpan(
                                              style: TextThemes.mediumbody,
                                              children: [
                                                TextSpan(
                                                    text: "\"" + userBio + "\"",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontStyle:
                                                            FontStyle.italic)),
                                              ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          currentUser.businessType == "Restaurant/Bar"
                              ? RestaurantMenu(currentUser.id)
                              : Container(),

                          PopularityBadges(currentUser.id),

                          StreamBuilder(
                              stream: postsRef
                                  .where('userId', isEqualTo: currentUser.id)
                                  // .orderBy("goingCount", descending: true)
                                  // .limit(6)
                                  // .orderBy("goingCount")
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data.docs.length == 0)
                                  return Text('');
                                return Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Container(
                                    height: (snapshot.data.docs.length <= 3 &&
                                            isLargePhone)
                                        ? 210
                                        : (snapshot.data.docs.length >= 3 &&
                                                isLargePhone)
                                            ? 345
                                            : (snapshot.data.docs.length <= 3 &&
                                                    !isLargePhone)
                                                ? 175
                                                : (snapshot.data.docs.length >=
                                                            3 &&
                                                        !isLargePhone)
                                                    ? 310
                                                    : 350,
                                    child: Column(
                                      children: [
                                        Text("Your MOOVs"),
                                        Divider(
                                          color: TextThemes.ndBlue,
                                          height: 20,
                                          thickness: 2,
                                          indent: 20,
                                          endIndent: 20,
                                        ),
                                        Expanded(
                                            child: CustomScrollView(
                                          // physics: NeverScrollableScrollPhysics(),
                                          slivers: [
                                            SliverGrid(
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                        (BuildContext context,
                                                            int index) {
                                                  DocumentSnapshot course =
                                                      snapshot.data.docs[index];

                                                  return PostOnTrending(
                                                       course);
                                                },
                                                        childCount: snapshot
                                                            .data.docs.length),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                )),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                          StreamBuilder(
                              stream: postsRef
                                  .where('going', arrayContains: currentUser.id)
                                  // .orderBy("startDate")
                                  // .limit(6)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data.docs.length == 0)
                                  return Text('');
                                return Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Container(
                                    height: (snapshot.data.docs.length <= 3 &&
                                            isLargePhone)
                                        ? 210
                                        : (snapshot.data.docs.length >= 3 &&
                                                isLargePhone)
                                            ? 345
                                            : (snapshot.data.docs.length <= 3 &&
                                                    !isLargePhone)
                                                ? 160
                                                : (snapshot.data.docs.length >=
                                                            3 &&
                                                        !isLargePhone)
                                                    ? 310
                                                    : 350,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5.0),
                                              child: Text("Upcoming MOOVs"),
                                            ),
                                            Icon(
                                              Icons.directions_run,
                                              color: Colors.green,
                                            )
                                          ],
                                        ),
                                        Divider(
                                          color: TextThemes.ndBlue,
                                          height: 20,
                                          thickness: 2,
                                          indent: 20,
                                          endIndent: 20,
                                        ),
                                        Expanded(
                                            child: CustomScrollView(
                                          // physics: NeverScrollableScrollPhysics(),
                                          slivers: [
                                            SliverGrid(
                                                delegate:
                                                    SliverChildBuilderDelegate(
                                                        (BuildContext context,
                                                            int index) {
                                                  DocumentSnapshot course =
                                                      snapshot.data.docs[index];

                                                  return PostOnTrending(
                                                   course);
                                                },
                                                        childCount: snapshot
                                                            .data.docs.length),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                )),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                          //             GestureDetector(
                          //               onTap: (){
                          //                     Navigator.push(
                          //                         context,
                          //                         MaterialPageRoute(
                          //                             builder: (context) => MessageList()));
                          //               },
                          //               child: Container(
                          //   child:
                          //   Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Padding(
                          //         padding: const EdgeInsets.only(left: 8.0),
                          //         child: Icon(
                          //           Icons.message,
                          //           color: Colors.white,
                          //           size: 20,
                          //         ),
                          //       ),
                          //       Expanded(
                          //         child: Center(
                          //           child: Padding(
                          //             padding: const EdgeInsets.only(right: 15.0),
                          //             child: Text(
                          //               "Messages",
                          //               style: TextStyle(
                          //                   fontSize: isLargePhone ? 18 : 16,
                          //                   color: Colors.white),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          //   width: MediaQuery.of(context).size.width * .4,
                          //   height: 50,
                          //   decoration: BoxDecoration(
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.grey.withOpacity(0.5),
                          //         spreadRadius: 5,
                          //         blurRadius: 7,
                          //         offset: Offset(0, 3), // changes position of shadow
                          //       ),
                          //     ],
                          //     borderRadius: BorderRadius.only(
                          //         topLeft: Radius.circular(10),
                          //         topRight: Radius.circular(10),
                          //         bottomLeft: Radius.circular(10),
                          //         bottomRight: Radius.circular(10)),
                          //     gradient: LinearGradient(
                          //       colors: [Colors.amber[300], Colors.amber[200]],
                          //       begin: Alignment.centerLeft,
                          //       end: Alignment.centerRight,
                          //     ),
                          //   ),
                          // )),
                          //             Padding(
                          //               padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                          //               child: SeeContactsButton(),
                          //             ),
                        ],
                      ),
                    )
                  ]),
                ),
              );
            });
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Sign out?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nWhere you goin'?"),
        actions: [
          CupertinoDialogAction(
              isDefaultAction: true,
              child:
                  Text("Yes, sign me out", style: TextStyle(color: Colors.red)),
              onPressed: () {
                googleSignIn.signOut();
                Navigator.of(context).pop(true);
              }),
          CupertinoDialogAction(
            child: Text("Nah, my bad"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }
}

class PopularityBadges extends StatelessWidget {
  String id;
  PopularityBadges(this.id);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: usersRef.doc(id).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return circularProgress();
          Map<String, dynamic> badges = snapshot.data['badges'];
          if (badges.isEmpty && id != currentUser.id) {
            return Container();
          } else if (badges.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Container(
                  height: 100.0,
                  width: MediaQuery.of(context).size.width * .8,
                  color: Colors.transparent,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: Center(
                          child: Text(
                        "Use MOOV often to earn badges!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TextThemes.ndBlue),
                      )))),
            );
          } else {
            List leaderboardWins = badges['leaderboardWin'] ?? [];
            List helpedMOOV = badges['helpedMOOV'] ?? [];
            List moovMaker = badges['moovMaker'] ?? [];
            List friends10 = badges['friends10'] ?? [];
            List mountains = badges['mountains'] ?? [];
            List natties = badges['natties'] ?? [];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text("Popularity Badges"),
                ),
                Container(
                    height: 100.0,
                    width: MediaQuery.of(context).size.width * .8,
                    color: Colors.transparent,
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        child: ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          children: [
                            leaderboardWins.isNotEmpty
                                ? Padding(
                                    //LEADERBOARD
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: GestureDetector(
                                      onTap: () => explainBadge(
                                          "Leaderboard Win", context),
                                      child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Colors.blue,
                                                          Colors.red,
                                                        ],
                                                        begin: Alignment
                                                            .bottomLeft,
                                                        end: Alignment
                                                            .topRight)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor:
                                                        TextThemes.ndBlue,
                                                    backgroundImage: AssetImage(
                                                        'lib/assets/trophy2.png'),
                                                  ),
                                                )),
                                            leaderboardWins.length > 1
                                                ? Positioned(
                                                    top: 20,
                                                    right: 0,
                                                    child: Container(
                                                      height: 20,
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.blue[400],
                                                              Colors.blue[600]
                                                            ],
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0)),
                                                      child: Text(
                                                        "x${leaderboardWins.length}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                          ]),
                                    ),
                                  )
                                : Container(),
                            helpedMOOV.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: GestureDetector(
                                      onTap: () =>
                                          explainBadge("Helped MOOV", context),
                                      child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Colors.blue,
                                                          Colors.red,
                                                        ],
                                                        begin: Alignment
                                                            .bottomLeft,
                                                        end: Alignment
                                                            .topRight)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor:
                                                        TextThemes.ndBlue,
                                                    backgroundImage: AssetImage(
                                                        'lib/assets/badges/clink.png'),
                                                  ),
                                                )),
                                            helpedMOOV.length > 1
                                                ? Positioned(
                                                    top: 20,
                                                    right: 0,
                                                    child: Container(
                                                      height: 20,
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.blue[400],
                                                              Colors.blue[600]
                                                            ],
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0)),
                                                      child: Text(
                                                        "x${helpedMOOV.length}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                          ]),
                                    ),
                                  )
                                : Container(),
                            friends10.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: GestureDetector(
                                      onTap: () =>
                                          explainBadge("10 Friends", context),
                                      child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Colors.blue,
                                                          Colors.red,
                                                        ],
                                                        begin: Alignment
                                                            .bottomLeft,
                                                        end: Alignment
                                                            .topRight)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor:
                                                        TextThemes.ndBlue,
                                                    backgroundImage: AssetImage(
                                                        'lib/assets/badges/10friends.png'),
                                                  ),
                                                )),
                                            friends10.length > 1
                                                ? Positioned(
                                                    top: 20,
                                                    right: 0,
                                                    child: Container(
                                                      height: 20,
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.blue[400],
                                                              Colors.blue[600]
                                                            ],
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0)),
                                                      child: Text(
                                                        "x${friends10.length}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                          ]),
                                    ),
                                  )
                                : Container(),
                            moovMaker.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: GestureDetector(
                                      onTap: () =>
                                          explainBadge("MOOV Maker", context),
                                      child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Colors.blue,
                                                          Colors.red,
                                                        ],
                                                        begin: Alignment
                                                            .bottomLeft,
                                                        end: Alignment
                                                            .topRight)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor:
                                                        TextThemes.ndBlue,
                                                    backgroundImage: AssetImage(
                                                        'lib/assets/badges/moovMaker.png'),
                                                  ),
                                                )),
                                            friends10.length > 1
                                                ? Positioned(
                                                    top: 20,
                                                    right: 0,
                                                    child: Container(
                                                      height: 20,
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.blue[400],
                                                              Colors.blue[600]
                                                            ],
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0)),
                                                      child: Text(
                                                        "x${friends10.length}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                          ]),
                                    ),
                                  )
                                : Container(),
                            mountains.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: GestureDetector(
                                      onTap: () => explainBadge(
                                          "MOOV Mountain", context),
                                      child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Colors.blue,
                                                          Colors.red,
                                                        ],
                                                        begin: Alignment
                                                            .bottomLeft,
                                                        end: Alignment
                                                            .topRight)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor:
                                                        TextThemes.ndBlue,
                                                    backgroundImage: AssetImage(
                                                        'lib/assets/badges/mountain.png'),
                                                  ),
                                                )),
                                            mountains.length > 1
                                                ? Positioned(
                                                    top: 20,
                                                    right: 0,
                                                    child: Container(
                                                      height: 20,
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      decoration: BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.blue[400],
                                                              Colors.blue[600]
                                                            ],
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0)),
                                                      child: Text(
                                                        "x${mountains.length}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                          ]),
                                    ),
                                  )
                                : Container(),
                            natties.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 22.5,
                                        bottom: 22.5,
                                        left: 15,
                                        right: 8),
                                    child: GestureDetector(
                                      onTap: () =>
                                          explainBadge("Natty", context),
                                      child: Image.asset(
                                        'lib/assets/badges/natty.png',
                                        height: 20,
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        ))),
                SizedBox(height: 20)
              ],
            );
          }
        });
  }

  explainBadge(String type, context) {
    showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text("$type"),
              content: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: type == "Leaderboard Win"
                    ? Text("#1 on the leaderboard! We see you.")
                    : type == "10 Friends"
                        ? Text("Made 10 friends! So popular.")
                        : type == "Helped MOOV"
                            ? Text(
                                "You helped MOOV at an early stage. Stick around and reap the benefits.")
                            : type == "MOOV Mountain"
                                ? Text(
                                    "You participated in a socially impactful event. Get 3 Mountains to be featured on our Homepage!")
                                : type == "MOOV Maker"
                                    ? Text(
                                        "You posted a MOOV that received 10+ statuses. Right on!")
                                    : Text(
                                        "You earned a Natty! Come find Kevin or Alvin to redeem (21+ only)!"),
              ),
            ),
        barrierDismissible: true);
  }
}

class RestaurantMenu extends StatefulWidget {
  final String id;
  RestaurantMenu(this.id);

  @override
  _RestaurantMenuState createState() => _RestaurantMenuState();
}

class _RestaurantMenuState extends State<RestaurantMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder(
            stream: usersRef.doc(widget.id).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              if (snapshot.data['businessType'] != "Restaurant/Bar") {
                return Container();
              }
              if (snapshot.data['menu'].isEmpty &&
                  widget.id == currentUser.id) {
                return PhotoPick(
                    Container(
                      width: MediaQuery.of(context).size.width * .99,
                      height: 200,
                      child: ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.menu_book),
                                      Text("Add your menu")
                                    ],
                                  ),
                                  height: 200,
                                  width: 175,
                                  decoration: BoxDecoration(
                                      color: Colors.purple[50],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)))),
                            ),
                            Container(
                                height: 200,
                                width: 175,
                                decoration: BoxDecoration(
                                    color: Colors.purple[50],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))))
                          ]),
                    ),
                    Container(),
                    "",
                    0);
              }
              if (snapshot.data['menu'].isEmpty &&
                  widget.id != currentUser.id) {
                return Container();
              }
              return Container(
                width: MediaQuery.of(context).size.width * .99,
                height: 250,
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, bottom: 7.5),
                          child: Text(
                            "Menu",
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 24),
                          ),
                        )),
                    Expanded(
                      child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data['menu'].length,
                          itemBuilder: (context, index) => widget.id ==
                                  currentUser.id
                              ? PhotoPick(
                                  Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Container(
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                  snapshot.data['menu'][index],
                                                  fit: BoxFit.cover)),
                                          height: 200,
                                          width: 175,
                                          decoration: BoxDecoration(
                                              color: Colors.red[50],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))))),
                                  Container(),
                                  snapshot.data['menu'][index],
                                  index)
                              : Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: OpenContainer(
                                      transitionType:
                                          ContainerTransitionType.fade,
                                      transitionDuration:
                                          Duration(milliseconds: 500),
                                      openBuilder: (context, _) =>
                                          PhotoFullScreen(
                                              snapshot.data['menu'][index],
                                              index),
                                      closedElevation: 0,
                                      closedBuilder: (context, _) => Container(
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                  snapshot.data['menu'][index],
                                                  fit: BoxFit.cover)),
                                          height: 200,
                                          width: 175,
                                          decoration: BoxDecoration(
                                              color: Colors.red[50],
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))))),
                                )),
                    ),
                  ],
                ),
              );
            }),
        SizedBox(height: 10)
      ],
    );
  }
}
