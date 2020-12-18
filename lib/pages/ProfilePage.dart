import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/models/user.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/leaderboard.dart';
import 'package:MOOV/pages/edit_profile.dart';
import 'package:MOOV/pages/notification_feed.dart';
import 'package:MOOV/widgets/contacts_button.dart';
import 'package:MOOV/widgets/friend_groups_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:MOOV/pages/notification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatefulWidget {
  User user;
  ProfilePage({Key key, this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    dynamic userScore = currentUser.score.toString();
    var strUserPic = currentUser.photoUrl;
    dynamic likeCount;
    var userYear = currentUser.year.toString().toLowerCase().capitalize();
    var userDorm = currentUser.dorm.toString().toLowerCase().capitalize();
    var userBio = currentUser.bio;

    return StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          userBio = snapshot.data.documents[0]['bio'];
          strUserPic = snapshot.data.documents[0]['photoUrl'];
          if (!snapshot.hasData) return Text('Loading data...');

          return Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Image.asset('lib/assets/ndlogo.png', height: 100),
              ),
              backgroundColor: TextThemes.ndBlue,
              //pinned: true,
              actions: <Widget>[
                IconButton(
                  padding: EdgeInsets.all(5.0),
                  icon: Icon(Icons.insert_chart),
                  color: Colors.white,
                  splashColor: Color.fromRGBO(220, 180, 57, 1.0),
                  onPressed: () {
                    // Implement navigation to leaderboard page here...
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LeaderBoardPage()));
                    print('Leaderboards clicked');
                  },
                ),
                IconButton(
                  padding: EdgeInsets.all(5.0),
                  icon: Icon(Icons.notifications_active),
                  color: Colors.white,
                  splashColor: Color.fromRGBO(220, 180, 57, 1.0),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationFeed()));
                  },
                )
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.all(5),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'lib/assets/moovblue.png',
                      fit: BoxFit.cover,
                      height: 55.0,
                    ),
                  ],
                ),
              ),
            ),
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 10),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: TextThemes.ndGold,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: TextThemes.ndBlue,
                        child: CircleAvatar(
                          backgroundImage: (strUserPic == null)
                              ? AssetImage('images/user-avatar.png')
                              : NetworkImage(strUserPic),
                          // backgroundImage: NetworkImage(currentUser.photoUrl),
                          radius: 50,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      currentUser.displayName != ""
                          ? currentUser.displayName
                          : "Username not found",
                      style: TextThemes.extraBold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
                        child: Text(
                          userYear != "" && userDorm != ""
                              ? userYear + ' in ' + userDorm
                              : "",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          userBio != ""
                              ? "\"" + userBio + "\""
                              : "Notre Dame",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: [
                          Text(
                            '2',
                            style: TextThemes.extraBold,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Next MOOVs   ',
                              style: TextThemes.bodyText1,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              '0',
                              style: TextThemes.extraBold,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Friends',
                                style: TextThemes.bodyText1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '0',
                            style: TextThemes.extraBold,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              'Friend Groups',
                              style: TextThemes.bodyText1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 7.5, bottom: 15, top: 15.5),
                    child: SizedBox(
                      height: 35.0,
                      width: 300,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfile()));
                        },
                        icon: Icon(Icons.edit),
                        backgroundColor: Color.fromRGBO(2, 43, 91, 1.0),
                        label: Text("Edit profile"),
                        foregroundColor: Colors.white,
                        elevation: 15,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: FriendButton(),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SeeContactsButton(),
                    ],
                  ),
                  Positioned(
                    bottom: 10,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 35.0),
                      child: RaisedButton(
                          color: TextThemes.ndBlue,
                          textColor: Colors.white,
                          child: Text('Sign out'),
                          onPressed: () => googleSignIn.signOut()),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
