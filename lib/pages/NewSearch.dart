import 'dart:async';

import 'package:MOOV/friendGroups/OtherGroup.dart';
import 'package:MOOV/friendGroups/group_detail.dart';
import 'package:MOOV/helpers/common.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/MessagesHub.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/searchWidgets/interestCommunitiesDashboard.dart';
import 'package:MOOV/searchWidgets/interestCommunityDetail.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:MOOV/widgets/trending_segment.dart';
import 'package:algolia/algolia.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlgoliaApplication {
  static final Algolia algolia = Algolia.init(
    applicationId: 'CUWBHO409I', //ApplicationID
    apiKey:
        '291f55bd5573004cf3e791b3c89d0daa', //search-only api key in flutter code
  );
}

class SearchBar extends StatefulWidget {
  final bool fromFriendFinder;
  SearchBar({this.fromFriendFinder = false});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar>
    with SingleTickerProviderStateMixin {
  bool showTabs = false;
  bool _showTrending = true;
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
  void _onFocusChange() {
    if (textFieldFocusNode.hasFocus) {
      _showTrending = false;
      setState(() {
        showTabs = true;
      });
      // if (dismissKeyboard) {
      //   textFieldFocusNode.unfocus();
      // }
    } else {

      // dismissKeyboard = false;
      setState(() {
        showTabs = false;
      });
    }

    // print("Focus: " + textFieldFocusNode.hasFocus.toString());
  }

  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _groupSearch(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("groups").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  Future<List<AlgoliaObjectSnapshot>> _userSearch(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("users").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  Future<List<AlgoliaObjectSnapshot>> _moovSearch(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("events").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  Future<List<AlgoliaObjectSnapshot>> _communityGroupSearch(
      String input) async {
    AlgoliaQuery query =
        _algoliaApp.instance.index("communityGroups").search(input);
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
    textFieldFocusNode.addListener(_onFocusChange);

    _tabController = TabController(vsync: this, length: 3, initialIndex: 0);
    // _tabController.animation
    //   ..addListener(() {
    //     setState(() {
    //       _currentIndex = (_tabController.animation.value).round();
    //     });
    //   });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();

    searchController.dispose();
  }

  // Future<void> _showSearch() async {
  //   final searchText = await showSearch<String>(
  //     context: context,
  //     delegate: SearchWithSuggestionDelegate(
  //       onSearchChanged: _getRecentSearchesLike,
  //     ),
  //   );

  //   //Save the searchText to SharedPref so that next time you can use them as recent searches.
  //   await _saveToRecentSearches(searchText);

  //   //Do something with searchText. Note: This is not a result.
  // }

  // Future<List<String>> _getRecentSearchesLike(String query) async {
  //   final pref = await SharedPreferences.getInstance();
  //   final allSearches = pref.getStringList("recentSearches");
  //   return allSearches.where((search) => search.startsWith(query)).toList();
  // }

  // Future<void> _saveToRecentSearches(String searchText) async {
  //   if (searchText == null) return; //Should not be null
  //   final pref = await SharedPreferences.getInstance();

  //   //Use `Set` to avoid duplication of recentSearches
  //   Set<String> allSearches =
  //       pref.getStringList("recentSearches")?.toSet() ?? {};

  //   //Place it at first in the set
  //   allSearches = {searchText, ...allSearches};
  //   pref.setStringList("recentSearches", allSearches.toList());
  // }

  // bool dismissKeyboard = false;
  // void _update(bool dismiss) {
  //   setState(() => dismissKeyboard = dismiss);
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: widget.fromFriendFinder
                ? CustomAppBar()
                : AppBar(
                    backgroundColor: Colors.white,
                    toolbarHeight: showTabs == true ? 96 : 50,
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
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 20),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.black),
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      // setState(() {
                                      //   dismissKeyboard = false;
                                      // });
                                      _showTrending = true;

                                      clearSearch();
                                      // Unfocus all focus nodes
                                      textFieldFocusNode.unfocus();

                                      // Disable text field's focus node request
                                      textFieldFocusNode.canRequestFocus =
                                          false;

                                      //Enable the text field's focus node request after some delay
                                      Future.delayed(Duration(milliseconds: 10),
                                          () {
                                        textFieldFocusNode.canRequestFocus =
                                            true;
                                      });
                                    },
                                    child: IconButton(
                                        onPressed: null,
                                        icon: Icon(
                                          Icons.clear,
                                          color: Colors.black,
                                        ))),
                              )),
                          showTabs == true
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    TextButton(
                                      style: ButtonStyle(
                                        overlayColor:
                                            MaterialStateColor.resolveWith(
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
                                              "    MOOVs",
                                              16.5,
                                              gradient: LinearGradient(colors: [
                                                Colors.blue.shade400,
                                                Colors.blue.shade900,
                                              ]),
                                            )
                                          : Text(
                                              "    MOOVs",
                                              style: TextStyle(
                                                  fontSize: 16.5,
                                                  color: Colors.black),
                                            ),
                                    ),
                                    TextButton(
                                      style: ButtonStyle(
                                        overlayColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.transparent),
                                      ),
                                      onPressed: () {
                                        _tabController.animateTo(1);
                                        setState(() {
                                          _currentIndex = (_tabController
                                                  .animation.value)
                                              .round(); //_tabController.animation.value returns double

                                          _currentIndex = 1;
                                        });
                                      },
                                      child: _currentIndex == 1
                                          ? GradientText(
                                              "   People ",
                                              16.5,
                                              gradient: LinearGradient(colors: [
                                                Colors.blue.shade400,
                                                Colors.blue.shade900,
                                              ]),
                                            )
                                          : Text(
                                              "   People ",
                                              style: TextStyle(
                                                  fontSize: 16.5,
                                                  color: Colors.black),
                                            ),
                                    ),
                                    TextButton(
                                      style: ButtonStyle(
                                        overlayColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.transparent),
                                      ),
                                      onPressed: () {
                                        _tabController.animateTo(2);
                                        setState(() {
                                          _currentIndex = 2;
                                        });
                                      },
                                      child: _currentIndex == 2
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
                                                  fontSize: 16.5,
                                                  color: Colors.black),
                                            ),
                                    )
                                  ],
                                )
                              : Container(),
                        ])),
                  ),
            backgroundColor: Colors.white,
            body: _searchTerm == null
                ? AnimatedCrossFade(
                    duration: Duration(milliseconds: 500),
                    crossFadeState: _showTrending
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Container(
                        height: MediaQuery.of(context).size.height,
                        child: TrendingSegment()),
                    secondChild: Container(
                        height: MediaQuery.of(context).size.height,
                        child:
                            // CommunityGroups(
                            //     dismissKeyboardCallback: this._update)
                            CommunityGroups()))
                : StreamBuilder<List<AlgoliaObjectSnapshot>>(
                    stream: Stream.fromFuture(_groupSearch(_searchTerm)),
                    builder: (context, snapshot0) {
                      List<AlgoliaObjectSnapshot> currSearchStuff0 =
                          snapshot0.data;
                      return StreamBuilder<List<AlgoliaObjectSnapshot>>(
                          stream: Stream.fromFuture(
                              _communityGroupSearch(_searchTerm)),
                          builder: (context, snapshotCommunity) {
                            if (!snapshotCommunity.hasData) {
                              return Container();
                            }
                            List<AlgoliaObjectSnapshot>
                                currSearchStuffCommunityGroup =
                                snapshotCommunity.data;
                            return Container(
                                child:
                                    StreamBuilder<List<AlgoliaObjectSnapshot>>(
                                        stream: Stream.fromFuture(
                                            _userSearch(_searchTerm)),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Container();
                                          }

                                          List<AlgoliaObjectSnapshot>
                                              currSearchStuff = snapshot.data;

                                          return StreamBuilder<
                                                  List<AlgoliaObjectSnapshot>>(
                                              stream: Stream.fromFuture(
                                                  _moovSearch(_searchTerm)),
                                              builder: (context, snapshot2) {
                                                if (_searchTerm == null) {
                                                  return linearProgress();
                                                }
                                                if (!snapshot2.hasData) {
                                                  return Container();
                                                }

                                                List<AlgoliaObjectSnapshot>
                                                    currSearchStuff2 =
                                                    snapshot2.data;

                                                return Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.90,
                                                  child: TabBarView(
                                                      controller:
                                                          _tabController,
                                                      children: [
                                                        CustomScrollView(
                                                          keyboardDismissBehavior:
                                                              ScrollViewKeyboardDismissBehavior
                                                                  .onDrag,
                                                          shrinkWrap: true,
                                                          slivers: <Widget>[
                                                            SliverPadding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 10,
                                                                      top: 15,
                                                                      right: 10,
                                                                      bottom:
                                                                          5),
                                                              sliver:
                                                                  SliverToBoxAdapter(
                                                                child:
                                                                    Container(
                                                                  height: currSearchStuffCommunityGroup.length != 0 ? 140 : 0,
                                                                  child: ListView
                                                                      .builder(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    itemCount:
                                                                        currSearchStuffCommunityGroup
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return (_searchTerm !=
                                                                              null)
                                                                          ? Padding(
                                                                            padding: const EdgeInsets.all(4.0),
                                                                            child: DisplayCommunityGroupResult(
                                                                                groupId: currSearchStuffCommunityGroup[index].data["groupId"]),
                                                                          )
                                                                          : Container();
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SliverList(
                                                              delegate:
                                                                  SliverChildBuilderDelegate(
                                                                (context,
                                                                    index) {
                                                                 
                                                                  String
                                                                      privacy =
                                                                      currSearchStuff2[index]
                                                                              .data[
                                                                          "privacy"];
                                                                  bool hide =
                                                                      false;
                                                                  if (privacy ==
                                                                          "Friends Only" ||
                                                                      privacy ==
                                                                          "Invite Only") {
                                                                    hide = true;
                                                                  }
                                                                  return _searchTerm !=
                                                                              null &&
                                                                          hide ==
                                                                              false
                                                                      ? DisplayMOOVResult(
                                                                          title:
                                                                              currSearchStuff2[index].data["title"],
                                                                          description:
                                                                              currSearchStuff2[index].data["description"],
                                                                          type:
                                                                              currSearchStuff2[index].data["type"],
                                                                          image:
                                                                              currSearchStuff2[index].data["image"],
                                                                          userId:
                                                                              currSearchStuff2[index].data["userId"],
                                                                          postId:
                                                                              currSearchStuff2[index].data["postId"],
                                                                        )
                                                                      : Container();
                                                                },
                                                                childCount:
                                                                    currSearchStuff2
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
                                                                (context,
                                                                    index) {
                                                                  return _searchTerm !=
                                                                              null &&
                                                                          _currentIndex ==
                                                                              1
                                                                      ? DisplaySearchResult(
                                                                          displayName:
                                                                              currSearchStuff[index].data["displayName"],
                                                                          email:
                                                                              currSearchStuff[index].data["email"],
                                                                          proPic:
                                                                              currSearchStuff[index].data["photoUrl"],
                                                                          userId:
                                                                              currSearchStuff[index].data["id"],
                                                                          verifiedStatus:
                                                                              currSearchStuff[index].data["verifiedStatus"],
                                                                          isBusiness:
                                                                              currSearchStuff[index].data['isBusiness'],
                                                                        )
                                                                      : Container();
                                                                },
                                                                childCount: currSearchStuff.length !=
                                                                            null &&
                                                                        _currentIndex ==
                                                                            0
                                                                    ? currSearchStuff
                                                                        .length
                                                                    : currSearchStuff0.length !=
                                                                                null &&
                                                                            _currentIndex ==
                                                                                2
                                                                        ? currSearchStuff0
                                                                            .length
                                                                        : currSearchStuff2.length != null &&
                                                                                _currentIndex == 1
                                                                            ? currSearchStuff2.length
                                                                            : 0,
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
                                                                (context,
                                                                    index) {
                                                                  return _searchTerm !=
                                                                              null &&
                                                                          _currentIndex ==
                                                                              2
                                                                      ? DisplayGroupResult(
                                                                          groupName:
                                                                              currSearchStuff0[index].data["groupName"],
                                                                          groupId:
                                                                              currSearchStuff0[index].data["groupId"],
                                                                          groupPic:
                                                                              currSearchStuff0[index].data["groupPic"],
                                                                          members:
                                                                              currSearchStuff0[index].data["members"],
                                                                          sendMOOV:
                                                                              false,
                                                                        )
                                                                      : DisplayMOOVResult(
                                                                          title:
                                                                              currSearchStuff2[index].data["title"],
                                                                          description:
                                                                              currSearchStuff2[index].data["description"],
                                                                          type:
                                                                              currSearchStuff2[index].data["type"],
                                                                          image:
                                                                              currSearchStuff2[index].data["image"],
                                                                          userId:
                                                                              currSearchStuff2[index].data["userId"],
                                                                          postId:
                                                                              currSearchStuff2[index].data["postId"],
                                                                        );
                                                                },
                                                                childCount:
                                                                    currSearchStuff0
                                                                            .length ??
                                                                        currSearchStuff2.length
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                );
                                              });
                                        }));
                          });
                    })));
  }
}

class DisplaySearchResult extends StatelessWidget {
  final String displayName;
  final String email;
  final String proPic;
  final String userId;
  final int verifiedStatus;
  final bool isBusiness;

  DisplaySearchResult(
      {Key key,
      this.email,
      this.displayName,
      this.proPic,
      this.userId,
      this.verifiedStatus,
      this.isBusiness})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => userId != currentUser.id
              ? OtherProfile(userId)
              : ProfilePageWithHeader())),
      child: Row(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 5, bottom: 5),
          child: CircleAvatar(
              radius: 27,
              backgroundColor: isBusiness ? Colors.blue : TextThemes.ndGold,
              child: CircleAvatar(
                backgroundImage: NetworkImage(proPic),
                radius: 25,
                backgroundColor: TextThemes.ndBlue,
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.5),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
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
                          padding: EdgeInsets.only(left: 5, top: 5),
                          child:
                              Image.asset('lib/assets/verif2.png', height: 20),
                        )
                      : verifiedStatus == 1
                          ? Padding(
                              padding: EdgeInsets.only(left: 2.5, top: 0),
                              child: Image.asset('lib/assets/verif.png',
                                  height: 30),
                            )
                          : Text("")
            ],
          ),
        ),
        // isAmbassador
        //     ? Padding(
        //         padding: const EdgeInsets.only(top: 3, left: 3),
        //         child: Image.asset('lib/assets/verif.png', height: 30),
        //       )
        //     : Text(""),
        // Text(
        //   email ?? "",
        //   style: TextStyle(color: Colors.black),
        // ),
        Divider(
          color: Colors.black,
        ),
      ]),
    );
  }
}

