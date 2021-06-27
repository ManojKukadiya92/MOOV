import 'dart:ui';
import 'package:MOOV/businessInterfaces/CrowdManagement.dart';
import 'package:MOOV/businessInterfaces/MobileOrdering.dart';
import 'package:MOOV/pages/MoovMaker.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

class LivePassesSheet extends StatefulWidget {
  final List livePasses;

  final Map oneLivePassFromShowPass;
  //if a user taps on 'show pass' from a post, theyll only see that specific pass

  LivePassesSheet({this.livePasses, this.oneLivePassFromShowPass});

  @override
  _LivePassesSheetState createState() => _LivePassesSheetState();
}

class _LivePassesSheetState extends State<LivePassesSheet> {
  bool isLoading = false;
  bool success = false;
  PageController _controller;

  @override
  Widget build(BuildContext context) {
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
            : Stack(
                children: [
                  (widget.oneLivePassFromShowPass != null)
                      ? Container(
                          decoration: BoxDecoration(
                              color: widget.oneLivePassFromShowPass['tip'] > 0
                                  ? Colors.pink
                                  : Colors.green,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15))),
                          height: 550,
                          child: StreamBuilder(
                              stream: postsRef
                                  .doc(widget.oneLivePassFromShowPass['postId'])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container();
                                }
                                String businessName =
                                    snapshot.data['posterName'];
                                Timestamp startTime =
                                    snapshot.data['startDate'];

                                return Stack(
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.only(
                                            left: 15, right: 15, bottom: 10),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .95,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 20, bottom: 5),
                                              child: CircleAvatar(
                                                radius: 90,
                                                backgroundColor:
                                                    Colors.blue[50],
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.green,
                                                  radius: 85,
                                                  child: widget.oneLivePassFromShowPass[
                                                              'type'] ==
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
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ))
                                                      : null,
                                                  backgroundImage:
                                                      widget.oneLivePassFromShowPass[
                                                                  'type'] ==
                                                              "MOOV Over Pass"
                                                          ? null
                                                          : NetworkImage(widget
                                                                  .oneLivePassFromShowPass[
                                                              'photo']),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 300,
                                              child: Text(
                                                widget.oneLivePassFromShowPass[
                                                    'name'],
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
                                                widget.oneLivePassFromShowPass[
                                                    'passId']),
                                            SizedBox(height: 20),
                                          ],
                                        )),
                                    widget.oneLivePassFromShowPass['type'] !=
                                            "MOOV Over Pass"
                                        ? Positioned(
                                            top: 5,
                                            right: 5,
                                            child: Column(
                                              children: [
                                                ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: Colors.pink,
                                                      elevation: 5.0,
                                                    ),
                                                    onPressed: () {
                                                      HapticFeedback
                                                          .lightImpact();
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return TipDialog(
                                                                passId: widget
                                                                        .oneLivePassFromShowPass[
                                                                    'passId']);
                                                          });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text('TIP',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    )),
                                                Text(
                                                  "(Tips turn your\npass Pink!)",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.pink,
                                                      fontSize: 8),
                                                )
                                              ],
                                            ))
                                        : Container(),
                                    Positioned(
                                        top: 5,
                                        left: 5,
                                        child: GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: Icon(Icons.cancel)))
                                  ],
                                );
                              }),
                        )
                      : PageView.builder(
                          controller: _controller,
                          itemCount: widget.livePasses.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            Color _sheetColor = Colors.green;
                            if (widget.livePasses[index]['tip'] > 0) {
                              _sheetColor = Colors.pink;
                            }

                            return Container(
                              decoration: BoxDecoration(
                                  color: _sheetColor,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15))),
                              height: 550,
                              child: StreamBuilder(
                                  stream: postsRef
                                      .doc(widget.livePasses[index]['postId'])
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container();
                                    }
                                    String businessName =
                                        snapshot.data['posterName'];
                                    Timestamp startTime =
                                        snapshot.data['startDate'];

                                    return Stack(
                                      children: [
                                        Container(
                                            margin: const EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                                bottom: 10),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .95,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20, bottom: 5),
                                                  child: CircleAvatar(
                                                    radius: 90,
                                                    backgroundColor:
                                                        Colors.blue[50],
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.green,
                                                      radius: 85,
                                                      child: widget.livePasses[
                                                                      index]
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
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ))
                                                          : null,
                                                      backgroundImage: widget
                                                                          .livePasses[
                                                                      index]
                                                                  ['type'] ==
                                                              "MOOV Over Pass"
                                                          ? null
                                                          : NetworkImage(widget
                                                                  .livePasses[
                                                              index]['photo']),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 300,
                                                  child: Text(
                                                    widget.livePasses[index]
                                                        ['name'],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.w700,
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
                                                        .format(
                                                            startTime.toDate()),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20)),
                                                SizedBox(height: 35),
                                                PulsatingCircleIconButton(
                                                    widget.livePasses[index]
                                                        ['passId']),
                                                SizedBox(height: 20),
                                                widget.livePasses.length > 1
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: 14.0,
                                                            height: 14.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                          SizedBox(width: 5),
                                                          Container(
                                                            width: 14.0,
                                                            height: 14.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                              ],
                                            )),
                                        widget.livePasses[index]['type'] !=
                                                "MOOV Over Pass"
                                            ? Positioned(
                                                top: 5,
                                                right: 5,
                                                child: Column(
                                                  children: [
                                                    ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          primary: Colors.pink,
                                                          elevation: 5.0,
                                                        ),
                                                        onPressed: () {
                                                          HapticFeedback
                                                              .lightImpact();
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return TipDialog(
                                                                    passId: widget
                                                                            .livePasses[index]
                                                                        [
                                                                        'passId']);
                                                              });
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text('TIP',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        )),
                                                    Text(
                                                      "(Tips turn your\npass Pink!)",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.pink,
                                                          fontSize: 8),
                                                    )
                                                  ],
                                                ))
                                            : Container(),
                                        Positioned(
                                            top: 5,
                                            left: 5,
                                            child: GestureDetector(
                                                onTap: () =>
                                                    Navigator.pop(context),
                                                child: Icon(Icons.cancel)))
                                      ],
                                    );
                                  }),
                            );
                          },
                        ),
                ],
              );
  }
}

