import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:MOOV/main.dart';
import 'package:MOOV/pages/friend_groups.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/add_users_post.dart';
import 'package:MOOV/widgets/camera.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class GroupForm extends StatefulWidget {
  final Home user;

  GroupForm({Key key, this.user}) : super(key: key);

  @override
  _GroupFormState createState() => new _GroupFormState();
}

class _GroupFormState extends State<GroupForm> {
  List<String> memberoonis = [currentUser.id];
  bool isUploading = false;
  get firestoreInstance => null;
  File _image;
  final picker = ImagePicker();

  void openCamera(context) async {
    final image = await CustomCamera.openCamera();
    setState(() {
      _image = image;
    });
  }

  void openGallery(context) async {
    final image = await CustomCamera.openGallery();
    setState(() {
      _image = image;
    });
  }

  Future<bool> doesNameAlreadyExist(groupName) async {
    List<String> groupNames = [];

    final QuerySnapshot result =
        await groupsRef.where('groupName', isEqualTo: groupName).get();
    for (int i = 0; i < result.docs.length; i++) {
      groupNames.add(result.docs[i].data()['groupName']);
    }
    if (groupNames.contains(groupName)) {
      nameExists = true;

      return true;
    } else

      // return false;
      print("No, this name does not exist, we're good to go.");
  }