class DisplayMOOVResult extends StatelessWidget {
  final String title;
  final String description;
  final String type;
  final String image;
  final String userId;
  final String postId;
  final int verifiedStatus;

  DisplayMOOVResult({
    Key key,
    this.description,
    this.title,
    this.type,
    this.image,
    this.userId,
    this.postId,
    this.verifiedStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return StreamBuilder(
        stream: usersRef.doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data == null) return Container();
          String proPic = snapshot.data['photoUrl'];
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: OpenContainer(
              transitionType: ContainerTransitionType.fade,
              transitionDuration: Duration(milliseconds: 500),
              openBuilder: (context, _) => PostDetail(postId),
              closedElevation: 0,
              closedBuilder: (context, _) =>
                  Stack(alignment: Alignment.center, children: <Widget>[
                Container(
                  width: isLargePhone
                      ? MediaQuery.of(context).size.width * 0.8
                      : MediaQuery.of(context).size.width * 0.8,
                  height: isLargePhone
                      ? MediaQuery.of(context).size.height * 0.15
                      : MediaQuery.of(context).size.height * 0.17,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  margin:
                      EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
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
                          maxWidth: MediaQuery.of(context).size.width * .4),
                      child: Text(
                        title,
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
                //     : Container(height:50,color:Colors.red),
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
                  bottom: 8.5,
                  right: isLargePhone ? 60 : 55,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: TextThemes.ndGold,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20.0,
                          offset: Offset(5.0, 5.0),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                        radius: 27,
                        backgroundColor: TextThemes.ndGold,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(proPic),
                          radius: 25,
                          backgroundColor: TextThemes.ndBlue,
                        )),
                  ),
                ),
              ]),
            ),
          );
        });
  }
}

