import 'package:MOOV/helpers/size_config.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class MOTD extends StatefulWidget {
  final String type, vibeType;

  MOTD(this.type, this.vibeType);

  @override
  _MOTDState createState() => _MOTDState();
}

class _MOTDState extends State<MOTD> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            postsRef.where("tags", arrayContains: widget.type + "All").get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          if (snapshot.data.docs.length == 0) {
            return FutureBuilder(
                future: postsRef
                    .where("tags", arrayContains: widget.type + widget.vibeType)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }

                  if (snapshot.data.docs.length == 0) {
                    return FutureBuilder(
                        future: postsRef
                            .where("goingCount", isGreaterThanOrEqualTo: 5)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          return MOTDUI(snapshot: snapshot);
                        });
                  }
                  return MOTDUI(snapshot: snapshot);
                });
          }
          return (MOTDUI(snapshot: snapshot));
        });
  }
}

class MOTDUI extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  const MOTDUI({this.snapshot});

  @override
  Widget build(BuildContext context) {
    String title;
    String pic;
    String type;

    bool isTablet = false;
    if (Device.get().isTablet) {
      isTablet = true;
    }
    return MediaQuery(
      data: MediaQuery.of(context).removePadding(removeTop: true),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: 1,
          itemBuilder: (context, index) {
            bool isLargePhone = Screen.diagonal(context) > 766;

            DocumentSnapshot course = snapshot.data.docs[index];
            pic = course['image'];
            title = course['title'];

            if (course['paymentAmount'] != null &&
                course['paymentAmount'] != 0) {
              type = "pay";
            }
            if (course.data()['mobileOrderMenu'] != null &&
                (course.data()['mobileOrderMenu']['item1'] ||
                    course.data()['mobileOrderMenu']['item2'] ||
                    course.data()['mobileOrderMenu']['item3'])) {
              type = "order";
            }

            return Container(
              alignment: Alignment.center,
              // width: width * 0.8,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: isLargePhone
                          ? SizeConfig.blockSizeVertical * 15
                          : isTablet
                              ? 800
                              : SizeConfig.blockSizeVertical * 18,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: OpenContainer(
                          transitionType: ContainerTransitionType.fade,
                          transitionDuration: Duration(milliseconds: 500),
                          openBuilder: (context, _) => PostDetail(course.id),
                          closedElevation: 0,
                          closedBuilder: (context, _) =>
                              Stack(children: <Widget>[
                            FractionallySizedBox(
                              widthFactor: 1,
                              child: Container(
                                child: Container(
                                  child: CachedNetworkImage(
                                    memCacheHeight: 100,
                                    memCacheWidth: 100,
                                    imageUrl: pic,
                                    fit: BoxFit.cover,
                                  ),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
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
                                        title,
                                        style: TextStyle(
                                            fontFamily: 'Solway',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ExtraCornerElements(type)
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class ExtraCornerElements extends StatelessWidget {
  final String type;
  const ExtraCornerElements(this.type);

  @override
  Widget build(BuildContext context) {
    return (type == "order")
        ? Positioned(
            bottom: 2.5,
            right: 2.5,
            child: Container(
              height: 30,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink[400], Colors.purple[300]],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 15,
                  ),
                  Text(
                    " Order Now",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        : (type == "pay")
            ? Positioned(
                bottom: 2.5,
                right: 2.5,
                child: Container(
                  height: 30,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[400], Colors.green[300]],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 15,
                      ),
                      Text(
                        " Pay Now ",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            : Container();
  }
}

class BiteSizePostUI extends StatelessWidget {
  final DocumentSnapshot course;
  const BiteSizePostUI({this.course});

  @override
  Widget build(BuildContext context) {
    String title = course['title'];
    String pic = course['image'];
    int goingCount = course['goingCount'];
    bool isTablet = false;
    if (Device.get().isTablet) {
      isTablet = true;
    }
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Container(
      alignment: Alignment.center,
      // width: width * 0.8,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              height: isLargePhone
                  ? SizeConfig.blockSizeVertical * 15
                  : isTablet
                      ? 800
                      : SizeConfig.blockSizeVertical * 18,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: OpenContainer(
                  openElevation: 10,
                  transitionType: ContainerTransitionType.fade,
                  transitionDuration: Duration(milliseconds: 500),
                  openBuilder: (context, _) => PostDetail(course.id),
                  closedElevation: 0,
                  closedBuilder: (context, _) => Stack(children: <Widget>[
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: Container(
                        child: Container(
                          child: CachedNetworkImage(
                            memCacheHeight: 100,
                            memCacheWidth: 100,
                            imageUrl: pic,
                            fit: BoxFit.cover,
                          ),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          alignment: Alignment(0.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(0)),
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
                                title,
                                style: TextStyle(
                                    fontFamily: 'Solway',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            goingCount > 0
                ? Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Text(goingCount.toString(),
                                style: TextStyle(color: Colors.green)),
                            Icon(Icons.directions_run, color: Colors.green),
                          ],
                        ),
                      ),
                    ))
                : Container()
          ],
        ),
      ),
    );
  }
}
