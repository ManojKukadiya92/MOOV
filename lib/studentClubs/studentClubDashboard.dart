import 'dart:async';
import 'dart:math';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/MOOVSPage.dart';
import 'package:MOOV/pages/MessagesHub.dart';
import 'package:MOOV/pages/edit_profile.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/studentClubs/editClub.dart';
import 'package:MOOV/studentClubs/promoteClub.dart';
import 'package:MOOV/studentClubs/recruitClub.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';

class StudentClubDashboard extends StatelessWidget {
  const StudentClubDashboard({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return (currentUser.userType[("clubExecutive")].isEmpty)
        ? ClubMaker()
        : StreamBuilder(
            stream: clubsRef
                .where("execs", arrayContains: currentUser.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Container();
              }
              if (snapshot.data.docs.isEmpty) {
                return Container(
                  child: Text("Error"),
                );
              }
              return Scaffold(
                  floatingActionButton: Row(
                    children: [
                      SizedBox(
                        width: 160,
                        child: ExpandableFab(
                          distance: 80.0,
                          children: [
                            ActionButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MessageDetail(
                                            isClubChat: true,
                                            gid: snapshot.data.docs[0]
                                                ['clubId'],
                                            members: snapshot.data.docs[0]
                                                ['memberNames'],
                                            sendingPost: {})));
                              },
                              icon: const Icon(Icons.chat_bubble,
                                  color: Colors.white),
                            ),
                            ActionButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PromoteClub(
                                            snapshot.data.docs[0]['clubId'])));
                              },
                              icon: const Icon(
                                Icons.campaign,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                            ActionButton(
                              onPressed: () {},
                              icon: const Icon(Icons.trending_up,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.white,
                  body: ListView(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            "lib/assets/clubDash.jpeg",
                            width: MediaQuery.of(context).size.width,
                            height: isLargePhone ? 150 : 130,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            "Club Dashboard",
                            style: TextThemes.headlineWhite,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 65.0, left: 20, right: 20),
                            child: Text("Here's your club's new best friend",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13)),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditClub(
                                          snapshot.data.docs[0]['clubId']))),
                              child: Text("Edit",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                      ClubDashBody(),
                      SizedBox(height: isLargePhone ? 0 : 60)
                    ],
                  ));
            });
  }
}

