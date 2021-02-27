import 'dart:async';

import 'package:MOOV/main.dart';
import 'package:MOOV/models/user.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/MessagesHub.dart';
import 'package:MOOV/pages/NewSearch.dart';
import 'package:MOOV/pages/OtherGroup.dart';
import 'package:MOOV/pages/group_detail.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/leaderboard.dart';
import 'package:MOOV/pages/notification_feed.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/widgets/trending_segment.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:MOOV/widgets/trending_segment.dart';
import 'package:algolia/algolia.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../pages/ProfilePageWithHeader.dart';
import '../pages/other_profile.dart';

class SearchUsersPost extends StatefulWidget {
  List<String> invitees;
  SearchUsersPost(this.invitees);

  @override
  _SearchUsersPostState createState() => _SearchUsersPostState(this.invitees);
}

class _SearchUsersPostState extends State<SearchUsersPost>
    with SingleTickerProviderStateMixin {
  // TabController to control and switch tabs
  TabController _tabController;
  int _currentIndex = 0;
  Map<int, Widget> map =
      new Map(); // Cupertino Segmented Control takes children in form of Map.
  List<Widget>
      childWidgets; //The Widgets that has to be loaded when a tab is selected.
  int selectedIndex = 0;

  Widget getChildWidget() => childWidgets[selectedIndex];

  List<String> invitees;
  _SearchUsersPostState(this.invitees);

  final TextEditingController searchController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _operation0(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("groups").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("users").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  clearSearch() {
    searchController.clear();

    setState(() {
      _searchTerm = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        new TabController(vsync: this, length: 2, initialIndex: _currentIndex);
    _tabController.animation
      ..addListener(() {
        setState(() {
          _currentIndex = (_tabController.animation.value).round();
        });
      });

    // Simple declarations
    TextEditingController searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          iconSize: 35,
          icon: Icon(
            Icons.arrow_drop_down_outlined,
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
      body: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 96,
            bottom: PreferredSize(
                preferredSize: null,
                child: Column(children: <Widget>[
                  TextField(
                      style: TextStyle(fontSize: 20),
                      controller: searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchTerm = val;
                        });
                      },
                      // Set Focus Node
                      focusNode: textFieldFocusNode,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: 20),
                        border: InputBorder.none,
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.black),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              clearSearch();
                              // Unfocus all focus nodes
                              textFieldFocusNode.unfocus();

                              // Disable text field's focus node request
                              textFieldFocusNode.canRequestFocus = false;

                              //Enable the text field's focus node request after some delay
                              Future.delayed(Duration(milliseconds: 10), () {
                                textFieldFocusNode.canRequestFocus = true;
                              });
                            },
                            child: IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                ))),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Sign In Button
                      new FlatButton(
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
                                "People",
                                gradient: LinearGradient(colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade900,
                                ]),
                              )
                            : Text(
                                "People",
                                style: TextStyle(fontSize: 16.5),
                              ),
                      ),
                      // Sign Up Button

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
                                gradient: LinearGradient(colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade900,
                                ]),
                              )
                            : Text(
                                "Friend Groups",
                                style: TextStyle(fontSize: 16.5),
                              ),
                      )
                    ],
                  ),
                ])),
          ),
          backgroundColor: Colors.white,
          body: _searchTerm == null
              ? SingleChildScrollView(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.pink[300], Colors.pink[200]],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: isLargePhone
                                      ? const EdgeInsets.only(bottom: 50)
                                      : const EdgeInsets.only(bottom: 20),
                                  child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          style: TextThemes.mediumbody,
                                          children: [
                                            TextSpan(
                                                text: "Invite them,",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                            TextSpan(
                                                text: " now",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            TextSpan(
                                                text: ".",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w300))
                                          ]))),
                              Padding(
                                  padding: EdgeInsets.only(bottom: 250),
                                  child: Image.asset('lib/assets/ff.png'))
                            ],
                          ),
                        ),
                      )),
                )
              : StreamBuilder<List<AlgoliaObjectSnapshot>>(
                  stream: Stream.fromFuture(_operation0(_searchTerm)),
                  builder: (context, snapshot0) {
                    List<AlgoliaObjectSnapshot> currSearchStuff0 =
                        snapshot0.data;
                    if (currSearchStuff0 == null) {
                      return linearProgress();
                    }
                    return Container(
                        child: StreamBuilder<List<AlgoliaObjectSnapshot>>(
                            stream: Stream.fromFuture(_operation(_searchTerm)),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Container();
                                default:
                                  if (snapshot.hasError || !snapshot.hasData)
                                    return linearProgress();
                                  else {
                                    List<AlgoliaObjectSnapshot>
                                        currSearchStuff = snapshot.data;

                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.90,
                                      child: TabBarView(
                                          controller: _tabController,
                                          children: [
                                            CustomScrollView(
                                              shrinkWrap: true,
                                              slivers: <Widget>[
                                                SliverList(
                                                  delegate:
                                                      SliverChildBuilderDelegate(
                                                    (context, index) {
                                                      return _searchTerm != null
                                                          ? UserPostResult(
                                                              currSearchStuff[
                                                                          index]
                                                                      .data[
                                                                  "displayName"],
                                                              currSearchStuff[
                                                                          index]
                                                                      .data[
                                                                  "email"],
                                                              currSearchStuff[
                                                                          index]
                                                                      .data[
                                                                  "photoUrl"],
                                                              currSearchStuff[
                                                                      index]
                                                                  .data["id"],
                                                              currSearchStuff[
                                                                          index]
                                                                      .data[
                                                                  "verifiedStatus"],
                                                              invitees,
                                                            )
                                                          : Container();
                                                    },
                                                    childCount: currSearchStuff
                                                            .length ??
                                                        0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            CustomScrollView(
                                              shrinkWrap: true,
                                              slivers: <Widget>[
                                                SliverList(
                                                  delegate:
                                                      SliverChildBuilderDelegate(
                                                    (context, index) {
                                                      return _searchTerm
                                                                      .length !=
                                                                  null &&
                                                              _searchTerm
                                                                      .length >
                                                                  0
                                                          ? InviteGroup(
                                                              currSearchStuff0[
                                                                          index]
                                                                      .data[
                                                                  "groupName"],
                                                              currSearchStuff0[
                                                                          index]
                                                                      .data[
                                                                  "groupId"],
                                                              currSearchStuff0[
                                                                          index]
                                                                      .data[
                                                                  "groupPic"],
                                                              currSearchStuff0[
                                                                          index]
                                                                      .data[
                                                                  "nextMOOV"],
                                                              currSearchStuff0[
                                                                          index]
                                                                      .data[
                                                                  "members"],
                                                              invitees,
                                                              currSearchStuff0[
                                                                          index]
                                                                      .data[
                                                                  "memberNames"])
                                                          : Container();
                                                    },
                                                    childCount: currSearchStuff0
                                                            .length ??
                                                        0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ]),
                                    );
                                  }
                              }
                            }));
                  })),
    );
  }
}

class AddUsersFromCreateGroup extends StatefulWidget {
  List<String> invitees;
  AddUsersFromCreateGroup(
    this.invitees,
  );

  @override
  _AddUsersFromCreateGroupState createState() =>
      _AddUsersFromCreateGroupState(this.invitees);
}

class _AddUsersFromCreateGroupState extends State<AddUsersFromCreateGroup>
    with SingleTickerProviderStateMixin {
  // TabController to control and switch tabs
  TabController _tabController;
  int _currentIndex = 0;
  Map<int, Widget> map =
      new Map(); // Cupertino Segmented Control takes children in form of Map.
  List<Widget>
      childWidgets; //The Widgets that has to be loaded when a tab is selected.
  int selectedIndex = 0;

  Widget getChildWidget() => childWidgets[selectedIndex];

  List<String> invitees;
  _AddUsersFromCreateGroupState(this.invitees);

  final TextEditingController searchController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("users").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  clearSearch() {
    searchController.clear();

    setState(() {
      _searchTerm = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        new TabController(vsync: this, length: 1, initialIndex: _currentIndex);
    _tabController.animation
      ..addListener(() {
        setState(() {
          _currentIndex = (_tabController.animation.value).round();
        });
      });

    // Simple declarations
    TextEditingController searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          iconSize: 35,
          icon: Icon(
            Icons.arrow_drop_down_outlined,
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
      body: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 96,
            bottom: PreferredSize(
                preferredSize: null,
                child: Column(children: <Widget>[
                  TextField(
                      style: TextStyle(fontSize: 20),
                      controller: searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchTerm = val;
                        });
                      },
                      // Set Focus Node
                      focusNode: textFieldFocusNode,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: 20),
                        border: InputBorder.none,
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.black),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              clearSearch();
                              // Unfocus all focus nodes
                              textFieldFocusNode.unfocus();

                              // Disable text field's focus node request
                              textFieldFocusNode.canRequestFocus = false;

                              //Enable the text field's focus node request after some delay
                              Future.delayed(Duration(milliseconds: 10), () {
                                textFieldFocusNode.canRequestFocus = true;
                              });
                            },
                            child: IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                ))),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Sign In Button
                      new FlatButton(
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
                          child: GradientText(
                            'People',
                            gradient: LinearGradient(colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade900,
                            ]),
                          )),
                      // Sign Up Button
                    ],
                  ),
                ])),
          ),
          backgroundColor: Colors.white,
          body: _searchTerm == null
              ? SingleChildScrollView(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.pink[300], Colors.pink[200]],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 50),
                                  child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          style: TextThemes.mediumbody,
                                          children: [
                                            TextSpan(
                                                text: "Invite the squad,",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                            TextSpan(
                                                text: " now",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            TextSpan(
                                                text: ".",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w300))
                                          ]))),
                              Padding(
                                  padding: EdgeInsets.only(bottom: 250),
                                  child: Image.asset('lib/assets/ff.png'))
                            ],
                          ),
                        ),
                      )),
                )
              : StreamBuilder<List<AlgoliaObjectSnapshot>>(
                  stream: Stream.fromFuture(_operation(_searchTerm)),
                  builder: (context, snapshot0) {
                    return Container(
                        child: StreamBuilder<List<AlgoliaObjectSnapshot>>(
                            stream: Stream.fromFuture(_operation(_searchTerm)),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Container();
                                default:
                                  if (snapshot.hasError || !snapshot.hasData)
                                    return linearProgress();
                                  else {
                                    List<AlgoliaObjectSnapshot>
                                        currSearchStuff = snapshot.data;

                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.90,
                                      child: TabBarView(
                                          controller: _tabController,
                                          children: [
                                            CustomScrollView(
                                              shrinkWrap: true,
                                              slivers: <Widget>[
                                                SliverList(
                                                  delegate:
                                                      SliverChildBuilderDelegate(
                                                    (context, index) {
                                                      return _searchTerm != null
                                                          ? UserPostResult(
                                                              currSearchStuff[
                                                                          index]
                                                                      .data[
                                                                  "displayName"],
                                                              currSearchStuff[
                                                                          index]
                                                                      .data[
                                                                  "email"],
                                                              currSearchStuff[
                                                                          index]
                                                                      .data[
                                                                  "photoUrl"],
                                                              currSearchStuff[
                                                                      index]
                                                                  .data["id"],
                                                              currSearchStuff[
                                                                          index]
                                                                      .data[
                                                                  "verifiedStatus"],
                                                              invitees)
                                                          : Container();
                                                    },
                                                    childCount: currSearchStuff
                                                            .length ??
                                                        0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ]),
                                    );
                                  }
                              }
                            }));
                  })),
    );
  }
}

