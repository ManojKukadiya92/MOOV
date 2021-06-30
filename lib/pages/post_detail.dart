import 'dart:async';
import 'dart:ui';
import 'package:MOOV/businessInterfaces/CrowdManagement.dart';
import 'package:MOOV/businessInterfaces/MobileOrdering.dart';
import 'package:MOOV/businessInterfaces/livePassesSheet.dart';
import 'package:MOOV/pages/MoovMaker.dart';
import 'package:MOOV/widgets/post_card_new.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/Comment.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:MOOV/pages/edit_post.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/widgets/pointAnimation.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:MOOV/widgets/send_moov.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:MOOV/widgets/going_statuses.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:page_transition/page_transition.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetail extends StatefulWidget {
  final String postId;
  PostDetail(this.postId);

  @override
  State<StatefulWidget> createState() {
    return _PostDetailState(this.postId);
  }
}

class _PostDetailState extends State<PostDetail>
    with SingleTickerProviderStateMixin {
  callback() {
    setState(() {});
  }

  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

  String postId;
  _PostDetailState(this.postId);
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

    // STRIPE INIT
    // StripePayment.setOptions(
    //   StripeOptions(
    //     publishableKey:
    //         'pk_test_51IaOZTLQOFOcsdSIxptB599XsntekECYQxHAUzKVvCkKYUTlTdnHHzZcoXknWcITerqCOHb2MGlnzse8QEWphopm00jBV1JxT0',
    //     merchantId: 'merchant.stripe.moov',
    //     androidPayMode: 'test',
    //   ),
    // );

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

  @override
  Widget build(BuildContext context) {
    bool isIncognito;

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
                floatingActionButton: FadeTransition(
                  opacity: _hideFabAnimController,
                  child: ScaleTransition(
                    scale: _hideFabAnimController,
                    child: FloatingActionButton.extended(
                        backgroundColor:
                            isIncognito ? Colors.black : Colors.white,
                        onPressed: () {
                          HapticFeedback.lightImpact();

                          isIncognito
                              ? usersRef.doc(currentUser.id).set({
                                  "privacySettings": {"incognito": false}
                                }, SetOptions(merge: true))
                              : usersRef.doc(currentUser.id).set({
                                  "privacySettings": {
                                    "incognito": true,
                                    "friendsOnly": false
                                  }
                                }, SetOptions(merge: true));
                        },
                        label: !isIncognito
                            ? Text("Go Incognito",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black))
                            : Row(
                                children: [
                                  Image.asset('lib/assets/incognito.png',
                                      height: 20),
                                  Text(" Incognito",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white)),
                                ],
                              )),
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                body: SafeArea(
                  top: false,
                  bottom: false,
                  child: Stack(children: [
                    StreamBuilder(
                        stream: postsRef.doc(postId).snapshots(),
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
                          int paymentAmount = course['paymentAmount'];
                          int goingCount = course['going'].length;
                          Map stats = course['stats'];

                          return Container(
                            color: Colors.white,
                            child: ListView(
                              physics: ClampingScrollPhysics(),
                              controller: _scrollController,
                              children: <Widget>[
                                _BannerImage(bannerImage, userId, postId,
                                    maxOccupancy, goingCount, stats),
                                _NonImageContents(
                                    title,
                                    description,
                                    startDate,
                                    address,
                                    userId,
                                    postId,
                                    course,
                                    commentCount,
                                    paymentAmount),
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
  final Map stats;
  _BannerImage(this.bannerImage, this.userId, this.postId, this.maxOccupancy,
      this.goingCount, this.stats);

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
            imageUrl: bannerImage,
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
          ),
        ),
      ),
      userId == currentUser.id ||
              currentUser.id == "108155010592087635288" ||
              currentUser.id == "118426518878481598299" ||
              currentUser.id == "107290090512658207959"
          ? Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EditPost(postId))),
                child: Container(
                  height: 45,
                  width: 70,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.red[300],
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      Text(
                        "Edit",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Text(''),
      maxOccupancy != null && maxOccupancy != 8000000 && maxOccupancy != 0
          ? Positioned(
              bottom: 10,
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
          : Container(),
      // stats.isNotEmpty
      //     ? Positioned(
      //         left: 5,
      //         bottom: 5,
      //         child: GestureDetector(
      //             onTap: () => Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                     builder: (context) => PostStats(postId))),
      //             child: Image.asset(
      //               'lib/assets/ratioChart.png',
      //               height: 50,
      //             )))
      //     : Container(),
      Positioned(
        bottom: 10,
        right: 5,
        child: userId != null ? PostOwnerInfo(userId) : Container(),
      ),
    ]);
  }
}

class _NonImageContents extends StatelessWidget {
  final String title, description, userId;
  final dynamic startDate, address, moovId;
  final DocumentSnapshot course;
  final int commentCount, paymentAmount;

  _NonImageContents(
      this.title,
      this.description,
      this.startDate,
      this.address,
      this.userId,
      this.moovId,
      this.course,
      this.commentCount,
      this.paymentAmount);

  double height = 0;

  @override
  Widget build(BuildContext context) {
    if (course['statuses'].containsKey(currentUser.id)) {
      height = 30;
    }
    Map mobileOrderMenu;
    if (course.data()['mobileOrderMenu'] != null) {
      mobileOrderMenu = course['mobileOrderMenu'];
    }
    return Container(
      //  margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Title(title),
          _Description(description),
          PostTimeAndPlace(startDate, address, course['paymentAmount'],
              course['userId'], course['postId']),
          // _AuthorContent(userId, course),
          PaySkipSendRow(
              course['paymentAmount'],
              course['moovOver'],
              mobileOrderMenu,
              course['userId'],
              moovId,
              course['tags'],
              course),
          CommentPreviewOnPost(
              postId: course['postId'], postOwnerId: course['userId']),
          // NeedARideButton(height),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.0),
            child: Container(
              height: 1.0,
              width: 500.0,
              color: Colors.grey[700],
            ),
          ),
          Buttons(moovId: moovId),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Container(
              height: 1.0,
              width: 500.0,
              color: Colors.grey[700],
            ),
          ),
          Stack(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 4.0),
                    child: Icon(Icons.directions_run, color: Colors.green),
                  ),
                  Text(
                    'Going List',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: TextThemes.ndBlue),
                  ),
                ],
              ),
            ),
            Positioned(
                right: 25,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    showComments(context,
                        postId: moovId,
                        ownerId: course['userId'],
                        mediaUrl: currentUser.photoUrl);
                  },
                  child: Column(
                    children: [
                      Icon(Icons.comment, size: 30, color: TextThemes.ndBlue),
                    ],
                  ),
                ))
          ]),
          GoingListSegment(moovId: moovId),
        ],
      ),
    );
  }
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

