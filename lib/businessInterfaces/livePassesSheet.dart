import 'dart:ui';

import 'package:MOOV/businessInterfaces/CrowdManagement.dart';
import 'package:MOOV/businessInterfaces/MobileOrdering.dart';
import 'package:MOOV/pages/MoovMaker.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:worm_indicator/indicator.dart';
import 'package:worm_indicator/shape.dart';

class LivePassesSheet extends StatefulWidget {
  final List livePasses;
  LivePassesSheet(this.livePasses);

  @override
  _LivePassesSheetState createState() => _LivePassesSheetState();
}

class _LivePassesSheetState extends State<LivePassesSheet> {
  bool isLoading = false;
  bool success = false;
  PageController _controller;

  @override
  Widget build(BuildContext context) {
    print(widget.livePasses);
    return (isLoading)
        ? linearProgress()
        : (success)
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Redeemed!"),
                SizedBox(height: 40),
                Icon(
                  Icons.check,
                  size: 100,
                  color: Colors.white,
                )
              ])
            : Column(
                children: [
                  // WormIndicator(
                  //   controller: _controller,
                  //   length: 1,
                  //   shape: Shape(
                  //       width: 100,
                  //       height: 18,
                  //       spacing: 0,
                  //       shape: DotShape.Rectangle),
                  // ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: widget.livePasses.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return StreamBuilder(
                            stream: postsRef
                                .doc(widget.livePasses[index]['postId'])
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }
                              String businessName = snapshot.data['posterName'];
                              Timestamp startTime = snapshot.data['startDate'];

                              return Container(
                                  color: Colors.green,
                                  margin: const EdgeInsets.only(
                                      left: 15, right: 15, bottom: 10),
                                  height: 400,
                                  width:
                                      MediaQuery.of(context).size.width * .95,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 5),
                                        child: CircleAvatar(
                                          radius: 90,
                                          backgroundColor: Colors.blue[50],
                                          child: CircleAvatar(
                                            backgroundColor: Colors.green,
                                            radius: 85,
                                            child: widget.livePasses[index]
                                                        ['type'] ==
                                                    "MOOV Over Pass"
                                                ? GradientIcon(
                                                    Icons
                                                        .confirmation_num_outlined,
                                                    100.0,
                                                    LinearGradient(
                                                      colors: <Color>[
                                                        Colors.red,
                                                        Colors.yellow,
                                                        Colors.blue,
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ))
                                                : null,
                                            backgroundImage:
                                                widget.livePasses[index]
                                                            ['type'] ==
                                                        "MOOV Over Pass"
                                                    ? null
                                                    : NetworkImage(
                                                        widget.livePasses[index]
                                                            ['photo']),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 300,
                                        child: Text(
                                          widget.livePasses[index]['name'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.fade,
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Text(businessName,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20)),
                                      Text(
                                          DateFormat('EEE')
                                              .add_jm()
                                              .format(startTime.toDate()),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20)),
                                      SizedBox(height: 35),
                                      PulsatingCircleIconButton(
                                          widget.livePasses[index]),
                                      SizedBox(height: 20),
                                      widget.livePasses.length > 1
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 14.0,
                                                  height: 14.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Container(
                                                  width: 14.0,
                                                  height: 14.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                    ],
                                  ));
                            });
                      },
                    ),
                  ),
                ],
              );
  }
}

class PulsatingCircleIconButton extends StatefulWidget {
  final Map livePasses;
  const PulsatingCircleIconButton(this.livePasses);
  @override
  _PulsatingCircleIconButtonState createState() =>
      _PulsatingCircleIconButtonState();
}

class _PulsatingCircleIconButtonState extends State<PulsatingCircleIconButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  bool _confirming = false;
  Color _color = Color.fromARGB(255, 27, 28, 30);

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
    return Center(
      child: GestureDetector(
        onDoubleTap: _confirming
            ? () {
                usersRef.doc(currentUser.id).set({
                  "livePasses": FieldValue.arrayRemove([widget.livePasses])
                }, SetOptions(merge: true));

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                  (Route<dynamic> route) => false,
                );
              }
            : () {
                setState(() {
                  _color = Colors.red;
                  _confirming = !_confirming;
                });
              },
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          width: 300,
          height: 220,
          child: Center(
              child: Stack(
            children: [
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: !_confirming ? 1 : 0,
                child: Center(
                  child: Text("RESTAURANT STAFF\n\nDOUBLE TAP",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: !_confirming ? 0 : 1,
                child: Center(
                  child: Text("DOUBLE TAP\n\nTO CONFIRM",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              shape: BoxShape.rectangle,
              color: _color,
              boxShadow: [
                BoxShadow(
                    color: Colors.green[50],
                    blurRadius: _animation.value,
                    spreadRadius: _animation.value)
              ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class BuyMoovOverPassSheet extends StatefulWidget {
  final String businessUserId, postId;
  final bool haveAlready;
  final List livePasses;

  BuyMoovOverPassSheet(this.businessUserId, this.postId, this.haveAlready, this.livePasses);

  @override
  _BuyMoovOverPassSheetState createState() => _BuyMoovOverPassSheetState();
}

class _BuyMoovOverPassSheetState extends State<BuyMoovOverPassSheet>
    with SingleTickerProviderStateMixin {
  var top = FractionalOffset.topCenter;
  var bottom = FractionalOffset.bottomCenter;
  var list = [
    Colors.green,
    Colors.redAccent,
  ];
  AnimationController _animationController;
  bool _confirming = false;
  bool _isLoading = false;
  bool _success = false;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    Animation _animation =
        Tween(begin: 2.0, end: 15.0).animate(_animationController)
          ..addListener(() {
            setState(() {
              top = FractionalOffset.bottomLeft;
              bottom = FractionalOffset.topRight;
              list = [Colors.blue, Colors.red];
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
            "MOOV Over Pass™",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
          ),
          Text(
            "No more waiting.",
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
                  "Will there be a line of people waiting for this MOOV? Screw that.\n\n\nSkip straight to the front with this pass.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          // _alreadyHave ?

          !_confirming
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.pink,
                    elevation: 5.0,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (!widget.haveAlready) {
                      setState(() {
                        _confirming = true;
                      });
                    }
                    showBottomSheet(
                        context: context,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        builder: (context) =>
                            LivePassesSheet(widget.livePasses));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.haveAlready
                        ? Text('Show Pass',
                            style: TextStyle(color: Colors.white))
                        : Text('\$10', style: TextStyle(color: Colors.white)),
                  ))
              : Column(
                  children: [
                    Text('\n\nConfirm:\n1x MOOV Over Pass,          \$10',
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
                                  primary: Colors.pink,
                                  elevation: 5.0,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  if (currentUser.moovMoney < 10) {
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
                                    print("H");

                                    usersRef.doc(currentUser.id).set({
                                      "moovMoney": FieldValue.increment(-10)
                                    }, SetOptions(merge: true));
                                    usersRef.doc(widget.businessUserId).set(
                                        {"moovMoney": FieldValue.increment(10)},
                                        SetOptions(merge: true));

                                    usersRef.doc(currentUser.id).set({
                                      "livePasses": FieldValue.arrayUnion([
                                        {
                                          "type": "MOOV Over Pass",
                                          "name": "MOOV Over Pass",
                                          "price": 10,
                                          "photo": "widget.photo",
                                          "time": Timestamp.now(),
                                          "businessId": widget.businessUserId,
                                          "postId": widget.postId,
                                          "passId": passId
                                        }
                                      ])
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
