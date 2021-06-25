import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:MOOV/pages/MoovMaker.dart';
import 'package:MOOV/widgets/google_map.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/models/user.dart';
import 'package:MOOV/pages/MOOVSPage.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/widgets/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
  static _CreateAccountState of(BuildContext context) =>
      context.findAncestorStateOfType<_CreateAccountState>();
}

class _CreateAccountState extends State<CreateAccount> {
  String businessLocationLatitude = "";
  String businessLocationLongitude = "";
  String businessAddress = "";

  set string(String value) => businessLocationLatitude = value;
  set string2(String value) => businessLocationLongitude = value;
  set string3(String value) => businessAddress = value;

  int selectedIndex = 0;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey0 = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  final _formKey5 = GlobalKey<FormState>();
  final _formKey6 = GlobalKey<FormState>();
  final _formKey7 = GlobalKey<FormState>();
  // final _formKey8 = GlobalKey<FormState>();
  final yearList = ["Freshman", "Sophomore", "Junior", "Senior", "Grad"];
  final genderList = ["Female", "Male", "Other"];
  final raceList = ["Black", "Latino", "Asian", "White", "Other"];
  final bizTypeList = [
    "Restaurant/Bar",
    "Theatre",
    "Night Club",
    "Student Club",
  ];
  String typeDropdownValue = 'Restaurant/Bar';

  String yearDropdownValue = "Freshman";
  String genderDropdownValue = "Female";
  String raceDropdownValue = "Black";

  String dorm;
  String gender;
  String race;
  String year;
  String referral;
  String venmoUsername;
  String businessName;
  String businessDescription;
  Map userTypeMap = {};
  bool isSingle = false;

