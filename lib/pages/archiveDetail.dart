import 'dart:ui';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/Comment.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:MOOV/pages/edit_post.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class ArchiveDetail extends StatefulWidget {
  final String postId;
  ArchiveDetail(this.postId);

  @override
  State<StatefulWidget> createState() {
    return _ArchiveDetailState(this.postId);
  }
}

class _ArchiveDetailState extends State<ArchiveDetail>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

  String postId;
  _ArchiveDetailState(this.postId);
  var commentCount = 0;
  int segmentedControlValue = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1,
    );

    _scrollController.addListener(() {
      switch (_scrollController.position.userScrollDirection) {
        // Scrolling up - forward the animation (value goes to 1)
        case ScrollDirection.forward:
          _hideFabAnimController.forward();
          break;
        // Scrolling down - reverse the animation (value goes to 0)
        case ScrollDirection.reverse:
          _hideFabAnimController.reverse();
          break;
        // Idle - keep FAB visibility unchanged
        case ScrollDirection.idle:
          break;
      }
    });
  }

  bool isIncognito;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersRef.doc(currentUser.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          isIncognito = snapshot.data['privacySettings']['incognito'];
          final bool includeMarkAsDoneButton = true;

          return GestureDetector(
            onPanUpdate: (details) {
              if (details.delta.dx > 0) {
                Navigator.pop(context);
              }
            },
            child: Scaffold(
                appBar: AppBar(
                  leading: (includeMarkAsDoneButton)
                      ? IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          tooltip: 'Mark as done',
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },
                        ),
                  backgroundColor: TextThemes.ndBlue,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.all(5),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'lib/assets/moovblue.png',
                          fit: BoxFit.cover,
                          height: 50.0,
                        ),
                      ],
                    ),
                  ),
                ),
                body: SafeArea(
                  top: false,
                  child: Stack(children: [
                    StreamBuilder(
                        stream: archiveRef.doc(postId).snapshots(),
                        builder: (context, snapshot) {
                          String title,
                              description,
                              bannerImage,
                              address,
                              userId,
                              postId;
                          dynamic startDate;

                          if (!snapshot.hasData)
                            return CircularProgressIndicator();
                          DocumentSnapshot course = snapshot.data;
                          title = course['title'];
                          bannerImage = course['image'];
                          description = course['description'];
                          startDate = course['startDate'];
                          address = course['address'];
                          userId = course['userId'];
                          postId = course['postId'];
                          int maxOccupancy = course['maxOccupancy'];
                          int goingCount = course['going'].length;
                          return Container(
                            color: Colors.white,
                            child: ListView(
                              controller: _scrollController,
                              children: <Widget>[
                                _BannerImage(bannerImage, userId, postId,
                                    maxOccupancy, goingCount),
                                _NonImageContents(
                                    title,
                                    description,
                                    startDate,
                                    address,
                                    userId,
                                    postId,
                                    course,
                                    commentCount),
                              ],
                            ),
                          );
                        }),
                  ]),
                )),
          );
        });
  }
}

