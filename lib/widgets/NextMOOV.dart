import 'dart:async';

import 'package:MOOV/helpers/size_config.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class NextMOOV extends StatefulWidget {
  final String selected;
  final String suggestorId;
  final String groupId;
  final int unix;

  NextMOOV(this.selected, this.suggestorId, this.groupId, this.unix);

  @override
  _NextMOOVState createState() =>
      _NextMOOVState(this.selected, this.suggestorId, this.groupId, this.unix);
}

class _NextMOOVState extends State<NextMOOV> {
  String selected;
  String suggestorId;
  String groupId;
  int unix;

  _NextMOOVState(this.selected, this.suggestorId, this.groupId, this.unix);
  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    String title;
    String pic;

    return StreamBuilder(
        stream: postsRef.where("postId", isEqualTo: selected).snapshots(),
        builder: (context, snapshot) {
          // title = snapshot.data['title'];
          // pic = snapshot.data['pic'];
          if (!snapshot.hasData) return Text('Loading data...');
          if (snapshot.data.docs.length == 0) return Container();

          return MediaQuery(
            data: MediaQuery.of(context)
                .removePadding(removeTop: true, removeBottom: true),
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 1,
                itemBuilder: (context, index) {
                  DocumentSnapshot course = snapshot.data.docs[index];
                  pic = course['image'];
                  title = course['title'];
                  Timestamp startDate = course['startDate'];
                  final now = DateTime.now();
                  bool isToday = false;
                  bool isTomorrow = false;

                  bool isNextWeek = false;

                  final today = DateTime(now.year, now.month, now.day);
                  final tomorrow = DateTime(now.year, now.month, now.day + 1);
                  final week = DateTime(now.year, now.month, now.day + 6);

                  final dateToCheck = startDate.toDate();
                  final aDate = DateTime(
                      dateToCheck.year, dateToCheck.month, dateToCheck.day);

                  if (aDate == today) {
                    isToday = true;
                  } else if (aDate == tomorrow) {
                    isTomorrow = true;
                  }

                  if (aDate.isAfter(week)) {
                    isNextWeek = true;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: isLargePhone
                              ? SizeConfig.blockSizeVertical * 15
                              : SizeConfig.blockSizeVertical * 18,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PostDetail(course.id)));
                            },
                            child: Stack(children: <Widget>[
                              FractionallySizedBox(
                                widthFactor: 1,
                                child: Container(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: OptimizedCacheImage(
                                      imageUrl: pic,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  margin: EdgeInsets.only(
                                      left: 20, top: 0, right: 20, bottom: 7.5),
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
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment(0.0, 0.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: <Color>[
                                          Colors.black.withAlpha(15),
                                          Colors.black,
                                          Colors.black12,
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .7),
                                        child: Text(
                                          title,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontFamily: 'Solway',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize:
                                                  isLargePhone ? 22.0 : 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              suggestorId == currentUser.id
                                  ? Positioned(
                                      left: 20,
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();

                                          showAlertDialog(context);
                                        },
                                        child: Container(
                                            height: 30,
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.red[400],
                                                    Colors.red[300]
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            child: Text(
                                              "Unsuggest",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            )),
                                      ),
                                    )
                                  : Text(""),
                              isToday == false
                                  ? Positioned(
                                      top: 0,
                                      right: 20,
                                      child: Container(
                                        height: 30,
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.pink[400],
                                                Colors.purple[300]
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: isNextWeek
                                            ? Text(
                                                DateFormat('MMM d')
                                                    .add_jm()
                                                    .format(course['startDate']
                                                        .toDate()),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              )
                                            : Text(
                                                DateFormat('EEE')
                                                    .add_jm()
                                                    .format(course['startDate']
                                                        .toDate()),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                      ),
                                    )
                                  : Container(),
                              isToday == true
                                  ? Positioned(
                                      top: 0,
                                      right: 20,
                                      child: Container(
                                        height: 30,
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.red[400],
                                                Colors.red[600]
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Text(
                                          DateFormat('EEE').add_jm().format(
                                              course['startDate'].toDate()),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      ),
                                    )
                                  : Text("")
                            ]),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          );
        });
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Unsuggest?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nRemove this suggestion?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Yeah", style: TextStyle(color: Colors.red)),
            onPressed: () {
              groupsRef
                  .doc(groupId)
                  .collection("suggestedMOOVs")
                  .doc(unix.toString() + " from " + currentUser.id)
                  .get()
                  .then((doc) {
                if (doc.exists) {
                  Navigator.pop(context);
                }
                Timer(Duration(seconds: 1), () {
                  doc.reference.delete();
                });
              });
            },
          ),
          CupertinoDialogAction(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }
}