  submit() {
    final form0 = _formKey0.currentState;
    final form = _formKey.currentState;
    final form2 = _formKey2.currentState;
    final form3 = _formKey3.currentState;
    final form4 = _formKey4.currentState;
    final form7 = _formKey7.currentState;

    if (form0.validate() &&
        form.validate() &&
        form2.validate() &&
        form3.validate()) {
      form0.save();
      form.save();
      form2.save();
      form3.save();
      form4.save();
      form7.save();

      if (_clubExecChecked) {
        userTypeMap = {"clubExecutive": []};
      }
      if (_isSingleChecked) {
        isSingle = true;
      }

      SnackBar snackbar = SnackBar(
          backgroundColor: Colors.green, content: Text("Welcome to MOOV!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      createUserInFirestore();

      Timer(Duration(seconds: 1), () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context,
                        [dorm, gender, year, referral, venmoUsername, auth]) =>
                    Home()));
      });
    }
  }

  submitBusiness() {
    final form5 = _formKey5.currentState;
    final form6 = _formKey6.currentState;
    // final form8 = _formKey8.currentState;

    if (form5.validate() && form6.validate()) {
      form5.save();
      form6.save();

      SnackBar snackbar = SnackBar(
          backgroundColor: Colors.green, content: Text("Welcome to MOOV!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      createBusinessInFirestore();

      Timer(Duration(seconds: 1), () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (
              context,
            ) =>
                    Home()));
      });
    }
  }

  File _image;
  final picker = ImagePicker();
  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Upload Business Picture",
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

  void openCamera(context) async {
    final image = await CustomCamera.openCamera();
    setState(() {
      _image = image;
      //  fileName = p.basename(_image.path);
    });
  }

  void openGallery(context) async {
    final image = await CustomCamera.openGallery();
    setState(() {
      _image = image;
    });
  }

  Future handleTakePhoto() async {
    Navigator.pop(context);
    final file2 = await picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      if (_image != null) {
        _image = File(file2.path);
      }
    });
  }

  handleChooseFromGallery2() async {
    Navigator.pop(context);
    final file2 = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      if (_image != null) {
        _image = File(file2.path);
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

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.doc(user.id).set({
        "id": user.id,
        "photoUrl": user.photoUrl,
        "badges": {},
        "isBusiness": false,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "Create a bio here",
        "header": "",
        "timestamp": timestamp,
        "score": 0,
        "moovMoney": 0,
        "gender": gender,
        "race": race,
        "year": year,
        "dorm": dorm,
        "referral": referral,
        "postLimit": 3,
        "sendLimit": 5,
        "verifiedStatus": 0,
        "followers": [],
        "friendArray": [],
        "friendRequests": [],
        "friendGroups": [],
        "userType": userTypeMap,
        "isSingle": false,
        "venmoUsername": venmoUsername,
        "pushSettings": {
          "going": true,
          "hourBefore": true,
          "suggestions": true,
          "friendPosts": true
        },
        "privacySettings": {
          "friendFinderVisibility": true,
          "friendsOnly": false,
          "incognito": false,
          "showDorm": true
        }
      });
      doc = await usersRef.doc(user.id).get();
    }
    currentUser = User.fromDocument(doc);
  }

  createBusinessInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();

    double businessLatitude = double.parse(businessLocationLatitude);
    double businessLongitude = double.parse(businessLocationLongitude);

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page

      // 3) get username from create account, use it to make new user document in users collection

      String abbrev = businessName
          .toLowerCase()
          .replaceAll("’", "")
          .replaceAll(" ", "")
          .substring(0, 4);
      String businessCode = abbrev + (1000 + Random().nextInt(100)).toString();

      usersRef.doc(user.id).set({
        "id": user.id,
        "email": user.email,
        "displayName": businessName,
        "businessLocation": GeoPoint(businessLatitude, businessLongitude),
        "businessType": typeDropdownValue,
        "menu": [],
        "photoUrl": user.photoUrl,
        "badges": {},
        "bio": businessDescription ?? "Create a bio here",
        "header": "",
        "timestamp": timestamp,
        "score": 0,
        "moovMoney": 0,
        "gender": "",
        "race": "",
        "year": "",
        "dorm": businessAddress ?? "",
        "referral": "",
        "isBusiness": true,
        "businessCode": businessCode,
        "postLimit": 3,
        "sendLimit": 5,
        "verifiedStatus": 3,
        "followers": [],
        "friendArray": [],
        "friendRequests": [],
        "friendGroups": [],
        "userType": userTypeMap,
        "isSingle": false,
        "venmoUsername": venmoUsername,
        "mobileOrderMenu": {"item1": {}, "item2": {}, "item3": {}},
        "pushSettings": {
          "friendPosts": true,
          "going": true,
          "hourBefore": true,
          "suggestions": true
        },
        "privacySettings": {
          "friendFinderVisibility": true,
          "friendsOnly": false,
          "incognito": false,
          "showDorm": true
        }
      });

      // StorageReference firebaseStorageRef = FirebaseStorage
      //     .instance
      //     .ref()
      //     .child("images/" + currentUser.displayName);

      doc = await usersRef.doc(user.id).get();
    }
    currentUser = User.fromDocument(doc);
  }

  bool _clubExecChecked = false;
  bool _isSingleChecked = false;
  bool noAddress = false;

  @override
  Widget build(BuildContext parentContext) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: TextThemes.ndBlue,
        //pinned: true,

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
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: isLargePhone ? 30 : 15),
                Container(
                  child: Container(
                      child: Column(children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.accessibility_new,
                          color: TextThemes.ndBlue,
                          size: 50,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child:
                          Text("Welcome to MOOV", style: TextThemes.headline1),
                    ),
                    Text(
                      "Tell us about you",
                    ),
                  ])),
                ),
                SizedBox(height: 15),
                BottomNavyBar(
                  mainAxisAlignment: MainAxisAlignment.center,
                  selectedIndex: selectedIndex,
                  items: [
                    BottomNavyBarItem(
                      icon: Icon(Icons.school, color: TextThemes.ndBlue),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("I'm a",
                              style: TextStyle(color: TextThemes.ndBlue)),
                          Text("Student",
                              style: TextStyle(color: TextThemes.ndBlue)),
                        ],
                      ),
                    ),
                    BottomNavyBarItem(
                      icon: Icon(Icons.store),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("I'm a"),
                          Text("Business"),
                        ],
                      ),
                    ),
                  ],
                  onItemSelected: (index) {
                    HapticFeedback.lightImpact();

                    setState(() => selectedIndex = index);
                  },
                ),
                SizedBox(height: 15),
                selectedIndex == 0
                    ? Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(top: 16.0, left: 50, right: 50),
                            child: Container(
                              child: Form(
                                key: _formKey,
                                autovalidate: true,
                                child: TextFormField(
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (val) {
                                    if (val.trim().length < 2 || val.isEmpty) {
                                      return "Dorm name is too short";
                                    } else if (val.trim().length > 16) {
                                      return "Dorm name is too long";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (val) => dorm = val,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Dorm",
                                    labelStyle: TextStyle(fontSize: 13.0),
                                    hintText: "Dorm",
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Form(
                                  key: _formKey3,
                                  autovalidate: true,
                                  child: Container(
                                    width: isLargePhone
                                        ? MediaQuery.of(context).size.width *
                                            .23
                                        : MediaQuery.of(context).size.width *
                                            .26,
                                    child: ButtonTheme(
                                      child: DropdownButtonFormField(
                                        value: genderDropdownValue,
                                        icon: Icon(Icons.arrow_downward,
                                            color: TextThemes.ndGold),
                                        decoration: InputDecoration(
                                          labelText: "Gender",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        items: genderList.map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            genderDropdownValue = newValue;
                                          });
                                        },
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'What gender are you?';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => gender = value,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Form(
                                    key: _formKey2,
                                    autovalidate: true,
                                    child: Container(
                                      width: isLargePhone
                                          ? MediaQuery.of(context).size.width *
                                              .3
                                          : MediaQuery.of(context).size.width *
                                              .34,
                                      child: ButtonTheme(
                                        child: DropdownButtonFormField(
                                          value: yearDropdownValue,
                                          icon: Icon(Icons.arrow_downward,
                                              color: TextThemes.ndGold),
                                          decoration: InputDecoration(
                                            labelText: "Year",
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          items: yearList.map((String value) {
                                            return new DropdownMenuItem<String>(
                                              value: value,
                                              child: new Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              yearDropdownValue = newValue;
                                            });
                                          },
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'What year are you?';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) => year = value,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Form(
                                  key: _formKey7,
                                  autovalidate: true,
                                  child: Container(
                                    width: isLargePhone
                                        ? MediaQuery.of(context).size.width *
                                            .23
                                        : MediaQuery.of(context).size.width *
                                            .25,
                                    child: ButtonTheme(
                                      child: DropdownButtonFormField(
                                        value: raceDropdownValue,
                                        icon: Icon(Icons.arrow_downward,
                                            color: TextThemes.ndGold),
                                        decoration: InputDecoration(
                                          labelText: "Race",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        items: raceList.map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            raceDropdownValue = newValue;
                                          });
                                        },
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'What race are you?';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) => race = value,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 50),
                          Text("—Optional Details—"),
                          SizedBox(height: 10),
                          SizedBox(
                            width: 194,
                            height: 35,
                            child: CheckboxListTile(
                                title: new Text("I'm a club exec."),
                                value: _clubExecChecked,
                                onChanged: (bool value) =>
                                    setState(() => _clubExecChecked = value)),
                          ),
                          //ratedPG
                          // SizedBox(
                          //   height: 40,
                          //   width: 194,
                          //   child: CheckboxListTile(
                          //       title: new Text("I'm single."),
                          //       value: _isSingleChecked,
                          //       onChanged: (bool value) =>
                          //           setState(() => _isSingleChecked = value)),
                          // ),
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: Form(
                                    key: _formKey0,
                                    autovalidate: true,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .4,
                                      child: ButtonTheme(
                                        child: TextFormField(
                                          autocorrect: false,
                                          validator: (val) {
                                            if (val.trim().length > 2 &&
                                                !val.contains("@nd.edu")) {
                                              return "Enter an @nd.edu address";
                                            } else if (val.trim().length > 16) {
                                              return "Enter an @nd.edu address";
                                            } else {
                                              return null;
                                            }
                                          },
                                          onSaved: (val) => referral = val,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Who referred you?",
                                            labelStyle:
                                                TextStyle(fontSize: 13.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Form(
                                    key: _formKey4,
                                    autovalidate: true,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .4,
                                      child: ButtonTheme(
                                        child: TextFormField(
                                          autocorrect: false,
                                          onSaved: (val) => venmoUsername = val,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Venmo Username",
                                            labelStyle:
                                                TextStyle(fontSize: 13.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isLargePhone ? 30 : 0),
                          GestureDetector(
                            onTap: submit,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 18.0, bottom: 18),
                              child: Container(
                                height: 50.0,
                                width: 300.0,
                                decoration: BoxDecoration(
                                  color: TextThemes.ndBlue,
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                child: Center(
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(top: 16.0, left: 50, right: 50),
                            child: Container(
                              child: Form(
                                key: _formKey5,
                                autovalidate: true,
                                child: TextFormField(
                                  autocorrect: false,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (val) {
                                    if (val.trim().length < 2 || val.isEmpty) {
                                      return "Name is too short";
                                    } else if (val.trim().length > 25) {
                                      return "Name is too long";
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (val) => businessName = val,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Business Name",
                                    labelStyle: TextStyle(fontSize: 13.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          Text("Type of Business"),
                          SizedBox(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width * .45,
                            child: ButtonTheme(
                              child: DropdownButtonFormField(
                                style: isLargePhone
                                    ? null
                                    : TextStyle(
                                        fontSize: 12.5, color: Colors.black),
                                value: typeDropdownValue,
                                icon: Icon(Icons.museum,
                                    color: TextThemes.ndGold),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                items: bizTypeList.map((String value) {
                                  return new DropdownMenuItem<String>(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                                onChanged: (String newValue) {
                                  setState(() {
                                    typeDropdownValue = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'What are we doing?';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          GoogleMap(
                              fromMOOVMaker: false,
                              callback: (val) => businessLocationLatitude = val,
                              callback2: (val) =>
                                  businessLocationLongitude = val,
                              callback3: (val) => businessAddress = val),
                          SizedBox(height: 20),
                          Text("— Optional Details —"),
                          // Padding(
                          //   padding:
                          //       const EdgeInsets.only(top: 15.0, bottom: 10),
                          //   child: CircleAvatar(
                          //     radius: 55,
                          //     backgroundColor: TextThemes.ndGold,
                          //     child: CircleAvatar(
                          //       radius: 50,
                          //       backgroundColor: TextThemes.ndBlue,
                          //       child: Stack(children: [
                          //         Opacity(
                          //           opacity: .5,
                          //           child: CircleAvatar(
                          //             backgroundImage:
                          //                 AssetImage('lib/assets/tux.jpg'),
                          //             // backgroundImage: NetworkImage(currentUser.photoUrl),
                          //             radius: 50,
                          //           ),
                          //         ),
                          //         Center(
                          //             child: _image != null
                          //                 ? CircleAvatar(
                          //                     backgroundImage:
                          //                         FileImage(_image),
                          //                     radius: 200,
                          //                   )
                          //                 : Container(
                          //                     width: 100,
                          //                     height: 100,
                          //                     child: IconButton(
                          //                         icon: Icon(Icons.add_a_photo,
                          //                             size: 50),
                          //                         onPressed: () =>
                          //                             selectImage(context))))
                          //       ]),
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: 16.0, left: 50, right: 50),
                            child: Container(
                              child: Form(
                                key: _formKey6,
                                autovalidate: true,
                                child: TextFormField(
                                  autocorrect: false,
                                  onSaved: (val) => businessDescription = val,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Business Description",
                                    labelStyle: TextStyle(fontSize: 13.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: EdgeInsets.all(16.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       Image.asset(
                          //         'lib/assets/venmo-icon.png',
                          //         height: 40,
                          //       ),
                          //       Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: Text("@",
                          //             style: TextStyle(
                          //                 fontSize: 30,
                          //                 fontWeight: FontWeight.bold)),
                          //       ),
                          //       Container(
                          //         child: Form(
                          //           key: _formKey8,
                          //           autovalidate: true,
                          //           child: Container(
                          //             width: MediaQuery.of(context).size.width *
                          //                 .4,
                          //             child: ButtonTheme(
                          //               child: TextFormField(
                          //                 autocorrect: false,
                          //                 onSaved: (val) => venmoUsername = val,
                          //                 decoration: InputDecoration(
                          //                   border: OutlineInputBorder(),
                          //                   labelText: "Venmo Username",
                          //                   labelStyle:
                          //                       TextStyle(fontSize: 13.0),
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(height: isLargePhone ? 10 : 10),
                          noAddress
                              ? Text("Set your address!",
                                  style: TextStyle(color: Colors.red))
                              : Container(),
                          GestureDetector(
                            onTap: () {
                              setState(() {});
                              businessLocationLatitude == null ||
                                      (businessLocationLatitude) == ""
                                  ? setState(() {
                                      noAddress = true;
                                    })
                                  : submitBusiness();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 18.0, bottom: 18),
                              child: Container(
                                height: 50.0,
                                width: 300.0,
                                decoration: BoxDecoration(
                                  color: TextThemes.ndBlue,
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                child: Center(
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