class _BannerImage extends StatelessWidget {
  final String bannerImage, userId, postId;
  final int maxOccupancy, goingCount;
  _BannerImage(this.bannerImage, this.userId, this.postId, this.maxOccupancy,
      this.goingCount);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      ClipRRect(
        child: Container(
          margin:
              const EdgeInsets.only(bottom: 6.0), //Same as `blurRadius` i guess
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
          child: CachedNetworkImage(
            memCacheHeight: 100,
            memCacheWidth: 100,
            imageUrl: bannerImage,
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
          ),
        ),
      ),
      // userId == currentUser.id ||
      //         currentUser.id == "108155010592087635288" ||
      //         currentUser.id == "118426518878481598299" ||
      //         currentUser.id == "107290090512658207959" ||
      //         currentUser.id == "115805501102171844515"
      //     ? Positioned(
      //         top: 5,
      //         right: 5,
      //         child: GestureDetector(
      //           onTap: () => Navigator.of(context).push(
      //               MaterialPageRoute(builder: (context) => EditPost(postId))),
      //           child: Container(
      //             height: 45,
      //             width: 70,
      //             padding: EdgeInsets.all(4),
      //             decoration: BoxDecoration(
      //                 gradient: LinearGradient(
      //                   colors: [
      //                     Colors.red,
      //                     Colors.red[300],
      //                   ],
      //                   begin: Alignment.centerLeft,
      //                   end: Alignment.centerRight,
      //                 ),
      //                 borderRadius: BorderRadius.circular(10.0)),
      //             child: Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 Icon(
      //                   Icons.edit,
      //                   color: Colors.white,
      //                 ),
      //                 Text(
      //                   "Edit",
      //                   textAlign: TextAlign.center,
      //                   style: TextStyle(color: Colors.white, fontSize: 18),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       )
      //     : Text(''),
      maxOccupancy != null && maxOccupancy != 8000000 && maxOccupancy != 0
          ? Positioned(
              bottom: 0,
              right: 50,
              child: Container(
                height: 45,
                width: maxOccupancy > 99
                    ? 100
                    : maxOccupancy > 9
                        ? 80
                        : 70,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange,
                        Colors.orange[300],
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.supervisor_account,
                      color: Colors.white,
                    ),
                    Text(
                      "$goingCount/$maxOccupancy",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            )
          : Container()
    ]);
  }
}

class _NonImageContents extends StatelessWidget {
  String title, description, userId;
  dynamic startDate, address, moovId;
  DocumentSnapshot course;
  var commentCount;

  _NonImageContents(this.title, this.description, this.startDate, this.address,
      this.userId, this.moovId, this.course, this.commentCount);

  @override
  Widget build(BuildContext context) {
    return Container(
      //  margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Title(title),
          _Description(description),
          PostTimeAndPlace(startDate, address, course['userId']),
          _AuthorContent(userId, course),
          GestureDetector(
            onTap: () {
              showComments(context,
                  postId: moovId,
                  ownerId: course['userId'],
                  mediaUrl: currentUser.photoUrl);
            },
            child: GestureDetector(
              onTap: () {
                showComments(context,
                    postId: moovId,
                    ownerId: course['userId'],
                    mediaUrl: currentUser.photoUrl);
              },
              child: StreamBuilder(
                  stream:
                      archiveRef.doc(moovId).collection('comments').snapshots(),
                  builder: (context, snapshot) {
                    bool isLargePhone = Screen.diagonal(context) > 766;
                    if (!snapshot.hasData || snapshot.data.docs.length == 0)
                      return Container();
                    String commentCount = snapshot.data.docs.length.toString();
                    return Stack(children: [
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 1.0),
                            child: Container(
                              height: 1.0,
                              width: 500.0,
                              color: Colors.grey[700],
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 34,
                                    backgroundColor: TextThemes.ndGold,
                                    child: CircleAvatar(
                                      // backgroundImage: snapshot.data
                                      //     .documents[index].data['photoUrl'],
                                      backgroundImage: NetworkImage(
                                          snapshot.data.docs[
                                                  snapshot.data.docs.length - 1]
                                              ['avatarUrl']),
                                      radius: 32,
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text("said")),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 1),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        child: Text(
                                          " \"" +
                                              snapshot.data.docs[
                                                  snapshot.data.docs.length -
                                                      1]['comment'] +
                                              "\"",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          // textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: isLargePhone ? 14 : 13),
                                        ),
                                      )),
                                ],
                              )),
                        ],
                      ),
                      Positioned(
                          right: 5,
                          bottom: 5,
                          child: commentCount == "1"
                              ? Text(
                                  "View $commentCount\n Comment",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: TextThemes.ndBlue),
                                )
                              : Text(
                                  "View all $commentCount\n Comments",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: TextThemes.ndBlue),
                                ))
                    ]);
                  }),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.0),
            child: Container(
              height: 1.0,
              width: 500.0,
              color: Colors.grey[700],
            ),
          ),
          _Buttons(moovId),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Container(
              height: 1.0,
              width: 500.0,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  showComments(BuildContext context,
      {String postId, String ownerId, String mediaUrl}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PostComments(
        postId: postId,
        postOwnerId: ownerId,
      );
    }));
  }
}

