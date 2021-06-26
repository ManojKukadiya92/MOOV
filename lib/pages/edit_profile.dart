import 'dart:io';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:MOOV/widgets/camera.dart';
import 'package:flutter/material.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  final Home user;

  EditProfile({Key key, this.user}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final nameController = TextEditingController();
  final dormController = TextEditingController();
  final bioController = TextEditingController();
  final venmoController = TextEditingController();
  get firestoreInstance => null;
  File _image;
  File _image2;
  final picker = ImagePicker();
  final picker2 = ImagePicker();

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
        cropStyle: CropStyle.circle,
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

  void openCamera2(context) async {
    final image2 = await CustomCamera.openCamera();
    setState(() {
      _image2 = image2;
      //  fileName = p.basename(_image.path);
    });
    _cropImage2();
  }

  void openGallery2(context) async {
    final image2 = await CustomCamera.openGallery();
    setState(() {
      _image2 = image2;
    });
    _cropImage2();
  }

  Future<Null> _cropImage2() async {
    File croppedFile = await ImageCropper.cropImage(
        maxHeight: 100,
        sourcePath: _image2.path,
        aspectRatioPresets: Platform.isAndroid
            ? [CropAspectRatioPreset.ratio16x9]
            : [CropAspectRatioPreset.ratio16x9],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Croperooni',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          title: 'Croperooni',
        ));
    if (croppedFile != null) {
      setState(() {
        _image2 = croppedFile;
      });
    }
  }

  Future handleTakePhoto2() async {
    Navigator.pop(context);
    final file2 = await picker2.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      if (_image2 != null) {
        _image2 = File(file2.path);
      }
    });
  }

  handleChooseFromGallery2() async {
    Navigator.pop(context);
    final file2 = await picker2.getImage(
      source: ImageSource.gallery,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      if (_image2 != null) {
        _image2 = File(file2.path);
      }
    });
  }

  selectImage2(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Upload Header",
            style: TextStyle(color: Colors.white),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                "Photo with Camera",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                openCamera2(context);
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
                openGallery2(context);
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

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;
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
              MaterialPageRoute(builder: (context) => ProfilePageWithHeader()),
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
                  height: 55.0,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(children: [
          Container(
            height: 145,
            child: GestureDetector(
              onTap: () => selectImage2(context),
              child: Stack(children: <Widget>[
                FractionallySizedBox(
                  widthFactor: isLargePhone ? 1.15 : 1.34,
                  child: Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: currentUser.header == "" && currentUser.isBusiness
                          ? Image.asset('lib/assets/tux.jpg', fit: BoxFit.cover)
                          : currentUser.header == "" && !currentUser.isBusiness
                              ? Image.asset('lib/assets/headerNoWhite.jpg',
                                  fit: BoxFit.cover)
                              : Image.network(
                                  currentUser.header,
                                  fit: BoxFit.fitWidth,
                                ),
                    ),
                    margin: EdgeInsets.only(
                        left: 20, top: 0, right: 20, bottom: 7.5),
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
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 50,
                  top: 20,
                  child: IconButton(
                      icon: Icon(Icons.add_a_photo, size: 50),
                      onPressed: () => selectImage2(context)),
                ),
                FractionallySizedBox(
                    widthFactor: isLargePhone ? 1.15 : 1.34,
                    child: _image2 != null
                        ? Container(
                            child: Image.file(_image2, fit: BoxFit.fitWidth),
                            margin: EdgeInsets.only(
                                left: 20, top: 0, right: 20, bottom: 7.5),
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
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                          )
                        : Text("")),
              ]),
            ),
          ),
          Container(
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
                      child: Stack(children: [
                        Opacity(
                          opacity: .5,
                          child: CircleAvatar(
                            backgroundImage: (currentUser.photoUrl == null)
                                ? AssetImage('images/user-avatar.png')
                                : NetworkImage(currentUser.photoUrl),
                            // backgroundImage: NetworkImage(currentUser.photoUrl),
                            radius: 50,
                          ),
                        ),
                        Center(
                            child: _image != null
                                ? CircleAvatar(
                                    backgroundImage: FileImage(_image),
                                    radius: 200,
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    child: IconButton(
                                        icon: Icon(Icons.add_a_photo, size: 50),
                                        onPressed: () => selectImage(context))))
                      ]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    currentUser.displayName != null
                        ? currentUser.displayName
                        : "Username not found",
                    style: TextThemes.extraBold,
                  ),
                ),
                currentUser.nameChangeLimit == 1
                    ? Padding(
                        padding: const EdgeInsets.only(top: 30.0, bottom: 5),
                        child: Text(
                          "Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      )
                    : Container(),
                SizedBox(height: 5),
                currentUser.nameChangeLimit == 1
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          autocorrect: false,
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "You can only change your name once.",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 10),
                  child: Text(
                    "Bio",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    autocorrect: false,
                    controller: bioController,
                    decoration: InputDecoration(
                      labelText: "Uncensored words to live by...",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 10),
                  child: Text(
                    "Venmo",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text("@  ",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: TextFormField(
                          autocorrect: false,
                          controller: venmoController,
                          decoration: InputDecoration(
                            labelText: "What's your @?",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 30)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      padding: EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [TextThemes.ndBlue, Color(0xff64B6FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: 125.0, minHeight: 50.0),
                          alignment: Alignment.center,
                          child: Text(
                            "Save",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (_image != null) {
                          firebase_storage.Reference ref = firebase_storage
                              .FirebaseStorage.instance
                              .ref()
                              .child("images/" + currentUser.displayName);

                          // StorageReference firebaseStorageRef = FirebaseStorage
                          //     .instance
                          //     .ref()
                          //     .child("images/" + currentUser.displayName);
                          firebase_storage.UploadTask uploadTask;

                          uploadTask = ref.putFile(_image);

                          firebase_storage.TaskSnapshot taskSnapshot =
                              await uploadTask;
                          if (uploadTask.snapshot.state ==
                              firebase_storage.TaskState.success) {
                            print("added to Firebase Storage");

                            final String downloadUrl =
                                await ref.getDownloadURL();

                            usersRef.doc(currentUser.id).update({
                              "photoUrl": downloadUrl,
                            });
                          }
                        }
                        if (_image2 != null) {
                          firebase_storage.Reference ref = firebase_storage
                              .FirebaseStorage.instance
                              .ref()
                              .child("images/" + currentUser.id + "/header");

                          // StorageReference firebaseStorageRef = FirebaseStorage
                          //     .instance
                          //     .ref()
                          //     .child("images/header" + currentUser.displayName);
                          firebase_storage.UploadTask uploadTask;

                          uploadTask = ref.putFile(_image2);

                          firebase_storage.TaskSnapshot taskSnapshot =
                              await uploadTask;
                          if (uploadTask.snapshot.state ==
                              firebase_storage.TaskState.success) {
                            print("added to Firebase Storage");
                            final String headerUrl =
                                await taskSnapshot.ref.getDownloadURL();
                            usersRef.doc(currentUser.id).update({
                              "header": headerUrl,
                            });
                          }
                        }
                        if (nameController.text != "") {
                          usersRef.doc(currentUser.id).update({
                            "displayName": nameController.text.toUpperCase(),
                            "nameChangeLimit": FieldValue.increment(-1)
                          });
                        }

                        if (dormController.text != "") {
                          usersRef.doc(currentUser.id).update({
                            "dorm": dormController.text.toUpperCase(),
                          });
                        }

                        if (bioController.text != "") {
                          usersRef.doc(currentUser.id).update({
                            "bio": bioController.text,
                          });
                        }
                        if (venmoController.text != "") {
                          usersRef.doc(currentUser.id).update({
                            "venmoUsername": venmoController.text,
                          });
                        }
                        Navigator.pop(context);
                      }),
                )
              ],
            ),
          )
        ]),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    venmoController.dispose();
    bioController.dispose();
  }
}