class _Title extends StatelessWidget {
  final String title;
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
  final String description;
  _Description(this.description);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 10.0, bottom: 15.0, left: 20, right: 20),
      child: Center(
        child: Linkify(
            onOpen: (link) async {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                throw 'Could not launch $link';
              }
            },
            text: description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class PostTimeAndPlace extends StatelessWidget {
  final dynamic startDate, address;
  final int paymentAmount;
  final String userId, moovId;

  PostTimeAndPlace(this.startDate, this.address, this.paymentAmount,
      this.userId, this.moovId);

  @override
  Widget build(BuildContext context) {
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
                      child: GestureDetector(
                        onTap: () => MapsLauncher.launchQuery(address),
                        child: Text(
                          address,
                          // textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.blue[800],
                              decoration: TextDecoration.underline),
                        ),
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
  final String userId;
  final DocumentSnapshot course;
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
                  Padding(
                    padding: isLargePhone
                        ? const EdgeInsets.only(right: 42.0, top: 10.0)
                        : const EdgeInsets.only(right: 30.0, top: 10.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(color: Colors.black)),
                      onPressed: () {
                        HapticFeedback.lightImpact();

                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: SendMOOVSearch(
                                  course['userId'],
                                  course['image'],
                                  course['startDate'],
                                  course['postId'],
                                  course['title'],
                                  course1['displayName'],
                                )));
                      },
                      color: Colors.white,
                      padding: EdgeInsets.all(5.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Column(
                          children: [
                            Text('Send'),
                            Icon(Icons.send_rounded,
                                color: Colors.blue[500], size: 25),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),
          );
        });
  }
}

class GoingListSegment extends StatefulWidget {
  final String moovId;
  GoingListSegment({Key key, @required this.moovId});

  static _GoingListSegmentState of(BuildContext context) =>
      context.findAncestorStateOfType<_GoingListSegmentState>();

  @override
  _GoingListSegmentState createState() => _GoingListSegmentState(moovId);
}

class _GoingListSegmentState extends State<GoingListSegment>
    with SingleTickerProviderStateMixin {
  dynamic _statusHeight = 0;
  set intt(dynamic value) => setState(() => _statusHeight = value);

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
      height: _statusHeight.toDouble() + 200 ?? 300,
      child: Column(
        children: <Widget>[
          //  Text((_statusHeight / 55).round().toString()),
          Padding(
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
          Expanded(
            child: TabBarView(controller: _tabController,
                // Restrict scroll by user
                children: [
                  Center(
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return GoingPage(moovId,
                              (val) => setState(() => _statusHeight = val));
                        }),
                  ),
                  Center(
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return GoingPageFriends(moovId,
                              (val) => setState(() => _statusHeight = val));
                        }),
                  )
                ]),
          )
        ],
      ),
    );
  }
}

class PaySkipSendRow extends StatelessWidget {
  final int paymentAmount;
  final bool moovOver;
  final Map menu;
  final String userId, postId;
  final List tags;
  final DocumentSnapshot course;
  PaySkipSendRow(this.paymentAmount, this.moovOver, this.menu, this.userId,
      this.postId, this.tags, this.course);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tags.contains('deal') ? 60 : 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          paymentAmount != null && paymentAmount != 0
              ? GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();

                    bool haveAlready = false;

                    List livePasses = [];
                    Map oneLivePass =
                        {}; //if user clicks on show pass, only show that pass

                    usersRef
                        .doc(currentUser.id)
                        .collection("livePasses")
                        .where("postId", isEqualTo: postId)
                        .get()
                        .then((value) {
                      for (int i = 0; i < value.docs.length; i++) {
                        if (value.docs.length != 0 &&
                            value.docs[i]['type'] == 'nondealCost') {
                          oneLivePass = value.docs[i].data();

                          haveAlready = true;
                        }
                      }

                      showBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          builder: (context) => PayNondealCostBottomSheet(
                              userId,
                              course['posterName'],
                              course['startDate'],
                              postId,
                              livePasses,
                              oneLivePass,
                              haveAlready,
                              paymentAmount,
                              course['maxOccupancy']));
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 3.0),
                    child: Icon(Icons.attach_money, color: Colors.orange),
                  ))
              : Container(),
          menu != null && (menu['item1'] || menu['item2'] || menu['item3'])
              ? Padding(
                  padding: const EdgeInsets.only(left: 10, right: 7.5),
                  child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MobileOrdering(
                                  userId: userId, postId: postId))),
                      child: Icon(Icons.menu_book, color: Colors.purple)),
                )
              : Container(),
          tags.contains('deal') && course['dealLimit'] > 0
              ? DealButton(
                  postId: postId,
                  businessUserId: course['userId'],
                  businessName: course['posterName'],
                  startDate: course['startDate'],
                  dealCost: course['dealCost'],
                  dealLimit: course['dealLimit'],
                )
              : Container(),
          moovOver
              ? Padding(
                  padding: const EdgeInsets.only(left: 7.5, right: 10),
                  child: GestureDetector(
                    onTap: () {
                      //check to see if they have the pass already
                      List livePasses = [];
                      Map oneLivePass = {}; //take to specific pass
                      usersRef
                          .doc(currentUser.id)
                          .collection("livePasses")
                          .where("postId", isEqualTo: postId)
                          .get()
                          .then((value) {
                        bool haveAlready = false;

                        for (int i = 0; i < value.docs.length; i++) {
                          if (value.docs.length != 0 &&
                              value.docs[i]['type'] == "MOOV Over Pass") {
                            oneLivePass = value.docs[i].data();
                            haveAlready = true;
                          }
                        }

                        showBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            builder: (context) => BuyMoovOverPassSheet(
                                businessUserId: userId,
                                businessName: course['posterName'],
                                startDate: course['startDate'],
                                postId: postId,
                                haveAlready: haveAlready,
                                livePasses: livePasses,
                                oneLivePass: oneLivePass));
                      });
                    },
                    child: GradientIcon(
                        Icons.confirmation_num_outlined,
                        35.0,
                        LinearGradient(
                          colors: <Color>[
                            Colors.red,
                            Colors.yellow,
                            Colors.blue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )),
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();

                  postsRef.doc(postId).get().then((value) {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.bottomToTop,
                            child: SendMOOVSearch(
                              value['userId'],
                              value['image'],
                              value['startDate'],
                              value['postId'],
                              value['title'],
                              value['posterName'],
                            )));
                  });
                },
                child: Icon(Icons.send, color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}