class _Title extends StatelessWidget {
  String title;
  _Title(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 10, right: 10),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextThemes.headline1,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _Description extends StatelessWidget {
  String description;
  _Description(this.description);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 10.0, bottom: 15.0, left: 10, right: 10),
      child: Center(
        child: Text(description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontStyle: FontStyle.italic)),
      ),
    );
  }
}

class PostTimeAndPlace extends StatelessWidget {
  dynamic startDate, address;
  String userId;

  PostTimeAndPlace(this.startDate, this.address, this.userId);

  @override
  Widget build(BuildContext context) {
    final TextStyle timeTheme = TextThemes.dateStyle;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                  child: Icon(Icons.timer, color: TextThemes.ndGold),
                ),
                Text('WHEN: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  DateFormat('MMMd').add_jm().format(startDate.toDate()),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 4.0),
                    child: Icon(
                      Icons.place,
                      color: TextThemes.ndGold,
                    ),
                  ),
                  Text(
                    'WHERE: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * .65,
                      child: Text(
                        address,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ))
                ],
              ),
            )
          ],
        ),
      ]),
    );
  }
}

class _AuthorContent extends StatelessWidget {
  String userId;
  DocumentSnapshot course;
  var data;
  _AuthorContent(this.userId, this.course);

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return FutureBuilder<DocumentSnapshot>(
        future: usersRef.doc(userId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot2) {
          if (snapshot2.hasError) {
            return Text("Something went wrong");
          }
          if (!snapshot2.hasData) return CircularProgressIndicator();

          Map<String, dynamic> course1 = snapshot2.data.data();
          int verifiedStatus = snapshot2.data['verifiedStatus'];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => course1['id'] != currentUser.id
                      ? OtherProfile(course1['id'])
                      : ProfilePageWithHeader())),
              child: Container(
                  child: Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                      child: CircleAvatar(
                        radius: 22.0,
                        backgroundImage:
                            CachedNetworkImageProvider(course1['photoUrl']),
                        backgroundColor: Colors.transparent,
                      )),
                  Container(
                    child: Column(
                      //  mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Row(
                            children: [
                              Text(course1['displayName'],
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: TextThemes.ndBlue,
                                      decoration: TextDecoration.none)),
                              verifiedStatus == 3
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                        left: 3,
                                      ),
                                      child: Icon(
                                        Icons.store,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                    )
                                  : verifiedStatus == 2
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            left: 5,
                                          ),
                                          child: Image.asset(
                                              'lib/assets/verif2.png',
                                              height: 15),
                                        )
                                      : verifiedStatus == 1
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  left: 2.5, top: 2.5),
                                              child: Image.asset(
                                                  'lib/assets/verif.png',
                                                  height: 25),
                                            )
                                          : Text("")
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(course1['email'],
                              style: TextStyle(
                                  fontSize: 12,
                                  color: TextThemes.ndBlue,
                                  decoration: TextDecoration.none)),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                ],
              )),
            ),
          );
        });
  }
}

class GoingListSegment extends StatefulWidget {
  dynamic moovId;
  GoingListSegment({Key key, @required this.moovId}) : super(key: key);

  @override
  _GoingListSegmentState createState() => _GoingListSegmentState(moovId);

  static of(BuildContext context) {}
}

