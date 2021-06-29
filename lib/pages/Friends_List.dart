import 'package:MOOV/friendGroups/OtherGroup.dart';
import 'package:MOOV/friendGroups/group_detail.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/services/database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class FriendsList extends StatefulWidget {
  final id;

  FriendsList({this.id});

  @override
  State<StatefulWidget> createState() {
    // ignore: todo
    // TODO: implement createState
    return FriendsListState(this.id);
  }
}

class FriendsListState extends State<FriendsList> {
  TextEditingController searchController = TextEditingController();
  var iter = 0;
  final id;

  FriendsListState(this.id);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return StreamBuilder(
        stream: usersRef.where("friendArray", arrayContains: id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data == null) return Container();

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
                      MaterialPageRoute(
                          builder: (context) => ProfilePageWithHeader()),
                    );
                  },
                ),
                backgroundColor: TextThemes.ndBlue,
                title: snapshot.data.docs.length == 1
                    ? Text(
                        "Friend",
                        style: TextStyle(color: Colors.white),
                      )
                    : Text(
                        "Friends",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              body: ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                            margin: EdgeInsets.all(0.0),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Column(
                                children: [
                                  Container(
                                      color: Colors.grey[300],
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(builder:
                                                          (BuildContext
                                                              context) {
                                                    return OtherProfile(snapshot
                                                        .data.docs[index]['id']
                                                        .toString());
                                                  })); //Material
                                                },
                                                child: CircleAvatar(
                                                    radius: 22,
                                                    child: CircleAvatar(
                                                        radius: 22.0,
                                                        backgroundImage:
                                                            NetworkImage(snapshot
                                                                    .data
                                                                    .docs[index]
                                                                ['photoUrl'])

                                                        // NetworkImage(likedArray[index]['strPic']),

                                                        ))),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(builder:
                                                          (BuildContext
                                                              context) {
                                                    return OtherProfile(snapshot
                                                        .data.docs[index]['id']
                                                        .toString());
                                                  })); //Material
                                                },
                                                child: Text(
                                                    snapshot
                                                        .data
                                                        .docs[index]
                                                            ['displayName']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            TextThemes.ndBlue,
                                                        decoration:
                                                            TextDecoration
                                                                .none))),
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: Container(),
                                            // currentUser.friendArray
                                            //         .contains(snapshot
                                            //             .data.docs[index]['id'])
                                            // ? RaisedButton(
                                            //     padding:
                                            //         const EdgeInsets.all(
                                            //             2.0),
                                            //     color: Colors.green,
                                            //     shape: RoundedRectangleBorder(
                                            //         borderRadius:
                                            //             BorderRadius.all(
                                            //                 Radius.circular(
                                            //                     3.0))),
                                            //     onPressed: () {
                                            //       Navigator.of(context).push(
                                            //           MaterialPageRoute(
                                            //               builder: (context) =>
                                            //                   OtherProfile(snapshot
                                            //                       .data
                                            //                       .docs[
                                            //                           index]
                                            //                           ['id']
                                            //                       .toString())));
                                            //     },
                                            //     child: Text(
                                            //       "Friends",
                                            //       style: new TextStyle(
                                            //         color: Colors.white,
                                            //         fontSize: 14.0,
                                            //       ),
                                            //     ),
                                            //   )
                                            // : RaisedButton(
                                            //     padding:
                                            //         const EdgeInsets.all(
                                            //             2.0),
                                            //     color: TextThemes.ndBlue,
                                            //     shape: RoundedRectangleBorder(
                                            //         borderRadius:
                                            //             BorderRadius.all(
                                            //                 Radius.circular(
                                            //                     3.0))),
                                            //     onPressed: () {
                                            //       Navigator.of(context).push(
                                            //           MaterialPageRoute(
                                            //               builder: (context) =>
                                            //                   OtherProfile(snapshot
                                            //                       .data
                                            //                       .docs[
                                            //                           index]
                                            //                           ['id']
                                            //                       .toString())));
                                            //     },
                                            //     child: Text(
                                            //       "Stranger",
                                            //       style: new TextStyle(
                                            //         color: Colors.white,
                                            //         fontSize: 14.0,
                                            //       ),
                                            //     ),
                                            //   ),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                            )),
                      )));
        });
  }
}