class StudentClubMOOV extends StatelessWidget {
  final String clubId;
  final List<String> memberIds;
  const StudentClubMOOV(this.clubId, this.memberIds);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: postsRef
            .where("clubId", isEqualTo: clubId)
            .orderBy("startDate")
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Container();
          }
          if (snapshot.data.docs.isEmpty) {
            return Column(
              children: [
                Container(
                  child: Stack(children: [
                    Container(
                      height: 150,
                      width: 300,
                      child: Stack(children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                            child: OpenContainer(
                                transitionType: ContainerTransitionType.fade,
                                transitionDuration: Duration(milliseconds: 500),
                                openBuilder: (context, _) =>
                                    PostDetail("aSjYC6ALUy8UIedyzBQ9"),
                                closedElevation: 0,
                                closedBuilder: (context, _) =>
                                    FractionallySizedBox(
                                      widthFactor: 1,
                                      heightFactor: 1,
                                      child: Container(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                              "lib/assets/clubMeeting.gif",
                                              fit: BoxFit.cover),
                                        ),
                                        // margin: EdgeInsets.only(left: 0, top: 5, right: 0, bottom: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                    "Next Meeting",
                                    textAlign: TextAlign.center,
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
                        Positioned(
                          top: 10,
                          right: 2.5,
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
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Text(
                              "Monday, Aug. 30",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        )
                      ]),
                    )
                  ]),
                ),
                Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width * .6,
                    color: Colors.transparent,
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Member Statuses",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .2,
                                child: Column(
                                  children: [
                                    Text(
                                      "5",
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text("Going ",
                                        style: TextStyle(fontSize: 10))
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .2,
                                child: Column(
                                  children: [
                                    Text(
                                      "2",
                                      style: TextStyle(
                                          color: Colors.yellow[800],
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text("Undecided",
                                        style: TextStyle(fontSize: 10))
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .2,
                                child: Column(
                                  children: [
                                    Text(
                                      "2",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text("Not Going",
                                        style: TextStyle(fontSize: 10))
                                  ],
                                ),
                              ),
                            ],
                          )
                        ]))),
              ],
            );
          }

          String id = snapshot.data.docs[0]['postId'];
          String pic = snapshot.data.docs[0]['image'];
          String title = snapshot.data.docs[0]['title'];
          Timestamp startDate = snapshot.data.docs[0]['startDate'];
          String time = DateFormat('MMMd').add_jm().format(startDate.toDate());
          Map statuses = snapshot.data.docs[0]['statuses'];
          // int goingCount = statuses.wh
          int goingCount = 0;
          int undecidedCount = 0;
          int notGoingCount = 0;

          for (int i = 0; i <= statuses.length - 1; i++) {
            if (statuses.isNotEmpty &&
                statuses.values.toList()[i] == 3 &&
                memberIds.contains(statuses.keys.toList()[i])) {
              goingCount++;
            }
            if (statuses.isNotEmpty &&
                statuses.values.toList()[i] == 2 &&
                memberIds.contains(statuses.keys.toList()[i])) {
              undecidedCount++;
            }
            if (statuses.isNotEmpty &&
                statuses.values.toList()[i] == 1 &&
                memberIds.contains(statuses.keys.toList()[i])) {
              notGoingCount++;
            }
          }

          return Column(
            children: [
              Stack(children: [
                Container(
                  height: 150,
                  width: 300,
                  child: Stack(children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                      child: OpenContainer(
                        transitionType: ContainerTransitionType.fade,
                        transitionDuration: Duration(milliseconds: 500),
                        openBuilder: (context, _) => PostDetail(id),
                        closedElevation: 0,
                        closedBuilder: (context, _) => FractionallySizedBox(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(pic, fit: BoxFit.cover),
                            ),
                            // margin: EdgeInsets.only(left: 0, top: 5, right: 0, bottom: 5),
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
                                textAlign: TextAlign.center,
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
                    Positioned(
                      top: 10,
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
                        child: Text(
                          time,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    )
                  ]),
                )
              ]),
              SizedBox(height: 5),
              Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width * .6,
                  color: Colors.transparent,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: Column(children: [
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Member Statuses",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .2,
                              child: Column(
                                children: [
                                  Text(
                                    goingCount.toString(),
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text("Going ", style: TextStyle(fontSize: 10))
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .2,
                              child: Column(
                                children: [
                                  Text(
                                    undecidedCount.toString(),
                                    style: TextStyle(
                                        color: Colors.yellow[800],
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text("Undecided",
                                      style: TextStyle(fontSize: 10))
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .2,
                              child: Column(
                                children: [
                                  Text(
                                    notGoingCount.toString(),
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text("Not Going",
                                      style: TextStyle(fontSize: 10))
                                ],
                              ),
                            ),
                          ],
                        )
                      ]))),
            ],
          );
        });
  }
}

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    Key key,
    this.initialOpen,
    @required this.distance,
    @required this.children,
  }) : super(key: key);

  final bool initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 500.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0;
        i < count;
        i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: angleInDegrees,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton.extended(
            onPressed: _toggle,
            icon: const Icon(Icons.home_repair_service, color: Colors.white),
            label: Text("Toolkit",
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  _ExpandingActionButton({
    Key key,
    @required this.directionInDegrees,
    @required this.maxDistance,
    @required this.progress,
    @required this.child,
  }) : super(key: key);

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (3.14 / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          left: 30.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * 3.14 / 2,
            child: child,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key key,
    this.onPressed,
    @required this.icon,
  }) : super(key: key);

  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.accentColor,
      elevation: 4.0,
      child: IconTheme.merge(
        data: theme.accentIconTheme,
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
        ),
      ),
    );
  }
}

@immutable
class FakeItem extends StatelessWidget {
  const FakeItem({
    Key key,
    @required this.isBig,
  }) : super(key: key);

  final bool isBig;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      height: isBig ? 200.0 : 36.0,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        color: Colors.grey.shade300,
      ),
    );
  }
}

class ClubMaker extends StatefulWidget {
  ClubMaker();

  @override
  _ClubMakerState createState() => _ClubMakerState();
}