class _GoingListSegmentState extends State<GoingListSegment>
    with SingleTickerProviderStateMixin {
  // TabController to control and switch tabs
  TabController _tabController;
  dynamic moovId;

  _GoingListSegmentState(this.moovId);

  // Current Index of tab
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController =
        new TabController(vsync: this, length: 2, initialIndex: _currentIndex);
    _tabController.animation
      ..addListener(() {
        setState(() {
          _currentIndex = (_tabController.animation.value)
              .round(); //_tabController.animation.value returns double
        });
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: TextThemes.ndBlue,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  new BoxShadow(
                    color: Colors.grey,
                    offset: new Offset(1.0, 1.0),
                  ),
                ],
              ),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Sign In Button
                  new FlatButton(
                    color: _currentIndex == 0 ? Colors.blue : Colors.white,
                    onPressed: () {
                      HapticFeedback.lightImpact();

                      _tabController.animateTo(0);
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                    child: new Text("All"),
                  ),
                  // Sign Up Button
                  new FlatButton(
                    color: _currentIndex == 1 ? Colors.blue : Colors.white,
                    onPressed: () {
                      HapticFeedback.lightImpact();

                      _tabController.animateTo(1);
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                    child: new Text("Friends"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Buttons extends StatefulWidget {
  dynamic moovId, likeCount;

  _Buttons(this.moovId);
  @override
  __ButtonsState createState() => __ButtonsState(this.moovId);
}

class __ButtonsState extends State<_Buttons> {
  bool positivePointAnimation = false;
  bool negativePointAnimation = false;
  bool positivePointAnimationUndecided = false;
  bool negativePointAnimationUndecided = false;
  bool positivePointAnimationNotGoing = false;
  bool negativePointAnimationNotGoing = false;
  dynamic moovId;

  __ButtonsState(this.moovId);

  int status;
  bool push = true;
  GlobalKey _buttonsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: archiveRef.doc(moovId).snapshots(),
        // ignore: missing_return
        builder: (context, snapshot) {
          // title = snapshot.data['title'];
          // pic = snapshot.data['pic'];
          if (!snapshot.hasData) return circularProgress();

          DocumentSnapshot course = snapshot.data;
          Map<String, dynamic> statuses = course['statuses'];
          int maxOccupancy = course['maxOccupancy'];
          int goingCount = course['going'].length;
          List<dynamic> goingList = course['going'];
          String postOwnerId = course['userId'];

          List<dynamic> statusesIds = statuses.keys.toList();

          List<dynamic> statusesValues = statuses.values.toList();
          List pushList = currentUser.pushSettings.values.toList();
          if (pushList[0] == false) {
            push = false;
          }

          if (statuses != null) {
            for (int i = 0; i < statuses.length; i++) {
              if (statusesIds[i] == currentUser.id) {
                if (statusesValues[i] == 1) {
                  status = 1;
                }
              }
            }
            if (statuses != null) {
              for (int i = 0; i < statuses.length; i++) {
                if (statusesIds[i] == currentUser.id) {
                  if (statusesValues[i] == 2) {
                    status = 2;
                  }
                }
              }
            }
            if (statuses != null) {
              for (int i = 0; i < statuses.length; i++) {
                if (statusesIds[i] == currentUser.id) {
                  if (statusesValues[i] == 3) {
                    status = 3;
                  }
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Stack(children: [
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: Colors.black)),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                      },
                      color: (status == 1) ? Colors.red : Colors.white,
                      padding: EdgeInsets.all(5.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Column(
                          children: [
                            Text('Not going'),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 3.0, top: 3.0),
                              child: Icon(Icons.directions_walk,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, bottom: 0.0),
                    child: Stack(children: [
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: Colors.black)),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
                        color:
                            (status == 2) ? Colors.yellow[600] : Colors.white,
                        padding: EdgeInsets.all(5.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3.0, right: 3),
                          child: Column(
                            children: [
                              Text('Undecided'),
                              Icon(Icons.accessibility,
                                  color: Colors.yellow[600], size: 30),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, bottom: 0.0),
                    child: Stack(children: [
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: Colors.black)),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
                        color: (status == 3) ? Colors.green : Colors.white,
                        padding: EdgeInsets.all(5.0),
                        child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Column(
                              children: [
                                Text('Going'),
                                Icon(Icons.directions_run_outlined,
                                    color: Colors.green[500], size: 30),
                              ],
                            )),
                      ),
                    ]),
                  ),
                ],
              ),
            );
          }
        });
  }

  void showMax(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("This MOOV is currently full",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nHate to see it"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Fuck me", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);

              // Database().deletePost(postId, userId);
            },
          ),
          // CupertinoDialogAction(
          //   child: Text("Cancel"),
          //   onPressed: () => Navigator.of(context).pop(true),
          // )
        ],
      ),
    );
  }
}
