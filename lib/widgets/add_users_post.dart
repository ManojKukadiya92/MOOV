import 'package:MOOV/models/user.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/leaderboard.dart';
import 'package:MOOV/pages/notification_feed.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/widgets/trending_segment.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:MOOV/widgets/trending_segment.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../pages/ProfilePage.dart';
import '../pages/other_profile.dart';

class AddUsersPost extends StatefulWidget {
  String me;
  List<String> invitees;

  AddUsersPost(this.me, this.invitees);

  @override
  _AddUsersPostState createState() =>
      _AddUsersPostState(this.me, this.invitees);
}

class _AddUsersPostState extends State<AddUsersPost> {
  String me;
  List<String> invitees;

  _AddUsersPostState(this.me, this.invitees);
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .limit(5)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
    setState(() {
      searchResultsFuture = null;
    });
  }

  AppBar buildSearchField() {
    return AppBar(
      toolbarHeight: 100,
      leading: IconButton(
          icon: Icon(Icons.arrow_drop_down_circle_outlined,
              color: Colors.white, size: 35),
          onPressed: () {
            // widget.refresh();
            Navigator.pop(context, invitees);
          }),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.all(2),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
      backgroundColor: TextThemes.ndBlue,
      //pinned: true,
      actions: <Widget>[],
      bottom: PreferredSize(
        preferredSize: null,
        child: TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            fillColor: Colors.white,
            hintStyle: TextStyle(fontSize: 15),
            contentPadding: EdgeInsets.only(top: 18, bottom: 10),
            hintText: "Search for Users...",
            filled: true,
            prefixIcon: Icon(
              Icons.account_box,
              size: 28.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearch,
            ),
          ),
          onFieldSubmitted: handleSearch,
        ),
      ),
    );
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      color: Colors.white,
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user, me, invitees);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatefulWidget {
  User user;
  String me;
  List<String> invitees;

  UserResult(this.user, this.me, this.invitees);

  @override
  _UserResultState createState() =>
      _UserResultState(this.user, this.me, this.invitees);
}

class _UserResultState extends State<UserResult> {
  User user;
  String me;
  List<String> invitees;

  bool status = false;

  _UserResultState(this.user, this.me, this.invitees);

  @override
  Widget build(BuildContext context) {
    // if (user.friendGroups == null) {
    //   return Container();
    // }
    invitees.contains(user.id) ? status = true : false;

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => print(user.dorm),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName == null ? "" : user.displayName,
                style: TextStyle(
                    color: TextThemes.ndBlue, fontWeight: FontWeight.bold),
              ),
              trailing: status
                  ? RaisedButton(
                      padding: const EdgeInsets.all(2.0),
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3.0))),
                      onPressed: () {
                        invitees.remove(user.id);
                        setState(() {
                          status = false;
                        });
                      },
                      child: Text(
                        "Added",
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ))
                  : RaisedButton(
                      padding: const EdgeInsets.all(2.0),
                      color: TextThemes.ndBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3.0))),
                      onPressed: () {
                        invitees.add(user.id);
                        print(invitees);
                        setState(() {
                          status = true;
                        });
                      },
                      child: Text(
                        "Add to Group",
                        style: new TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      )),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
