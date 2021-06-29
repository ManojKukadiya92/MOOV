import 'dart:async';
import 'dart:math';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/pointAnimation.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:polls/polls.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class PollView extends StatefulWidget {
  final ValueNotifier<double> notifier;

  const PollView({Key key, this.notifier});

  @override
  _PollViewState createState() => _PollViewState();
}

class _PollViewState extends State<PollView> {
  bool positivePointAnimation = false;
  bool positivePointAnimation2 = false;

  double option1 = 1;
  double option2 = 90;
  // double option3 = 2.0;
  // double option4 = 3.0;

  Map voters = {};
  String creator = "me";
  String userId;
  String voter;
  List<dynamic> option1List;
  List<dynamic> option2List;

  Color _colorTween(Color begin, Color end) {
    return ColorTween(begin: begin, end: end).transform(widget.notifier.value);
  }

  var x;
  var y;

  @override
  Widget build(BuildContext context) {
    String question;
    String choice1;
    String choice2;

    final dateToCheck = Timestamp.now().toDate();
    final aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);

    String day = DateFormat('MMMd').format(aDate);

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notreDame')
            .doc('data')
            .collection('poll')
            .doc("PERMANENT")
            .snapshots(),
        // ignore: missing_return
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          // dynamic moovId;
          bool isLargePhone = Screen.diagonal(context) > 766;

          voters = snapshot.data['voters'];
          question = snapshot.data['question'];
          choice1 = snapshot.data['choice1'];
          choice2 = snapshot.data['choice2'];
          String suggestorName = snapshot.data['suggestorName'];
          String suggestorYear = snapshot.data['suggestorYear'];

          List _list = voters.values.toList();

          option1 =
              _list.where((element) => element == 1).toList().length.toDouble();
          option2 =
              _list.where((element) => element == 2).toList().length.toDouble();

          option1List = _list.where((element) => element == 1).toList();

          option2List = _list.where((element) => element == 2).toList();

          // var count = _list.where((c) => c.product_id == 2).toList().length;