  Future handleTakePhoto() async {
    Navigator.pop(context);
    final file = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      if (_image != null) {
        _image = File(file.path);
      }
    });
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  createGroupInFirestore(gname, cid, pic) async {
    List<String> memberNames = [];
    final String groupName = gname;
    final groupId = generateRandomString(20);

    for (int i = 0; i < memberoonis.length; i++) {
      usersRef.doc(memberoonis[i]).get().then((snap) => {
            memberNames.add(snap.data()['displayName']),
            groupsRef.doc(groupId).set({
              "groupName": groupName,
              "members": memberoonis,
              "memberNames": memberNames,
              "groupPic": pic,
              "groupId": groupId,
              // "chat": {'messages': []},
              "nextMOOV": "",
              "voters": {}
              // "gid": id
            })
          });
    }

    // .then((value) {
    //   String data = value.documentID;
    // FirebaseFirestore.instance.document('friendGroups/$data').updateData({"gid" : data});
    // // newDocRef.setData({
    // //   "groupName": groupName,
    // //   "members": [cid],
    // //   "groupPic": pic,
    // //   "chat": {'messages': []},
    // //   "nextMOOV": "",
    // //   "gid": newDocRef.documentID
    // // }, merge: true);
    // });
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      for (int i = 0; i < memberoonis.length; i++) {
        final DocumentReference userRefs = FirebaseFirestore.instance
            .doc('notreDame/data/users/${memberoonis[i]}');

        transaction.update(userRefs, {
          'friendGroups': FieldValue.arrayUnion([groupId]),
        });
        if (memberoonis[i] != currentUser.id) {
          Database().addedToGroup(memberoonis[i], groupName, groupId, pic);
        }
      }
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    final file = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      if (_image != null) {
        _image = File(file.path);
      }
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Upload Group Picture",
            style: TextStyle(color: Colors.white),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                "Photo with Camera",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                openCamera(context);
                Navigator.of(context).pop();
              },
            ),
            SimpleDialogOption(
              child: Text(
                "Image from Gallery",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                openGallery(context);
                Navigator.of(context).pop();
              },
            ),
            SimpleDialogOption(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context, true),
            )
          ],
        );
      },
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String groupName;
  bool _termsChecked = false;
  int radioValue = -1;
  bool _autoValidate = false;
  int id = 0;
  bool noImage = false;
  bool nameExists = false;

  void refreshData() {
    id++;
  }

  FutureOr onGoBack(dynamic value) {
    refreshData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => FriendGroupsPage()),
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
        body: isUploading
            ? linearProgress()
            : SingleChildScrollView(
                child: Column(children: [
                  Container(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(children: [
                            _image != null
                                ? Container(
                                    height: 200,
                                    width: 200,
                                    child:
                                        Image.file(_image, fit: BoxFit.cover),
                                    margin: EdgeInsets.only(
                                        left: 20,
                                        top: 0,
                                        right: 20,
                                        bottom: 7.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Container(
                                          width: 100,
                                          height: 100,
                                          child: IconButton(
                                              icon: Icon(Icons.add_a_photo,
                                                  size: 50),
                                              onPressed: () =>
                                                  selectImage(context))),
                                      noImage == true && _image == null
                                          ? Text(
                                              "No pic, no fun.",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )
                                          : Container(),
                                    ],
                                  ),
                          ]))),
                  Container(
                      margin: const EdgeInsets.all(20.0),
                      child: new Form(
                          key: _formKey,
                          autovalidate: _autoValidate,
                          child: new Column(children: <Widget>[
                            new SizedBox(
                              height: 20.0,
                            ),
                            new TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Friend Group Name'),
                              onSaved: (String value) {
                                groupName = value;
                              },
                              validator: _validateGroupName,
                              keyboardType: TextInputType.name,
                            ),
                            new SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0, vertical: 10),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.all(0.0),
                                              icon: Icon(
                                                Icons.person_add,
                                                size: 35,
                                              ),
                                              color: TextThemes.ndBlue,
                                              splashColor: Color.fromRGBO(
                                                  220, 180, 57, 1.0),
                                              onPressed: () {
                                                HapticFeedback.lightImpact();

                                                Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            type:
                                                                PageTransitionType
                                                                    .bottomToTop,
                                                            child:
                                                                AddUsersFromCreateGroup(
                                                                    memberoonis)))
                                                    .then(onGoBack);
                                              },
                                            ),
                                            Text("Add",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 100,
                                        width: memberoonis.length == 0
                                            ? 0
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .64,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            itemCount: memberoonis.length,
                                            itemBuilder: (_, index) {
                                              return StreamBuilder(
                                                  stream: usersRef
                                                      .doc(memberoonis[index])
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    // bool isLargePhone = Screen.diagonal(context) > 766;

                                                    if (!snapshot.hasData)
                                                      return CircularProgressIndicator();
                                                    String userName = snapshot
                                                        .data['displayName'];
                                                    String userPic = snapshot
                                                        .data['photoUrl'];

                                                    // userMoovs = snapshot.data['likedMoovs'];

                                                    return Container(
                                                      height: 50,
                                                      child: Column(
                                                        children: <Widget>[
                                                          CircleAvatar(
                                                            radius: 34,
                                                            backgroundColor:
                                                                TextThemes
                                                                    .ndGold,
                                                            child:
                                                                CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      userPic),
                                                              radius: 32,
                                                              backgroundColor:
                                                                  TextThemes
                                                                      .ndBlue,
                                                              child:
                                                                  CircleAvatar(
                                                                // backgroundImage: snapshot.data
                                                                //     .documents[index].data['photoUrl'],
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        userPic),
                                                                radius: 32,
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: Center(
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        5.0),
                                                                child: RichText(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textScaleFactor:
                                                                      1.0,
                                                                  text: TextSpan(
                                                                      style: TextThemes
                                                                          .mediumbody,
                                                                      children: [
                                                                        TextSpan(
                                                                            text:
                                                                                userName,
                                                                            style:
                                                                                TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            }),
                                      ),
                                    ])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 80.0),
                              child: CheckboxListTile(
                                  title: new Text("We'll be lit."),
                                  value: _termsChecked,
                                  onChanged: (bool value) =>
                                      setState(() => _termsChecked = value)),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Container(
                              height: 50.0,
                              child: RaisedButton(
                                onPressed: _validateInputs,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(80.0)),
                                padding: EdgeInsets.all(0.0),
                                child: Ink(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          TextThemes.ndBlue,
                                          Color(0xff64B6FF)
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(30.0)),
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth: 300.0, minHeight: 50.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Create",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ])))
                ]),
              ));
  }

  String _validateGroupName(String value) {
    doesNameAlreadyExist(value);
    if (value.isEmpty) {
      // The form is empty
      return "Enter group name";
    }
    // This is just a regular expression for email addresses
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      // So, the email is valid
      return null;
    }

    return 'Group name is invalid!';

    // The pattern of the email didn't match the regex above.
  }

  _validateInputs() {
    if (_image == null) {
      setState(() {
        noImage = true;
      });
    }
    if (_formKey.currentState.validate() &&
        _image != null &&
        nameExists == false) {
      setState(() {
        isUploading = true;
      });
    }
    final form = _formKey.currentState;
    if (form.validate()) {
      if (!_termsChecked) {
        // The checkbox wasn't checked
        _showSnackBar("Please accept our terms");
      } else {
        // Every of the data in the form are valid at this point
        form.save();
        _saveFirebase();
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }

  void _saveFirebase() async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child("images/group" + groupName);
    // Reference firebaseStorageRef =
    //     FirebaseStorage.instance.ref().child("images/group" + gid);

    firebase_storage.UploadTask uploadTask;

    uploadTask = ref.putFile(_image);

    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
    if (uploadTask.snapshot.state == firebase_storage.TaskState.success) {
      print("added to Firebase Storage");
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      createGroupInFirestore(groupName, currentUser.id, downloadUrl);
    }

    setState(() {
      isUploading = false;
    });

    Navigator.pop(context);
  }

  void _showSnackBar(message) {
    final snackBar = new SnackBar(
      backgroundColor: Colors.red,
      content: new Text(message),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