class DisplayGroupResult extends StatelessWidget {
  final String groupName;
  final String groupId;
  final String groupPic;
  final List<dynamic> members;
  final String postId, title, pic;
  final bool sendMOOV;

  DisplayGroupResult(
      {Key key,
      this.groupName,
      this.groupId,
      this.groupPic,
      this.members,
      this.postId,
      this.title,
      this.pic,
      this.sendMOOV})
      : super(key: key);

  void toMessageDetail(
      BuildContext context, String postId, String pic, String title) {
    Timer(Duration(milliseconds: 200), () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessageDetail(
                      isGroupChat: true,
                      gid: groupId,
                      members: members,
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
    for (int i = 0; i < members.length; i++) {
      return StreamBuilder(
          stream: usersRef
              .where('friendGroups', arrayContains: groupId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            if (snapshot.data.docs == null) return Container();
            var length = members.length - 2;
            var course = snapshot.data.docs;

            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Stack(alignment: Alignment.center, children: <Widget>[
                Container(
                  width: isLargePhone
                      ? MediaQuery.of(context).size.width * 0.8
                      : MediaQuery.of(context).size.width * 0.8,
                  height: isLargePhone
                      ? MediaQuery.of(context).size.height * 0.15
                      : MediaQuery.of(context).size.height * 0.17,
                  child: OpenContainer(
                    transitionType: ContainerTransitionType.fade,
                    transitionDuration: Duration(milliseconds: 500),
                    openBuilder: (context, _) =>
                        members.contains(currentUser.id)
                            ? GroupDetail(groupId)
                            : OtherGroup(groupId),
                    closedElevation: 0,
                    closedBuilder: (context, _) => Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: groupPic,
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
                        groupName,
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
                                    radius: 25.0,
                                    backgroundImage: NetworkImage(
                                      course[1]['photoUrl'],
                                    ),
                                  )
                                : Container()),
                        Padding(
                            padding: const EdgeInsets.only(top: 4, left: 25.0),
                            child: CircleAvatar(
                              radius: 25.0,
                              backgroundImage: NetworkImage(
                                course[0]['photoUrl'],
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 50.0),
                          child: CircleAvatar(
                            radius: 25.0,
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
                sendMOOV
                    ? Positioned(
                        right: MediaQuery.of(context).size.width / 2,
                        bottom: -2.5,
                        child: RaisedButton(
                            padding: const EdgeInsets.all(2.0),
                            color: TextThemes.ndBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3.0))),
                            onPressed: () {
                              toMessageDetail(context, postId, pic, title);
                            },
                            child: Text(
                              "Send",
                              style: new TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            )),
                      )
                    : Container(),
              ]),
            );
          });
    }
    return Container();
  }
}

class DisplayCommunityGroupResult extends StatelessWidget {
  final String groupId;