          for (var entry in voters.entries) {
            x = entry.key;
            y = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Stack(children: [
                Container(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 7),
                    child: Column(
                      children: [
                        Text(
                          question,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Solway',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color:
                                  _colorTween(TextThemes.ndBlue, Colors.white)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Polls(
                            children: [
                              // This cannot be less than 2, else will throw an exception
                              Polls.options(title: choice1, value: option1),
                              Polls.options(title: choice2, value: option2),
                            ],
                            question: Text(
                              'ON or OFF Campus Tonight?',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 0),
                              overflow: TextOverflow.ellipsis,
                            ),
                            pollStyle: TextStyle(color: TextThemes.ndBlue),
                            currentUser: currentUser.id,
                            creatorID: this.creator,
                            voteData: voters,
                            // voteData: usersWhoVoted,
                            // userChoice: usersWhoVoted[this.userId],
                            userChoice: voters[currentUser.id],
                            onVoteBackgroundColor: Colors.blue,
                            leadingBackgroundColor: TextThemes.ndGold,
                            backgroundColor: Colors.white,
                            onVote: (choice) {
                              HapticFeedback.lightImpact();

                              for (var entry in voters.entries) {
                                x = entry.key;
                                y = entry.value;
                              }

                              setState(() {
                                x = choice;
                              });

                              FirebaseFirestore.instance
                                  .collection('notreDame')
                                  .doc('data')
                                  .collection('poll')
                                  .doc("PERMANENT")
                                  .set({
                                "voters": {currentUser.id ?? "": choice}
                              }, SetOptions(merge: true));

                              if (choice == 1) {
                                usersRef.doc(currentUser.id).update(
                                    {"score": FieldValue.increment(25)});
                                setState(() {
                                  option1 += 1.0;
                                });
                                positivePointAnimation = true;

                                Timer(Duration(seconds: 2), () {
                                  setState(() {
                                    positivePointAnimation = false;
                                  });
                                });
                              }
                              if (choice == 2) {
                                usersRef.doc(currentUser.id ?? "").update(
                                    {"score": FieldValue.increment(25)});

                                setState(() {
                                  option2 += 1.0;
                                });
                                positivePointAnimation2 = true;

                                Timer(Duration(seconds: 2), () {
                                  setState(() {
                                    positivePointAnimation2 = false;
                                  });
                                });
                              }

                              // if (choice == 3) {
                              //   setState(() {
                              //     option3 += 1.0;
                              //   });
                              // }
                              // if (choice == 4) {
                              //   setState(() {
                              //     option4 += 1.0;
                              //   });
                              // }
                            }),
                      ],
                    ),
                  ),
                ),
                TranslationAnimatedWidget(
                    enabled: this
                        .positivePointAnimation, //update this boolean to forward/reverse the animation
                    values: [
                      Offset(175, 50), // disabled value value
                      Offset(175, 50), //intermediate value
                      Offset(175, 20) //enabled value
                    ],
                    child: OpacityAnimatedWidget.tween(
                        opacityEnabled: 1, //define start value
                        opacityDisabled: 0, //and end value
                        enabled: positivePointAnimation,
                        child: PointAnimation(25, true))),
                TranslationAnimatedWidget(
                    enabled: this
                        .positivePointAnimation2, //update this boolean to forward/reverse the animation
                    values: [
                      Offset(175, 50), // disabled value value
                      Offset(175, 50), //intermediate value
                      Offset(175, 20) //enabled value
                    ],
                    child: OpacityAnimatedWidget.tween(
                        opacityEnabled: 1, //define start value
                        opacityDisabled: 0, //and end value
                        enabled: positivePointAnimation2,
                        child: PointAnimation(25, true))),
                voters.containsKey(currentUser.id)
                    ? Positioned(
                        top: isLargePhone ? 60 : 60,
                        left: isLargePhone ? 90 : 90,
                        child: Container(
                          height: 100,
                          width: voters.length == 0
                              ? 0
                              : isLargePhone
                                  ? MediaQuery.of(context).size.width * .6
                                  : MediaQuery.of(context).size.width * .53,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: AlwaysScrollableScrollPhysics(),
                              // itemCount: invitees.length,
                              itemCount: option1.toInt(),
                              itemBuilder: (_, index) {
                                voters = snapshot.data['voters'];

                                voters.removeWhere((key, value) => value == 2);

                                var p = voters.keys.toList();

                                return FutureBuilder(
                                    future: usersRef.doc(p[index]).get(),
                                    builder: (context, snapshot2) {
                                      if (!snapshot2.hasData) {
                                        return Container();
                                      }
                                      // bool isLargePhone = Screen.diagonal(context) > 766;

                                      var name = snapshot2.data['displayName'];
                                      var pic = snapshot2.data['photoUrl'];
                                      var id = snapshot2.data['id'];

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Container(
                                          height: 27,
                                          child: Column(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: currentUser.id == id
                                                    ? () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ProfilePageWithHeader()));
                                                      }
                                                    : () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        OtherProfile(
                                                                          id,
                                                                        )));
                                                      },
                                                child: CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor:
                                                      TextThemes.ndBlue,
                                                  child: CircleAvatar(
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                            pic),
                                                    radius: 17,
                                                    backgroundColor:
                                                        TextThemes.ndBlue,
                                                    child: CircleAvatar(
                                                      // backgroundImage: snapshot.data
                                                      //     .documents[index].data['photoUrl'],
                                                      child: CachedNetworkImage(
                                                        memCacheHeight: 100,
                                                        memCacheWidth: 100,
                                                        // memCacheHeight: 15,
                                                        // memCacheWidth: 15,
                                                        imageUrl: pic,
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            CircleAvatar(
                                                          foregroundImage:
                                                              imageProvider,
                                                        ),
                                                        placeholder:
                                                            (context, url) =>
                                                                Icon(
                                                          Icons.person,
                                                          color: Colors
                                                                  .primaries[
                                                              Random().nextInt(
                                                                  Colors
                                                                      .primaries
                                                                      .length)],
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.person,
                                                                color:
                                                                    Colors.red),
                                                      ),
                                                      // backgroundImage:
                                                      //     CachedNetworkImageProvider(
                                                      //         pic),
                                                      radius: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              }),
                        ),
                      )
                    : Container(),
                voters.containsKey(currentUser.id)
                    ? Positioned(
                        bottom: isLargePhone ? -35 : -35,
                        left: isLargePhone ? 90 : 90,
                        child: Container(
                          height: 100,
                          width: voters.length == 0
                              ? 0
                              : isLargePhone
                                  ? MediaQuery.of(context).size.width * .6
                                  : MediaQuery.of(context).size.width * .53,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: AlwaysScrollableScrollPhysics(),
                              // itemCount: invitees.length,
                              itemCount: option2.toInt(),
                              itemBuilder: (_, index) {
                                voters = snapshot.data['voters'];

                                voters.removeWhere((key, value) => value == 1);

                                var w = voters.keys.toList();

                                return FutureBuilder(
                                    future: usersRef.doc(w[index]).get(),
                                    builder: (context, snapshot3) {
                                      if (!snapshot3.hasData) {
                                        return Container();
                                      }
                                      // bool isLargePhone = Screen.diagonal(context) > 766;

                                      var name2 = snapshot3.data['displayName'];
                                      var pic2 =
                                          snapshot3.data['photoUrl'] ?? "";
                                      var id2 = snapshot3.data['id'];

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0),
                                        child: Container(
                                          height: 27,
                                          child: Column(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: currentUser.id == id2
                                                    ? () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ProfilePageWithHeader()));
                                                      }
                                                    : () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        OtherProfile(
                                                                          id2,
                                                                        )));
                                                      },
                                                child: CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor:
                                                      TextThemes.ndBlue,
                                                  child: CircleAvatar(
                                                    backgroundImage:
                                                        CachedNetworkImageProvider(
                                                            pic2),
                                                    radius: 17,
                                                    backgroundColor:
                                                        TextThemes.ndBlue,
                                                    child: CircleAvatar(
                                                      // backgroundImage: snapshot.data
                                                      //     .documents[index].data['photoUrl'],
                                                      backgroundImage:
                                                          CachedNetworkImageProvider(
                                                              pic2),
                                                      radius: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              }),
                        ),
                      )
                    : Container(),
                Positioned(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PollMaker(),
                    )),
                    child: Text(
                      "Suggest a poll",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  bottom: 0,
                  right: 10,
                ),
                suggestorName != null
                    ? Positioned(
                        child: Text(
                          "Poll by $suggestorName $suggestorYear",
                          style: TextStyle(
                              color:
                                  _colorTween(TextThemes.ndBlue, Colors.white),
                              fontWeight: FontWeight.w500),
                        ),
                        bottom: 0,
                        left: 10,
                      )
                    : Container(),
              ]),
            );
          }
        });
  }
}

