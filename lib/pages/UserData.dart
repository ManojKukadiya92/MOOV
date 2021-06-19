import 'package:MOOV/main.dart';
import 'package:MOOV/pages/home.dart' as home;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MOOV/helpers/themes.dart';
import 'HomePage.dart';
import 'home.dart';

class UserData extends StatefulWidget {
  @override
  _UserDataState createState() {
    return _UserDataState();
  }
}

class _UserDataState extends State<UserData> {
  Container buildNoContent() {
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
                      MaterialPageRoute(builder: (context) => home.Home()),
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
                stream: home.usersRef
                    .orderBy('score', descending: true)
                    .limit(50)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    var prize;

                    return Scaffold(
                      body: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    child: Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.data_usage_sharp,
                                        color: TextThemes.ndBlue,
                                        size: 50,
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text("Data Transparency Policy",
                                        style: TextThemes.headline1),
                                  ),
                                  Text(
                                    "You are not the product. We respect your privacy.",
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 7.5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [],
                                    ),
                                  ),
                                ])),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [],
                                      ),
                                      Text("User: " + currentUser.displayName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          "Joined: " +
                                              currentUser.timestamp
                                                  .toDate()
                                                  .toUtc()
                                                  .toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      currentUser.isBusiness
                                          ? Text(
                                              "Location: " + currentUser.dorm,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold))
                                          : Text(
                                              "Demographic: " +
                                                  currentUser.year +
                                                  " " +
                                                  currentUser.gender +
                                                  " in " +
                                                  currentUser.dorm,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                      Text("Email: " + currentUser.email,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text("Google ID: " + currentUser.id,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),

                                     currentUser.venmoUsername != null ? Text(
                                          "Venmo: @" +
                                              currentUser.venmoUsername
                                                  .toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)) : Container(),
                                      Text(
                                          "Score: " +
                                              currentUser.score.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          "Verified Status: " +
                                              currentUser.verifiedStatus
                                                  .toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      // Text("Joined MOOV on " +
                                      //     currentUser.timestamp.toString())
                                    ])
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                })));
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade400,
    );
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Sign out?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nWhere you goin'?"),
        actions: [
          CupertinoDialogAction(
              isDefaultAction: true,
              child:
                  Text("Yes, sign me out", style: TextStyle(color: Colors.red)),
              onPressed: () {
                home.googleSignIn.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => home.Home()),
                  (Route<dynamic> route) => false,
                );
              }),
          CupertinoDialogAction(
            child: Text("Nah, my bad"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }
}