class Buttons extends StatefulWidget {
  final dynamic moovId;
  final String text = 'https://www.whatsthemoov.com';

  Buttons({Key key, this.moovId});
  @override
  _ButtonsState createState() => _ButtonsState(this.moovId);
}

class _ButtonsState extends State<Buttons> {
  bool positivePointAnimation = false;
  bool negativePointAnimation = false;
  bool positivePointAnimationUndecided = false;
  bool negativePointAnimationUndecided = false;
  bool positivePointAnimationNotGoing = false;
  bool negativePointAnimationNotGoing = false;
  dynamic moovId;
  double height = 40;

  changeScore(String postOwnerId, bool increment) {
    increment //for status responder
        ? usersRef
            .doc(currentUser.id)
            .update({"score": FieldValue.increment(30)})
        : usersRef
            .doc(currentUser.id)
            .update({"score": FieldValue.increment(-30)});

    increment //for post owner
        ? usersRef.doc(postOwnerId).update({"score": FieldValue.increment(10)})
        : usersRef
            .doc(postOwnerId)
            .update({"score": FieldValue.increment(-10)});
  }

  _ButtonsState(this.moovId);

  int status;
  bool push = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: postsRef.doc(moovId).snapshots(),
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
          String title = course['title'];

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
                        if (statuses != null && status == 1) {
                          changeScore(postOwnerId, false);
                        }
                        if (statuses != null && status != 1) {
                          positivePointAnimationNotGoing = true;
                          if (status == 3) {
                            //if youre switching statuses we dont double count
                            negativePointAnimation = true;
                            Timer(Duration(seconds: 2), () {
                              setState(() {
                                negativePointAnimation = false;
                              });
                            });
                          }
                          if (status == 2) {
                            //if youre switching statuses we dont double count
                            negativePointAnimationUndecided = true;
                            Timer(Duration(seconds: 2), () {
                              setState(() {
                                negativePointAnimationUndecided = false;
                              });
                            });
                          }

                          Timer(Duration(seconds: 2), () {
                            setState(() {
                              positivePointAnimationNotGoing = false;
                            });
                          });
                          Database().addNotGoing(
                              currentUser.id, moovId, goingList, title);
                          if (status != 3 && status != 2) {
                            changeScore(postOwnerId, true);
                          }
                          status = 1;
                          print(status);
                        } else if (statuses != null && status == 1) {
                          negativePointAnimationNotGoing = true;

                          Timer(Duration(seconds: 2), () {
                            setState(() {
                              negativePointAnimationNotGoing = false;
                            });
                          });

                          Database().removeNotGoing(currentUser.id, moovId);
                          status = 0;
                        }
                      },
                      color: (status == 1) ? Colors.red : Colors.white,
                      padding: EdgeInsets.all(5.0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: (status == 1)
                            ? Column(
                                children: [
                                  Text(
                                    'Not going',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 3.0, top: 3.0),
                                    child: Icon(Icons.directions_run,
                                        color: Colors.white),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Text('Not going'),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 3.0, top: 3.0),
                                    child: Icon(Icons.directions_walk,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    TranslationAnimatedWidget(
                        enabled: this
                            .positivePointAnimationNotGoing, //update this boolean to forward/reverse the animation
                        values: [
                          Offset(20, -20), // disabled value value
                          Offset(20, -20), //intermediate value
                          Offset(20, -40) //enabled value
                        ],
                        child: OpacityAnimatedWidget.tween(
                            opacityEnabled: 1, //define start value
                            opacityDisabled: 0, //and end value
                            enabled: positivePointAnimationNotGoing,
                            child: PointAnimation(30, true))),
                    TranslationAnimatedWidget(
                        enabled: this
                            .negativePointAnimationNotGoing, //update this boolean to forward/reverse the animation
                        values: [
                          Offset(20, -20), // disabled value value
                          Offset(20, -20), //intermediate value
                          Offset(20, -40) //enabled value
                        ],
                        child: OpacityAnimatedWidget.tween(
                            opacityEnabled: 1, //define start value
                            opacityDisabled: 0, //and end value
                            enabled: negativePointAnimationNotGoing,
                            child: PointAnimation(30, false))),
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

                          if (statuses != null && status == 2) {
                            changeScore(postOwnerId, false);
                          }
                          if (statuses != null && status != 2) {
                            positivePointAnimationUndecided = true;
                            if (status == 3) {
                              //if youre switching statuses we dont double count
                              negativePointAnimation = true;
                              Timer(Duration(seconds: 2), () {
                                setState(() {
                                  negativePointAnimation = false;
                                });
                              });
                            }
                            if (status == 1) {
                              //if youre switching statuses we dont double count
                              negativePointAnimationNotGoing = true;
                              Timer(Duration(seconds: 2), () {
                                setState(() {
                                  negativePointAnimationNotGoing = false;
                                });
                              });
                            }

                            Timer(Duration(seconds: 2), () {
                              setState(() {
                                positivePointAnimationUndecided = false;
                              });
                            });
                            Database().addUndecided(
                                currentUser.id, moovId, goingList, title);
                            if (status != 1 && status != 3) {
                              changeScore(postOwnerId, true);
                            }
                            status = 2;
                            print(status);
                          } else if (statuses != null && status == 2) {
                            negativePointAnimationUndecided = true;

                            Timer(Duration(seconds: 2), () {
                              setState(() {
                                negativePointAnimationUndecided = false;
                              });
                            });
                            Database().removeUndecided(currentUser.id, moovId);

                            status = 0;
                          }
                        },
                        color:
                            (status == 2) ? Colors.yellow[600] : Colors.white,
                        padding: EdgeInsets.all(5.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3.0, right: 3),
                          child: (status == 2)
                              ? Column(
                                  children: [
                                    Text('Undecided',
                                        style: TextStyle(color: Colors.white)),
                                    Icon(Icons.accessibility,
                                        color: Colors.white, size: 30),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Text('Undecided'),
                                    Icon(Icons.accessibility,
                                        color: Colors.yellow[600], size: 30),
                                  ],
                                ),
                        ),
                      ),
                      TranslationAnimatedWidget(
                          enabled: this
                              .positivePointAnimationUndecided, //update this boolean to forward/reverse the animation
                          values: [
                            Offset(20, -20), // disabled value value
                            Offset(20, -20), //intermediate value
                            Offset(20, -40) //enabled value
                          ],
                          child: OpacityAnimatedWidget.tween(
                              opacityEnabled: 1, //define start value
                              opacityDisabled: 0, //and end value
                              enabled: positivePointAnimationUndecided,
                              child: PointAnimation(30, true))),
                      TranslationAnimatedWidget(
                          enabled: this
                              .negativePointAnimationUndecided, //update this boolean to forward/reverse the animation
                          values: [
                            Offset(20, -20), // disabled value value
                            Offset(20, -20), //intermediate value
                            Offset(20, -40) //enabled value
                          ],
                          child: OpacityAnimatedWidget.tween(
                              opacityEnabled: 1, //define start value
                              opacityDisabled: 0, //and end value
                              enabled: negativePointAnimationUndecided,
                              child: PointAnimation(30, false))),
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

                          if (statuses != null && status == 3) {
                            changeScore(postOwnerId, false);
                          }
                          if (goingCount == maxOccupancy && status != 3) {
                            showMax(context);
                          }
                          if (statuses != null &&
                              status != 3 &&
                              goingCount < maxOccupancy) {
                            positivePointAnimation = true;
                            if (status == 2) {
                              //if youre switching statuses we dont double count
                              negativePointAnimationUndecided = true;
                              Timer(Duration(seconds: 2), () {
                                setState(() {
                                  negativePointAnimationUndecided = false;
                                });
                              });
                            }
                            if (status == 1) {
                              //if youre switching statuses we dont double count
                              negativePointAnimationNotGoing = true;
                              Timer(Duration(seconds: 2), () {
                                setState(() {
                                  negativePointAnimationNotGoing = false;
                                });
                              });
                            }

                            Timer(Duration(seconds: 2), () {
                              setState(() {
                                positivePointAnimation = false;
                              });
                            });

                            Database().addGoingGood(
                                currentUser.id,
                                course['userId'],
                                moovId,
                                course['title'],
                                course['image'],
                                course['push']);
                            if (status != 1 && status != 2) {
                              changeScore(postOwnerId, true);
                            }
                            //ask about RideShare
                            // setState(() {
                            //   widget.needRideHeight = 40;
                            // });

                            status = 3;
                            print(status);
                          } else if (statuses != null && status == 3) {
                            negativePointAnimation = true;

                            Timer(Duration(seconds: 2), () {
                              setState(() {
                                negativePointAnimation = false;
                              });
                            });
                            Database().removeGoingGood(
                                currentUser.id,
                                course['userId'],
                                moovId,
                                course['title'],
                                course['image']);
                            status = 0;
                          }
                        },
                        color: (status == 3) ? Colors.green : Colors.white,
                        padding: EdgeInsets.all(5.0),
                        child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: (status == 3)
                                ? Column(
                                    children: [
                                      Text('Going!',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      Icon(Icons.directions_run_outlined,
                                          color: Colors.white, size: 30),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Text('Going'),
                                      Icon(Icons.directions_run_outlined,
                                          color: Colors.green[500], size: 30),
                                    ],
                                  )),
                      ),
                      TranslationAnimatedWidget(
                          enabled: this
                              .positivePointAnimation, //update this boolean to forward/reverse the animation
                          values: [
                            Offset(20, -20), // disabled value value
                            Offset(20, -20), //intermediate value
                            Offset(20, -40) //enabled value
                          ],
                          child: OpacityAnimatedWidget.tween(
                              opacityEnabled: 1, //define start value
                              opacityDisabled: 0, //and end value
                              enabled: positivePointAnimation,
                              child: PointAnimation(30, true))),
                      TranslationAnimatedWidget(
                          enabled: this
                              .negativePointAnimation, //update this boolean to forward/reverse the animation
                          values: [
                            Offset(20, -20), // disabled value value
                            Offset(20, -20), //intermediate value
                            Offset(20, -40) //enabled value
                          ],
                          child: OpacityAnimatedWidget.tween(
                              opacityEnabled: 1, //define start value
                              opacityDisabled: 0, //and end value
                              enabled: negativePointAnimation,
                              child: PointAnimation(30, false))),
                    ]),
                  ),
                ],
              ),
            );
          }
        });
  }
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
          child: Text("Damn, okay", style: TextStyle(color: Colors.red)),
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