class FollowersList extends StatefulWidget {
  TextEditingController searchController = TextEditingController();
  final id;

  FollowersList({this.id});

  @override
  State<StatefulWidget> createState() {
    return FollowersListState(this.id);
  }
}

class FollowersListState extends State<FollowersList> {
  TextEditingController searchController = TextEditingController();
  final id;

  FollowersListState(this.id);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersRef.doc(id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data == null) return Container();
          List followers = snapshot.data['followers'];

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
                      MaterialPageRoute(
                          builder: (context) => ProfilePageWithHeader()),
                    );
                  },
                ),
                backgroundColor: TextThemes.ndBlue,
                title: followers.length == 1
                    ? Text(
                        "Follower",
                        style: TextStyle(color: Colors.white),
                      )
                    : Text(
                        "Followers",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              body: ListView.builder(
                  itemCount: followers.length,
                  itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: StreamBuilder(
                            stream: usersRef.doc(followers[index]).snapshots(),
                            builder: (context, snapshot2) {
                              return Container(
                                  margin: EdgeInsets.all(0.0),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: Column(
                                      children: [
                                        Container(
                                            color: Colors.grey[300],
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                          return OtherProfile(
                                                              snapshot2
                                                                  .data['id']);
                                                        })); //Material
                                                      },
                                                      child: CircleAvatar(
                                                          radius: 22,
                                                          child: CircleAvatar(
                                                              radius: 22.0,
                                                              backgroundImage:
                                                                  NetworkImage(snapshot2
                                                                          .data[
                                                                      'photoUrl'])

                                                              // NetworkImage(likedArray[index]['strPic']),

                                                              ))),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10.0),
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                          return OtherProfile(
                                                              snapshot2
                                                                  .data['id']);
                                                        })); //Material
                                                      },
                                                      child: Text(
                                                          snapshot2.data[
                                                                  'displayName']
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color: TextThemes
                                                                  .ndBlue,
                                                              decoration:
                                                                  TextDecoration
                                                                      .none))),
                                                ),
                                                Spacer(),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8),
                                                  child: Container(),
                                                  // currentUser.friendArray
                                                  //         .contains(snapshot
                                                  //             .data.docs[index]['id'])
                                                  // ? RaisedButton(
                                                  //     padding:
                                                  //         const EdgeInsets.all(
                                                  //             2.0),
                                                  //     color: Colors.green,
                                                  //     shape: RoundedRectangleBorder(
                                                  //         borderRadius:
                                                  //             BorderRadius.all(
                                                  //                 Radius.circular(
                                                  //                     3.0))),
                                                  //     onPressed: () {
                                                  //       Navigator.of(context).push(
                                                  //           MaterialPageRoute(
                                                  //               builder: (context) =>
                                                  //                   OtherProfile(snapshot
                                                  //                       .data
                                                  //                       .docs[
                                                  //                           index]
                                                  //                           ['id']
                                                  //                       .toString())));
                                                  //     },
                                                  //     child: Text(
                                                  //       "Friends",
                                                  //       style: new TextStyle(
                                                  //         color: Colors.white,
                                                  //         fontSize: 14.0,
                                                  //       ),
                                                  //     ),
                                                  //   )
                                                  // : RaisedButton(
                                                  //     padding:
                                                  //         const EdgeInsets.all(
                                                  //             2.0),
                                                  //     color: TextThemes.ndBlue,
                                                  //     shape: RoundedRectangleBorder(
                                                  //         borderRadius:
                                                  //             BorderRadius.all(
                                                  //                 Radius.circular(
                                                  //                     3.0))),
                                                  //     onPressed: () {
                                                  //       Navigator.of(context).push(
                                                  //           MaterialPageRoute(
                                                  //               builder: (context) =>
                                                  //                   OtherProfile(snapshot
                                                  //                       .data
                                                  //                       .docs[
                                                  //                           index]
                                                  //                           ['id']
                                                  //                       .toString())));
                                                  //     },
                                                  //     child: Text(
                                                  //       "Stranger",
                                                  //       style: new TextStyle(
                                                  //         color: Colors.white,
                                                  //         fontSize: 14.0,
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                )
                                              ],
                                            )),
                                      ],
                                    ),
                                  ));
                            }),
                      )));
        });
  }
}