class UserPostResult extends StatefulWidget {
  final String displayName;
  final String email;
  final String proPic;
  final String userId;
  final int verifiedStatus;
  List<String> invitees;

  UserPostResult(this.displayName, this.email, this.proPic, this.userId,
      this.verifiedStatus, this.invitees);

  @override
  _UserPostResultState createState() => _UserPostResultState(this.displayName,
      this.email, this.proPic, this.userId, this.verifiedStatus, this.invitees);
}

class _UserPostResultState extends State<UserPostResult> {
  String displayName;
  String email;
  String proPic;
  String userId;
  int verifiedStatus;
  List<String> invitees;

  bool status = false;

  _UserPostResultState(this.displayName, this.email, this.proPic, this.userId,
      this.verifiedStatus, this.invitees);

  @override
  Widget build(BuildContext context) {
    invitees.contains(userId) ? status = true : false;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => userId != currentUser.id
              ? OtherProfile(userId)
              : ProfilePageWithHeader())),
      child: Stack(children: [
        Row(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 5, bottom: 5),
            child: CircleAvatar(
                radius: 27,
                backgroundColor: TextThemes.ndGold,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(proPic),
                  radius: 25,
                  backgroundColor: TextThemes.ndBlue,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.5),
            child: Text(
              displayName ?? "",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 20),
            ),
          ),
          verifiedStatus == 3
              ? Padding(
                  padding: EdgeInsets.only(
                    left: 2.5,
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
                        left: 5,
                      ),
                      child: Image.asset('lib/assets/verif2.png', height: 20),
                    )
                  : verifiedStatus == 1
                      ? Padding(
                          padding: EdgeInsets.only(left: 2.5, top: 2.5),
                          child:
                              Image.asset('lib/assets/verif.png', height: 30),
                        )
                      : Text(""),
          // Text(
          //   email ?? "",
          //   style: TextStyle(color: Colors.black),
          // ),
          Divider(
            color: Colors.black,
          ),
        ]),
        userId == currentUser.id
            ? Container()
            : status
                ? Positioned(
                    right: 20,
                    top: 10,
                    child: RaisedButton(
                        padding: const EdgeInsets.all(2.0),
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(3.0))),
                        onPressed: () {
                          invitees.remove(userId);

                          setState(() {
                            status = false;
                          });
                        },
                        child: Text(
                          "Added",
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        )),
                  )
                : Positioned(
                    right: 20,
                    top: 10,
                    child: RaisedButton(
                        padding: const EdgeInsets.all(2.0),
                        color: TextThemes.ndBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(3.0))),
                        onPressed: () {
                          invitees.add(userId);
                          setState(() {
                            status = true;
                          });
                        },
                        child: Text(
                          "Add",
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        )),
                  ),
      ]),
    );
  }
}