class PollMaker extends StatefulWidget {
  PollMaker();

  @override
  _PollMakerState createState() => _PollMakerState();
}

class _PollMakerState extends State<PollMaker> {
  final pollTitleController = TextEditingController();
  final choice1Controller = TextEditingController();
  final choice2Controller = TextEditingController();
  bool isUploading = false;
  bool blankField = false;
  bool goodCheck = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
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
      body: (isUploading)
          ? linearProgress()
          : (goodCheck)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Thank you!",
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
                              "lib/assets/poll.png",
                              width: MediaQuery.of(context).size.width,
                            ),
                            Text(
                              "Poll Maker",
                              style: TextThemes.headlineWhite,
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 20),
                          child: TextFormField(
                            controller: pollTitleController,
                            decoration: InputDecoration(
                              labelText: "Poll Question",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 20),
                          child: TextFormField(
                            controller: choice1Controller,
                            decoration: InputDecoration(
                              labelText: "Choice 1",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextFormField(
                            controller: choice2Controller,
                            decoration: InputDecoration(
                              labelText: "Choice 2",
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
                                      ? Text("Fill out all fields!",
                                          style: TextStyle(
                                            color: Colors.red,
                                          ))
                                      : Container(),
                                ],
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 50.0, top: 20),
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
                                    "Suggest",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                HapticFeedback.lightImpact();

                                if (pollTitleController.text == "" ||
                                    choice1Controller.text == "" ||
                                    choice2Controller.text == "") {
                                  setState(() {
                                    blankField = true;
                                  });
                                }
                                if (blankField == false) {
                                  setState(() {
                                    isUploading = true;
                                  });
                                  FirebaseFirestore.instance
                                      .collection('notreDame')
                                      .doc('data')
                                      .collection('poll')
                                      .doc("xSuggestions")
                                      .collection("suggestions")
                                      .doc()
                                      .set({
                                        "choice1": choice1Controller.text,
                                        "choice2": choice2Controller.text,
                                        "question": pollTitleController.text,
                                        "suggestor": currentUser.displayName,
                                        "suggestorClass": currentUser.year ==
                                                "Freshman"
                                            ? "'ND 24"
                                            : currentUser.year == "Sophomore"
                                                ? "'ND 23"
                                                : currentUser.year == "Junior"
                                                    ? "'ND 22"
                                                    : currentUser.year ==
                                                            "Senior"
                                                        ? "'ND 21"
                                                        : "",
                                        "when": DateTime.now(),
                                        "voters": {"115805501102171844515": 1}
                                      }, SetOptions(merge: true))
                                      .then((value) => setState(() {
                                            isUploading = false;
                                          }))
                                      .then((value) => setState(() {
                                            goodCheck = true;
                                          }))
                                      .then((value) =>
                                          Timer(Duration(seconds: 1), () {
                                            Navigator.of(context).pop();
                                          }));
                                }
                              }),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}

