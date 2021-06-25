import 'package:MOOV/models/user.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/group_detail.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/leaderboard.dart';
import 'package:MOOV/pages/notification_feed.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/widgets/trending_segment.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:MOOV/widgets/trending_segment.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'ProfilePageWithHeader.dart';
import 'other_profile.dart';

class SearchNoTrending extends StatefulWidget {
  @override
  _SearchNoTrendingState createState() => _SearchNoTrendingState();
}

class _SearchNoTrendingState extends State<SearchNoTrending>
    with AutomaticKeepAliveClientMixin {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  Future<QuerySnapshot> searchResultsEvents;
  Future<QuerySnapshot> searchResultsGroups;
  bool get wantKeepAlive => true;
  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .limit(5)
        .get();
    Future<QuerySnapshot> events =
        postsRef.where("title", isGreaterThanOrEqualTo: query).limit(5).get();
    Future<QuerySnapshot> groups = groupsRef
        .where("groupName", isGreaterThanOrEqualTo: query)
        .limit(5)
        .get();
    setState(() {
      searchResultsFuture = users;
      searchResultsEvents = events;
      searchResultsGroups = groups;
    });
  }

  clearSearch() {
    searchController.clear();

    setState(() {
      searchResultsFuture = null;
      searchResultsEvents = null;
      searchResultsGroups = null;
    });
  }

  @override
  void initState() {
    super.initState();

    // Simple declarations
    TextEditingController searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  AppBar buildSearchField() {
    return AppBar(
      leadingWidth: 60,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(pageBuilder: (_, __, ___) => Home()),
            (Route<dynamic> route) => false,
          );
        },
      ),
      backgroundColor: TextThemes.ndBlue,
      actions: <Widget>[
        IconButton(
          padding: EdgeInsets.only(left: 5.0),
          icon: Icon(Icons.insert_chart),
          color: Colors.white,
          splashColor: Color.fromRGBO(220, 180, 57, 1.0),
          onPressed: () {
            // Implement navigation to leaderboard page here...
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LeaderBoardPage()));
          },
        ),
        NamedIcon(
          iconData: Icons.notifications_active,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NotificationFeed()));
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.all(5),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {},
              child: Bounce(
                duration: Duration(milliseconds: 50),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(pageBuilder: (_, __, ___) => Home()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Image.asset(
                    'lib/assets/moovblue.png',
                    fit: BoxFit.cover,
                    height: 50.0,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      toolbarHeight: 105,
      bottom: PreferredSize(
        preferredSize: null,
        child: TextFormField(
          onChanged: (value) {
            handleSearch(value);
          },
          controller: searchController,
          decoration: InputDecoration(
            fillColor: Colors.white,
            hintStyle: TextStyle(fontSize: 15),
            contentPadding: EdgeInsets.only(top: 18, bottom: 10),
            hintText: "Search",
            filled: true,
            prefixIcon: Icon(
              Icons.account_box,
              size: 28.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                clearSearch();
              },
            ),
          ),
          onFieldSubmitted: handleSearch,
        ),
      ),
    );
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container();
  }

  buildSearchResults() {
    return FutureBuilder(
      future: Future.wait(
          [searchResultsFuture, searchResultsGroups, searchResultsEvents]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Widget> searchResults = [];
        snapshot.data[0].docs.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        snapshot.data[1].docs.forEach((doc) {
          var group = doc;
          GroupResult searchResult = GroupResult(group);
          searchResults.add(searchResult);
        });
        snapshot.data[2].docs.forEach((doc) {
          var moov = doc;
          EventResult searchResult = EventResult(moov);
          searchResults.add(searchResult);
        });
        return ListView(children: searchResults);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount userMe = googleSignIn.currentUser;
    final strUserId = userMe.id;
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              if (user.id == strUserId) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePageWithHeader()));
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => OtherProfile(user.id)));
              }
            },
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
              trailing: Icon(Icons.person, color: TextThemes.ndBlue),
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

class EventResult extends StatelessWidget {
  final moov;

  EventResult(this.moov);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostDetail(moov['postId'])))
            },
            child: ListTile(
              leading: Image.network(moov['image'],
                  fit: BoxFit.cover, height: 50, width: 70),
              title: Text(
                moov['title'] == null ? "" : moov['title'],
                style: TextStyle(
                    color: TextThemes.ndBlue, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.event, color: Colors.green),
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

class GroupResult extends StatelessWidget {
  final group;

  GroupResult(this.group);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => GroupDetail(group['groupId'])))
            },
            child: ListTile(
              leading: Image.network(
                group['groupPic'],
                fit: BoxFit.cover,
                height: 40,
                width: 60,
              ),
              title: Text(
                group['groupName'] == null ? "" : group['groupName'],
                style: TextStyle(
                    color: TextThemes.ndBlue, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.people, color: TextThemes.ndGold),
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