// // STRIPE ERROR AND CONFIRMATION HANDLER
// class ShowDialogToDismiss extends StatelessWidget {
//   final String content;
//   final String title;
//   final String buttonText;
//   ShowDialogToDismiss({this.title, this.buttonText, this.content});
//   @override
//   Widget build(BuildContext context) {
//     if (!Platform.isIOS) {
//       return AlertDialog(
//         title: new Text(
//           title,
//         ),
//         content: new Text(
//           this.content,
//         ),
//         actions: <Widget>[
//           new FlatButton(
//             child: new Text(
//               buttonText,
//             ),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     } else {
//       return CupertinoAlertDialog(
//           title: Text(
//             title,
//           ),
//           content: new Text(
//             this.content,
//           ),
//           actions: <Widget>[
//             CupertinoDialogAction(
//               isDefaultAction: true,
//               child: new Text(
//                 buttonText[0].toUpperCase() +
//                     buttonText.substring(1).toLowerCase(),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             )
//           ]);
//     }
//   }
// }

// class PaymentButton extends StatefulWidget {
//   final String postId;
//   PaymentButton(this.postId);

//   @override
//   _PaymentButtonState createState() => _PaymentButtonState();
// }

// class _PaymentButtonState extends State<PaymentButton> {
//   // STRIPE INIT
//   String text = 'Click the button to start the payment';
//   double totalCost = 10.0;
//   double tip = 1.0;
//   double tax = 0.0;
//   double taxPercent = 0.2;
//   int amount = 0;
//   bool showSpinner = false;
//   String url =
//       'https://us-central1-demostripe-b9557.cloudfunctions.net/StripePI';

