import 'dart:developer';
import 'dart:ui';

import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/models/going.dart';
import 'package:MOOV/models/going_model.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/ProfilePage.dart';
import 'package:MOOV/pages/friend_groups.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/widgets/set_moov.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:MOOV/services/database.dart';
import 'package:page_transition/page_transition.dart';
import '../widgets/add_users.dart';
import 'edit_group.dart';
import 'home.dart';

class EditGroup extends StatefulWidget {
  String photoUrl, displayName, gid;
  List<dynamic> members;

  EditGroup(this.photoUrl, this.displayName, this.members, this.gid);

  @override
  State<StatefulWidget> createState() {
    return _EditGroupState(
        this.photoUrl, this.displayName, this.members, this.gid);
  }
}

class _EditGroupState extends State<EditGroup> {
  String photoUrl, displayName, gid;
  List<dynamic> members;
  final dbRef = Firestore.instance;
  _EditGroupState(this.photoUrl, this.displayName, this.members, this.gid);

  sendChat() {
    Database().sendChat(currentUser.displayName, chatController.text, gid);
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      child: CupertinoAlertDialog(
        title: Text("Leave the group?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nTime to MOOV on?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Yes get me out", style: TextStyle(color: Colors.red)),
            onPressed: () {
              leaveGroup();
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: Text("Nah, my mistake"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }

  leaveGroup() {
    if (members.length == 1) {
      Database().leaveGroup(currentUser.id, displayName, gid);
      Database().destroyGroup(gid);
    } else {
      Database().leaveGroup(currentUser.id, displayName, gid);
    }
    Navigator.pop(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  bool requestsent = false;
  TextEditingController chatController = TextEditingController();
  bool sendRequest = false;
  bool friends;
  var status;
  var userRequests;
  final GoogleSignInAccount userMe = googleSignIn.currentUser;
  final strUserId = currentUser.id;
  final strPic = currentUser.photoUrl;
  final strUserName = currentUser.displayName;
  var profilePic;
  var otherDisplay;
  var id;
  var iter = 1;

  @override
  Widget build(BuildContext context) {
    final groupNameController = TextEditingController();

    return StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .where('friendGroups', arrayContains: displayName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

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
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              backgroundColor: TextThemes.ndBlue,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.all(15),
                title: Text('Edit Group',
                    style: TextStyle(fontSize: 25.0, color: Colors.white)),
              ),
            ),
            body: Container(
              child: Column(
                children: [
                  Container(
                    height: 200,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (_, index) {
                          DocumentSnapshot course =
                              snapshot.data.documents[index];
                          profilePic =
                              snapshot.data.documents[index].data['photoUrl'];
                          otherDisplay = snapshot
                              .data.documents[index].data['displayName'];
                          id = snapshot.data.documents[index].data['id'];
                          print(id);
                          return Container(
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30.0, bottom: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (course['id'] == strUserId) {
                                        // what do we do in this case?
                                      } else {
                                        Database().leaveGroup(
                                            course['id'], displayName, gid);
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 54,
                                      backgroundColor: TextThemes.ndGold,
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(snapshot
                                            .data
                                            .documents[index]
                                            .data['photoUrl']),
                                        radius: 50,
                                        backgroundColor: TextThemes.ndBlue,
                                        child: CircleAvatar(
                                          // backgroundImage: snapshot.data
                                          //     .documents[index].data['photoUrl'],
                                          backgroundImage: NetworkImage(snapshot
                                              .data
                                              .documents[index]
                                              .data['photoUrl']),
                                          radius: 50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: RichText(
                                        textScaleFactor: 1.1,
                                        text: TextSpan(
                                            style: TextThemes.mediumbody,
                                            children: [
                                              TextSpan(
                                                  text: snapshot
                                                      .data
                                                      .documents[index]
                                                      .data['displayName']
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ]),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: groupNameController,
                      decoration: InputDecoration(
                        labelText: displayName,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Container(
                        child: CachedNetworkImage(imageUrl: photoUrl)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: RaisedButton(
                        color: TextThemes.ndBlue,
                        child:
                            Text('Save', style: TextStyle(color: Colors.white)),
                        onPressed: () async {
                          // if (_image != null) {
                          //   StorageReference firebaseStorageRef = FirebaseStorage
                          //       .instance
                          //       .ref()
                          //       .child("images/" + currentUser.displayName);
                          //   StorageUploadTask uploadTask =
                          //       firebaseStorageRef.putFile(_image);
                          //   StorageTaskSnapshot taskSnapshot =
                          //       await uploadTask.onComplete;
                          //   if (taskSnapshot.error == null) {
                          //     print("added to Firebase Storage");
                          //     final String downloadUrl =
                          //         await taskSnapshot.ref.getDownloadURL();
                          //     usersRef.document(currentUser.id).updateData({
                          //       "photoUrl": downloadUrl,
                          //     });
                          //   }
                          // }

                          if (groupNameController.text != "") {
                            Database().updateGroupNames(members,
                                groupNameController.text, gid, displayName);
                            Firestore.instance
                                .collection('friendGroups')
                                .document(gid)
                                .updateData({
                              "groupName": groupNameController.text,
                            });
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => friendGroupsPage()));
                        }),
                  )
                ],
              ),
            ),
          );
        });
  }
}

class CircleImages extends StatefulWidget {
  var image = "";

  CircleImages({this.image});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CircleWidgets(image: image);
  }
}

class CircleWidgets extends State<CircleImages> {
  var image;
  CircleWidgets({this.image});
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (var x = 0; x < 10; x++) {
      widgets.add(Container(
          height: 60.0,
          width: 60.0,
          margin: EdgeInsets.all(6.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              boxShadow: [
                new BoxShadow(
                    color: Color.fromARGB(100, 0, 0, 0),
                    blurRadius: 5.0,
                    offset: Offset(5.0, 5.0))
              ],
              border: Border.all(
                  width: 2.0,
                  style: BorderStyle.solid,
                  color: Color.fromARGB(255, 0, 0, 0)),
              image: DecorationImage(
                  fit: BoxFit.cover, image: NetworkImage(image)))));
    }
    return Container(
        height: 80.0,
        child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(5.0),
            children: widgets));
  }
}
