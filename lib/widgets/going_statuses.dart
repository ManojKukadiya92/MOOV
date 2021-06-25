import 'dart:async';
import 'dart:collection';
import 'dart:ui';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/pages/OtherGroup.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:MOOV/pages/group_detail.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef void HeightAdjustCallback(int val);

class GoingPage extends StatelessWidget {
  final HeightAdjustCallback callback;
  final String moovId;
  GoingPage(this.moovId, this.callback);

  @override
  Widget build(BuildContext context) {
    int status = 0;

    return StreamBuilder(
        stream: postsRef.doc(moovId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text('Loading data...');

          DocumentSnapshot course = snapshot.data;
          if (snapshot.hasError) return CircularProgressIndicator();

          Map<String, dynamic> statuses = course['statuses'];

          var sortedKeys = statuses.keys.toList(growable: false)
            ..sort((k1, k2) => statuses[k2].compareTo(statuses[k1]));
          LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
              key: (k) => k, value: (k) => statuses[k]);

          List<dynamic> statusesIds = sortedMap.keys.toList();

          List<dynamic> statusesValues = sortedMap.values.toList();

          return Column(
            children: [
              statuses != null
                  ? ListView.builder(
                      shrinkWrap: true, //MUST TO ADDED
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: statusesIds.length,
                      itemBuilder: (context, index) {
                        Timer(Duration(microseconds: 1), () {
                          callback(statusesIds.length * 55);
                        });
                        bool hide = false;
                        if (!_isNumeric(statusesIds[index])) {
                          hide = true;
                        }
                        return (hide == false)
                            ? StreamBuilder(
                                stream: usersRef
                                    .doc(statusesIds[index])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return CircularProgressIndicator();

                                  bool friendsOnly = false;
                                  bool incognito = false;

                                  if (snapshot.data['privacySettings']
                                          ['friendsOnly'] ==
                                      true) {
                                    friendsOnly = true;
                                  }
                                  if (friendsOnly == true &&
                                      !currentUser.friendArray
                                          .contains(statusesIds[index])) {
                                    incognito = true;
                                  }
                                  if (snapshot.data['privacySettings']
                                          ['incognito'] ==
                                      true) {
                                    incognito = true;
                                  }

                                  statusesValues[index] == (2)
                                      ? status = 2
                                      : statusesValues[index] == 1
                                          ? status = 1
                                          : statusesValues[index] == 3
                                              ? status = 3
                                              : statusesValues[index] == -1
                                                  ? status = -1
                                                  : statusesValues[index] == 4
                                                      ? status = 4
                                                      : status = 0;

                                  var pic = snapshot.data['photoUrl'];
                                  var name = snapshot.data['displayName'];
                                  int verifiedStatus =
                                      snapshot.data['verifiedStatus'];

                                  return (hide == false)
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0),
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: incognito
                                                    ? null
                                                    : () {
                                                        if (statusesIds[
                                                                index] ==
                                                            currentUser.id) {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ProfilePageWithHeader()));
                                                        } else {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      OtherProfile(
                                                                          statusesIds[
                                                                              index])));
                                                        }
                                                      },
                                                child: Stack(children: [
                                                  Container(
                                                      height:
                                                          status == 0 ? 0 : 55,
                                                      color: status == 2
                                                          ? Colors.yellow[50]
                                                          : status == 1
                                                              ? Colors.red[50]
                                                              : status == 3
                                                                  ? Colors
                                                                      .green[50]
                                                                  : status == 4
                                                                      ? Colors.amber[
                                                                          500]
                                                                      : Colors.blue[
                                                                          50],
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            12,
                                                                        top: 4,
                                                                        bottom:
                                                                            4),
                                                                child:
                                                                    CircleAvatar(
                                                                        radius:
                                                                            22,
                                                                        backgroundColor:
                                                                            TextThemes
                                                                                .ndBlue,
                                                                        child:
                                                                            CircleAvatar(
                                                                          radius:
                                                                              22.0,
                                                                          backgroundImage: incognito
                                                                              ? AssetImage('lib/assets/incognitoPic.jpg')
                                                                              : NetworkImage(pic),
                                                                          backgroundColor:
                                                                              Colors.transparent,
                                                                        )),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            16.0),
                                                                child: Row(
                                                                  children: [
                                                                    incognito
                                                                        ? Text(
                                                                            "Incognito Student",
                                                                            style: TextStyle(
                                                                                fontSize: 16,
                                                                                color: TextThemes.ndBlue,
                                                                                decoration: TextDecoration.none))
                                                                        : Text(name, style: TextStyle(fontSize: 16, color: TextThemes.ndBlue, decoration: TextDecoration.none)),
                                                                    verifiedStatus ==
                                                                            3
                                                                        ? Padding(
                                                                            padding:
                                                                                EdgeInsets.only(
                                                                              left: 4,
                                                                            ),
                                                                            child: Icon(Icons.store,
                                                                                size: 20,
                                                                                color: Colors.blue),
                                                                          )
                                                                        : verifiedStatus ==
                                                                                2
                                                                            ? Padding(
                                                                                padding: EdgeInsets.only(
                                                                                  left: 5,
                                                                                ),
                                                                                child: Image.asset('lib/assets/verif2.png', height: 15),
                                                                              )
                                                                            : verifiedStatus == 1
                                                                                ? Padding(
                                                                                    padding: EdgeInsets.only(left: 2.5, top: 2.5),
                                                                                    child: Image.asset('lib/assets/verif.png', height: 25),
                                                                                  )
                                                                                : Text("")
                                                                  ],
                                                                ),
                                                              ),
                                                            ]),
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            8.0),
                                                                child: status ==
                                                                        2
                                                                    ? Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 8.0),
                                                                            child:
                                                                                Icon(Icons.accessibility, color: Colors.yellow[600]),
                                                                          ),
                                                                          Text(
                                                                            "Undecided",
                                                                            style:
                                                                                TextStyle(color: Colors.yellow[600], fontWeight: FontWeight.w700),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : status ==
                                                                            1
                                                                        ? Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(right: 8.0),
                                                                                child: Icon(Icons.directions_walk, color: Colors.red),
                                                                              ),
                                                                              Text(
                                                                                "Not going",
                                                                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                                                                              )
                                                                            ],
                                                                          )
                                                                        : status ==
                                                                                3
                                                                            ? Row(
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(right: 8.0),
                                                                                    child: Icon(Icons.directions_run, color: Colors.green),
                                                                                  ),
                                                                                  Text(
                                                                                    "Going!",
                                                                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            : status == -1
                                                                                ? Row(
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 8.0),
                                                                                        child: Icon(Icons.redeem, color: Colors.blue),
                                                                                      ),
                                                                                      Text(
                                                                                        "Invited",
                                                                                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
                                                                                      )
                                                                                    ],
                                                                                  )
                                                                                : status == 4
                                                                                    ? Row(
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.only(right: 8.0),
                                                                                            child: Icon(Icons.check, color: Colors.white),
                                                                                          ),
                                                                                          Text(
                                                                                            "Checked In",
                                                                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                                                                          )
                                                                                        ],
                                                                                      )
                                                                                    : Container())
                                                          ])),
                                                  friendsOnly &&
                                                          statusesIds[index] ==
                                                              currentUser.id
                                                      ? Positioned(
                                                          bottom: 2.5,
                                                          left: 72.5,
                                                          child: Text(
                                                            "ONLY YOUR FRIENDS CAN SEE",
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    Colors.red),
                                                          ))
                                                      : incognito &&
                                                              statusesIds[
                                                                      index] ==
                                                                  currentUser.id
                                                          ? Positioned(
                                                              bottom: 2.5,
                                                              left: 72.5,
                                                              child: Text(
                                                                "YOU'RE INCOGNITO. NO ONE CAN SEE.",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .red),
                                                              ))
                                                          : Text("")
                                                ]),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container();
                                })
                            : StreamBuilder(
                                stream: groupsRef
                                    .doc(statusesIds[index])
                                    .snapshots(),
                                builder: (context, snapshot2) {
                                  if (!snapshot2.hasData)
                                    return CircularProgressIndicator();

                                  statusesValues[index] == (2)
                                      ? status = 2
                                      : statusesValues[index] == 1
                                          ? status = 1
                                          : statusesValues[index] == 3
                                              ? status = 3
                                              : statusesValues[index] == -1
                                                  ? status = -1
                                                  : status = 0;

                                  var pic = snapshot2.data['groupPic'];
                                  var name = snapshot2.data['groupName'];
                                  var members = snapshot2.data['members'];
                                  String groupId = snapshot2.data['groupId'];

                                  if (status == 0) {
                                    return Container();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (members
                                                .contains(currentUser.id)) {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          GroupDetail(
                                                              groupId)));
                                            } else {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OtherGroup(groupId)));
                                            }
                                          },
                                          child: Container(
                                              color: status == 2
                                                  ? Colors.yellow[50]
                                                  : status == 1
                                                      ? Colors.red[50]
                                                      : status == 3
                                                          ? Colors.green[50]
                                                          : Colors.blue[50],
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 12,
                                                                top: 4,
                                                                bottom: 4),
                                                        child: CircleAvatar(
                                                            radius: 22,
                                                            backgroundColor:
                                                                TextThemes
                                                                    .ndBlue,
                                                            child: CircleAvatar(
                                                              radius: 22.0,
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      pic),
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                            )),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 16.0),
                                                        child: Row(
                                                          children: [
                                                            Text(name,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: TextThemes
                                                                        .ndBlue,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .none)),
                                                          ],
                                                        ),
                                                      ),
                                                    ]),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 8.0),
                                                        child: status == 2
                                                            ? Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .accessibility,
                                                                        color: Colors
                                                                            .yellow[600]),
                                                                  ),
                                                                  Text(
                                                                    "Undecided",
                                                                    style: TextStyle(
                                                                        color: Colors.yellow[
                                                                            600],
                                                                        fontWeight:
                                                                            FontWeight.w700),
                                                                  )
                                                                ],
                                                              )
                                                            : status == 1
                                                                ? Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(right: 8.0),
                                                                        child: Icon(
                                                                            Icons
                                                                                .directions_walk,
                                                                            color:
                                                                                Colors.red),
                                                                      ),
                                                                      Text(
                                                                        "Not going",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontWeight: FontWeight.w700),
                                                                      )
                                                                    ],
                                                                  )
                                                                : status == -1
                                                                    ? Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 8.0),
                                                                            child:
                                                                                Icon(Icons.redeem, color: Colors.blue),
                                                                          ),
                                                                          Text(
                                                                            "Invited",
                                                                            style:
                                                                                TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 8.0),
                                                                            child:
                                                                                Icon(Icons.directions_run, color: Colors.green),
                                                                          ),
                                                                          Text(
                                                                            "Going!",
                                                                            style:
                                                                                TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
                                                                          )
                                                                        ],
                                                                      ))
                                                  ])),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                      })
                  : Center(child: Text('')),
            ],
          );
        });
  }

  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }
}

