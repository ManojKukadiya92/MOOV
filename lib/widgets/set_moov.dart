import 'package:MOOV/models/user.dart';
import 'package:MOOV/pages/friend_groups.dart';
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

class SetMOOV extends StatefulWidget {
  String gname, gid;

  SetMOOV(this.gname, this.gid);

  @override
  _SetMOOVState createState() => _SetMOOVState(this.gname, this.gid);
}

class _SetMOOVState extends State<SetMOOV> {
  String gname, gid;

  _SetMOOVState(this.gname, this.gid);
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  Future<QuerySnapshot> searchResultsEvents;

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .limit(5)
        .getDocuments();
    Future<QuerySnapshot> events =
        postsRef.where("title", isGreaterThanOrEqualTo: query).getDocuments();

    setState(() {
      searchResultsFuture = users;
      searchResultsEvents = events;
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
            Navigator.pop(context);
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
            hintText: "Search for MOOVs...",
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
    List<Widget> results = [];
    return FutureBuilder(
      future: searchResultsEvents,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        // List<EventResult> searchResults = [];
        snapshot.data.documents.forEach((doc) {
          var moov = doc;
          EventResult searchResult = EventResult(moov, gid);
          results.add(searchResult);
        });
        return ListView(
          children: results,
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

class EventResult extends StatelessWidget {
  final moov, gid;

  EventResult(this.moov, this.gid);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => print('moov tapped'),
            child: ListTile(
              leading: Image.network(moov.data['image'],
                  fit: BoxFit.cover, height: 50, width: 70),
              title: Text(
                moov.data['title'] == null ? "" : moov.data['title'],
                style: TextStyle(
                    color: TextThemes.ndBlue, fontWeight: FontWeight.bold),
              ),
              trailing: RaisedButton(
                padding: const EdgeInsets.all(2.0),
                color: TextThemes.ndBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3.0))),
                onPressed: () {
                  Database().setMOOV(gid, moov.data['postId']);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FriendGroupsPage()));
                },
                child: Text(
                  "Set MOOV",
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
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