class _ClubMakerState extends State<ClubMaker> {
  final clubNameController = TextEditingController();
  final bioController = TextEditingController();
  bool isUploading = false;
  bool blankField = false;
  bool goodCheck = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: (isUploading)
          ? linearProgress()
          : (goodCheck)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sweet!",
                        style: TextThemes.headline1,
                      ),
                      SizedBox(height: 30),
                      Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Container(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              "lib/assets/clubDash.jpeg",
                              width: MediaQuery.of(context).size.width,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              "Club Maker",
                              style: TextThemes.headlineWhite,
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Text("What's your club's name?"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 20),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                blankField = false;
                              });
                            },
                            controller: clubNameController,
                            decoration: InputDecoration(
                              labelText: "Club Name",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Text(".. and a lil bit about it? (optional)"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 20),
                          child: TextFormField(
                            controller: bioController,
                            decoration: InputDecoration(
                              labelText: "Short Club Bio",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        blankField
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 50,
                                  ),
                                  blankField
                                      ? Text("what's your name again?",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ))
                                      : Container(),
                                ],
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0, top: 20),
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80.0)),
                              padding: EdgeInsets.all(0.0),
                              child: Ink(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        TextThemes.ndBlue,
                                        Color(0xff64B6FF)
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30.0)),
                                child: Container(
                                  constraints: BoxConstraints(
                                      maxWidth: 125.0, minHeight: 50.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Save",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                HapticFeedback.lightImpact();

                                if (clubNameController.text == "") {
                                  setState(() {
                                    blankField = true;
                                  });
                                }
                                if (blankField == false) {
                                  setState(() {
                                    isUploading = true;
                                  });
                                  String clubId = generateRandomString(20);
                                  usersRef.doc(currentUser.id).set({
                                    "userType": {
                                      "clubExecutive": [clubId]
                                    }
                                  },SetOptions(merge: true));
                                  clubsRef
                                      .doc(clubId)
                                      .set({
                                        "bio": bioController.text,
                                        "clubName": clubNameController.text,
                                        "clubId": clubId,
                                        "joinDate": DateTime.now(),
                                        "execs": [currentUser.id],
                                        "members": {currentUser.id: 3},
                                        "memberIds": [currentUser.id]
                                      }, SetOptions(merge: true))
                                      .then((value) => setState(() {
                                            isUploading = false;
                                          }))
                                      .then((value) => setState(() {
                                            goodCheck = true;
                                          }))
                                      .then((value) =>
                                          Timer(Duration(seconds: 1), () {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>
                                                      Home()),
                                              (Route<dynamic> route) => false,
                                            );
                                          }));
                                }
                              }),
                        ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Club already made?",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Have another exec. add you \nas an exec.",
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
    );
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }
}

class ClubMembersList extends StatefulWidget {
  final String clubId;
  ClubMembersList(this.clubId);

  @override
  _ClubMembersListState createState() => _ClubMembersListState();
}

class _ClubMembersListState extends State<ClubMembersList> {
  String directMessageId;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: clubsRef.doc(widget.clubId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Container();
          }

          Map members = snapshot.data['members'];
          List<String> memberNames = List<String>.from(members.keys.toList());
          List memberStatus = members.values.toList();