class SearchUsersGroup extends StatefulWidget {
  String gname, gid, pic, moov;
  List<dynamic> members;
  SearchUsersGroup(this.gname, this.gid, this.pic, this.moov, this.members);

  @override
  _SearchUsersGroupState createState() => _SearchUsersGroupState(
      this.gname, this.gid, this.pic, this.moov, this.members);
}

class _SearchUsersGroupState extends State<SearchUsersGroup> {
  String gname, gid, pic, moov;
  List<dynamic> members;
  _SearchUsersGroupState(
      this.gname, this.gid, this.pic, this.moov, this.members);

  final TextEditingController searchController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("users").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  clearSearch() {
    searchController.clear();

    setState(() {
      _searchTerm = null;
    });
  }

  @override
  void initState() {
    super.initState();

    // Simple declarations
    TextEditingController searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_drop_down_outlined,
                color: Colors.white, size: 35),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: TextThemes.ndBlue,
        //pinned: true,

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
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          TextField(
              style: TextStyle(fontSize: 20),
              controller: searchController,
              onChanged: (val) {
                setState(() {
                  _searchTerm = val;
                });
              },
              // Set Focus Node
              decoration: InputDecoration(
                labelStyle: TextStyle(fontSize: 20),
                border: InputBorder.none,
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                suffixIcon: GestureDetector(
                    onTap: () {
                      clearSearch();
                      // Unfocus all focus nodes

                      // Disable text field's focus node request

                      //Enable the text field's focus node request after some delay
                    },
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.clear,
                          color: Colors.black,
                        ))),
              )),
          StreamBuilder<List<AlgoliaObjectSnapshot>>(
              stream: Stream.fromFuture(_operation(_searchTerm)),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data.length == 0 ||
                    _searchTerm == null)
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.pink[300], Colors.pink[200]],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(50.0),
                                  child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          style: TextThemes.mediumbody,
                                          children: [
                                            TextSpan(
                                                text: "Squad",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                            TextSpan(
                                                text: " up",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            TextSpan(
                                                text: ".",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w300))
                                          ]))),
                              Image.asset('lib/assets/ff.png')
                            ],
                          ),
                        ),
                      ));
                List<AlgoliaObjectSnapshot> currSearchStuff = snapshot.data;

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Container();
                  default:
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    else
                      return CustomScrollView(
                        shrinkWrap: true,
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return _searchTerm.length > 0
                                    ? UserGroupResultAdd(
                                        currSearchStuff[index]
                                            .data["displayName"],
                                        currSearchStuff[index].data["email"],
                                        currSearchStuff[index].data["photoUrl"],
                                        currSearchStuff[index].data["id"],
                                        currSearchStuff[index]
                                            .data["verifiedStatus"],
                                        currSearchStuff[index]
                                            .data["friendGroups"],
                                        gname,
                                        gid,
                                        pic,
                                        moov,
                                        members)
                                    : Container();
                              },
                              childCount: currSearchStuff.length ?? 0,
                            ),
                          ),
                        ],
                      );
                }
              }),
        ]),
      ),
    );
  }
}

