import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:flutter/material.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/pages/ProfilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendFinder extends StatefulWidget {
  String moovId;
  TextEditingController searchController = TextEditingController();
  List<dynamic> likedArray;
  final userFriends;
  // var moovRef;
  FriendFinder({this.userFriends});

  @override
  State<StatefulWidget> createState() {
    return FriendFinderState(this.userFriends);
  }
}

class FriendFinderState extends State<FriendFinder> {
  String moovId;
  var moovArray;
  var moovRef;
  var moov;
  TextEditingController searchController = TextEditingController();
  List<dynamic> likedArray;
  final userFriends;

  friendFind(arr) {
    moovRef = Firestore.instance
        .collection('food')
        .where('liker', arrayContains: arr) // add document id
        .orderBy("startDate")
        .getDocuments()
        .then((QuerySnapshot docs) => {
              if (docs.documents.isNotEmpty)
                {
                  // setState(() {
                  moov = docs.documents[0].data['title']
                  // })
                }
            });
    print(moov);
  }

  FriendFinderState(this.userFriends);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .where("friendArray", arrayContains: currentUser.id)
            .snapshots(),
        builder: (context, snapshot) {
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
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
                backgroundColor: TextThemes.ndBlue,
                title: Text(
                  "Friend Finder",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // body: Column(children: <Widget>[
              //   // Text(friendFind(snapshot.data.documents[0].data).toString()),
              //   Text(friendFind(snapshot.data.documents[1].data).toString()),
              //   Text(friendFind(snapshot.data.documents[2].data).toString()),
              // ])
              body: ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (_, index) {
                    var iter = 0;
                    while (iter == 0) {
                      print(snapshot.data.documents[index].data['id']);
                                            print(snapshot.data.documents[index].data['id']);
                      print(snapshot.data.documents[index].data['id']);

                      friendFind(snapshot.data.documents[index].data['id']);
                      iter = iter + 1;
                    }
                    return moov == null
                        ? Container(color: Colors.white)
                        : Padding(
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                        return OtherProfile(
                                                            snapshot
                                                                .data
                                                                .documents[
                                                                    index]
                                                                .data[
                                                                    'photoUrl']
                                                                .toString(),
                                                            snapshot
                                                                .data
                                                                .documents[
                                                                    index]
                                                                .data[
                                                                    'displayName']
                                                                .toString(),
                                                            snapshot
                                                                .data
                                                                .documents[
                                                                    index]
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
                                                                        .documents[
                                                                            index]
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
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                        return OtherProfile(
                                                            snapshot
                                                                .data
                                                                .documents[
                                                                    index]
                                                                .data[
                                                                    'photoUrl']
                                                                .toString(),
                                                            snapshot
                                                                .data
                                                                .documents[
                                                                    index]
                                                                .data[
                                                                    'displayName']
                                                                .toString(),
                                                            snapshot
                                                                .data
                                                                .documents[
                                                                    index]
                                                                .data['id']
                                                                .toString());
                                                      })); //Material
                                                    },
                                                    child: Text(
                                                        snapshot
                                                            .data
                                                            .documents[index]
                                                            .data['displayName']
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: TextThemes
                                                                .ndBlue,
                                                            decoration:
                                                                TextDecoration
                                                                    .none))),
                                              ),
                                              Text(' is',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                              Text(' Going ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.green)),
                                              Text('to ',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                              Spacer(),
                                              GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                      return OtherProfile(
                                                          snapshot
                                                              .data
                                                              .documents[index]
                                                              .data['photoUrl']
                                                              .toString(),
                                                          snapshot
                                                              .data
                                                              .documents[index]
                                                              .data[
                                                                  'displayName']
                                                              .toString(),
                                                          snapshot
                                                              .data
                                                              .documents[index]
                                                              .data['id']
                                                              .toString());
                                                    })); //Material
                                                  },
                                                  child: Text(moov.toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color:
                                                              TextThemes.ndBlue,
                                                          decoration:
                                                              TextDecoration
                                                                  .none))),
                                            ],
                                          )),
                                    ],
                                  ),
                                )),
                          );
                  }));
        });
  }
}