  DisplayCommunityGroupResult({this.groupId});

  @override
  Widget build(BuildContext context) {
    // bool isLargePhone = Screen.diagonal(context) > 766;

    return StreamBuilder(
        stream: communityGroupsRef.doc(groupId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          String pic = snapshot.data['groupPic'];
          String name = snapshot.data['groupName'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          InterestCommunityDetail(groupId: groupId)));
            },
            child: Container(
              width: MediaQuery.of(context).size.width * .3,
              height: 140,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.25),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                image: DecorationImage(
                    image: NetworkImage(pic),
                    fit: BoxFit.cover,
                    colorFilter:
                        ColorFilter.mode(Colors.grey, BlendMode.darken)),
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17),
                  ),
                  SizedBox(height: 10),
                  Icon(
                      IconData(snapshot.data['groupIcon']['codePoint'],
                          fontFamily: snapshot.data['groupIcon']['fontFamily'],
                          fontPackage: "font_awesome_flutter"),
                      color: Colors.white,
                      size: 40),
                  // Icon(Icons.face, size: 40, color: Colors.white),
                ],
              ),
            ),
          );
        });
  }
}

class GradientText extends StatelessWidget {
  GradientText(this.text, this.size,
      {@required this.gradient, this.montserrat = false});

  final String text;
  final double size;
  final Gradient gradient;
  final bool montserrat;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: montserrat
            ? GoogleFonts.montserrat(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)
            : TextStyle(
                // The color must be set to white for this to work
                color: Colors.white,
                fontSize: size,
              ),
      ),
    );
  }
}

