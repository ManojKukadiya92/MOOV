import 'package:MOOV/main.dart';
import 'package:MOOV/pages/OtherGroup.dart';
import 'package:MOOV/pages/group_detail.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/services/database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequests extends StatefulWidget {
  TextEditingController searchController = TextEditingController();
  final id;

  FriendRequests({this.id});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FriendsListState(this.id);
  }
}

class FriendsListState extends State<FriendRequests> {
  TextEditingController searchController = TextEditingController();
  var iter = 0;
  final id;

  FriendsListState(this.id);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return StreamBuilder(
        stream: usersRef
            .where("id", whereIn: currentUser.friendRequests)
            .snapshots(),
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
                        "Friend Request",
                        style: TextStyle(color: Colors.white),
                      )
                    : Text(
                        "Friend Requests",
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
