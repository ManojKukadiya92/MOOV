import 'dart:async';

import 'package:MOOV/main.dart';
import 'package:MOOV/models/user.dart';
import 'package:MOOV/pages/MessagesHub.dart';
import 'package:MOOV/pages/NewSearch.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/leaderboard.dart';
import 'package:MOOV/pages/notification_feed.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/pages/searchNoTrending.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'ProfilePageWithHeader.dart';
import 'other_profile.dart';

class FriendFinder extends StatefulWidget {
  @override
  _FriendFinderState createState() => _FriendFinderState();
}

class _FriendFinderState extends State<FriendFinder>
    with AutomaticKeepAliveClientMixin {
  Future request() async => await Future.delayed(
      const Duration(milliseconds: 500),
      () => usersRef.doc(currentUser.id).get());
  int todayOnly = 0;
  int tomorrowOnly = 0;

  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  bool get wantKeepAlive => true;
  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        // .where("displayName", isGreaterThanOrEqualTo: query)
        .where("friendArray", arrayContains: currentUser.id)
        .get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
    setState(() {
      searchResultsFuture = null;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.all(2),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 2.5),
              child: GestureDetector(
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
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(
            context,
            MaterialPageRoute(builder: (context) => ProfilePageWithHeader()),
          );
        },
      ),
      backgroundColor: TextThemes.ndBlue,
      //pinned: true,
      actions: <Widget>[
        NamedIconMessages(
            iconData: Icons.mail_outline,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MessageList()));
            }),
        NamedIcon(
            iconData: Icons.notifications_active_outlined,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NotificationFeed()));
              Database().setNotifsSeen();
            }),
      ],
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<UserResult> searchResults = [];
        snapshot.data.docs.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user, todayOnly, tomorrowOnly);
          searchResults.add(searchResult);
        });
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding:
                        const EdgeInsets.only(bottom: 20.0, top: 20, right: 5),
                    child: todayOnly == 0
                        ? RaisedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();

                              setState(() {
                                todayOnly = 1;
                              });
                            },
                            color: TextThemes.ndBlue,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: TextThemes.ndGold),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Today?',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          )
                        : RaisedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();

                              setState(() {
                                todayOnly = 0;
                              });
                            },
                            color: Colors.green,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, color: TextThemes.ndGold),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Today!',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          )),
                Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, top: 20),
                    child: tomorrowOnly == 0
                        ? RaisedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();

                              setState(() {
                                tomorrowOnly = 1;
                              });
                            },
                            color: TextThemes.ndBlue,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: TextThemes.ndGold),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Tomorrow?',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          )
                        : RaisedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();

                              setState(() {
                                tomorrowOnly = 0;
                              });
                            },
                            color: Colors.green,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, color: TextThemes.ndGold),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Tomorrow!',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          )),
              ],
            ),
            Expanded(
              child: ListView(
                children: searchResults,
              ),
            ),
          ],
        );
      },
    );
  }

  buildNoContent() {
    currentUser.friendArray.length != 0 && currentUser.friendArray != null
        ? Timer(Duration(milliseconds: 1), () {
            handleSearch("");
          })
        : Container();

    // return SingleChildScrollView(
    //     child: Container(
    //   height: MediaQuery.of(context).size.height,
    //   decoration: BoxDecoration(
    //     gradient: LinearGradient(
    //       colors: [Colors.pink[300], Colors.pink[200]],
    //       begin: Alignment.centerLeft,
    //       end: Alignment.centerRight,
    //     ),
    //   ),
    //   child: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Padding(
    //             padding: const EdgeInsets.all(50.0),
    //             child: RichText(
    //                 textAlign: TextAlign.center,
    //                 text: TextSpan(style: TextThemes.mediumbody, children: [
    //                   TextSpan(
    //                       text: "Fuck FOMO. \n Find your friends",
    //                       style: TextStyle(
    //                           fontSize: 30, fontWeight: FontWeight.w300)),
    //                   TextSpan(
    //                       text: " now",
    //                       style: TextStyle(
    //                           fontSize: 30, fontWeight: FontWeight.w600)),
    //                   TextSpan(
    //                       text: ".",
    //                       style: TextStyle(
    //                           fontSize: 30, fontWeight: FontWeight.w300))
    //                 ]))),
    //         Image.asset('lib/assets/ff.png')
    //       ],
    //     ),
    //   ),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: currentUser.friendArray.isNotEmpty
          ? buildSearchField()
          : AppBar(
              leading: IconButton(
                  icon: Icon(Icons.arrow_drop_up_outlined,
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
      body: currentUser.friendArray.isEmpty
          ? FutureBuilder(
              future: request(),
              builder: (context, snapshot) {
                bool isLargePhone = Screen.diagonal(context) > 766;

                if (!snapshot.hasData) return CircularProgressIndicator();
                if (snapshot.connectionState != ConnectionState.done)
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: Container(
                      height: 60.0,
                      width: 60.0,
                      color: Colors.grey[300],
                    ),
                  );
                List friendArray = snapshot.data['friendArray'];
                if (friendArray.isEmpty) {
                  return Container(
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
                                  ? const EdgeInsets.only(
                                      top: 50.0,
                                      left: 50,
                                      right: 50,
                                      bottom: 10)
                                  : const EdgeInsets.only(
                                      top: 10.0,
                                      left: 50,
                                      right: 50,
                                      bottom: 0),
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      style: TextThemes.mediumbody,
                                      children: [
                                        TextSpan(
                                            text: "Aw, no friends? Add some",
                                            style: TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w300)),
                                        TextSpan(
                                            text: " now",
                                            style: TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600)),
                                        TextSpan(
                                            text: ".",
                                            style: TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w300))
                                      ]))),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SearchBar(fromFriendFinder: true)),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                elevation: 20,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                    height: 45,
                                    width: 150,
                                    padding: EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.pink[400],
                                            Colors.pink[300]
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Find Friends",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                        textAlign: TextAlign.center,
                                      ),
                                    )),
                              ),
                            ),
                          ),
                          Image.asset('lib/assets/ff.png')
                        ],
                      ),
                    ),
                  );
                } else {
                  return buildNoContent();
                }
              })
          : searchResultsFuture == null
              ? buildNoContent()
              : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  int todayOnly, tomorrowOnly;
  bool isIncognito;
  bool friendFinderVisibility;

  UserResult(this.user, this.todayOnly, this.tomorrowOnly);

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Container(
      height: 140,
      color: Colors.white,
      child: GestureDetector(
        onTap: () => print('tapped'),
        child: Card(
            color: Colors.white,
            child: FutureBuilder(
                future: usersRef.doc(user.id).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return circularProgress();
                  isIncognito = snapshot.data['privacySettings']['incognito'];
                  friendFinderVisibility = snapshot.data['privacySettings']
                      ['friendFinderVisibility'];

                  return Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (user.id == currentUser.id) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfilePageWithHeader()));
                                  } else {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => OtherProfile(
                                                  user.id,
                                                )));
                                  }
                                },
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              user.photoUrl),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FittedBox(
                                        child: Text(
                                          user.displayName == null
                                              ? ""
                                              : user.displayName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: TextThemes.ndBlue,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              width: isIncognito || !friendFinderVisibility
                                  ? 50
                                  : 0),
                          Container(
                              decoration: isIncognito || !friendFinderVisibility
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(25.0),
                                      color: Colors.black,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 20.0,
                                          offset: Offset(5.0, 5.0),
                                        ),
                                      ],
                                    )
                                  : null,
                              child: isIncognito || !friendFinderVisibility
                                  ? Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Row(children: [
                                        Image.asset(
                                          'lib/assets/incognito.png',
                                          height: 20,
                                        ),
                                        Text(" Incognito",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold))
                                      ]),
                                    )
                                  : Text("is going to")),
                          Container(
                              child: FutureBuilder(
                                  future: postsRef
                                      .where('going', arrayContains: user.id)
                                      .orderBy("startDate")
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return Center(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: isIncognito ||
                                                !friendFinderVisibility
                                            ? Text("")
                                            : Text("nothing, right now."),
                                      ));
                                    if ((!snapshot.hasData ||
                                            snapshot.data.docs.length == 0) &&
                                        (!isIncognito ||
                                            !friendFinderVisibility))
                                      return SizedBox(
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: !isLargePhone
                                                    ? const EdgeInsets.all(4.0)
                                                    : EdgeInsets.all(2.0),
                                                child:
                                                    Text("nothing, right now."),
                                              )),
                                          width: isLargePhone
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.51
                                              : isIncognito ||
                                                      !friendFinderVisibility
                                                  ? 0
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.49,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.15);
                                    var course = snapshot.data.docs[0];
                                    Timestamp startDate = course["startDate"];
                                    bool hide = false;

                                    final now = DateTime.now();
                                    bool isToday = false;
                                    bool isTomorrow = false;
                                    bool isBoth = false;
                                    bool isEither = false;

                                    bool isNextWeek = false;

                                    final today =
                                        DateTime(now.year, now.month, now.day);
                                    final yesterday = DateTime(
                                        now.year, now.month, now.day - 1);
                                    final tomorrow = DateTime(
                                        now.year, now.month, now.day + 1);
                                    final week = DateTime(
                                        now.year, now.month, now.day + 6);

                                    final dateToCheck = startDate.toDate();
                                    final aDate = DateTime(dateToCheck.year,
                                        dateToCheck.month, dateToCheck.day);

                                    if (aDate == today) {
                                      isToday = true;
                                    } else if (aDate == tomorrow) {
                                      isTomorrow = true;
                                    }
                                    if (isToday == false && todayOnly == 1) {
                                      hide = true;
                                    }

                                    if (isTomorrow == false &&
                                        tomorrowOnly == 1) {
                                      hide = true;
                                    }
                                    if (todayOnly == 1 && tomorrowOnly == 1) {
                                      isBoth = true;
                                    }
                                    if (isToday || isTomorrow) {
                                      isEither = true;
                                    }
                                    if (isBoth == true && isEither == true) {
                                      hide = false;
                                    }
                                    if (aDate.isAfter(week)) {
                                      isNextWeek = true;
                                    }
                                    if (isIncognito == true ||
                                        friendFinderVisibility == false) {
                                      hide = true;
                                    }
                                    if (course['privacy'] == "Invite Only") {
                                      hide = true;
                                    }

                                    return (hide == false)
                                        ? GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          (PostDetail(course[
                                                              'postId']))));
                                            },
                                            child: Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: isLargePhone
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.51
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.49,
                                                    height: isLargePhone
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.15
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.17,
                                                    child: Container(
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl:
                                                              course['image'],
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          left: 20,
                                                          top: 0,
                                                          right: 20,
                                                          bottom: 7.5),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(10),
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 5,
                                                            blurRadius: 7,
                                                            offset: Offset(0,
                                                                3), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
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
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                            maxWidth: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .3),
                                                        child: Text(
                                                          snapshot.data.docs[0]
                                                              ['title'],
                                                          maxLines: 2,
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Solway',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  isLargePhone
                                                                      ? 17.0
                                                                      : 14),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  isToday == false
                                                      ? Positioned(
                                                          top: 0,
                                                          right: 0,
                                                          child: Container(
                                                            height: 30,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            decoration:
                                                                BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                      colors: [
                                                                        Colors.pink[
                                                                            400],
                                                                        Colors.purple[
                                                                            300]
                                                                      ],
                                                                      begin: Alignment
                                                                          .centerLeft,
                                                                      end: Alignment
                                                                          .centerRight,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0)),
                                                            child: isNextWeek
                                                                ? Text(
                                                                    DateFormat(
                                                                            'MMM d')
                                                                        .add_jm()
                                                                        .format(
                                                                            course['startDate'].toDate()),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18),
                                                                  )
                                                                : Text(
                                                                    DateFormat(
                                                                            'EEE')
                                                                        .add_jm()
                                                                        .format(
                                                                            course['startDate'].toDate()),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                          ),
                                                        )
                                                      : Container(),
                                                  isToday == true
                                                      ? Positioned(
                                                          top: 0,
                                                          right: 0,
                                                          child: Container(
                                                            height: 30,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            decoration:
                                                                BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                      colors: [
                                                                        Colors.red[
                                                                            400],
                                                                        Colors.red[
                                                                            600]
                                                                      ],
                                                                      begin: Alignment
                                                                          .centerLeft,
                                                                      end: Alignment
                                                                          .centerRight,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0)),
                                                            child: Text(
                                                              DateFormat('EEE')
                                                                  .add_jm()
                                                                  .format(course[
                                                                          'startDate']
                                                                      .toDate()),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18),
                                                            ),
                                                          ),
                                                        )
                                                      : Text(""),
                                                ]),
                                          )
                                        : isIncognito || !friendFinderVisibility
                                            ? Text("")
                                            : SizedBox(
                                                width: isLargePhone
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.51
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.49,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.15,
                                                child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 2.0),
                                                      child: Text(
                                                          "no MOOVs, right now."),
                                                    )),
                                              );
                                  }))
                        ]),
                  );
                })),
      ),
    );
  }
}

// import 'package:MOOV/pages/home.dart';