//   // STRIPE check if device is ready for payment
//   // void checkIfNativePayReady() async {
//   //   print('started to check if native pay ready');
//   //   bool deviceSupportNativePay = await StripePayment.deviceSupportsNativePay();
//   //   bool isNativeReady = await StripePayment.canMakeNativePayPayments(
//   //       ['american_express', 'visa', 'maestro', 'master_card']);
//   //   deviceSupportNativePay && isNativeReady
//   //       ? createPaymentMethodNative()
//   //       : createPaymentMethod();
//   // }

//   // Future<void> createPaymentMethodNative() async {
//   //   print('started NATIVE payment...');
//   //   StripePayment.setStripeAccount(null);
//   //   List<ApplePayItem> items = [];
//   //   items.add(ApplePayItem(
//   //     label: 'Demo Order',
//   //     amount: totalCost.toString(),
//   //   ));
//   //   if (tip != 0.0)
//   //     items.add(ApplePayItem(
//   //       label: 'Tip',
//   //       amount: tip.toString(),
//   //     ));
//   //   if (taxPercent != 0.0) {
//   //     tax = ((totalCost * taxPercent) * 100).ceil() / 100;
//   //     items.add(ApplePayItem(
//   //       label: 'Tax',
//   //       amount: tax.toString(),
//   //     ));
//   //   }
//   //   items.add(ApplePayItem(
//   //     label: 'Vendor A',
//   //     amount: (totalCost + tip + tax).toString(),
//   //   ));
//   //   amount = ((totalCost + tip + tax) * 100).toInt();
//   //   print('amount in pence/cent which will be charged = $amount');
//   //   //step 1: add card
//   //   PaymentMethod paymentMethod = PaymentMethod();
//   //   Token token = await StripePayment.paymentRequestWithNativePay(
//   //     androidPayOptions: AndroidPayPaymentRequest(
//   //       totalPrice: (totalCost + tax + tip).toStringAsFixed(2),
//   //       currencyCode: 'US',
//   //     ),
//   //     applePayOptions: ApplePayPaymentOptions(
//   //       countryCode: 'US',
//   //       currencyCode: 'USD',
//   //       items: items,
//   //     ),
//   //   );
//   //   paymentMethod = await StripePayment.createPaymentMethod(
//   //     PaymentMethodRequest(
//   //       card: CreditCard(
//   //         token: token.tokenId,
//   //       ),
//   //     ),
//   //   );
//   //   paymentMethod != null
//   //       ? processPaymentAsDirectCharge(paymentMethod)
//   //       : showDialog(
//   //           context: context,
//   //           builder: (BuildContext context) => ShowDialogToDismiss(
//   //               title: 'Error',
//   //               content:
//   //                   'It is not possible to pay with this card. Please try again with a different card',
//   //               buttonText: 'CLOSE'));
//   // }

//   // Future<void> createPaymentMethod() async {
//   //   StripePayment.setStripeAccount(null);
//   //   tax = ((totalCost * taxPercent) * 100).ceil() / 100;
//   //   amount = ((totalCost + tip + tax) * 100).toInt();
//   //   print('amount in pence/cent which will be charged = $amount');
//   //   //step 1: add card
//   //   PaymentMethod paymentMethod = PaymentMethod();
//   //   paymentMethod = await StripePayment.paymentRequestWithCardForm(
//   //     CardFormPaymentRequest(),
//   //   ).then((PaymentMethod paymentMethod) {
//   //     return paymentMethod;
//   //   }).catchError((e) {
//   //     print('Errore Card: ${e.toString()}');
//   //   });
//   //   paymentMethod != null
//   //       ? processPaymentAsDirectCharge(paymentMethod)
//   //       : showDialog(
//   //           context: context,
//   //           builder: (BuildContext context) => ShowDialogToDismiss(
//   //               title: 'Error',
//   //               content:
//   //                   'It is not possible to pay with this card. Please try again with a different card',
//   //               buttonText: 'CLOSE'));
//   // }

//   // Future<void> processPaymentAsDirectCharge(PaymentMethod paymentMethod) async {
//   //   setState(() {
//   //     showSpinner = true;
//   //   });
//   //   //step 2: request to create PaymentIntent, attempt to confirm the payment & return PaymentIntent
//   //   final http.Response response = await http
//   //       .post('$url?amount=$amount&currency=GBP&paym=${paymentMethod.id}');
//   //   print('Now i decode');
//   //   if (response.body != null && response.body != 'error') {
//   //     final paymentIntentX = jsonDecode(response.body);
//   //     final status = paymentIntentX['paymentIntent']['status'];
//   //     final strAccount = paymentIntentX['stripeAccount'];
//   //     //step 3: check if payment was succesfully confirmed
//   //     if (status == 'succeeded') {
//   //       //payment was confirmed by the server without need for futher authentification
//   //       StripePayment.completeNativePayRequest();
//   //       setState(() {
//   //         text =
//   //             'Payment completed. ${paymentIntentX['paymentIntent']['amount'].toString()}p succesfully charged';
//   //         showSpinner = false;
//   //       });
//   //     } else {
//   //       //step 4: there is a need to authenticate
//   //       StripePayment.setStripeAccount(strAccount);
//   //       await StripePayment.confirmPaymentIntent(PaymentIntent(
//   //               paymentMethodId: paymentIntentX['paymentIntent']
//   //                   ['payment_method'],
//   //               clientSecret: paymentIntentX['paymentIntent']['client_secret']))
//   //           .then(
//   //         (PaymentIntentResult paymentIntentResult) async {
//   //           //This code will be executed if the authentication is successful
//   //           //step 5: request the server to confirm the payment with
//   //           final statusFinal = paymentIntentResult.status;
//   //           if (statusFinal == 'succeeded') {
//   //             StripePayment.completeNativePayRequest();
//   //             setState(() {
//   //               showSpinner = false;
//   //             });
//   //           } else if (statusFinal == 'processing') {
//   //             StripePayment.cancelNativePayRequest();
//   //             setState(() {
//   //               showSpinner = false;
//   //             });
//   //             showDialog(
//   //                 context: context,
//   //                 builder: (BuildContext context) => ShowDialogToDismiss(
//   //                     title: 'Warning',
//   //                     content:
//   //                         'The payment is still in \'processing\' state. This is unusual. Please contact us',
//   //                     buttonText: 'CLOSE'));
//   //           } else {
//   //             StripePayment.cancelNativePayRequest();
//   //             setState(() {
//   //               showSpinner = false;
//   //             });
//   //             showDialog(
//   //                 context: context,
//   //                 builder: (BuildContext context) => ShowDialogToDismiss(
//   //                     title: 'Error',
//   //                     content:
//   //                         'There was an error to confirm the payment. Details: $statusFinal',
//   //                     buttonText: 'CLOSE'));
//   //           }
//   //         },
//   //         //If Authentication fails, a PlatformException will be raised which can be handled here
//   //       ).catchError((e) {
//   //         //case B1
//   //         StripePayment.cancelNativePayRequest();
//   //         setState(() {
//   //           showSpinner = false;
//   //         });
//   //         showDialog(
//   //             context: context,
//   //             builder: (BuildContext context) => ShowDialogToDismiss(
//   //                 title: 'Error',
//   //                 content:
//   //                     'There was an error to confirm the payment. Please try again with another card',
//   //                 buttonText: 'CLOSE'));
//   //       });
//   //     }
//   //   } else {
//   //     //case A
//   //     StripePayment.cancelNativePayRequest();
//   //     setState(() {
//   //       showSpinner = false;
//   //     });
//   //     showDialog(
//   //         context: context,
//   //         builder: (BuildContext context) => ShowDialogToDismiss(
//   //             title: 'Error',
//   //             content:
//   //                 'There was an error in creating the payment. Please try again with another card',
//   //             buttonText: 'CLOSE'));
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: postsRef.doc(widget.postId).snapshots(),
//         // ignore: missing_return
//         builder: (context, snapshot) {
//           // title = snapshot.data['title'];
//           // pic = snapshot.data['pic'];
//           if (!snapshot.hasData) return circularProgress();

