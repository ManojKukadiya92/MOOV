import 'dart:async';

import 'package:MOOV/main.dart';
import 'package:MOOV/pages/MessagesHub.dart';
import 'package:MOOV/pages/NewSearch.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import '../pages/ProfilePageWithHeader.dart';
import '../pages/other_profile.dart';

class SendMOOVSearch extends StatefulWidget {
  final String ownerId, previewImg;
  final dynamic startDate, moovId;
  final String title, ownerName;
  SendMOOVSearch(
    this.ownerId,
    this.previewImg,
    this.startDate,
    this.moovId,
    this.title,
    this.ownerName,
  );

  @override
  _SendMOOVSearchState createState() => _SendMOOVSearchState(
        this.ownerId,
        this.previewImg,
        this.startDate,
        this.moovId,
        this.title,
        this.ownerName,
      );
}

class _SendMOOVSearchState extends State<SendMOOVSearch>
    with SingleTickerProviderStateMixin {
  String ownerId, previewImg;
  TabController _tabController;
  int _currentIndex = 0;

  dynamic startDate, moovId;
  String title, ownerName;
  _SendMOOVSearchState(this.ownerId, this.previewImg, this.startDate,
      this.moovId, this.title, this.ownerName);

  final TextEditingController searchController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _operation1(String input) async {
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
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
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
                              16.5,
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
                              16.5,
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
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
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
                                    return SendMOOVResult(
                                      snapshot2.data.docs[index]["displayName"],
                                      snapshot2.data.docs[index]["email"],
                                      snapshot2.data.docs[index]["photoUrl"],
                                      snapshot2.data.docs[index]["id"],
                                      snapshot2.data.docs[index]
                                          ["verifiedStatus"],
                                      ownerId,
                                      previewImg,
                                      startDate,
                                      moovId,
                                      title,
                                      ownerName,
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
                        return Container();
                      else
                        return StreamBuilder<List<AlgoliaObjectSnapshot>>(
                            stream: Stream.fromFuture(_operation1(_searchTerm)),
                            builder: (context, snapshot1) {
                              if (!snapshot1.hasData ||
                                  snapshot1.data.length == 0 ||
                                  _searchTerm == null)
                                return circularProgress();
                              List<AlgoliaObjectSnapshot> currSearchStuff1 =
                                  snapshot1.data;

                              switch (snapshot1.connectionState) {
                                case ConnectionState.waiting:
                                  return Container();
                                default:
                                  if (snapshot1.hasError)
                                    return new Text(
                                        'Error: ${snapshot1.error}');
                                  else
                                    return Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1,
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
                                                      return _searchTerm
                                                                  .length >
                                                              0
                                                          ? SendMOOVResult(
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
                                                              ownerId,
                                                              previewImg,
                                                              startDate,
                                                              moovId,
                                                              title,
                                                              ownerName,
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
                                                                  .length >
                                                              0
                                                          ? DisplayGroupResult(
                                                              groupName: currSearchStuff1[
                                                                          index]
                                                                      .data[
                                                                  "groupName"],
                                                              groupId: currSearchStuff1[
                                                                          index]
                                                                      .data[
                                                                  "groupId"],
                                                              groupPic: currSearchStuff1[
                                                                          index]
                                                                      .data[
                                                                  "groupPic"],
                                                              members: currSearchStuff1[
                                                                          index]
                                                                      .data[
                                                                  "members"],
                                                              postId: moovId,
                                                              title: title,
                                                              pic: previewImg,
                                                              sendMOOV: true,
                                                            )
                                                          : Container();
                                                    },
                                                    childCount: currSearchStuff1
                                                            .length ??
                                                        0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ]),
                                    );
                              }
                            });
                  }
                }),
          ]),
        ),
      ),
    );
  }
}

class SendMOOVResult extends StatefulWidget {
  final String displayName;
  final String email;
  final String proPic;
  final String userId;
  final int verifiedStatus;
  final String ownerId, previewImg;
  final dynamic startDate, moovId;
  final String title, ownerName;

  SendMOOVResult(
    this.displayName,
    this.email,
    this.proPic,
    this.userId,
    this.verifiedStatus,
    this.ownerId,
    this.previewImg,
    this.startDate,
    this.moovId,
    this.title,
    this.ownerName,
  );

  @override
  _SendMOOVResultState createState() => _SendMOOVResultState(
        this.displayName,
        this.email,
        this.proPic,
        this.userId,
        this.verifiedStatus,
        this.ownerId,
        this.previewImg,
        this.startDate,
        this.moovId,
        this.title,
        this.ownerName,
      );
}

class _SendMOOVResultState extends State<SendMOOVResult> {
  String displayName;
  String email;
  String proPic;
  String userId;
  int verifiedStatus;
  String ownerId, previewImg;
  dynamic startDate, moovId;
  String title, description, address, ownerName, ownerEmail;
  bool status = false;

  _SendMOOVResultState(
    this.displayName,
    this.email,
    this.proPic,
    this.userId,
    this.verifiedStatus,
    this.ownerId,
    this.previewImg,
    this.startDate,
    this.moovId,
    this.title,
    this.ownerName,
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

  void toMessageDetail(String postId, String pic, String title) {
    Timer(Duration(milliseconds: 200), () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessageDetail(
                      directMessageId: directMessageId,
                      otherPerson: userId,
                      members: [],
                      sendingPost: {
                        "postId": postId,
                        "pic": pic,
                        "title": title
                      })));
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => userId != currentUser.id
              ? OtherProfile(userId)
              : ProfilePageWithHeader())),
      child: Stack(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * .72,
          child: Row(children: <Widget>[
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
              child: SizedBox(
                child: Text(
                  displayName ?? "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: isLargePhone
                      ? TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18)
                      : TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                ),
              ),
            ),
            verifiedStatus == 3
                ? Padding(
                    padding: EdgeInsets.only(
                      left: 2.5,
                    ),
                    child: Icon(Icons.store, size: 20, color: Colors.blue),
                  )
                : verifiedStatus == 2
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: 5,
                        ),
                        child: Image.asset('lib/assets/verif2.png', height: 15),
                      )
                    : verifiedStatus == 1
                        ? Padding(
                            padding: EdgeInsets.only(
                              left: 2.5,
                            ),
                            child:
                                Image.asset('lib/assets/verif.png', height: 25),
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
        ),
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
                          setState(() {
                            status = false;
                          });
                        },
                        child: Text(
                          "Sent",
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
                          dmChecker().then((value) =>
                              toMessageDetail(moovId, previewImg, title));

                          // Database().sendMOOVNotification(
                          //   userId,
                          //   previewImg,
                          //   moovId,
                          //   startDate,
                          //   title,
                          //   ownerProPic,
                          //   ownerName,
                          // );
                          // setState(() {
                          //   status = true;
                          // });
                        },
                        child: Text(
                          "Send MOOV",
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
