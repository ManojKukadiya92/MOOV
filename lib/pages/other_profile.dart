import 'dart:async';
import 'dart:ui';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/Friends_List.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/MessagesHub.dart';
import 'package:MOOV/pages/ProfilePage.dart';
import 'package:MOOV/pages/leaderboard.dart';
import 'package:MOOV/widgets/trending_segment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:MOOV/services/database.dart';
import 'package:maps_launcher/maps_launcher.dart';

import 'home.dart';

Future dmChecker(String otherPersonId, String directMessageId) async {
  messagesRef.doc(otherPersonId + currentUser.id).get().then((doc) async {
    messagesRef.doc(currentUser.id + otherPersonId).get().then((doc2) async {
      if (!doc2.exists && !doc.exists) {
        directMessageId = "nothing";
      } else if (!doc2.exists) {
        directMessageId = doc['directMessageId'];
      } else if (!doc.exists) {
        directMessageId = doc2['directMessageId'];
      }
    });
  });
}

void toMessageDetail(String otherPersonId, String directMessageId, context) {
  Timer(Duration(milliseconds: 200), () {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MessageDetail(
                directMessageId: directMessageId,
                otherPerson: otherPersonId,
                members: [],
                sendingPost: {})));
  });
}

class OtherProfile extends StatefulWidget {
  String id;

  OtherProfile(this.id);

  @override
  State<StatefulWidget> createState() {
    return _OtherProfileState(this.id);
  }
}

class _OtherProfileState extends State<OtherProfile> {
  String photoUrl, displayName, id;
  final dbRef = FirebaseFirestore.instance;
  _OtherProfileState(this.id);
  bool requestsent = false;
  bool sendRequest = false;
  bool friends;
  var status;
  var userRequests;
  final strUserId = currentUser.id;
  final strPic = currentUser.photoUrl;
  final strUserName = currentUser.displayName;
  int verifiedStatus = currentUser.verifiedStatus;
  var iter = 1;
  String directMessageId;

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Unfriend user?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nCut 'em out?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Yes", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Database().unfriend(strUserId, id);
              setState(() {
                status = null;
              });
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: Text("No"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }

