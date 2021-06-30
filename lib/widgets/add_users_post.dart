import 'dart:async';
import 'package:MOOV/businessInterfaces/MobileOrdering.dart';
import 'package:MOOV/businessInterfaces/livePassesSheet.dart';
import 'package:MOOV/friendGroups/OtherGroup.dart';
import 'package:MOOV/friendGroups/group_detail.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/MessagesHub.dart';
import 'package:MOOV/pages/NewSearch.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:algolia/algolia.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../pages/ProfilePageWithHeader.dart';
import '../pages/other_profile.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class SearchUsersPost extends StatefulWidget {
  final List<String> invitees;
  SearchUsersPost({this.invitees});

  @override
  _SearchUsersPostState createState() => _SearchUsersPostState();
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
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent),
                        ),
                        onPressed: () {
                          _tabController.animateTo(0);
                          setState(() {
                            _currentIndex = 0;
                          });
                        },
                        child: _currentIndex == 0
                            ? GradientText(
                                "People",
                                16.5,
                                gradient: LinearGradient(colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade900,
                                ]),
                              )
                            : Text(
                                "People",
                                style: TextStyle(
                                    fontSize: 16.5, color: Colors.black),
                              ),
                      ),
                      SizedBox(width: 15),
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateColor.resolveWith(
                              (states) => Colors.transparent),
                        ),
                        onPressed: () {
                          _tabController.animateTo(1);
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                        child: _currentIndex == 1
                            ? GradientText(
                                "Friend Groups",
                                16.5,
                                gradient: LinearGradient(colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade900,
                                ]),
                              )
                            : Text(
                                "Friend Groups",
                                style: TextStyle(
                                    fontSize: 16.5, color: Colors.black),
                              ),
                      )
                    ],
                  ),
                ])),
          ),
          backgroundColor: Colors.white,
          body: _searchTerm == null
              ? CustomScrollView(
                  shrinkWrap: true,
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return (_currentIndex == 0)
                              ? FutureBuilder(
                                  future: usersRef
                                      .doc(currentUser.friendArray[index])
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        currentUser.friendArray.isEmpty) {
                                      return Container();
                                    }
                                    if (snapshot.connectionState !=
                                        ConnectionState.done) {
                                      return Container();
                                    }
                                    return UserPostResult(
                                      snapshot.data["displayName"],
                                      snapshot.data["email"],
                                      snapshot.data["photoUrl"],
                                      snapshot.data["id"],
                                      snapshot.data["verifiedStatus"],
                                      widget.invitees,
                                    );
                                  })
                              : FutureBuilder(
                                  future: groupsRef
                                      .doc(currentUser.friendGroups[index])
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        currentUser.friendGroups.isEmpty) {
                                      return Container();
                                    }
                                    if (snapshot.connectionState !=
                                        ConnectionState.done) {
                                      return Container();
                                    }
                                    return InviteGroup(
                                        snapshot.data["groupName"],
                                        snapshot.data["groupId"],
                                        snapshot.data["groupPic"],
                                        snapshot.data["nextMOOV"],
                                        snapshot.data["members"],
                                        widget.invitees,
                                        snapshot.data["memberNames"]);
                                  });
                        },
                        childCount: _currentIndex == 0
                            ? currentUser.friendArray.length
                            : currentUser.friendGroups.length ?? 0,
                      ),
                    ),
                  ],
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
                                                              widget.invitees,
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
                                                              widget.invitees,
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
  final List<String> invitees;
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
                            16.5,
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
              ? FutureBuilder(
                  future: usersRef.get(),
                  builder: (context, snapshot0) {
                    if (!snapshot0.hasData) {
                      return Container();
                    }
                    return CustomScrollView(
                      shrinkWrap: true,
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return UserPostResult(
                                  snapshot0.data.docs[index]["displayName"],
                                  snapshot0.data.docs[index]["email"],
                                  snapshot0.data.docs[index]["photoUrl"],
                                  snapshot0.data.docs[index]["id"],
                                  snapshot0.data.docs[index]["verifiedStatus"],
                                  invitees);
                            },
                            childCount: snapshot0.data.docs.length ?? 0,
                          ),
                        ),
                      ],
                    );
                  })
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
  final List<String> invitees;

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
    bool isLargePhone = Screen.diagonal(context) > 766;

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
                  fontSize: isLargePhone ? 20 : 16),
            ),
          ),
          verifiedStatus == 3
              ? Padding(
                  padding: EdgeInsets.only(
                    left: 2.5,
                  ),
                  child: Icon(Icons.store, size: 25, color: Colors.blue),
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
                          HapticFeedback.lightImpact();

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
  final String gname, gid, pic, moov;
  final List<dynamic> members;
  final Map livePass; // for gifting a livepass
  SearchUsersGroup(
      {this.gname, this.gid, this.pic, this.moov, this.members, this.livePass});

  @override
  _SearchUsersGroupState createState() => _SearchUsersGroupState();
}