          if (memberNames.length <= 1) {
            return Container(
                height: 100.0,
                width: MediaQuery.of(context).size.width * .8,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: Center(
                          child: Text(
                        "Add your members now!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TextThemes.ndBlue),
                      ))),
                ));
          }
          return Stack(
            children: [
              Container(
                  height: 100.0,
                  width: MediaQuery.of(context).size.width * .8,
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: memberNames.length,
                        itemBuilder: (BuildContext context, int index) {
                          return StreamBuilder(
                              stream:
                                  usersRef.doc(memberNames[index]).snapshots(),
                              builder: (context, snapshot2) {
                                if (!snapshot2.hasData ||
                                    snapshot2.data == null) {
                                  return Container();
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 4),
                                      FocusedMenuHolder(
                                        menuWidth:
                                            MediaQuery.of(context).size.width *
                                                0.50,
                                        blurSize: 5.0,
                                        menuItemExtent: 45,
                                        menuBoxDecoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15.0))),
                                        duration: Duration(milliseconds: 100),
                                        animateMenuItems: true,
                                        blurBackgroundColor: Colors.black54,
                                        openWithTap:
                                            true, // Open Focused-Menu on Tap rather than Long Press
                                        menuOffset:
                                            10.0, // Offset value to show menuItem from the selected item
                                        bottomOffsetHeight:
                                            80.0, // Offset height to consider, for showing the menu item ( for Suggestions bottom navigation bar), so that the popup menu will be shown on top of selected item.
                                        menuItems: <FocusedMenuItem>[
                                          // Add Each FocusedMenuItem  for Menu Options

                                          (memberNames[index] != currentUser.id)
                                              ? FocusedMenuItem(
                                                  title: Text("Message"),
                                                  trailingIcon:
                                                      Icon(Icons.message),
                                                  onPressed: () {
                                                    dmChecker(
                                                            memberNames[index],
                                                            directMessageId)
                                                        .then((value) =>
                                                            toMessageDetail(
                                                                memberNames[
                                                                    index],
                                                                directMessageId,
                                                                context));
                                                  })
                                              : FocusedMenuItem(
                                                  title: Text("Edit Profile"),
                                                  trailingIcon:
                                                      Icon(Icons.person),
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                EditProfile()));
                                                  }),

                                          FocusedMenuItem(
                                              title:
                                                  Text("Change title/status"),
                                              trailingIcon: Icon(Icons.edit),
                                              onPressed: () {
                                                showAlertDialog3(
                                                    context,
                                                    memberNames[index],
                                                    widget.clubId,
                                                    memberStatus[index]);
                                              }),
                                          memberStatus[index] == 1
                                              ? FocusedMenuItem(
                                                  title: Text("Manage dues",
                                                      style: TextStyle(
                                                          color: Colors.green)),
                                                  trailingIcon: Icon(
                                                      Icons
                                                          .monetization_on_outlined,
                                                      color: Colors.green),
                                                  onPressed: () {
                                                    showAlertDialog2(
                                                        context,
                                                        memberNames[index],
                                                        widget.clubId);
                                                  })
                                              : FocusedMenuItem(
                                                  title: Text("Refund dues",
                                                      style: TextStyle(
                                                          color: Colors.green)),
                                                  trailingIcon: Icon(
                                                      Icons
                                                          .monetization_on_outlined,
                                                      color: Colors.green),
                                                  onPressed: () {}),
                                          FocusedMenuItem(
                                              title: Text(
                                                "Remove from club",
                                                style: TextStyle(
                                                    color: Colors.redAccent),
                                              ),
                                              trailingIcon: Icon(
                                                Icons.directions_walk,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed: () {
                                                showAlertDialog(
                                                    context,
                                                    memberNames[index],
                                                    widget.clubId);
                                              }),
                                        ],
                                        onPressed: () {},
                                        child: CircleAvatar(
                                            radius: 35,
                                            backgroundColor:
                                                memberStatus[index] == -1
                                                    ? Colors.blue
                                                    : memberStatus[index] == 1
                                                        ? Colors.red
                                                        : TextThemes.ndGold,
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  snapshot2.data['photoUrl']),
                                              radius: 32,
                                              backgroundColor:
                                                  TextThemes.ndBlue,
                                            )),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(firstNamer(
                                              snapshot2.data['displayName'])),
                                          memberStatus[index] == 3
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 2.0),
                                                  child: Icon(
                                                      Icons
                                                          .admin_panel_settings_outlined,
                                                      color: TextThemes.ndGold,
                                                      size: 15),
                                                )
                                              : Container()
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              });
                        },
                      ),
                    ),
                  )),
              Positioned(
                  bottom: 5,
                  right: 5,
                  child: GestureDetector(
                      onTap: () => showDialog(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                                title: Text("Member States"),
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                          "The outer ring color indicates your member's state.\n"),
                                      Text(
                                        "Blue = Member has been invited",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Red = Member has not yet paid dues",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Gold = Member is good to go!",
                                        style: TextStyle(
                                            color: Colors.amber[700],
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          "\nPro Tip: Hold down on a pic to see more settings!",
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ),
                              )),
                      child: Image.asset(
                        "lib/assets/colorGrid.png",
                        height: 20,
                      )))
            ],
          );
        });
  }

  void showAlertDialog(BuildContext context, String userId, String clubId) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Remove from the club?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Remove", style: TextStyle(color: Colors.red)),
            onPressed: () {
              removeMember(userId, clubId);
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: Text("Nah, my bad"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }

  void showAlertDialog2(BuildContext context, String userId, String clubId) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Manage Dues",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          CupertinoDialogAction(
            child: Text("Set status to 'paid'?",
                style: TextStyle(color: Colors.green)),
            onPressed: () {
              clubsRef.doc(clubId).set({
                "members": {userId: 2}
              }, SetOptions(merge: true));

              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: Text("Remind about dues"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }

  void showAlertDialog3(
      BuildContext context, String userId, String clubId, int status) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Change Status",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          CupertinoDialogAction(
            child: Text("Set status to 'unpaid'?",
                style: TextStyle(color: Colors.red)),
            onPressed: () {
              clubsRef.doc(clubId).set({
                "members": {userId: 1},
              }, SetOptions(merge: true));

              Navigator.of(context).pop(true);
            },
          ),
          (status != 3)
              ? CupertinoDialogAction(
                  child: Text("Make Exec",
                      style: TextStyle(
                          color: TextThemes.ndBlue,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    clubsRef.doc(clubId).set({
                      "members": {userId: 3},
                      "execs": FieldValue.arrayUnion([userId])
                    }, SetOptions(merge: true));
                    usersRef.doc(userId).set({
                      "userType": {
                        "clubExecutive": [clubId]
                      },
                      "execs": FieldValue.arrayUnion([userId])
                    }, SetOptions(merge: true));

                    Navigator.of(context).pop(true);
                  },
                )
              : CupertinoDialogAction(
                  child: Text("Revoke Exec",
                      style: TextStyle(
                          color: TextThemes.ndBlue,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    clubsRef.doc(clubId).set({
                      "members": {userId: 2}
                    }, SetOptions(merge: true));

                    Navigator.of(context).pop(true);
                  },
                )
        ],
      ),
    );
  }

  String firstNamer(String fullName) {
    List<String> tempList = fullName.split(" ");
    int start = 0;
    int end = tempList.length;
    if (end > 1) {
      end = 1;
    }
    final selectedWords = tempList.sublist(start, end);
    String firstName = selectedWords.join(" ");
    return firstName;
  }

  removeMember(String userId, String clubId) {
    clubsRef.doc(clubId).set({
      "memberNames": FieldValue.arrayRemove([userId]),
      "execs": FieldValue.arrayRemove([userId]),
      "members": {userId: FieldValue.delete()}
    }, SetOptions(merge: true));
  }
}