  void showAlertDialog2(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Unfollow?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nDon't like with 'em anymore?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Unfollow", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Database().unfollowBusiness(id, currentUser.id);
              // setState(() {
              // });
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: Text("Forget it"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }

  checkFunction() {
    // check to see if a request from other user already exists
    Database().checkStatus(id, strUserId).then((QuerySnapshot docs) => {
          if (docs.docs.isNotEmpty)
            {
              // setState(
              //     () => userRequests = docs.documents[0].data['friendRequests']),
              // for (var i = 0; i < userRequests.length; i++)
              //   {
              //     if (userRequests[i][id] == 0) {status = 2, print('hio')}
              //   }
              setState(() {
                status = 2;
              })
            }
        });
  }

  checkFunction2() {
    // checks to see if current user has sent request already
    Database().checkStatus(strUserId, id).then((QuerySnapshot docs) => {
          if (docs.docs.isNotEmpty)
            {
              setState(
                  () => userRequests = docs.docs[0].data()['friendRequests']),
              if (userRequests[0] != null) {status = 0}
            }
        });
  }

  checkFunction3() {
    // users are already friends
    Database().checkFriends(strUserId, id).then((QuerySnapshot docs) => {
          if (docs.docs.isNotEmpty)
            {
              setState(
                () => userRequests = docs.docs[0].data()['friendRequests'],
              ),
              status = 1
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    List userFriends;
    var score;

    bool isLargePhone = Screen.diagonal(context) > 766;

    return StreamBuilder(
        stream: usersRef.doc(id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text('Loading data...');
          while (iter > 0) {
            checkFunction();
            checkFunction2();
            checkFunction3();
            iter = iter - 1;
          }
          verifiedStatus = snapshot.data['verifiedStatus'];
          displayName = snapshot.data['displayName'];
          photoUrl = snapshot.data['photoUrl'];
          userFriends = snapshot.data['friendArray'];
          List<dynamic> userGroups = snapshot.data['friendGroups'];
          score = snapshot.data['score'];
          String venmo = snapshot.data['venmoUsername'];
          bool isBusiness = snapshot.data['isBusiness'];
          List<dynamic> followers = snapshot.data['followers'];

          return (!isBusiness)
              ? Scaffold(
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
                  body: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Stack(children: [
                      Container(
                        height: 130,
                        child: Stack(children: <Widget>[
                          FractionallySizedBox(
                            widthFactor: isLargePhone ? 1.17 : 1.34,
                            child: Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: snapshot.data['header'] == ""
                                    ? Image.asset(
                                        'lib/assets/headerNoWhite.jpg',
                                        fit: BoxFit.fitWidth,
                                      )
                                    : Image.network(
                                        snapshot.data['header'],
                                        fit: BoxFit.fitWidth,
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
                          currentUser.id == "118426518878481598299" ||
                                  currentUser.id == "108155010592087635288" ||
                                  currentUser.id == "115805501102171844515" ||
                                  currentUser.id == "107290090512658207959"
                              ? GestureDetector(
                                  onTap: () => remoteBadgeDialog(context),
                                  child: Icon(Icons.settings_remote,
                                      color: Colors.red))
                              : Container()
                        ]),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 30.0, bottom: 10),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: TextThemes.ndGold,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: TextThemes.ndBlue,
                                child: CircleAvatar(
                                  backgroundImage: (photoUrl == null)
                                      ? AssetImage('images/user-avatar.png')
                                      : NetworkImage(photoUrl),
                                  // backgroundImage: NetworkImage(currentUser.photoUrl),
                                  radius: 50,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName != ""
                                      ? displayName
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
                                          color: Colors.blue,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 2.0, bottom: 12.0),
                                child: currentUser.isBusiness == true
                                    ? Container()
                                    : snapshot.data['privacySettings']
                                            ['showDorm']
                                        ? Text(
                                            snapshot.data['year'] +
                                                " in " +
                                                snapshot.data['dorm'],
                                            style: TextStyle(fontSize: 15),
                                          )
                                        : Text("Top secret year and dorm"),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => LeaderBoardPage()));
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      score.toString(),
                                      style: TextThemes.extraBold,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
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
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          FriendsList(id: id)));
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
                                      padding: const EdgeInsets.only(top: 4.0),
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
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => GroupsList(id)));
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
                                      padding: const EdgeInsets.only(top: 4.0),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(5),
                                  child: RaisedButton(
                                      padding: const EdgeInsets.all(12.0),
                                      color: TextThemes.ndGold,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3.0))),
                                      onPressed: () {
                                        dmChecker(id, directMessageId).then(
                                            (value) => toMessageDetail(
                                                id, directMessageId, context));
                                      },
                                      child: Text("Message",
                                          style:
                                              TextStyle(color: Colors.white)))),
                              currentUser.isBusiness == false
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          right: 7.5, bottom: 15, top: 15.5),
                                      child: status == 2
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                RaisedButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    color: Colors.green,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    3.0))),
                                                    onPressed: () {
                                                      Database()
                                                          .acceptFriendRequest(
                                                              id,
                                                              strUserId,
                                                              displayName,
                                                              photoUrl);
                                                      setState(() {
                                                        status = 1;
                                                      });
                                                      Database()
                                                          .friendAcceptNotification(
                                                              id,
                                                              photoUrl,
                                                              displayName,
                                                              strUserId);
                                                    },
                                                    child: Text(
                                                      "Accept Friend Request",
                                                      style: new TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.0,
                                                      ),
                                                    )),
                                                RaisedButton(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    color: Colors.red,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    3.0))),
                                                    onPressed: () {
                                                      setState(() {
                                                        status = null;
                                                      });
                                                      Database()
                                                          .rejectFriendRequest(
                                                              strUserId,
                                                              id,
                                                              strUserName,
                                                              strPic);
                                                    },
                                                    child: Text(
                                                      "Decline Friend Request",
                                                      style: new TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.0,
                                                      ),
                                                    )),
                                              ],
                                            )
                                          : status != 1
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                      RaisedButton(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12.0),
                                                        color: Color.fromRGBO(
                                                            2, 43, 91, 1.0),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        3.0))),
                                                        onPressed: () {
                                                          Database()
                                                              .sendFriendRequest(
                                                                  strUserId,
                                                                  id,
                                                                  strUserName,
                                                                  strPic);
                                                          status = 0;
                                                          Database()
                                                              .friendRequestNotification(
                                                                  id,
                                                                  photoUrl,
                                                                  displayName,
                                                                  strUserId);
                                                        },
                                                        child: status == null
                                                            ? Text(
                                                                "Send Friend Request",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      14.0,
                                                                ),
                                                              )
                                                            : Text(
                                                                "Request Sent",
                                                                style:
                                                                    new TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      14.0,
                                                                ),
                                                              ),
                                                      ),
                                                    ])
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                      RaisedButton(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12.0),
                                                          color: Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.all(
                                                                      Radius.circular(
                                                                          3.0))),
                                                          onPressed: () {
                                                            // unfriend code here
                                                          },
                                                          child:
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    showAlertDialog(
                                                                        context);
                                                                  },
                                                                  child: Text(
                                                                    "Friends",
                                                                    style:
                                                                        new TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          14.0,
                                                                    ),
                                                                  ))),
                                                    ]),
                                    )
                                  : Container(),
                            ],
                          ),
                          venmo != null && venmo != ""
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, bottom: 12.5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('lib/assets/venmo-icon.png',
                                          height: 35),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Venmo: @" + venmo,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(""),
                          snapshot.data['bio'] != "Create a bio here"
                              ? Card(
                                  margin: EdgeInsets.only(
                                      left: 15, right: 15, bottom: 20, top: 10),
                                  color: TextThemes.ndBlue,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                        fontWeight:
                                                            FontWeight.w200,
                                                        color:
                                                            TextThemes.ndGold)),
                                              ]),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 40),
                                        child: Center(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0),
                                              child: RichText(
                                                textAlign: TextAlign.center,
                                                textScaleFactor: 1.3,
                                                text: TextSpan(
                                                    style:
                                                        TextThemes.mediumbody,
                                                    children: [
                                                      TextSpan(
                                                          text: "\"" +
                                                              snapshot
                                                                  .data['bio'] +
                                                              "\"",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic)),
                                                    ]),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(""),
                          // PopularityBadges(id),
                          StreamBuilder(
                              stream: postsRef
                                  .where('userId', isEqualTo: id)
                                  .where("privacy", isEqualTo: 'Public')
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
                                        Text("Their Posts"),
                                        Divider(
                                          color: TextThemes.ndBlue,
                                          height: 20,
                                          thickness: 2,
                                          indent: 20,
                                          endIndent: 20,
                                        ),
                                        Expanded(
                                            child: CustomScrollView(
                                          physics:
                                              NeverScrollableScrollPhysics(),
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
                                  .where('going', arrayContains: id)
                                  .where("privacy", isEqualTo: 'Public')
                                  // .orderBy("startDate")
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
                                                    : snapshot.data.docs
                                                                .length >=
                                                            6
                                                        ? 500
                                                        : 550,
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
                        ],
                      ),
                    ]),
                  ))
              : Scaffold(
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
                  body: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Stack(children: [
                      Container(
                        height: 130,
                        child: Stack(children: <Widget>[
                          FractionallySizedBox(
                            widthFactor: isLargePhone ? 1.17 : 1.34,
                            child: Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: snapshot.data['header'] == ""
                                    ? Image.asset(
                                        'lib/assets/headerNoWhite.jpg',
                                        fit: BoxFit.fitWidth,
                                      )
                                    : Image.network(
                                        snapshot.data['header'],
                                        fit: BoxFit.fitWidth,
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 30.0, bottom: 10),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.blue,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: TextThemes.ndBlue,
                                child: CircleAvatar(
                                  backgroundImage: (photoUrl == null)
                                      ? AssetImage('images/user-avatar.png')
                                      : NetworkImage(photoUrl),
                                  // backgroundImage: NetworkImage(currentUser.photoUrl),
                                  radius: 50,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName != ""
                                      ? displayName
                                      : "Username not found",
                                  style: TextThemes.extraBold,
                                ),
                                verifiedStatus == 3
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          left: 5,
                                          top: 2.5,
                                        ),
                                        child: Icon(Icons.store,
                                            size: 25, color: Colors.blue),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(
                                      top: 2.0, bottom: 12.0),
                                  child: SizedBox(
                                      width: 275,
                                      child: GestureDetector(
                                        onTap: () => MapsLauncher.launchQuery(
                                            snapshot.data['dorm']),
                                        child: Text(
                                          snapshot.data['dorm'],
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.blue[800],
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      )))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => LeaderBoardPage()));
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      score.toString(),
                                      style: TextThemes.extraBold,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
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
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          FollowersList(id: id)));
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
                                      padding: const EdgeInsets.only(top: 4.0),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(5),
                                  child: RaisedButton(
                                      padding: const EdgeInsets.all(12.0),
                                      color: TextThemes.ndGold,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3.0))),
                                      onPressed: () {
                                        dmChecker(id, directMessageId).then(
                                            (value) => toMessageDetail(
                                                id, directMessageId, context));
                                      },
                                      child: Text("Message",
                                          style:
                                              TextStyle(color: Colors.white)))),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 7.5, bottom: 15, top: 15.5),
                                child: !snapshot.data['followers']
                                        .contains(currentUser.id)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                            RaisedButton(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                color: Color.fromRGBO(
                                                    2, 43, 91, 1.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                3.0))),
                                                onPressed: () {
                                                  Database().followBusiness(
                                                      id,
                                                      strPic,
                                                      snapshot.data['photoUrl'],
                                                      currentUser.id);
                                                },
                                                child: Text(
                                                  "Follow",
                                                  style: new TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14.0,
                                                  ),
                                                )),
                                          ])
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                            RaisedButton(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                color: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                3.0))),
                                                onPressed: () {
                                                  // unfriend code here
                                                },
                                                child: GestureDetector(
                                                    onTap: () {
                                                      showAlertDialog2(context);
                                                    },
                                                    child: Text(
                                                      "Following",
                                                      style: new TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.0,
                                                      ),
                                                    ))),
                                          ]),
                              ),
                            ],
                          ),
                          venmo != null && venmo != ""
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, bottom: 12.5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('lib/assets/venmo-icon.png',
                                          height: 35),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Venmo: @" + venmo,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(""),
                          snapshot.data['bio'] != "Create a bio here"
                              ? Card(
                                  margin: EdgeInsets.only(
                                      left: 15, right: 15, bottom: 20, top: 10),
                                  color: TextThemes.ndBlue,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                        fontWeight:
                                                            FontWeight.w200,
                                                        color:
                                                            TextThemes.ndGold)),
                                              ]),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 40),
                                        child: Center(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0),
                                              child: RichText(
                                                textAlign: TextAlign.center,
                                                textScaleFactor: 1.3,
                                                text: TextSpan(
                                                    style:
                                                        TextThemes.mediumbody,
                                                    children: [
                                                      TextSpan(
                                                          text: "\"" +
                                                              snapshot
                                                                  .data['bio'] +
                                                              "\"",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic)),
                                                    ]),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Text(""),
                          PopularityBadges(id),
                          RestaurantMenu(id),
                          StreamBuilder(
                              stream: postsRef
                                  .where('userId', isEqualTo: id)
                                  .where("privacy", isEqualTo: 'Public')
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
                                        Text("Their MOOVs"),
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
                                  .where('going', arrayContains: id)
                                  .where("privacy", isEqualTo: 'Public')
                                  // .orderBy("startDate")
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
                        ],
                      ),
                    ]),
                  ));
        });
  }

  remoteBadgeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Remote Control Shit",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          CupertinoDialogAction(
            child:
                Text("Helped MOOV Badge", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Database().giveBadge(id, "helpedMOOV");
            },
          ),
          CupertinoDialogAction(
            child: Text("Leaderboard Win Badge",
                style: TextStyle(color: Colors.red)),
            onPressed: () {
              Database().giveBadge(id, "leaderboardWin");
            },
          ),
          CupertinoDialogAction(
            child: Text("Give Natty", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Database().giveBadge(id, "natties");
            },
          ),
          CupertinoDialogAction(
            child: Text("Give friends", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Database().giveBadge(id, "friends10");
            },
          ),
        ],
      ),
    );
  }
}
