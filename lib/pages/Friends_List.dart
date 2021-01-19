import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:flutter/material.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final usersRef = FirebaseFirestore.instance.collection('users');

class friendsList extends StatefulWidget {
  dynamic moovId;
  TextEditingController searchController = TextEditingController();
  List<dynamic> likedArray;
  final userFriends;

  friendsList(this.moovId, this.likedArray, {this.userFriends});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return friendsListState(this.moovId, this.likedArray, this.userFriends);
  }
}

class friendsListState extends State<friendsList> {
  dynamic moovId;
  TextEditingController searchController = TextEditingController();
  List<dynamic> likedArray;
  var iter = 0;
  final userFriends;

  friendsListState(this.moovId, this.likedArray, this.userFriends);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where("friendArray", arrayContains: currentUser.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data == null) return Container();

          return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePageWithHeader()),
                    );
                  },
                ),
                backgroundColor: TextThemes.ndBlue,
                title: Text(
                  "Friends",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                            margin: EdgeInsets.all(0.0),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Column(
                                children: [
                                  Container(
                                      color: Colors.grey[300],
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(builder:
                                                          (BuildContext
                                                              context) {
                                                    return OtherProfile(snapshot
                                                        .data
                                                        .docs[index]
                                                        .data['id']
                                                        .toString());
                                                  })); //Material
                                                },
                                                child: CircleAvatar(
                                                    radius: 22,
                                                    child: CircleAvatar(
                                                        radius: 22.0,
                                                        backgroundImage:
                                                            NetworkImage(snapshot
                                                                    .data
                                                                    .docs[index]
                                                                    .data[
                                                                'photoUrl'])

                                                        // NetworkImage(likedArray[index]['strPic']),

                                                        ))),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(builder:
                                                          (BuildContext
                                                              context) {
                                                    return OtherProfile(snapshot
                                                        .data
                                                        .docs[index]
                                                        .data['id']
                                                        .toString());
                                                  })); //Material
                                                },
                                                child: Text(
                                                    snapshot.data.docs[index]
                                                        .data['displayName']
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            TextThemes.ndBlue,
                                                        decoration:
                                                            TextDecoration
                                                                .none))),
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: RaisedButton(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              color: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              3.0))),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            OtherProfile(snapshot
                                                                .data
                                                                .docs[index]
                                                                .data['id']
                                                                .toString())));
                                              },
                                              child: Text(
                                                "Friends",
                                                style: new TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                            )),
                      )));
        });
  }
}