//           DocumentSnapshot course = snapshot.data;
//           Map<String, dynamic> statuses = course['statuses'];
//           int maxOccupancy = course['maxOccupancy'];
//           int goingCount = course['going'].length;
//           bool hasPaid = false;

//           if (statuses[currentUser.id] == 5) {
//             hasPaid = true;
//           }

//           return Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             // ignore: deprecated_member_use
//             child: RaisedButton(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                   side: BorderSide(color: Colors.black)),
//               onPressed: () {
//                 HapticFeedback.lightImpact();

//                 if (goingCount == maxOccupancy &&
//                     (statuses[currentUser.id] != 3 ||
//                         statuses[currentUser.id] != 4)) {
//                   showMax(context);
//                 }
//                 if (hasPaid == false) {
//                   //process payment HERE!!!
//                   //
//                   //
//                   // checkIfNativePayReady();
//                   //if successful, set button
//                   setState(() {});
//                 }
//               },
//               color: (hasPaid == true) ? Colors.orange[600] : Colors.white,
//               padding: EdgeInsets.all(5.0),
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 3.0, right: 3),
//                 child: (hasPaid == true)
//                     ? Column(
//                         children: [
//                           Text('Paid', style: TextStyle(color: Colors.white)),
//                           Icon(Icons.attach_money,
//                               color: Colors.white, size: 25),
//                         ],
//                       )
//                     : Column(
//                         children: [
//                           Text('Pay'),
//                           Icon(Icons.attach_money,
//                               color: Colors.orange[600], size: 25),
//                         ],
//                       ),
//               ),
//             ),
//           );
//         });
//   }
// }

class CommentPreviewOnPost extends StatelessWidget {
  final String postId, postOwnerId;
  final bool fromCommunity;
  const CommentPreviewOnPost(
      {this.postId, this.postOwnerId, this.fromCommunity = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showComments(
          context,
          postId: postId,
          ownerId: postOwnerId,
        );
      },
      child: StreamBuilder(
          stream: postsRef.doc(postId).collection('comments').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            bool isLargePhone = Screen.diagonal(context) > 766;
            if (snapshot.data.docs.length == 0 && fromCommunity) {
              return ChatBubble(
                  alignment: Alignment.centerLeft,
                  clipper: ChatBubbleClipper5(type: BubbleType.sendBubble),
                  backGroundColor: Colors.blue[400],
                  margin: EdgeInsets.only(top: 20),
                  child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Text("talk about it..",
                          style: TextStyle(color: Colors.white))));
            }
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
                      width: fromCommunity
                          ? MediaQuery.of(context).size.width * .6
                          : MediaQuery.of(context).size.width,
                      color: Colors.grey[700],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: TextThemes.ndGold,
                            child: CircleAvatar(
                              // backgroundImage: snapshot.data
                              //     .documents[index].data['photoUrl'],
                              backgroundImage: NetworkImage(snapshot
                                      .data.docs[snapshot.data.docs.length - 1]
                                  ['avatarUrl']),
                              radius: 22,
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text("said")),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * .5,
                                child: Text(
                                  " \"" +
                                      snapshot.data.docs[
                                              snapshot.data.docs.length - 1]
                                          ['comment'] +
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
                  right: fromCommunity ? 37.5 : 5,
                  bottom: fromCommunity ? 20 : 5,
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
    );
  }
}

class DealButton extends StatefulWidget {
  final String postId, businessUserId, businessName;
  final int dealCost, dealLimit;
  final Timestamp startDate;

  DealButton(
      {this.postId,
      this.businessUserId,
      this.businessName,
      this.startDate,
      this.dealCost,
      this.dealLimit});

  @override
  _DealButtonState createState() => _DealButtonState();
}

class _DealButtonState extends State<DealButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        List livePasses = [];
        Map oneLivePass = {}; //if user clicks on show pass, only show that pass
        bool haveAlready = false;

        usersRef
            .doc(currentUser.id)
            .collection("livePasses")
            .where("postId", isEqualTo: widget.postId)
            .get()
            .then((value) {
          for (int i = 0; i < value.docs.length; i++) {
            if (value.docs.length != 0 && value.docs[i]['type'] == 'deal') {
              oneLivePass = value.docs[i].data();
              haveAlready = true;
            }
          }
          print(haveAlready);

          HapticFeedback.lightImpact();

          showBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              builder: (context) => RedeemDealBottomSheet(
                  widget.businessUserId,
                  widget.businessName,
                  widget.startDate,
                  widget.postId,
                  livePasses,
                  oneLivePass,
                  haveAlready,
                  widget.dealCost,
                  widget.dealLimit));
        });
      },
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
            width: 45,
            height: 45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_offer,
                  size: 20,
                  color: Colors.white,
                ),
                Text("DEAL",
                    style: TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TextThemes.ndBlue,
                boxShadow: [
                  BoxShadow(
                      color: Colors.amber,
                      blurRadius: _animation.value / 2,
                      spreadRadius: _animation.value / 2)
                ])),
      )),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class RedeemDealBottomSheet extends StatefulWidget {
  final String businessUserId, businessName, postId;
  final List livePasses;
  final Map oneLivePass;
  final bool haveAlready;
  final Timestamp startDate;
  final int dealCost, dealLimit;

  RedeemDealBottomSheet(
      this.businessUserId,
      this.businessName,
      this.startDate,
      this.postId,
      this.livePasses,
      this.oneLivePass,
      this.haveAlready,
      this.dealCost,
      this.dealLimit);

  @override
  _RedeemDealBottomSheetState createState() => _RedeemDealBottomSheetState();
}