class ClubDashBody extends StatefulWidget {
  @override
  _ClubDashBodyState createState() => _ClubDashBodyState();
}

class _ClubDashBodyState extends State<ClubDashBody> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            clubsRef.where("execs", arrayContains: currentUser.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Container();
          }
          if (snapshot.data.docs.isEmpty) {
            return Container(
              child: Text("Error"),
            );
          }

          //you exec multiple clubs
          if (snapshot.data.docs.length > 1) {
            // List<String> memberNames = snapshot.data.docs[selectedIndex]['memberNames'];

            List<String> memberNames = List<String>.from(
                snapshot.data.docs[selectedIndex]['memberNames']);

            return Column(children: [
              Container(
                height: 50,
                child: ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    String clubName = snapshot.data.docs[0]['clubName'];
                    String clubName2 = snapshot.data.docs[1]['clubName'];

                    return BottomNavyBar(
                      mainAxisAlignment: MainAxisAlignment.center,
                      selectedIndex: selectedIndex,
                      items: [
                        BottomNavyBarItem(
                          icon: Icon(Icons.corporate_fare,
                              color: TextThemes.ndBlue),
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(clubName,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: TextThemes.ndBlue),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        BottomNavyBarItem(
                          icon: Icon(Icons.corporate_fare,
                              color: TextThemes.ndBlue),
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(clubName2,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: TextThemes.ndBlue),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                      onItemSelected: (index) {
                        HapticFeedback.lightImpact();

                        setState(() => selectedIndex = index);
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    ClubMembersList(
                        snapshot.data.docs[selectedIndex]['clubId']),
                    Container(
                      width: MediaQuery.of(context).size.width * .2,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RecruitClub(
                                    memberNames,
                                    snapshot.data.docs[selectedIndex]
                                        ['clubId']))),
                        child: Column(
                          children: [
                            Icon(Icons.person_search),
                            Text("Recruit")
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text("Next Meeting",
                  style: TextStyle(color: TextThemes.ndBlue, fontSize: 18)),
              SizedBox(height: 10),
              StudentClubMOOV(
                  snapshot.data.docs[selectedIndex]['clubId'], memberNames)
            ]);
          }

          List<String> memberNames = List<String>.from(
              snapshot.data.docs[selectedIndex]['memberNames']);

          //you only exec one club
          return Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  ClubMembersList(snapshot.data.docs[selectedIndex]['clubId']),
                  Container(
                    width: MediaQuery.of(context).size.width * .2,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RecruitClub(
                                  memberNames,
                                  snapshot.data.docs[selectedIndex]
                                      ['clubId']))),
                      child: Column(
                        children: [Icon(Icons.person_search), Text("Recruit")],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text("Next Meeting",
                style: TextStyle(color: TextThemes.ndBlue, fontSize: 18)),
            SizedBox(height: 10),
            StudentClubMOOV(
                snapshot.data.docs[selectedIndex]['clubId'], memberNames)
          ]);
        });
  }
}