class _SearchUsersGroupState extends State<SearchUsersGroup> {
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
      body: ListView(children: <Widget>[
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
              if (_searchTerm == null) {
                return FutureBuilder(
                    future: usersRef.get(),
                    builder: (context, snapshot0) {
                      if (!snapshot0.hasData) {
                        return Container();
                      }

                      return CustomScrollView(
                        shrinkWrap: true,
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return UserGroupResultAdd(
                                    snapshot0.data.docs[index]["displayName"],
                                    snapshot0.data.docs[index]["email"],
                                    snapshot0.data.docs[index]["photoUrl"],
                                    snapshot0.data.docs[index]["id"],
                                    snapshot0.data.docs[index]
                                        ["verifiedStatus"],
                                    snapshot0.data.docs[index]["friendGroups"],
                                    widget.gname,
                                    widget.gid,
                                    widget.pic,
                                    widget.moov,
                                    widget.members,
                                    widget.livePass);
                              },
                              childCount: snapshot0.data.docs.length ?? 0,
                            ),
                          ),
                        ],
                      );
                    });
              }
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
                                      widget.gname,
                                      widget.gid,
                                      widget.pic,
                                      widget.moov,
                                      widget.members,
                                      widget.livePass)
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
  final String gname, gid, pic, moov;
  final List<dynamic> members;
  final Map livePass;

  UserGroupResultAdd(
      this.displayName,
      this.email,
      this.proPic,
      this.userId, //
      this.verifiedStatus,
      this.friendGroups,
      this.gname,
      this.gid,
      this.pic,
      this.moov,
      this.members,
      this.livePass);

  @override
  _UserGroupResultAddState createState() => _UserGroupResultAddState();
}

class _UserGroupResultAddState extends State<UserGroupResultAdd> {
  bool status = false;

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    if (widget.friendGroups.contains(widget.gid)) {
      status = true;
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => widget.userId != currentUser.id
              ? OtherProfile(widget.userId)
              : ProfilePageWithHeader())),
      child: Stack(children: [
        Row(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 5, bottom: 5),
            child: CircleAvatar(
                radius: 27,
                backgroundColor: TextThemes.ndGold,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.proPic),
                  radius: 25,
                  backgroundColor: TextThemes.ndBlue,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.5),
            child: Text(
              widget.displayName ?? "",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: isLargePhone ? 20 : 16),
            ),
          ),
          widget.verifiedStatus == 2
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
        widget.livePass != null
            ? Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                      onPressed: () {
                        //  isLoading = true;
                        showBottomSheet(
                            backgroundColor: Colors.pink[100],
                            context: context,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            builder: (context) => GiftBottomSheet(
                                widget.livePass, widget.userId));
                      },
                      //  else {
                      //   usersRef
                      //                   .doc(currentUser.id)
                      //                   .collection('livePasses')
                      //                   .doc(passId)
                      //                   .set({
                      //                 "type": "MOOV Over Pass",
                      //                 "name": "MOOV Over Pass",
                      //                 "startDate": widget.startDate,
                      //                 "businessName": widget.businessName,
                      //                 "price": 10,
                      //                 "photo": "widget.photo",
                      //                 "time": Timestamp.now(),
                      //                 "businessId": widget.businessUserId,
                      //                 "postId": widget.postId,
                      //                 "passId": passId,
                      //                 "tip": 0
                      //               }, SetOptions(merge: true)).

                      //   usersRef.doc(currentUser.id).set({
                      //     "moovMoney": FieldValue.increment(-1 * _tipAmount)
                      //   }, SetOptions(merge: true));

                      //   usersRef.doc(widget.userId).collection('livePasses') set(
                      //       {"moovMoney": FieldValue.increment(_tipAmount)},
                      //       SetOptions(merge: true));

                      //   setState(() {
                      //     isChecking = true;
                      //   });
                      //   Future.delayed(Duration(seconds: 2), () {
                      //     Navigator.pushAndRemoveUntil(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => Home()),
                      //       (Route<dynamic> route) => false,
                      //     );
                      //   });
                      // }
                      style: TextButton.styleFrom(
                          side: BorderSide(color: Colors.green)),
                      child: Text(
                        "Gift",
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      )),
                ),
              )
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(3.0))),
                        onPressed: () {
                          Database().addUserToGroup(widget.userId, widget.gname,
                              widget.gid, widget.displayName);
                          Database().addedToGroup(widget.userId, widget.gname,
                              widget.gid, widget.pic);
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
  final String gname, gid, pic, moov;
  final List<dynamic> members;
  final List<String> invitees;
  final List<dynamic> memberNames;

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
    if (invitees.contains(gid)) {
      status = true;
    }
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
                                HapticFeedback.lightImpact();

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
  bool needAppBar;
  SearchUsersMessage(this.needAppBar);

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
      appBar: widget.needAppBar
          ? AppBar(
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
            )
          : null,
      backgroundColor: Colors.white,
      body: ListView(children: <Widget>[
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
              if (!snapshot.hasData || _searchTerm == null)
                return FutureBuilder(
                    future: usersRef.get(),
                    builder: (context, snapshot2) {
                      if (!snapshot2.hasData) {
                        return Container();
                      }
                      return CustomScrollView(
                        shrinkWrap: true,
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return MessageResultAdd(
                                  snapshot2.data.docs[index]["displayName"],
                                  snapshot2.data.docs[index]["email"],
                                  snapshot2.data.docs[index]["photoUrl"],
                                  snapshot2.data.docs[index]["id"],
                                  snapshot2.data.docs[index]["verifiedStatus"],
                                );
                              },
                              childCount: 30,
                            ),
                          ),
                        ],
                      );
                    });
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
              builder: (context) => MessageDetail(
                  directMessageId: directMessageId,
                  otherPerson: userId,
                  members: [],
                  sendingPost: {})));
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