class UserGroupResultAdd extends StatefulWidget {
  final String displayName;
  final String email;
  final String proPic;
  final String userId;
  final int verifiedStatus;
  final List<dynamic> friendGroups;
  String gname, gid, pic, moov;
  List<dynamic> members;

  UserGroupResultAdd(
      this.displayName,
      this.email,
      this.proPic,
      this.userId,
      this.verifiedStatus,
      this.friendGroups,
      this.gname,
      this.gid,
      this.pic,
      this.moov,
      this.members);

  @override
  _UserGroupResultAddState createState() => _UserGroupResultAddState(
      this.displayName,
      this.email,
      this.proPic,
      this.userId,
      this.verifiedStatus,
      this.friendGroups,
      this.gname,
      this.gid,
      this.pic,
      this.moov,
      this.members);
}

class _UserGroupResultAddState extends State<UserGroupResultAdd> {
  String displayName;
  String email;
  String proPic;
  String userId;
  int verifiedStatus;
  String gname, gid, pic, moov;
  List<dynamic> members, friendGroups;
  bool status = false;

  _UserGroupResultAddState(
      this.displayName,
      this.email,
      this.proPic,
      this.userId,
      this.verifiedStatus,
      this.friendGroups,
      this.gname,
      this.gid,
      this.pic,
      this.moov,
      this.members);