typedef OnSearchChanged = Future<List<String>> Function(String);

class SearchWithSuggestionDelegate extends SearchDelegate<String> {
  ///[onSearchChanged] gets the [query] as an argument. Then this callback
  ///should process [query] then return an [List<String>] as suggestions.
  ///Since its returns a [Future] you get suggestions from server too.
  final OnSearchChanged onSearchChanged;

  ///This [_oldFilters] used to store the previous suggestions. While waiting
  ///for [onSearchChanged] to completed, [_oldFilters] are displayed.
  List<String> _oldFilters = const [];

  SearchWithSuggestionDelegate({String searchFieldLabel, this.onSearchChanged})
      : super(searchFieldLabel: searchFieldLabel);

  ///
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = "",
      ),
    ];
  }

  ///OnSubmit in the keyboard, returns the [query]
  @override
  void showResults(BuildContext context) {
    close(context, query);
  }

  ///Since [showResults] is overridden we can don't have to build the results.
  @override
  Widget buildResults(BuildContext context) => null;

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: onSearchChanged != null ? onSearchChanged(query) : null,
      builder: (context, snapshot) {
        if (snapshot.hasData) _oldFilters = snapshot.data;
        return ListView.builder(
          itemCount: _oldFilters.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.restore),
              title: Text("${_oldFilters[index]}"),
              onTap: () {
                close(context, _oldFilters[index]);
              },
            );
          },
        );
      },
    );
  }
}