class GroupsList extends StatefulWidget {
  TextEditingController searchController = TextEditingController();
  final String id;

  GroupsList(this.id);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GroupsListState(this.id);
  }
}

class GroupsListState extends State<GroupsList> {
  TextEditingController searchController = TextEditingController();
  var iter = 0;
  final String id;

  GroupsListState(this.id);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return StreamBuilder(
        stream: groupsRef.where("members", arrayContains: id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data == null) return Container();

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
                      MaterialPageRoute(
                          builder: (context) => ProfilePageWithHeader()),
                    );
                  },
                ),
                backgroundColor: TextThemes.ndBlue,
                title: snapshot.data.docs.length == 1
                    ? Text(
                        "Friend Group",
                        style: TextStyle(color: Colors.white),
                      )
                    : Text(
                        "Friend Groups",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              body: ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (_, index) {
                    bool isLargePhone = Screen.diagonal(context) > 766;

                    DocumentSnapshot course = snapshot.data.docs[index];
                    String groupPic = course['groupPic'];
                    String groupName = course['groupName'];
                    List<dynamic> members = course['members'];
                    String groupId = course['groupId'];
                    // print(members);

                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                          margin: EdgeInsets.all(0.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Column(
                              children: [
                                Container(
                                    color: Colors.grey[300],
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              bool memberStatus = members
                                                      .contains(currentUser.id)
                                                  ? true
                                                  : false;
                                              if (memberStatus == true) {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(builder:
                                                        (BuildContext context) {
                                                  return GroupDetail(groupId);
                                                }));
                                              } else if (memberStatus ==
                                                  false) {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(builder:
                                                        (BuildContext context) {
                                                  return OtherGroup(groupId);
                                                }));
                                              }
                                            },
                                            child: SizedBox(
                                              width: isLargePhone
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                              height: isLargePhone
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.1
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
                                                    imageUrl: groupPic,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                margin: EdgeInsets.only(
                                                    left: 5,
                                                    top: 0,
                                                    right: 10,
                                                    bottom: 0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, right: 5),
                                          child: SizedBox(
                                            width: 100,
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(builder:
                                                          (BuildContext
                                                              context) {
                                                    return OtherGroup(groupId);
                                                  })); //Material
                                                },
                                                child: Text(groupName,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            TextThemes.ndBlue,
                                                        decoration:
                                                            TextDecoration
                                                                .none))),
                                          ),
                                        ),
                                        Spacer(),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: RaisedButton(
                                            padding: const EdgeInsets.all(2.0),
                                            color: Colors.green,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(3.0))),
                                            onPressed: () {
                                              showAlertDialog(
                                                  context, groupName, groupId);
                                            },
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 3.0),
                                                  child: members.contains(
                                                          currentUser.id)
                                                      ? Icon(Icons.check,
                                                          color: Colors.white)
                                                      : Icon(
                                                          Icons
                                                              .accessibility_new,
                                                          color: Colors.white,
                                                        ),
                                                ),
                                                members.contains(currentUser.id)
                                                    ? Text(
                                                        " Member ",
                                                        style: new TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14.0,
                                                        ),
                                                      )
                                                    : Text(
                                                        " Ask to Join? ",
                                                        style: new TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14.0,
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                              ],
                            ),
                          )),
                    );
                  }));
        });
  }

  void showAlertDialog(BuildContext context, groupName, groupId) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Ask to Join?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nYou cool enough?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Ask", style: TextStyle(color: Colors.green)),
            onPressed: () {
              Database().askToJoinGroup(currentUser.id, currentUser.photoUrl,
                  currentUser.id, groupName, groupId);

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
}