  @override
  Widget build(BuildContext context) {
    friendGroups.contains(gid) ? status = true : false;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => userId != currentUser.id
              ? OtherProfile(userId)
              : ProfilePageWithHeader())),
      child: Stack(children: [
        Row(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 5, bottom: 5),
            child: CircleAvatar(
                radius: 27,
                backgroundColor: TextThemes.ndGold,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(proPic),
                  radius: 25,
                  backgroundColor: TextThemes.ndBlue,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.5),
            child: Text(
              displayName ?? "",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 20),
            ),
          ),
          verifiedStatus == 2
              ? Padding(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  child: Image.asset('lib/assets/verif.png', height: 30),
                )
              : Text(""),
          // Text(
          //   email ?? "",
          //   style: TextStyle(color: Colors.black),
          // ),
          Divider(
            color: Colors.black,
          ),
        ]),
        status
            ? Positioned(
                right: 20,
                top: 10,
                child: RaisedButton(
                    padding: const EdgeInsets.all(2.0),
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3.0))),
                    onPressed: () {
                      setState(() {
                        status = true;
                      });
                    },
                    child: Text(
                      "Added",
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    )))
            : Positioned(
                right: 20,
                top: 10,
                child: RaisedButton(
                    padding: const EdgeInsets.all(2.0),
                    color: TextThemes.ndBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3.0))),
                    onPressed: () {
                      Database().addUser(userId, gname, gid, displayName);
                      Database().addedToGroup(userId, gname, gid, pic);
                      setState(() {
                        status = true;
                      });
                    },
                    child: Text(
                      "Add to Group",
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    )),
              ),
      ]),
    );
  }
}

