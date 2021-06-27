import 'dart:io';
import 'dart:ui';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/widgets/camera.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:MOOV/services/database.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import '../pages/home.dart';

class EditGroup extends StatefulWidget {
  final String photoUrl, displayName, gid;
  final List<dynamic> members;

  EditGroup(this.photoUrl, this.displayName, this.members, this.gid);

  @override
  State<StatefulWidget> createState() {
    return _EditGroupState(
        this.photoUrl, this.displayName, this.members, this.gid);
  }
}

class _EditGroupState extends State<EditGroup> {
  File _image;
  final picker = ImagePicker();

  void openCamera(context) async {
    final image = await CustomCamera.openCamera();
    setState(() {
      _image = image;
      //  fileName = p.basename(_image.path);
    });
    _cropImage();
  }

  void openGallery(context) async {
    final image = await CustomCamera.openGallery();
    setState(() {
      _image = image;
    });
    _cropImage();
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        maxHeight: 100,
        sourcePath: _image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Croperooni',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Croperooni',
        ));
    if (croppedFile != null) {
      setState(() {
        _image = croppedFile;
      });
    }
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
            "Upload Profile Pic",
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
              //    child: Text("Image from Gallery", style: TextStyle(color: Colors.white),), onPressed: handleChooseFromGallery),
              //    child: Text("Image from Gallery", style: TextStyle(color: Colors.white),), onPressed: () => openGallery(context)),
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

  String photoUrl, displayName, gid;
  List<dynamic> members;
  final dbRef = FirebaseFirestore.instance;
  _EditGroupState(this.photoUrl, this.displayName, this.members, this.gid);

  sendChat() {
    Database().sendChat(currentUser.displayName, chatController.text, gid);
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
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
            child: Text("Nah, my bad"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }

  leaveGroup() {
    if (members.length == 1) {
      Database().leaveGroup(
          currentUser.id, displayName, gid, currentUser.displayName);
      Database().destroyGroup(gid, displayName);
    } else {
      Database().leaveGroup(
          currentUser.id, displayName, gid, currentUser.displayName);
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
        stream: usersRef.where('friendGroups', arrayContains: gid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

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
                titlePadding: EdgeInsets.all(15),
                title: Text('Edit Group',
                    style: TextStyle(fontSize: 25.0, color: Colors.white)),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (_, index) {
                            DocumentSnapshot course = snapshot.data.docs[index];
                            profilePic = snapshot.data.docs[index]['photoUrl'];
                            otherDisplay =
                                snapshot.data.docs[index]['displayName'];
                            id = snapshot.data.docs[index]['id'];
                            return Container(
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 30.0, bottom: 10),
                                    child: course['id'] != strUserId
                                        ? GestureDetector(
                                            onTap: () {
                                              showAlertDialog2(
                                                  context,
                                                  course['id'],
                                                  course['displayName']);
                                            },
                                            child: Stack(children: [
                                              ShakeAnimatedWidget(
                                                enabled: true,
                                                duration:
                                                    Duration(milliseconds: 500),
                                                shakeAngle: Rotation.deg(z: 10),
                                                curve: Curves.linear,
                                                child: CircleAvatar(
                                                  radius: 54,
                                                  backgroundColor: Colors.red,
                                                  child: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(snapshot
                                                                .data
                                                                .docs[index]
                                                            ['photoUrl']),
                                                    radius: 50,
                                                    backgroundColor:
                                                        TextThemes.ndBlue,
                                                    child: CircleAvatar(
                                                      // backgroundImage: snapshot.data
                                                      //     .documents[index].data['photoUrl'],
                                                      backgroundImage:
                                                          NetworkImage(snapshot
                                                                  .data
                                                                  .docs[index]
                                                              ['photoUrl']),
                                                      radius: 50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                  right: -10,
                                                  top: -7.5,
                                                  child: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                    size: 50,
                                                  )),
                                            ]),
                                          )
                                        : CircleAvatar(
                                            radius: 54,
                                            backgroundColor: TextThemes.ndGold,
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  snapshot.data.docs[index]
                                                      ['photoUrl']),
                                              radius: 50,
                                              backgroundColor:
                                                  TextThemes.ndBlue,
                                              child: CircleAvatar(
                                                // backgroundImage: snapshot.data
                                                //     .documents[index].data['photoUrl'],
                                                backgroundImage: NetworkImage(
                                                    snapshot.data.docs[index]
                                                        ['photoUrl']),
                                                radius: 50,
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
                                                        .docs[index]
                                                            ['displayName']
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
                      child: Stack(alignment: Alignment.center, children: [
                        Opacity(
                          opacity: .5,
                          child: Container(
                            child: (currentUser.photoUrl == null)
                                ? AssetImage('images/user-avatar.png')
                                : OptimizedCacheImage(imageUrl: photoUrl),
                            // backgroundImage: NetworkImage(currentUser.photoUrl),
                          ),
                        ),
                        _image != null
                            ? Container(
                                child: Image.file(_image),
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                child: IconButton(
                                    icon: Icon(Icons.add_a_photo, size: 50),
                                    onPressed: () => selectImage(context)))
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: RaisedButton(
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
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: 125.0, minHeight: 50.0),
                              alignment: Alignment.center,
                              child: Text(
                                "Save",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 22),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if (_image != null) {
                              firebase_storage.Reference ref = firebase_storage
                                  .FirebaseStorage.instance
                                  .ref()
                                  .child("images/group" + gid);

                              // StorageReference firebaseStorageRef =
                              //     FirebaseStorage.instance
                              //         .ref()
                              //         .child("images/group" + gid);

                              // Reference firebaseStorageRef =
                              //     FirebaseStorage.instance
                              //         .ref()
                              //         .child("images/" +
                              //             titleController.text);

                              firebase_storage.UploadTask uploadTask;

                              uploadTask = ref.putFile(_image);

                              firebase_storage.TaskSnapshot taskSnapshot =
                                  await uploadTask;
                              if (uploadTask.snapshot.state ==
                                  firebase_storage.TaskState.success) {
                                print("added to Firebase Storage");
                                final String downloadUrl =
                                    await taskSnapshot.ref.getDownloadURL();
                                groupsRef.doc(gid).update({
                                  "groupPic": downloadUrl,
                                });
                              }
                            }

                            if (groupNameController.text != "") {
                              // Database().updateGroupNames(members,
                              //     groupNameController.text, gid, displayName);
                              groupsRef.doc(gid).update({
                                "groupName": groupNameController.text,
                              });
                            }
                            Navigator.pop(context);
                          }),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void showAlertDialog2(BuildContext context, id, displayName) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Crew get smaller?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nKick user out of the group?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Yup", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Database().leaveGroup(id, displayName, gid, displayName);
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: Text("Nah, my bad"),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      ),
    );
  }
}