class PullUpPoll extends StatefulWidget {
  final String messageId, postId;
  const PullUpPoll(this.messageId, this.postId);

  @override
  _PullUpPollState createState() => _PullUpPollState();
}

class _PullUpPollState extends State<PullUpPoll> {
  double option1 = 1;
  double option2 = 90;
  double option3 = 2.0;
  double option4 = 3.0;

  Map voters = {};
  String creator = "me";
  String userId;
  String voter;
  List<dynamic> option1List;
  List<dynamic> option2List;

  var x;
  var y;

  @override
  Widget build(BuildContext context) {
    String choice1;
    String choice2;
    String choice3;
    String choice4;

    final dateToCheck = Timestamp.now().toDate();
    final aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);

    String day = DateFormat('MMMd').format(aDate);

    return StreamBuilder(
        stream: messagesRef
            .doc(widget.messageId)
            .collection("pullUpTimeForPosts")
            .doc(widget.postId)
            .snapshots(),

        // ignore: missing_return
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          // dynamic moovId;
          bool isLargePhone = Screen.diagonal(context) > 766;

          voters = snapshot.data['voters'];
          // question = snapshot.data['question'];
          choice1 = snapshot.data['choice1'];
          choice2 = snapshot.data['choice2'];
          choice3 = snapshot.data['choice3'];
          choice4 = snapshot.data['choice4'];

          List _list = voters.values.toList();

          option1 =
              _list.where((element) => element == 1).toList().length.toDouble();
          option2 =
              _list.where((element) => element == 2).toList().length.toDouble();

          option3 =
              _list.where((element) => element == 3).toList().length.toDouble();

          option4 =
              _list.where((element) => element == 4).toList().length.toDouble();

          option1List = _list.where((element) => element == 1).toList();

          option2List = _list.where((element) => element == 2).toList();

          // var count = _list.where((c) => c.product_id == 2).toList().length;

          for (var entry in voters.entries) {
            x = entry.key;
            y = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                height: 240,
                child: Column(
                  children: [
                    Polls(
                        question: Text(""),
                        children: [
                          // This cannot be less than 2, else will throw an exception
                          Polls.options(title: choice1, value: option1),
                          Polls.options(title: choice2, value: option2),
                          Polls.options(title: choice3, value: option3),
                          Polls.options(title: choice4, value: option4),
                        ],
                        pollStyle: TextStyle(color: TextThemes.ndBlue),
                        currentUser: currentUser.id,
                        creatorID: this.creator,
                        voteData: voters,
                        // voteData: usersWhoVoted,
                        // userChoice: usersWhoVoted[this.userId],
                        userChoice: voters[currentUser.id],
                        onVoteBackgroundColor: Colors.blue,
                        leadingBackgroundColor: TextThemes.ndGold,
                        backgroundColor: Colors.white,
                        onVote: (choice) {
                          HapticFeedback.lightImpact();

                          for (var entry in voters.entries) {
                            x = entry.key;
                            y = entry.value;
                          }

                          setState(() {
                            x = choice;
                          });

                          messagesRef
                              .doc(widget.messageId)
                              .collection("pullUpTimeForPosts")
                              .doc(widget.postId)
                              .set({
                            "voters": {currentUser.id: choice}
                          }, SetOptions(merge: true));

                          if (choice == 1) {
                            setState(() {
                              option1 += 1.0;
                            });
                          }
                          if (choice == 2) {
                            setState(() {
                              option2 += 1.0;
                            });
                          }

                          if (choice == 3) {
                            setState(() {
                              option3 += 1.0;
                            });
                          }
                          if (choice == 4) {
                            setState(() {
                              option4 += 1.0;
                            });
                          }
                        }),
                  ],
                ),
              ),
            );
          }
        });
  }
}