class InviteGroup extends StatefulWidget {
  String gname, gid, pic, moov;
  List<dynamic> members;
  List<String> invitees;
  List<dynamic> memberNames;

  InviteGroup(this.gname, this.gid, this.pic, this.moov, this.members,
      this.invitees, this.memberNames);

  @override
  _InviteGroupState createState() => _InviteGroupState(this.gname, this.gid,
      this.pic, this.moov, this.members, this.invitees, this.memberNames);
}

class _InviteGroupState extends State<InviteGroup> {
  String gname, gid, pic, moov;
  List members, friendGroups;
  bool status = false;
  List<String> invitees;
  List<dynamic> memberNames;

  _InviteGroupState(this.gname, this.gid, this.pic, this.moov, this.members,
      this.invitees, this.memberNames);

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    invitees.contains(gid) ? status = true : false;
    for (int i = 0; i < members.length; i++) {
      return StreamBuilder(
          stream:
              usersRef.where('friendGroups', arrayContains: gid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            if (snapshot.data.docs == null) return Container();
            var length = members.length - 2;
            var course = snapshot.data.docs;

            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => members.contains(currentUser.id)
                        ? GroupDetail(gid)
                        : OtherGroup(gid))),
                child: Stack(alignment: Alignment.center, children: <Widget>[
                  SizedBox(
                    width: isLargePhone
                        ? MediaQuery.of(context).size.width * 0.8
                        : MediaQuery.of(context).size.width * 0.8,
                    height: isLargePhone
                        ? MediaQuery.of(context).size.height * 0.15
                        : MediaQuery.of(context).size.height * 0.17,
                    child: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: pic,
                          fit: BoxFit.cover,
                        ),
                      ),
                      margin: EdgeInsets.only(
                          left: 10, top: 0, right: 10, bottom: 0),
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
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
                      padding: const EdgeInsets.all(4.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * .3),
                        child: Text(
                          gname,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Solway',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: isLargePhone ? 17.0 : 14),
                        ),
                      ),
                    ),
                  ),
                  // isToday == false
                  //     ? Positioned(
                  //         top: 0,
                  //         right: 0,
                  //         child: Container(
                  //           height: 30,
                  //           padding: EdgeInsets.all(4),
                  //           decoration: BoxDecoration(
                  //               gradient: LinearGradient(
                  //                 colors: [Colors.pink[400], Colors.purple[300]],
                  //                 begin: Alignment.centerLeft,
                  //                 end: Alignment.centerRight,
                  //               ),
                  //               borderRadius: BorderRadius.circular(10.0)),
                  //           child: isNextWeek ? Text("") : Text(""),
                  //         ),
                  //       )
                  //     : Container(),
                  // isToday == true
                  //     ? Positioned(
                  //         top: 0,
                  //         right: 0,
                  //         child: Container(
                  //           height: 30,
                  //           padding: EdgeInsets.all(4),
                  //           decoration: BoxDecoration(
                  //               gradient: LinearGradient(
                  //                 colors: [Colors.red[400], Colors.red[600]],
                  //                 begin: Alignment.centerLeft,
                  //                 end: Alignment.centerRight,
                  //               ),
                  //               borderRadius: BorderRadius.circular(10.0)),
                  //           child: Text(""),
                  //         ),
                  //       )
                  //     : Text(""),

                  Positioned(
                    bottom: isLargePhone ? 0 : 0,
                    right: 55,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(children: [
                          Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: members.length > 1
                                  ? CircleAvatar(
                                      radius: isLargePhone ? 25 : 15.0,
                                      backgroundImage: NetworkImage(
                                        course[1]['photoUrl'],
                                      ),
                                    )
                                  : Container()),
                          Padding(
                              padding:
                                  const EdgeInsets.only(top: 4, left: 25.0),
                              child: CircleAvatar(
                                radius: isLargePhone ? 25 : 15.0,
                                backgroundImage: NetworkImage(
                                  course[0]['photoUrl'],
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 50.0),
                            child: CircleAvatar(
                              radius: isLargePhone ? 25 : 15.0,
                              child: members.length > 2
                                  ? Text(
                                      "+" + (length.toString()),
                                      style: TextStyle(
                                          color: TextThemes.ndGold,
                                          fontWeight: FontWeight.w500),
                                    )
                                  : Text(
                                      (members.length.toString()),
                                      style: TextStyle(
                                          color: TextThemes.ndGold,
                                          fontWeight: FontWeight.w500),
                                    ),
                              backgroundColor: TextThemes.ndBlue,
                            ),
                          ),
                        ])
                      ],
                    ),
                  ),
                  status
                      ? Positioned(
                          bottom: 2.5,
                          child: RaisedButton(
                              padding: const EdgeInsets.all(2.0),
                              color: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.0))),
                              onPressed: () {
                                invitees.remove(gid);
                                setState(() {
                                  status = false;
                                });
                              },
                              child: Text(
                                "Added",
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              )),
                        )
                      : Positioned(
                          bottom: 2.5,
                          child: RaisedButton(
                              padding: const EdgeInsets.all(2.0),
                              color: TextThemes.ndBlue,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3.0))),
                              onPressed: () {
                                invitees.add(gid);
                                setState(() {
                                  status = true;
                                });
                              },
                              child: Text(
                                "Add",
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              )),
                        ),
                ]),
              ),
            );
          });
    }
    return Container();
  }
}

