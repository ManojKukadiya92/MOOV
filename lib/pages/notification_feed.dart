import 'package:MOOV/main.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/ProfilePage.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'group_detail.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationFeed extends StatefulWidget {
  @override
  _NotificationFeedState createState() => _NotificationFeedState();
}

class _NotificationFeedState extends State<NotificationFeed> {
  getNotificationFeed() async {
    QuerySnapshot snapshot = await notificationFeedRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .getDocuments();
    List<NotificationFeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(NotificationFeedItem.fromDocument(doc));
    });
    return feedItems;
  }

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
          child: FutureBuilder(
        future: getNotificationFeed(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return ListView(
              children: snapshot.hasData
                  ? snapshot.data
                  : Text(
                      'No Notifications',
                    ));
        },
      )),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class NotificationFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type; // 'like', 'follow', 'friendgroup'
  final String previewImg;
  final String postId;
  final String userProfilePic;
  final String userEmail;

  //for redirecting to PostDetail
  final String title;
  final String description;
  final String location;
  final String ownerProPic;
  final String ownerName;
  final String ownerEmail;
  final dynamic startDate, address, moovId;
  final List<dynamic> likedArray;

  final Timestamp timestamp;

  NotificationFeedItem(
      {this.title,
      this.description,
      this.location,
      this.username,
      this.userEmail,
      this.userId,
      this.type,
      this.previewImg,
      this.postId,
      this.userProfilePic,
      this.timestamp,
      this.ownerProPic,
      this.ownerName,
      this.ownerEmail,
      this.startDate,
      this.address,
      this.moovId,
      this.likedArray});

  factory NotificationFeedItem.fromDocument(DocumentSnapshot doc) {
    return NotificationFeedItem(
      username: doc['username'],
      userEmail: doc['userEmail'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfilePic: doc['userProfilePic'],
      timestamp: doc['timestamp'],
      title: doc['title'],
      description: doc['description'],
      ownerProPic: doc['ownerProPic'],
      ownerName: doc['ownerName'],
      ownerEmail: doc['ownerEmail'],
      address: doc['address'],
      location: doc['location'],
      moovId: doc['moovId'],
      likedArray: doc['likedArray'],
      startDate: doc['startDate'],
      previewImg: doc['previewImg'],
    );
  }

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostDetail(previewImg, title, description,
                startDate, location, address, userId, likedArray, postId)));
  }

  showGroup(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                GroupDetail(previewImg, title, likedArray, postId, address)));
  }

  configureMediaPreview(context) {
    if (type == 'going') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(previewImg),
                  ),
                ),
              )),
        ),
      );
    } else if (type == 'friendgroup') {
      mediaPreview = GestureDetector(
        onTap: () => showGroup(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(previewImg),
                  ),
                ),
              )),
        ),
      );
    } else if (type == 'invite') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(previewImg),
                  ),
                ),
              )),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (type == 'going') {
      activityItemText = "is going to ";
    } else if (type == 'request') {
      activityItemText = "has sent you a friend request.";
    } else if (type == 'accept') {
      activityItemText = "has accepted your friend request.";
    } else if (type == 'friendgroup') {
      activityItemText = 'has added you to ';
    } else if (type == 'invite') {
      activityItemText = 'has invited you to ';
    } else {
      activityItemText = "Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: isLargePhone ? 13.5 : 12,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' $activityItemText',
                    ),
                    TextSpan(
                        text: title,
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.blue)),
                  ]),
            ),
          ),
          leading: GestureDetector(
            onTap: () => showProfile(context),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(userProfilePic),
            ),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }

  showProfile(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => OtherProfile(userProfilePic, username, userId)));
  }
}