class PulsatingCircleIconButton extends StatefulWidget {
  final String passId;
  const PulsatingCircleIconButton(this.passId);
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
                usersRef
                    .doc(currentUser.id)
                    .collection("livePasses")
                    .doc(widget.passId)
                    .delete();

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
          height: 164,
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
                          fontSize: 32.5,
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
                          fontSize: 35,
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
  final Map oneLivePass;

  BuyMoovOverPassSheet(
      {this.businessUserId,
      this.postId,
      this.haveAlready,
      this.livePasses,
      this.oneLivePass});

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

                                    usersRef.doc(currentUser.id).set({
                                      "moovMoney": FieldValue.increment(-10)
                                    }, SetOptions(merge: true));
                                    usersRef.doc(widget.businessUserId).set(
                                        {"moovMoney": FieldValue.increment(10)},
                                        SetOptions(merge: true));

                                    usersRef
                                        .doc(currentUser.id)
                                        .collection('livePasses')
                                        .doc(passId)
                                        .set({
                                      "type": "MOOV Over Pass",
                                      "name": "MOOV Over Pass",
                                      "price": 10,
                                      "photo": "widget.photo",
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

class TipDialog extends StatefulWidget {
  final int moovMoneyBalance;
  final int tip;
  final String passId;
  final String businessId;

  const TipDialog(
      {this.moovMoneyBalance, this.tip, this.passId, this.businessId});

  @override
  _TipDialogState createState() => _TipDialogState();
}

class _TipDialogState extends State<TipDialog> {
  bool isChecking = false;
  int _tipAmount = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: isChecking ? Colors.green : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 110,
              ),
              isChecking
                  ? Icon(Icons.check, size: 45, color: Colors.white)
                  : Text(
                      "Make their night.",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
              SizedBox(
                height: 15,
              ),
              Text(
                "The highest tip of the night gets a FREE MOOV Over Pass™ and 100 points!",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 22,
              ),
              SizedBox(height: 16),
              NumberPicker(
                itemHeight: 30,
                value: _tipAmount,
                minValue: 0,
                maxValue: 100,
                step: 1,
                haptics: true,
                onChanged: (value) => setState(() => _tipAmount = value),
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () => setState(() {
                      final newValue = _tipAmount - 1;
                      _tipAmount = newValue.clamp(0, 100);
                    }),
                  ),
                  Text('Tip: \$$_tipAmount'),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => setState(() {
                      final newValue = _tipAmount + 1;
                      _tipAmount = newValue.clamp(0, 100);
                    }),
                  ),
                ],
              ),
              TextButton(
                  onPressed: () {
                    if (_tipAmount == 0) {
                      return null;
                    }
                    //  isLoading = true;

                    usersRef.doc(currentUser.id).get().then((value) {
                      if (value['moovMoney'] < _tipAmount) {
                        showDialog(
                            barrierColor: Colors.blue[100],
                            context: context,

                            // backgroundColor: Colors.white,
                            // context: context,
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(15)),
                            builder: (context) =>
                                Center(child: BottomSheetDeposit()));
                      } else {
                        usersRef
                            .doc(currentUser.id)
                            .collection('livePasses')
                            .doc(widget.passId)
                            .set({"tip": FieldValue.increment(_tipAmount)},
                                SetOptions(merge: true));

                        usersRef.doc(currentUser.id).set({
                          "moovMoney": FieldValue.increment(-1 * _tipAmount)
                        }, SetOptions(merge: true));

                        usersRef.doc(widget.businessId).set(
                            {"moovMoney": FieldValue.increment(_tipAmount)},
                            SetOptions(merge: true));

                        setState(() {
                          isChecking = true;
                        });
                        Future.delayed(Duration(seconds: 2), () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                            (Route<dynamic> route) => false,
                          );
                        });
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                      side: BorderSide(color: Colors.green)),
                  child: Text(
                    "Add",
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  )),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Container(
            child: Stack(alignment: Alignment.center, children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: Image.asset(
                  'lib/assets/tip.jpeg',
                  color: Colors.black38,
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: MediaQuery.of(context).size.width * 0.75,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    alignment: Alignment(0.0, 0.0),
                    child: Container(
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
                        child: Text(
                          "Tip",
                          style: TextStyle(
                              fontFamily: 'Solway',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class Parallax extends StatefulWidget {
  @override
  _ParallaxState createState() => _ParallaxState();
}

class _ParallaxState extends State<Parallax> {
  PageController pageController;
  double pageOffset = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.7);
    pageController.addListener(() {
      setState(() {
        pageOffset = pageController.page;
      });
    });
  }

  List<Map> paintings = [
    {
      'image': 'lib/assets/clouds.jpeg',
      'name': 'The Sower',
    },
    {
      'image': 'lib/assets/editclub.jpeg',
      'name': 'The Starry Night',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/clouds.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Text(
                    'Vincent\nvan Gogh',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '30 March 1853-29 July 1890',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Vincent Willem van Gogh was a Dutch post-impressionist painter who posthumously became one of the most famous and influential figures in the history of Western art.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 20),
                  child: Text(
                    'Highlight Paintings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  height: 400,
                  padding: EdgeInsets.only(bottom: 30),
                  child: PageView.builder(
                      itemCount: paintings.length,
                      controller: pageController,
                      itemBuilder: (context, i) {
                        return Transform.scale(
                          scale: 1,
                          child: Container(
                            padding: EdgeInsets.only(right: 20),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    paintings[i]['image'],
                                    height: 370,
                                    fit: BoxFit.cover,
                                    alignment:
                                        Alignment(-pageOffset.abs() + i, 0),
                                  ),
                                ),
                                Positioned(
                                  left: 10,
                                  bottom: 20,
                                  right: 10,
                                  child: Text(
                                    paintings[i]['name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 35,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LivePassesWalletSheet extends StatelessWidget {
  final List livePasses;
  const LivePassesWalletSheet(this.livePasses);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50))),
        height: 400,
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Passes",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: Colors.black),
                  ),
                  Container(
                    height: 4,
                    width: 80,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(50),
                        )),
                  ),
                  Text(
                    "0 Karma",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.grey[800]),
                  )
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 15),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text(
                              "All",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.grey[900]),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey[200],
                                      blurRadius: 10.0,
                                      spreadRadius: 4.5)
                                ]),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor: Colors.green,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Purchases",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.grey[900]),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey[200],
                                      blurRadius: 10.0,
                                      spreadRadius: 4.5)
                                ]),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor: Colors.orange,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Gifts",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.grey[900]),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey[200],
                                      blurRadius: 10.0,
                                      spreadRadius: 4.5)
                                ]),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          )
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 16,
                    ),

                    Container(
                      child: Text(
                        "TODAY",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[500]),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32),
                    ),

                    SizedBox(
                      height: 16,
                    ),

                    ListView.builder(
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 18.0, right: 3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                      width: 40,
                                      height: 3,
                                      color: TextThemes.ndGold),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "Swipe\nto",
                                                style: TextStyle(),
                                              ),
                                              TextSpan(
                                                  text: '\nGIFT',
                                                  style: TextStyle(
                                                    color: TextThemes.ndGold,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  )),
                                            ]),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Container(
                                        height: 3, color: TextThemes.ndGold),
                                  ),
                                  Transform.rotate(
                                      angle: 90 * 3.14 / 180,
                                      child: Icon(
                                        Icons.change_history,
                                        color: TextThemes.ndGold,
                                      ))
                                ],
                              ),
                            ),
                            Dismissible(
                              direction: DismissDirection.startToEnd,
                              // Each Dismissible must contain a Key. Keys allow Flutter to
                              // uniquely identify widgets.
                              key: Key(''),
                              // Provide a function that tells the app
                              // what to do after an item has been swiped away.
                              onDismissed: (direction) {
                                Navigator.pop(context);
                              },
                              //   if (feedItems.contains(docId)) {
                              //     //_personList is list of person shown in ListView
                              //     setState(() {
                              //       feedItems.remove(docId);
                              //     });
                              //   }

                              //   // Remove the item from the data source.

                              //   // Then show a snackbar.
                              //   Scaffold.of(context).showSnackBar(SnackBar(
                              //       duration: Duration(milliseconds: 1500),
                              //       backgroundColor: TextThemes.ndBlue,
                              //       content: Padding(
                              //         padding: const EdgeInsets.all(2.0),
                              //         child: Text("See ya notification."),
                              //       )));
                              // },

                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 32),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(18))),
                                      child: Icon(
                                        Icons.local_offer,
                                        color: Colors.lightBlue[900],
                                      ),
                                      padding: EdgeInsets.all(12),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            livePasses[index]['name'],
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey[900]),
                                          ),
                                          Text(
                                            "BusinessName",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey[500]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          "\$cost",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.lightGreen),
                                        ),
                                        Text(
                                          "26 Jan",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      shrinkWrap: true,
                      itemCount: 2,
                      padding: EdgeInsets.all(0),
                      controller: ScrollController(keepScrollOffset: false),
                    ),

                    //now expense
                    SizedBox(
                      height: 16,
                    ),

                    Container(
                      child: Text(
                        "YESTERDAY",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[500]),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32),
                    ),

                    SizedBox(
                      height: 16,
                    ),

                    ListView.builder(
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 32),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Row(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(18))),
                                child: Icon(
                                  Icons.directions_car,
                                  color: Colors.lightBlue[900],
                                ),
                                padding: EdgeInsets.all(12),
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Biz",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey[900]),
                                    ),
                                    Text(
                                      "descr",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    "\$gift",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.orange),
                                  ),
                                  Text(
                                    "26 Jan",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      shrinkWrap: true,
                      itemCount: 2,
                      padding: EdgeInsets.all(0),
                      controller: ScrollController(keepScrollOffset: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