class SearchUsersMessage extends StatefulWidget {
  @override
  _SearchUsersMessageState createState() => _SearchUsersMessageState();
}

class _SearchUsersMessageState extends State<SearchUsersMessage> {
  _SearchUsersMessageState();

  final TextEditingController searchController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("users").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  clearSearch() {
    searchController.clear();

    setState(() {
      _searchTerm = null;
    });
  }

  @override
  void initState() {
    super.initState();

    // Simple declarations
    TextEditingController searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_drop_down_outlined,
                color: Colors.white, size: 35),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: TextThemes.ndBlue,
        //pinned: true,

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
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          TextField(
              style: TextStyle(fontSize: 20),
              controller: searchController,
              onChanged: (val) {
                setState(() {
                  _searchTerm = val;
                });
              },
              // Set Focus Node
              decoration: InputDecoration(
                labelStyle: TextStyle(fontSize: 20),
                border: InputBorder.none,
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                suffixIcon: GestureDetector(
                    onTap: () {
                      clearSearch();
                      // Unfocus all focus nodes

                      // Disable text field's focus node request

                      //Enable the text field's focus node request after some delay
                    },
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.clear,
                          color: Colors.black,
                        ))),
              )),
          StreamBuilder<List<AlgoliaObjectSnapshot>>(
              stream: Stream.fromFuture(_operation(_searchTerm)),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data.length == 0 ||
                    _searchTerm == null)
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.pink[300], Colors.pink[200]],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(50.0),
                                  child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          style: TextThemes.mediumbody,
                                          children: [
                                            TextSpan(
                                                text: "Slide",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                            TextSpan(
                                                text: " in",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            TextSpan(
                                                text: ".",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.w300))
                                          ]))),
                              Image.asset('lib/assets/ff.png')
                            ],
                          ),
                        ),
                      ));
                List<AlgoliaObjectSnapshot> currSearchStuff = snapshot.data;

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Container();
                  default:
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    else
                      return CustomScrollView(
                        shrinkWrap: true,
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return _searchTerm.length > 0
                                    ? MessageResultAdd(
                                        currSearchStuff[index]
                                            .data["displayName"],
                                        currSearchStuff[index].data["email"],
                                        currSearchStuff[index].data["photoUrl"],
                                        currSearchStuff[index].data["id"],
                                        currSearchStuff[index]
                                            .data["verifiedStatus"],
                                      )
                                    : Container();
                              },
                              childCount: currSearchStuff.length ?? 0,
                            ),
                          ),
                        ],
                      );
                }
              }),
        ]),
      ),
    );
  }
}