class GoingPageFriends extends StatelessWidget {
  final HeightAdjustCallback callback;

  dynamic moovId, likeCount;
  int status = 0;

  GoingPageFriends(this.moovId, this.callback);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: postsRef.doc(moovId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text('Loading data...');

          DocumentSnapshot course = snapshot.data;
          if (snapshot.hasError) return CircularProgressIndicator();

          Map<String, dynamic> statuses = course['statuses'];

          var sortedKeys = statuses.keys.toList(growable: false)
            ..sort((k1, k2) => statuses[k2].compareTo(statuses[k1]));
          LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
              key: (k) => k, value: (k) => statuses[k]);

          List<dynamic> statusesIds = sortedMap.keys.toList();

          List<dynamic> statusesValues = sortedMap.values.toList();

          return Column(
            children: [
              statuses != null
                  ? ListView.builder(
                      shrinkWrap: true, //MUST TO ADDED
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: statusesIds.length,
                      itemBuilder: (context, index) {
                        Timer(Duration(microseconds: 1), () {
                          callback(statusesIds.length * 55);
                        });
                        bool hide = false;
                        if (!_isNumeric(statusesIds[index])) {
                          hide = true;
                        }

                        return (hide == false)
                            ? StreamBuilder(
                                stream: usersRef
                                    .doc(statusesIds[index])
                                    .snapshots(),
                                builder: (context, snapshot2) {
                                  if (!snapshot2.hasData)
                                    return CircularProgressIndicator();
                                  if (snapshot2.data['friendArray']
                                      .contains(currentUser.id)) {
                                    bool incognito = false;

                                    if (snapshot2.data['privacySettings']
                                            ['incognito'] ==
                                        true) {
                                      incognito = true;
                                    }
                                    if (incognito == true &&
                                        statusesIds[index] != currentUser.id) {
                                      bool incognitoHide = true;
                                    }

                                    statusesValues[index] == (2)
                                        ? status = 2
                                        : statusesValues[index] == 1
                                            ? status = 1
                                            : statusesValues[index] == 3
                                                ? status = 3
                                                : statusesValues[index] == -1
                                                    ? status = -1
                                                    : statusesValues[index] == 4
                                                        ? status = 4
                                                        : status = 0;

                                    var pic = snapshot2.data['photoUrl'];
                                    var name = snapshot2.data['displayName'];
                                    int verifiedStatus =
                                        snapshot2.data['verifiedStatus'];

                                    if (status == 0) {
                                      return Container();
                                    }

                                    return (hide == false)
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2.0),
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: incognito
                                                      ? null
                                                      : () {
                                                          if (statusesIds[
                                                                  index] ==
                                                              currentUser.id) {
                                                            Navigator.of(
                                                                    context)
                                                                .push(MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ProfilePageWithHeader()));
                                                          } else {
                                                            Navigator.of(
                                                                    context)
                                                                .push(MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        OtherProfile(
                                                                            statusesIds[index])));
                                                          }
                                                        },
                                                  child: Container(
                                                      color: status == 2
                                                          ? Colors.yellow[50]
                                                          : status == 1
                                                              ? Colors.red[50]
                                                              : status == 3
                                                                  ? Colors
                                                                      .green[50]
                                                                  : status == 4
                                                                      ? Colors.amber[
                                                                          600]
                                                                      : Colors.blue[
                                                                          50],
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            12,
                                                                        top: 4,
                                                                        bottom:
                                                                            4),
                                                                child:
                                                                    CircleAvatar(
                                                                        radius:
                                                                            22,
                                                                        backgroundColor:
                                                                            TextThemes
                                                                                .ndBlue,
                                                                        child:
                                                                            CircleAvatar(
                                                                          radius:
                                                                              22.0,
                                                                          backgroundImage: incognito
                                                                              ? AssetImage('lib/assets/incognitoPic.jpg')
                                                                              : NetworkImage(pic),
                                                                          backgroundColor:
                                                                              Colors.transparent,
                                                                        )),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            16.0),
                                                                child: Row(
                                                                  children: [
                                                                    incognito
                                                                        ? Text(
                                                                            "Incognito Student",
                                                                            style: TextStyle(
                                                                                fontSize: 16,
                                                                                color: TextThemes.ndBlue,
                                                                                decoration: TextDecoration.none))
                                                                        : Text(name, style: TextStyle(fontSize: 16, color: TextThemes.ndBlue, decoration: TextDecoration.none)),
                                                                    verifiedStatus ==
                                                                            2
                                                                        ? Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: 5),
                                                                            child: Image.asset('lib/assets/verif2.png', height: 15))
                                                                        : Text("")
                                                                  ],
                                                                ),
                                                              ),
                                                            ]),
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            8.0),
                                                                child: status ==
                                                                        2
                                                                    ? Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 8.0),
                                                                            child:
                                                                                Icon(Icons.accessibility, color: Colors.yellow[600]),
                                                                          ),
                                                                          Text(
                                                                            "Undecided",
                                                                            style:
                                                                                TextStyle(color: Colors.yellow[600], fontWeight: FontWeight.w700),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : status ==
                                                                            1
                                                                        ? Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(right: 8.0),
                                                                                child: Icon(Icons.directions_walk, color: Colors.red),
                                                                              ),
                                                                              Text(
                                                                                "Not going",
                                                                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                                                                              )
                                                                            ],
                                                                          )
                                                                        : status ==
                                                                                -1
                                                                            ? Row(
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(right: 8.0),
                                                                                    child: Icon(Icons.redeem, color: Colors.blue),
                                                                                  ),
                                                                                  Text(
                                                                                    "Invited",
                                                                                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            : status == 4
                                                                                ? Row(
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 8.0),
                                                                                        child: Icon(Icons.check, color: Colors.white),
                                                                                      ),
                                                                                      Text(
                                                                                        "Checked In",
                                                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                                                                      )
                                                                                    ],
                                                                                  )
                                                                                : Row(
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 8.0),
                                                                                        child: Icon(Icons.directions_run, color: Colors.green),
                                                                                      ),
                                                                                      Text(
                                                                                        "Going!",
                                                                                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
                                                                                      )
                                                                                    ],
                                                                                  ))
                                                          ])),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container();
                                  } else {
                                    return Container();
                                  }
                                })
                            : Text("");
                      })
                  : Center(child: Text('')),
            ],
          );
        });
  }

  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }
}