class _RedeemDealBottomSheetState extends State<RedeemDealBottomSheet>
    with SingleTickerProviderStateMixin {
  var top = FractionalOffset.topCenter;
  var bottom = FractionalOffset.bottomCenter;
  var list = [TextThemes.ndBlue, TextThemes.ndGold];
  AnimationController _animationController;
  bool _confirming = false;
  bool _isLoading = false;
  bool _success = false;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.repeat(reverse: true);

    Tween(begin: 2.0, end: 15.0).animate(_animationController)
      ..addListener(() {
        setState(() {
          top = FractionalOffset.bottomLeft;
          bottom = FractionalOffset.topRight;
          list = [TextThemes.ndBlue, Colors.amber];
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (){

    // }
    return AnimatedContainer(
      height: 500,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: new LinearGradient(
            begin: top,
            end: bottom,
            colors: list,
            stops: [0.0, 1.0],
          ),
          color: Colors.lightGreen),
      duration: Duration(seconds: 2),
      child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Text(
            "MOOV Exclusive Deal™",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
          ),
          Text(
            "Only on MOOV.",
            style: TextStyle(
                fontStyle: FontStyle.italic, fontSize: 14, color: Colors.white),
          ),
          SizedBox(
            height: 40,
            child: Center(
                child: Text("${widget.dealLimit} left!",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ))),
          ),
          Container(
            height: 2,
            width: 100,
            color: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Container(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(143, 143, 143, 0.5),
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Redeem this deal and show your pass at the venue!\n\n\nIt's that easy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          !_confirming
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    elevation: 5.0,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (!widget.haveAlready) {
                      setState(() {
                        _confirming = true;
                      });
                    } else {
                      showBottomSheet(
                          context: context,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          builder: (context) => LivePassesSheet(
                                oneLivePassFromShowPass: widget.oneLivePass,
                              ));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.haveAlready
                        ? Text('Show Pass',
                            style: TextStyle(color: Colors.white))
                        : widget.dealCost == null || widget.dealCost == 0
                            ? Text('Claim',
                                style: TextStyle(color: Colors.white))
                            : Text('\$${widget.dealCost}',
                                style: TextStyle(color: Colors.white)),
                  ))
              : Column(
                  children: [
                    widget.dealCost == null
                        ? Text('\n\nConfirm:\n1x Deal     —     \$0',
                            style: TextStyle(color: Colors.white))
                        : Text(
                            '\n\nConfirm:\n1x Deal     —     \$${widget.dealCost}',
                            style: TextStyle(color: Colors.white)),
                    SizedBox(height: 5),
                    (_isLoading)
                        ? linearProgress()
                        : (_success)
                            ? Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.white,
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  elevation: 5.0,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  if (widget.dealCost != null &&
                                      currentUser.moovMoney < widget.dealCost) {
                                    showBottomSheet(
                                        backgroundColor: Colors.white,
                                        context: context,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        builder: (context) =>
                                            BottomSheetDeposit());
                                  } else {
                                    String passId = generateRandomString(20);

                                    if (widget.dealCost != null &&
                                        widget.dealCost > 0) {
                                      usersRef.doc(currentUser.id).set({
                                        "moovMoney": FieldValue.increment(
                                            -1 * widget.dealCost)
                                      }, SetOptions(merge: true));
                                      usersRef.doc(widget.businessUserId).set({
                                        "moovMoney": FieldValue.increment(
                                            widget.dealCost)
                                      }, SetOptions(merge: true));
                                    }

                                    postsRef.doc(widget.postId).update({
                                      "dealLimit": FieldValue.increment(-1)
                                    });

                                    //setting the dashboard for biz's
                                    businessDashboardRef
                                        .doc(widget.businessUserId)
                                        .collection('dashboard')
                                        .doc(widget.postId)
                                        .get()
                                        .then((value) {
                                      if (!value.exists) {
                                        businessDashboardRef
                                            .doc(widget.businessUserId)
                                            .collection('dashboard')
                                            .doc(widget.postId)
                                            .set({
                                          "totalEarnings": FieldValue.increment(
                                              widget.dealCost),
                                          "dealsRedeemed":
                                              FieldValue.increment(1),
                                          "dealRevenue": FieldValue.increment(
                                              widget.dealCost)
                                        }, SetOptions(merge: true));
                                      } else {
                                        businessDashboardRef
                                            .doc(widget.businessUserId)
                                            .collection('dashboard')
                                            .doc(widget.postId)
                                            .update({
                                          "totalEarnings": FieldValue.increment(
                                              widget.dealCost),
                                          "dealsRedeemed":
                                              FieldValue.increment(1),
                                          "dealRevenue": FieldValue.increment(
                                              widget.dealCost)
                                        });
                                      }
                                    });

                                    usersRef
                                        .doc(currentUser.id)
                                        .collection('livePasses')
                                        .doc(passId)
                                        .set({
                                      "type": "deal",
                                      "name": "DEAL",
                                      "businessName": widget.businessName,
                                      "startDate": widget.startDate,
                                      "price": widget.dealCost,
                                      "photo": currentUser.photoUrl,
                                      "time": Timestamp.now(),
                                      "businessId": widget.businessUserId,
                                      "postId": widget.postId,
                                      "passId": passId,
                                      "tip": 0
                                    }, SetOptions(merge: true)).then(
                                            (value) => setState(() {
                                                  _isLoading = false;
                                                  _success = true;
                                                }));
                                    Future.delayed(Duration(seconds: 2), () {
                                      Navigator.pop(context);
                                    });
                                  }
                                },
                                child: widget.dealCost == null ||
                                        widget.dealCost == 0
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Redeem',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Buy',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ))
                  ],
                ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class PayNondealCostBottomSheet extends StatefulWidget {
  final String businessUserId, businessName, postId;
  final List livePasses;
  final Timestamp startDate;
  final Map oneLivePass;
  final bool haveAlready;
  final int nondealCost, dealLimit;

  PayNondealCostBottomSheet(
      this.businessUserId,
      this.businessName,
      this.startDate,
      this.postId,
      this.livePasses,
      this.oneLivePass,
      this.haveAlready,
      this.nondealCost,
      this.dealLimit);

  @override
  _PayNondealCostBottomSheetState createState() =>
      _PayNondealCostBottomSheetState();
}

class _PayNondealCostBottomSheetState extends State<PayNondealCostBottomSheet>
    with SingleTickerProviderStateMixin {
  var top = FractionalOffset.topCenter;
  var bottom = FractionalOffset.bottomCenter;
  var list = [Colors.orange, Colors.deepOrange];
  AnimationController _animationController;
  bool _confirming = false;
  bool _isLoading = false;
  bool _success = false;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.repeat(reverse: true);

    Tween(begin: 2.0, end: 15.0).animate(_animationController)
      ..addListener(() {
        setState(() {
          top = FractionalOffset.bottomLeft;
          bottom = FractionalOffset.topRight;
          list = [Colors.orange, Colors.deepOrange];
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (){

    // }
    return AnimatedContainer(
      height: 500,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: new LinearGradient(
            begin: top,
            end: bottom,
            colors: list,
            stops: [0.0, 1.0],
          ),
          color: Colors.lightGreen),
      duration: Duration(seconds: 2),
      child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Text(
            "Pay In Advance",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
          ),
          Text(
            "Only on MOOV.",
            style: TextStyle(
                fontStyle: FontStyle.italic, fontSize: 14, color: Colors.white),
          ),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Container(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(143, 143, 143, 0.5),
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Buy this pass and show it at your venue!\n\n\nIt's that easy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          !_confirming
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    elevation: 5.0,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (!widget.haveAlready) {
                      setState(() {
                        _confirming = true;
                      });
                    } else {
                      showBottomSheet(
                          context: context,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          builder: (context) => LivePassesSheet(
                              oneLivePassFromShowPass: widget.oneLivePass));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.haveAlready
                        ? Text('Show Pass',
                            style: TextStyle(color: Colors.white))
                        : widget.nondealCost == null || widget.nondealCost == 0
                            ? Text('Buy', style: TextStyle(color: Colors.white))
                            : Text('\$${widget.nondealCost}',
                                style: TextStyle(color: Colors.white)),
                  ))
              : Column(
                  children: [
                    widget.nondealCost == null
                        ? Text('\n\nConfirm:\n1x Payment     —     \$0',
                            style: TextStyle(color: Colors.white))
                        : Text(
                            '\n\nConfirm:\n1x Payment     —     \$${widget.nondealCost}',
                            style: TextStyle(color: Colors.white)),
                    SizedBox(height: 5),
                    (_isLoading)
                        ? linearProgress()
                        : (_success)
                            ? Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.white,
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.blue,
                                  elevation: 5.0,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  if (widget.nondealCost != null &&
                                      currentUser.moovMoney <
                                          widget.nondealCost) {
                                    showBottomSheet(
                                        backgroundColor: Colors.white,
                                        context: context,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        builder: (context) =>
                                            BottomSheetDeposit());
                                  } else {
                                    String passId = generateRandomString(20);

                                    if (widget.nondealCost != null &&
                                        widget.nondealCost > 0) {
                                      usersRef.doc(currentUser.id).set({
                                        "moovMoney": FieldValue.increment(
                                            -1 * widget.nondealCost)
                                      }, SetOptions(merge: true));
                                      usersRef.doc(widget.businessUserId).set({
                                        "moovMoney": FieldValue.increment(
                                            widget.nondealCost)
                                      }, SetOptions(merge: true));
                                    }

                                    //adding to biz dashboard

                                    businessDashboardRef
                                        .doc(widget.businessUserId)
                                        .collection('dashboard')
                                        .doc(widget.postId)
                                        .get()
                                        .then((value) {
                                      if (!value.exists) {
                                        businessDashboardRef
                                            .doc(widget.businessUserId)
                                            .collection('dashboard')
                                            .doc(widget.postId)
                                            .set({
                                          "totalEarnings": FieldValue.increment(
                                              widget.nondealCost),
                                          "nondealPaymentRevenue":
                                              FieldValue.increment(
                                                  widget.nondealCost),
                                          "distinctNondealPayments":
                                              FieldValue.increment(1)
                                        });
                                      } else {
                                        businessDashboardRef
                                            .doc(widget.businessUserId)
                                            .collection('dashboard')
                                            .doc(widget.postId)
                                            .update({
                                          "totalEarnings": FieldValue.increment(
                                              widget.nondealCost),
                                          "nondealPaymentRevenue":
                                              FieldValue.increment(
                                                  widget.nondealCost),
                                          "distinctNondealPayments":
                                              FieldValue.increment(1)
                                        });
                                      }
                                    });

                                    usersRef
                                        .doc(currentUser.id)
                                        .collection('livePasses')
                                        .doc(passId)
                                        .set({
                                      "type": "nondealCost",
                                      "name": "PAID — \$${widget.nondealCost}",
                                      "price": widget.nondealCost,
                                      "photo": currentUser.photoUrl,
                                      "time": Timestamp.now(),
                                      "businessId": widget.businessUserId,
                                      "businessName": widget.businessName,
                                      "startDate": widget.startDate,
                                      "postId": widget.postId,
                                      "passId": passId,
                                      "tip": 0
                                    }, SetOptions(merge: true)).then(
                                            (value) => setState(() {
                                                  _isLoading = false;
                                                  _success = true;
                                                }));
                                    Future.delayed(Duration(seconds: 2), () {
                                      Navigator.pop(context);
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Buy',
                                      style: TextStyle(color: Colors.white)),
                                ))
                  ],
                ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// class NeedARideButton extends StatefulWidget {
//   final double height;

//   NeedARideButton(this.height);
//   @override
//   _NeedARideButtonState createState() => _NeedARideButtonState();
// }

// class _NeedARideButtonState extends State<NeedARideButton> {
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: Duration(seconds: 1),
//       height: widget.height,
//     );
//   }
// }
