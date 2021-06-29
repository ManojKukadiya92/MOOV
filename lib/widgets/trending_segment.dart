import 'package:MOOV/main.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:MOOV/pages/home.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class TrendingSegment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TrendingSegmentState();
  }
}

class TrendingSegmentState extends State<TrendingSegment>
    with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;

  @override
  bool get wantKeepAlive => true;

  EasyRefreshController _controller;

  Map<int, Widget> map = new Map();
  @override
  void initState() {
    super.initState();
    loadCupertinoTabs();
    _controller = EasyRefreshController();
  }

  void loadCupertinoTabs() {
    map = new Map();
    map = {
      0: Container(
          width: 100,
          child: Center(
            child: Text(
              "Featured",
              style: TextStyle(color: Colors.white),
            ),
          )),
      1: Container(
          width: 100,
          child: Center(
            child: Text(
              "All",
              style: TextStyle(color: Colors.white),
            ),
          )),
      2: Container(
          width: 100,
          child: Center(
            child: Text(
              "Friends",
              style: TextStyle(color: Colors.white),
            ),
          ))
    };
  }

  // int id=0;
  // void refreshData() {
  //   id++;
  // }
  Future request(String type, bool other) async => await Future.delayed(
        const Duration(milliseconds: 500),
        !other
            ? () => postsRef
                .where('type', isEqualTo: type)
                .where('privacy', isEqualTo: "Public")
                .orderBy("goingCount", descending: true)
                .limit(6)
                .get()
            : () => postsRef
                .where('isPartyOrBar', isEqualTo: false)
                .where('privacy', isEqualTo: 'Public')
                .orderBy("goingCount", descending: true)
                .limit(6)
                .get(),
      );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isLargePhone = Screen.diagonal(context) > 766;
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Colors.pinkAccent[200], TextThemes.ndBlue])),
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text('T R E N D I N G',
                    style: GoogleFonts.sriracha(
                        color: Colors.white, fontSize: 30)),
              ))),
          Expanded(
            child: EasyRefresh(
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 1), () {
                  _controller.resetLoadState();
                });
              },
              onLoad: () async {
                await Future.delayed(Duration(seconds: 1), () {
                  setState(() {
                    // refreshData();
                    setState(() {});
                  });
                  _controller.finishLoad();
                });
              },
              enableControlFinishRefresh: false,
              enableControlFinishLoad: true,
              controller: _controller,
              header: BezierCircleHeader(
                  color: Colors.pinkAccent[200],
                  backgroundColor: TextThemes.ndBlue),
              footer: BezierBounceFooter(backgroundColor: Colors.white),
              bottomBouncing: false,
              child: ListView(children: [
                SizedBox(height: 2.5),
                Container(
                  child: StreamBuilder(
                      stream: postsRef
                          .where('type', isEqualTo: "Food/Drink")
                          .where('privacy', isEqualTo: "Public")
                          .orderBy("goingCount", descending: true)
                          .limit(6)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data.docs.length == 0)
                          return Text('');

                        return Container(
                          height: (snapshot.data.docs.length <= 3 &&
                                  isLargePhone)
                              ? 200
                              : (snapshot.data.docs.length >= 3 && isLargePhone)
                                  ? 345
                                  : (snapshot.data.docs.length <= 3 &&
                                          !isLargePhone)
                                      ? 190
                                      : (snapshot.data.docs.length >= 3 &&
                                              !isLargePhone)
                                          ? 310
                                          : 350,
                          child: Column(
                            children: [
                              Expanded(
                                  child: CustomScrollView(
                                physics: NeverScrollableScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                            'lib/assets/icons/BarICON.png',
                                            height: 35),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text('Food/Drink',
                                              style: TextThemes.extraBold),
                                        ),
                                      ],
                                    ),
                                  )),
                                  SliverGrid(
                                      delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                        DocumentSnapshot course =
                                            snapshot.data.docs[index];

                                        return PostOnTrending(course);
                                      }, childCount: snapshot.data.docs.length),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                      )),
                                ],
                              )),
                            ],
                          ),
                        );
                      }),
                ),
                Container(
                  child: StreamBuilder(
                      stream: postsRef
                          .where('type', isEqualTo: "Parties")
                          .where("privacy", isEqualTo: "Public")
                          .orderBy("goingCount", descending: true)
                          .limit(6)
                          .snapshots(),
                      builder: (context, snapshot) {
                        bool hide = false;
                        if (!snapshot.hasData || snapshot.data.docs.length == 0)
                          return Text('');

                        return Container(
                          height: (snapshot.data.docs.length <= 3 &&
                                  isLargePhone)
                              ? 200
                              : (snapshot.data.docs.length >= 3 && isLargePhone)
                                  ? 345
                                  : (snapshot.data.docs.length <= 3 &&
                                          !isLargePhone)
                                      ? 190
                                      : (snapshot.data.docs.length >= 3 &&
                                              !isLargePhone)
                                          ? 310
                                          : 350,
                          child: Column(
                            children: [
                              Expanded(
                                  child: CustomScrollView(
                                physics: NeverScrollableScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                            'lib/assets/icons/HangoutsICON.png',
                                            height: 25.5),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text('Hangouts',
                                              style: TextThemes.extraBold),
                                        ),
                                      ],
                                    ),
                                  )),
                                  SliverGrid(
                                      delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                        DocumentSnapshot course =
                                            snapshot.data.docs[index];
                                        if (course['privacy'] ==
                                                "Friends Only" ||
                                            course['privacy'] ==
                                                "Invite Only") {
                                          hide = true;
                                        }

                                        return (hide == false)
                                            ? PostOnTrending(course)
                                            : Container();
                                      }, childCount: snapshot.data.docs.length),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                      )),
                                ],
                              )),
                            ],
                          ),
                        );
                      }),
                ),
                Container(
                  child: StreamBuilder(
                      stream: postsRef
                          .where('isPartyOrBar', isEqualTo: false)
                          .where('privacy', isEqualTo: 'Public')
                          .orderBy("goingCount", descending: true)
                          .limit(6)
                          .snapshots(),
                      builder: (context, snapshot) {
                        bool hide = false;
                        if (!snapshot.hasData || snapshot.data.docs.length == 0)
                          return Container();

                        return Container(
                          height: (snapshot.data.docs.length <= 3 &&
                                  isLargePhone)
                              ? 210
                              : (snapshot.data.docs.length >= 3 && isLargePhone)
                                  ? 345
                                  : (snapshot.data.docs.length <= 3 &&
                                          !isLargePhone)
                                      ? 190
                                      : (snapshot.data.docs.length >= 3 &&
                                              !isLargePhone)
                                          ? 310
                                          : 350,
                          child: Column(
                            children: [
                              Expanded(
                                  child: CustomScrollView(
                                physics: NeverScrollableScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 2.0),
                                          child: Image.asset(
                                              'lib/assets/icons/ShowICON.png',
                                              height: 40),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, top: 5),
                                          child: Text('More',
                                              style: TextThemes.extraBold),
                                        ),
                                      ],
                                    ),
                                  )),
                                  SliverGrid(
                                      delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                        DocumentSnapshot course =
                                            snapshot.data.docs[index];
                                        if (course['privacy'] ==
                                                "Friends Only" ||
                                            course['privacy'] ==
                                                "Invite Only") {
                                          hide = true;
                                        }

                                        return (hide == false)
                                            ? PostOnTrending(course)
                                            : Container();
                                      }, childCount: snapshot.data.docs.length),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                      )),
                                ],
                              )),
                            ],
                          ),
                        );
                      }),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class PostOnTrending extends StatelessWidget {
  final DocumentSnapshot course;

  PostOnTrending(this.course);

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Container(
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: OpenContainer(
          transitionType: ContainerTransitionType.fade,
          transitionDuration: Duration(milliseconds: 500),
          openBuilder: (context, _) => PostDetail(course.id),
          closedElevation: 0,
          closedBuilder: (context, _) => Stack(
            children: <Widget>[
              InkWell(
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(alignment: Alignment.center, children: [
                        Container(
                          height: 500,
                          child: CachedNetworkImage(
                            memCacheHeight: 100,
                            memCacheWidth: 100,
                            imageUrl: course['image'],
                            fit: BoxFit.cover,
                            width: isLargePhone
                                ? MediaQuery.of(context).size.width * 0.315
                                : MediaQuery.of(context).size.width * 0.315,
                          ),
                        ),
                        Container(
                          alignment: Alignment(0.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
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
                              child: Text(
                                course['title'],
                                maxLines: 2,
                                style: TextStyle(
                                    fontFamily: 'Solway',
                                    color: Colors.white,
                                    fontSize: isLargePhone ? 13.0 : 10,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    Container(
                      height: 21,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Colors.pink[100], Colors.blue[100]])),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 4.0, top: 2.0),
                          //   child: CircleAvatar(
                          //     radius: 8.0,
                          //     backgroundImage: NetworkImage(
                          //       course['profilePic'],
                          //     ),
                          //     backgroundColor: Colors.transparent,
                          //   ),
                          // ),

                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                                DateFormat('EEE')
                                    .add_jm()
                                    .format(course['startDate'].toDate()),
                                style: TextStyle(
                                    fontFamily: 'Solway',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