class MessageResultAdd extends StatefulWidget {
  final String displayName;
  final String email;
  final String proPic;
  final String userId;
  final int verifiedStatus;

  MessageResultAdd(
    this.displayName,
    this.email,
    this.proPic,
    this.userId,
    this.verifiedStatus,
  );

  @override
  _MessageResultAddState createState() => _MessageResultAddState(
        this.displayName,
        this.email,
        this.proPic,
        this.userId,
        this.verifiedStatus,
      );
}

class _MessageResultAddState extends State<MessageResultAdd> {
  String displayName;
  String email;
  String proPic;
  String userId;
  int verifiedStatus;

  _MessageResultAddState(
    this.displayName,
    this.email,
    this.proPic,
    this.userId,
    this.verifiedStatus,
  );
  String directMessageId;

  Future dmChecker() async {
    messagesRef.doc(userId + currentUser.id).get().then((doc) async {
      messagesRef.doc(currentUser.id + userId).get().then((doc2) async {
        if (!doc2.exists && !doc.exists) {
          directMessageId = "nothing";
        } else if (!doc2.exists) {
          directMessageId = doc['directMessageId'];
        } else if (!doc.exists) {
          directMessageId = doc2['directMessageId'];
        }
        print(directMessageId);
      });
    });
  }

  void toMessageDetail() {
    Timer(Duration(milliseconds: 200), () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessageDetail(directMessageId, userId, false, " ")));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => userId != currentUser.id
              ? OtherProfile(userId)
              : ProfilePageWithHeader())),
      child: Stack(children: [
        Row(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 5, bottom: 5),
            child: CircleAvatar(
                radius: 27,
                backgroundColor: TextThemes.ndGold,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(proPic),
                  radius: 25,
                  backgroundColor: TextThemes.ndBlue,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.5),
            child: Text(
              displayName ?? "",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 17),
            ),
          ),
          verifiedStatus == 2
              ? Padding(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  child: Image.asset('lib/assets/verif.png', height: 30),
                )
              : Text(""),
          // Text(
          //   email ?? "",
          //   style: TextStyle(color: Colors.black),
          // ),
          Divider(
            color: Colors.black,
          ),
        ]),
        Positioned(
          right: 20,
          top: 10,
          child: currentUser.id == userId
              ? Container()
              : RaisedButton(
                  padding: const EdgeInsets.all(2.0),
                  color: TextThemes.ndBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(3.0))),
                  onPressed: () {
                    dmChecker().then((value) => toMessageDetail());
                  },
                  child: Text(
                    "Chat",
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  )),
        ),
      ]),
    );
  }
}
