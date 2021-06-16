import 'package:MOOV/main.dart';
import 'package:MOOV/models/user.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:MOOV/helpers/themes.dart';
import 'HomePage.dart';
import 'ProfilePageWithHeader.dart';
import 'other_profile.dart';

class LeaderBoardPage extends StatefulWidget {
  @override
  _LeaderBoardState createState() {
    return _LeaderBoardState();
  }
}

class _LeaderBoardState extends State<LeaderBoardPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.search),
            Text(
              "",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isLargePhone = Screen.diagonal(context) > 766;

    var myIndex = 0;
    var score;
    var pic;
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
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream:
              usersRef.orderBy('score', descending: true).limit(50).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Loading..."),
                    SizedBox(
                      height: 50.0,
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              );
            } else {

              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('notreDame')
                      .doc('data')
                      .collection('leaderboard')
                      .doc('prizes')
                      .snapshots(),
                  builder: (context, snapshot2) {
                    if (!snapshot2.hasData) return CircularProgressIndicator();

                    for (int i = 0; i < snapshot.data.docs.length; i++) {
                      if (snapshot.data.docs[i]['id'] == currentUser.id) {
                        myIndex = i;
                      }
                    }

                    var prize = snapshot2.data['prize'];
                    return Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('lib/assets/trophy.png',
                                height: 75),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text("MOOV Weekly Leaderboard",
                                style: TextThemes.headline1),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                    border: Border(),
                                    gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment(0.9, 0.9),
                                        colors: [
                                          TextThemes.ndBlue,
                                          TextThemes.ndBlue
                                        ])),
                                child: Center(
                                    child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    "Do you like free stuff?"
                                    " \nRise to the top of the leaderboard to win. \nWeek ends with payouts on Money MOOV Mondays.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isLargePhone ? 14 : 15,
                                      fontFamily: 'Pacifico',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ))),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text("This Week's Prize: ",
                                    style: TextStyle(fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  prize.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipOval(
                                  child: Material(
                                    child: InkWell(
                                      splashColor:
                                          TextThemes.ndGold, // inkwell color
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Icon(
                                            Icons.info_outline,
                                            size: 20,
                                          )),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (_) =>
                                                CupertinoAlertDialog(
                                                  title: Text("MOOV Score"),
                                                  content: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Text(
                                                      "Your score is calculated as follows:"
                                                      "\n"
                                                      "\n\n20pts: Voting on a suggestion"
                                                      "\n\n25pts: Voting on the poll"
                                                      "\n\n30pts: Leaving a status on a MOOV"
                                                      "\n\n10pts: Receiving a status on a MOOV"
                                                      "\n\n30pts: Suggesting a MOOV"
                                                      "\n\n50pts: Sending a MOOV to a friend"
                                                      "\n\n75pts: Joining a Friend Group"
                                                      "\n\n100pts: Posting a MOOV"
                                                      "\n\n\n**Negative points arise from gaming the system or undoing actions. If you are suspected of cheating, your score will be reset to zero"
                                                      "",
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ),
                                                ),
                                            barrierDismissible: true);
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Text('Your MOOV Score: '),
                                ),
                                Text(
                                  currentUser.score.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (_, index) {
                                score =
                                    snapshot.data.docs[index].data()['score'];
                                pic = snapshot.data.docs[index]
                                    .data()['photoUrl'];

                                return GestureDetector(
                                    onTap: () => {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OtherProfile(
                                                        snapshot
                                                            .data.docs[index]
                                                            .data()['id'],
                                                      )))
                                        },
                                    child: Card(
                                      color: snapshot.data.docs[index]
                                                  .data()['displayName'] ==
                                              currentUser.displayName
                                          ? Colors.green[300]
                                          : Colors.grey[50],
                                      child: ListTile(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  (index + 1).toString() +
                                                      '   ',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                CircleAvatar(
                                                  radius: 17,
                                                  backgroundColor:
                                                      TextThemes.ndGold,
                                                  child: CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor:
                                                        TextThemes.ndBlue,
                                                    child: CircleAvatar(
                                                      backgroundImage: (pic ==
                                                              null)
                                                          ? AssetImage(
                                                              'images/user-avatar.png')
                                                          : NetworkImage(pic),
                                                      // backgroundImage: NetworkImage(currentUser.photoUrl),
                                                      radius: 15,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    snapshot.data.docs[index]
                                                        .data()['displayName'],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                (index == 0)
                                                    ? Image.asset(
                                                        'lib/assets/trophy2.png',
                                                        height: 25)
                                                    : Text(''),
                                              ],
                                            ),
                                            Text(
                                              snapshot.data.docs[index]
                                                  .data()['score']
                                                  .toString(),
                                              style: TextStyle(
                                                  color: TextThemes.ndBlue,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ), // getting the data from firestore
                                      ),
                                    ));
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            }
          },
        ),
      ),
    );
  }
}
