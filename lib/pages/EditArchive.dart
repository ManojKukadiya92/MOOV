import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:MOOV/friendGroups/OtherGroup.dart';
import 'package:MOOV/friendGroups/group_detail.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/widgets/add_users_post.dart';
import 'package:MOOV/widgets/camera.dart';
import 'package:MOOV/widgets/date_picker.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:MOOV/services/database.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'home.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class EditArchive extends StatefulWidget {
  final String postId;
  EditArchive(this.postId);

  @override
  State<StatefulWidget> createState() {
    return _EditArchiveState(this.postId);
  }
}

class _EditArchiveState extends State<EditArchive> {
  bool isUploading = false;

  final _formKey = GlobalKey<FormState>();
  final privacyList = ["Public", "Friends Only", "Invite Only"];
  final listOfTypes = [
    "Food/Drink",
    "Parties",
    "Clubs",
    "Sports",
    "Shows",
    "Virtual",
    "Recreation",
    "Shopping",
    "Games",
    "Music",
    "Black Market",
    "Study",
    "Student Gov",
    "Mass",
    "Service"
  ];

  DateTime currentValue = DateTime.now();
  DateTime currentValues;
  // DateTime endTime = DateTime.now().add(Duration(minutes: 120));
  // DateTime endTimes;
  final titleController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final paymentAmountController = TextEditingController();
  final maxOccupancyController = TextEditingController();

  final startDateController = DatePicker();
  final format = DateFormat("EEE, MMM d,' at' h:mm a");
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
            "Update Image",
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

  String postId;
  final dbRef = FirebaseFirestore.instance;
  _EditArchiveState(this.postId);

  bool friends;
  var status;
  var userRequests;
  final GoogleSignInAccount userMe = googleSignIn.currentUser;
  final strUserId = currentUser.id;
  final strPic = currentUser.photoUrl;
  final strUserName = currentUser.displayName;
  var profilePic;
  var otherDisplay;
  var iter = 1;
  int id = 0;
  List<String> invitees = [];

  bool noHeight = true;

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

    final groupNameController = TextEditingController();
    Stream stream = archiveRef.doc(postId).snapshots();

    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          String title = snapshot.data['title'];
          String type = snapshot.data['type'];
          String address = snapshot.data['address'];
          String visibility = snapshot.data['privacy'];
          String privacyDropdownValue = visibility;
          List<dynamic> going = snapshot.data['going'];
          String description = snapshot.data['description'];

          String maxOccupancy = snapshot.data['maxOccupancy'].toString();
          String paymentAmount = snapshot.data['paymentAmount'].toString();
          final Map statuses = snapshot.data['statuses'];

          statuses.removeWhere((key, value) => value != -1 && value != 5);

          final List<String> oldInvitees = statuses.keys.toList();

          if (invitees.length == 0) {
            noHeight = true;
          }
          if (invitees.length != 0) {
            noHeight = false;
          }

          int maxOccupancyInt;
          int paymentAmountInt;
          bool negativeOccupancy = false;

          dynamic startDate = snapshot.data['startDate'];
          String image = snapshot.data['image'];
          String typeDropdownValue = snapshot.data['type'];

          return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                automaticallyImplyLeading: false,

                backgroundColor: TextThemes.ndBlue,
                //pinned: true,
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
              body: Form(
                key: _formKey,
                child: isUploading
                    ? linearProgress()
                    : SingleChildScrollView(
                        child: Container(
                            child: Column(children: [
                          Container(
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => selectImage(context),
                                  child: Stack(children: <Widget>[
                                    SizedBox(
                                      height: 200,
                                      width: double.infinity,
                                      child: Container(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: image == null
                                              ? AssetImage(
                                                  'images/user-avatar.png')
                                              : Image.network(
                                                  image,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                        margin: EdgeInsets.only(
                                            left: 20,
                                            top: 7.5,
                                            right: 20,
                                            bottom: 7.5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: 200,
                                        width: double.infinity,
                                        child: _image != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                  child: Image.file(_image,
                                                      fit: BoxFit.cover),
                                                  margin: EdgeInsets.only(
                                                      left: 20,
                                                      top: 7.5,
                                                      right: 20,
                                                      bottom: 7.5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 5,
                                                        blurRadius: 7,
                                                        offset: Offset(0,
                                                            3), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Text("")),
                                  ]),
                                ),
                                // Padding(
                                //   //title
                                //   padding: const EdgeInsets.only(top: 5.0),
                                //   child: Center(
                                //     child: Text(
                                //       title,
                                //       textAlign: TextAlign.center,
                                //       style: TextThemes.headline1,
                                //       maxLines: 2,
                                //       overflow: TextOverflow.ellipsis,
                                //     ),
                                //   ),
                                // ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: TextFormField(
                                    onChanged: (text) {
                                      setState(() {});
                                    },

                                    controller: titleController,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      icon: Text("New \nTitle"),
                                      labelStyle: TextThemes.mediumbody,
                                      labelText: title,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    // The validator receives the text that the user has entered.
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter Event Title';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, right: 10, top: 10),
                                  child: TextFormField(
                                    onChanged: (text) {
                                      setState(() {
                                        description = text;
                                      });
                                    },

                                    controller: descriptionController,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      icon: Text("New \nDesc."),
                                      labelStyle: TextThemes.mediumbody,
                                      labelText: description,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    // The validator receives the text that the user has entered.
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter Event Title';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                // Padding(
                                //     padding: EdgeInsets.only(top: 20),
                                //     child: Container(
                                //       width: 250,
                                //       child: ButtonTheme(
                                //         alignedDropdown: true,
                                //         child: DropdownButtonFormField(
                                //           value: typeDropdownValue,
                                //           icon: Icon(Icons.arrow_downward,
                                //               color: TextThemes.ndGold),
                                //           decoration: InputDecoration(
                                //             labelText: "Type",
                                //             enabledBorder: OutlineInputBorder(
                                //               borderRadius:
                                //                   BorderRadius.circular(10.0),
                                //             ),
                                //           ),
                                //           items:
                                //               listOfTypes.map((String value) {
                                //             return new DropdownMenuItem<String>(
                                //               value: value,
                                //               child: new Text(value),
                                //             );
                                //           }).toList(),
                                //           onChanged: (String newValue) {
                                //             setState(() {
                                //               typeDropdownValue = newValue;
                                //             });
                                //           },
                                //           validator: (value) {
                                //             if (value.isEmpty) {
                                //               return 'What type?';
                                //             }
                                //             return null;
                                //           },
                                //         ),
                                //       ),
                                //     )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 10,
                                        top: 20,
                                        right: 10,
                                        bottom: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .43,
                                          child: ButtonTheme(
                                            alignedDropdown: true,
                                            child: DropdownButtonFormField(
                                              icon: Icon(Icons.arrow_downward,
                                                  color: TextThemes.ndGold),
                                              decoration: InputDecoration(
                                                labelText: visibility,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),
                                              items: privacyList
                                                  .map((String value) {
                                                return new DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: new Text(value),
                                                );
                                              }).toList(),
                                              onChanged: (String newValue) {
                                                setState(() {
                                                  privacyDropdownValue =
                                                      newValue;
                                                });
                                              },
                                              validator: (value) {
                                                if (value.isEmpty) {
                                                  return 'Who can come?';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .43,
                                          child: ButtonTheme(
                                            child: DateTimeField(
                                              format: format,
                                              keyboardType:
                                                  TextInputType.datetime,
                                              decoration: InputDecoration(
                                                  suffixIcon: Icon(
                                                    Icons.arrow_downward,
                                                    color: TextThemes.ndGold,
                                                  ),
                                                  labelText: 'Enter Start Time',
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0)),
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .always),
                                              onChanged: (DateTime newValue) {
                                                setState(() {
                                                  currentValue =
                                                      currentValues; // = newValue;
                                                  //   newValue = currentValue;
                                                });
                                              },
                                              onShowPicker: (context,
                                                  currentValue) async {
                                                final date =
                                                    await showDatePicker(
                                                  context: context,
                                                  firstDate: DateTime(1970),
                                                  currentDate:
                                                      startDate.toDate(),
                                                  initialDate:
                                                      startDate.toDate(),
                                                  lastDate: DateTime(2100),
                                                  builder:
                                                      (BuildContext context,
                                                          Widget child) {
                                                    return Theme(
                                                      data: ThemeData.light()
                                                          .copyWith(
                                                        primaryColor:
                                                            TextThemes.ndGold,
                                                        accentColor:
                                                            TextThemes.ndGold,
                                                        colorScheme:
                                                            ColorScheme.light(
                                                                primary:
                                                                    TextThemes
                                                                        .ndBlue),
                                                        buttonTheme: ButtonThemeData(
                                                            textTheme:
                                                                ButtonTextTheme
                                                                    .primary),
                                                      ),
                                                      child: child,
                                                    );
                                                  },
                                                );
                                                if (date != null) {
                                                  final time =
                                                      await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.fromDateTime(
                                                            currentValue ??
                                                                DateTime.now()),
                                                    builder:
                                                        (BuildContext context,
                                                            Widget child) {
                                                      return Theme(
                                                        data: ThemeData.light()
                                                            .copyWith(
                                                          primaryColor:
                                                              TextThemes.ndGold,
                                                          accentColor:
                                                              TextThemes.ndGold,
                                                          colorScheme:
                                                              ColorScheme.light(
                                                                  primary:
                                                                      TextThemes
                                                                          .ndBlue),
                                                          buttonTheme: ButtonThemeData(
                                                              textTheme:
                                                                  ButtonTextTheme
                                                                      .primary),
                                                        ),
                                                        child: child,
                                                      );
                                                    },
                                                  );
                                                  currentValues =
                                                      DateTimeField.combine(
                                                          date, time);
                                                  return currentValues;
                                                } else {
                                                  return currentValue;
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 0, bottom: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: ButtonTheme(
                                          child: TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (text) {
                                                setState(() {
                                                  maxOccupancy = text;
                                                });
                                              },
                                              controller:
                                                  maxOccupancyController,
                                              decoration: InputDecoration(
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior.never,
                                                icon: Text("Max \nOccup."),
                                                labelStyle:
                                                    TextThemes.mediumbody,
                                                labelText:
                                                    maxOccupancy.toString() ==
                                                            "8000000"
                                                        ? "0"
                                                        : "$maxOccupancy",
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),
                                              // The validator receives the text that the user has entered.
                                              validator: numberValidator),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .4,
                                        child: ButtonTheme(
                                          child: TextFormField(
                                            onChanged: (text) {
                                              setState(() {
                                                paymentAmount = text;
                                              });
                                            },
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              CurrencyTextInputFormatter(
                                                decimalDigits: 0,
                                                symbol: '\$',
                                              )
                                            ],
                                            controller: paymentAmountController,
                                            decoration: InputDecoration(
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.never,
                                              icon: Text("Cost"),
                                              labelStyle: TextThemes.mediumbody,
                                              labelText:
                                                  paymentAmount.toString() ==
                                                          "null"
                                                      ? "0"
                                                      : "\$$paymentAmount",
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            // The validator receives the text that the user has entered.
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                (negativeOccupancy == true)
                                    ? Row(children: [
                                        Text("Negative heads??",
                                            style: TextStyle(color: Colors.red))
                                      ])
                                    : Text(""),
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
                                        splashColor:
                                            Color.fromRGBO(220, 180, 57, 1.0),
                                        onPressed: () {
                                          Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      type: PageTransitionType
                                                          .bottomToTop,
                                                      child: SearchUsersPost(
                                                          invitees: invitees)))
                                              .then(onGoBack);
                                        },
                                      ),
                                      Text("Invite",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 100,
                                  width: invitees.length == 0
                                      ? 0
                                      : MediaQuery.of(context).size.width * .74,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: AlwaysScrollableScrollPhysics(),
                                      itemCount: invitees.length,
                                      itemBuilder: (_, index) {
                                        bool hide = false;
                                        if (!_isNumeric(invitees[index])) {
                                          hide = true;
                                        }
                                        return (hide == false)
                                            ? StreamBuilder(
                                                stream: usersRef
                                                    .doc(invitees[index])
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  // bool isLargePhone = Screen.diagonal(context) > 766;

                                                  if (!snapshot.hasData)
                                                    return CircularProgressIndicator();

                                                  String displayName = snapshot
                                                      .data['displayName'];
                                                  String proPic =
                                                      snapshot.data['photoUrl'];

                                                  // userMoovs = snapshot.data['likedMoovs'];

                                                  return Container(
                                                    height: 50,
                                                    child: Column(
                                                      children: <Widget>[
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            OtherProfile(
                                                                              invitees[index],
                                                                            )));
                                                          },
                                                          child: Stack(
                                                              children: [
                                                                CircleAvatar(
                                                                  radius: 34,
                                                                  backgroundColor:
                                                                      TextThemes
                                                                          .ndGold,
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                            proPic),
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
                                                                              proPic),
                                                                      radius:
                                                                          32,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                    right: -5,
                                                                    child: GestureDetector(
                                                                        onTap: () {
                                                                          invitees
                                                                              .remove(invitees[index]);
                                                                          onGoBack(
                                                                              id);
                                                                          print(
                                                                              "got it");
                                                                        },
                                                                        child: Icon(Icons.delete, color: Colors.red, size: 30)))
                                                              ]),
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
                                                                              displayName,
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w500)),
                                                                    ]),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                })
                                            : Container();
                                      }),
                                ),
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 23.0),
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        itemCount: invitees.length,
                                        itemBuilder: (_, index) {
                                          bool hide = false;
                                          if (_isNumeric(invitees[index])) {
                                            hide = true;
                                          }
                                          if (invitees.length == 0) {
                                            noHeight = true;
                                          }
                                          if (invitees.length != 0) {
                                            noHeight = false;
                                          }
                                          return (hide == false)
                                              ? StreamBuilder(
                                                  stream: groupsRef
                                                      .doc(invitees[index])
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData)
                                                      return CircularProgressIndicator();

                                                    String groupName = snapshot
                                                        .data['groupName'];
                                                    String groupPic = snapshot
                                                        .data['groupPic'];
                                                    String groupId = snapshot
                                                        .data['groupId'];
                                                    List members = snapshot
                                                        .data['members'];

                                                    return Container(
                                                      height: 50,
                                                      child: Column(
                                                        children: <Widget>[
                                                          GestureDetector(
                                                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                                                builder: (context) => members.contains(
                                                                        currentUser
                                                                            .id)
                                                                    ? GroupDetail(
                                                                        groupId)
                                                                    : OtherGroup(
                                                                        groupId))),
                                                            child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  SizedBox(
                                                                    width: isLargePhone
                                                                        ? MediaQuery.of(context).size.width *
                                                                            0.3
                                                                        : MediaQuery.of(context).size.width *
                                                                            0.3,
                                                                    height: isLargePhone
                                                                        ? MediaQuery.of(context).size.height *
                                                                            0.09
                                                                        : MediaQuery.of(context).size.height *
                                                                            0.07,
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        child:
                                                                            CachedNetworkImage(
                                                                          memCacheHeight:
                                                                              100,
                                                                          memCacheWidth:
                                                                              100,
                                                                          imageUrl:
                                                                              groupPic,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                      margin: EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          top:
                                                                              0,
                                                                          right:
                                                                              10,
                                                                          bottom:
                                                                              0),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.all(
                                                                          Radius.circular(
                                                                              10),
                                                                        ),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.grey.withOpacity(0.5),
                                                                            spreadRadius:
                                                                                5,
                                                                            blurRadius:
                                                                                7,
                                                                            offset:
                                                                                Offset(0, 3), // changes position of shadow
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(20)),
                                                                      gradient:
                                                                          LinearGradient(
                                                                        begin: Alignment
                                                                            .topCenter,
                                                                        end: Alignment
                                                                            .bottomCenter,
                                                                        colors: <
                                                                            Color>[
                                                                          Colors
                                                                              .black
                                                                              .withAlpha(0),
                                                                          Colors
                                                                              .black,
                                                                          Colors
                                                                              .black12,
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                      child:
                                                                          ConstrainedBox(
                                                                        constraints:
                                                                            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .2),
                                                                        child:
                                                                            Text(
                                                                          groupName,
                                                                          maxLines:
                                                                              2,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                              fontFamily: 'Solway',
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.white,
                                                                              fontSize: isLargePhone ? 11.0 : 9),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                      right: -3,
                                                                      top: 0,
                                                                      child: GestureDetector(
                                                                          onTap: () {
                                                                            invitees.remove(invitees[index]);
                                                                            onGoBack(id);
                                                                          },
                                                                          child: Icon(Icons.delete, color: Colors.red, size: 30)))
                                                                ]),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  })
                                              : Container();
                                        }),
                                  ),
                                  height: noHeight ? 0 : 100,
                                  width: noHeight
                                      ? 0
                                      : MediaQuery.of(context).size.width * .74,
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(80.0)),
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
                                              maxWidth: 125.0, minHeight: 50.0),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Save",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22),
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        invitees.removeWhere((item) =>
                                            oldInvitees.contains(item));

                                        setState(() {
                                          isUploading = true;
                                        });

                                        if (_formKey.currentState != null) {
                                          if (_image != null) {
                                            firebase_storage.Reference ref =
                                                firebase_storage
                                                    .FirebaseStorage.instance
                                                    .ref()
                                                    .child("images/" +
                                                        titleController.text);

                                            // Reference firebaseStorageRef =
                                            //     FirebaseStorage.instance
                                            //         .ref()
                                            //         .child("images/" +
                                            //             titleController.text);

                                            firebase_storage.UploadTask
                                                uploadTask;

                                            uploadTask = ref.putFile(_image);

                                            firebase_storage
                                                    .TaskSnapshot /*!*/ taskSnapshot =
                                                await uploadTask;
                                            if (uploadTask.snapshot.state ==
                                                firebase_storage
                                                    .TaskState.success) {
                                              print(
                                                  "added to Firebase Storage");
                                              final String downloadUrl =
                                                  await taskSnapshot.ref
                                                      .getDownloadURL();
                                              archiveRef.doc(postId).update({
                                                "image": downloadUrl,
                                              });
                                            }
                                          }

                                          if (titleController.text != "") {
                                            archiveRef.doc(postId).update({
                                              "title": titleController.text,
                                            });
                                          }

                                          if (descriptionController.text !=
                                              "") {
                                            archiveRef.doc(postId).update({
                                              "description":
                                                  descriptionController.text,
                                            });
                                          }
                                          if (maxOccupancyController.text !=
                                              "") {
                                            maxOccupancyInt = int.parse(
                                                maxOccupancyController.text);
                                            archiveRef.doc(postId).update({
                                              "maxOccupancy": maxOccupancyInt,
                                            });
                                          }
                                          if (paymentAmountController.text !=
                                              "") {
                                            String x = paymentAmountController
                                                .text
                                                .substring(1);
                                            paymentAmountInt = int.parse(x);
                                            archiveRef.doc(postId).update({
                                              "paymentAmount": paymentAmountInt,
                                            });
                                          }

                                          if (typeDropdownValue != null) {
                                            archiveRef.doc(postId).update({
                                              "type": typeDropdownValue,
                                            });
                                          }

                                          if (privacyDropdownValue != "") {
                                            print(privacyDropdownValue);
                                            archiveRef.doc(postId).update({
                                              "privacy": privacyDropdownValue,
                                            });
                                          }

                                          if (invitees != []) {
                                            for (var item in invitees)
                                              archiveRef.doc(postId).set({
                                                "statuses": {item: -1}
                                              }, SetOptions(merge: true)).then(
                                                  Database()
                                                      .inviteesNotification(
                                                          postId,
                                                          image,
                                                          title,
                                                          invitees));
                                          }

                                          if (currentValues != null) {
                                            print(currentValue);
                                            print(startDate);
                                            print(DateFormat('MMMd')
                                                .add_jm()
                                                .format(currentValue));

                                            print(DateFormat('MMMd')
                                                .add_jm()
                                                .format(startDate.toDate()));

                                            archiveRef.doc(postId).update({
                                              "startDate": currentValue,
                                            });
                                            Database().editPostNotification(
                                                postId, title, going);
                                          }
                                          setState(() {
                                            isUploading = false;
                                          });
                                        }
                                        Navigator.pop(
                                          context,
                                        );
                                      }),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, bottom: 20),
                                  child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(80.0)),
                                      padding: EdgeInsets.all(0.0),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.red[200],
                                                Colors.red
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth: 125.0, minHeight: 50.0),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Delete",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22),
                                          ),
                                        ),
                                      ),
                                      onPressed: () => {
                                            showAlertDialog2(
                                                context,
                                                postId,
                                                currentUser.id,
                                                title,
                                                snapshot.data['going'],
                                                snapshot.data['statuses'],
                                                snapshot.data['posterName']),
                                          }),
                                ),
                                currentUser.id == "108155010592087635288" ||
                                        currentUser.id ==
                                            "118426518878481598299" ||
                                        currentUser.id ==
                                            "107290090512658207959"
                                    ? //ADMIN CONTROLS
                                    GestureDetector(
                                        onTap: () {
                                          FirebaseFirestore.instance
                                              .collection('notreDame')
                                              .doc('data')
                                              .collection('food')
                                              .doc(postId)
                                              .set({
                                            "MOTD": true,
                                          }, SetOptions(merge: true));
                                        },
                                        child: Container(
                                          height: 30,
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue[400],
                                                  Colors.purple[300]
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          child: Text(
                                            "MAKE MOTD",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                      )
                                    : Text(""),
                                currentUser.id == "108155010592087635288" ||
                                        currentUser.id ==
                                            "118426518878481598299" ||
                                        currentUser.id ==
                                            "107290090512658207959"
                                    ? //ADMIN CONTROLS
                                    GestureDetector(
                                        onTap: () {
                                          FirebaseFirestore.instance
                                              .collection('notreDame')
                                              .doc('data')
                                              .collection('food')
                                              .doc(postId)
                                              .set({
                                            "featured": true,
                                          }, SetOptions(merge: true));
                                        },
                                        child: Container(
                                          height: 30,
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.orange[400],
                                                  Colors.purple[300]
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          child: Text(
                                            "FEATURE",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        ),
                                      )
                                    : Text(""),
                              ],
                            ),
                          )
                        ])),
                      ),
              ));
        });
  }

  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

  String numberValidator(String value) {
    if (value == null) {
      return null;
    }
    final n = num.tryParse(value);
    if (n < 0) {
      return '"$value" is not a valid number';
    } else
      return null;
  }
}

class _BannerImage extends StatelessWidget {
  String bannerImage;
  _BannerImage(this.bannerImage);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      ClipRRect(
        child: Container(
          margin:
              const EdgeInsets.only(bottom: 6.0), //Same as `blurRadius` i guess
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
          child: CachedNetworkImage(
            memCacheHeight: 100,
            memCacheWidth: 100,
            imageUrl: bannerImage,
            fit: BoxFit.fitWidth,
            height: 200,
            width: double.infinity,
          ),
        ),
      ),
    ]);
  }
}

void showAlertDialog2(
    BuildContext context, postId, userId, title, going, statuses, posterName) {
  delete() {
    Database().canceledNotification(postId, title, going);
    Future.delayed(const Duration(milliseconds: 1000), () {
      Database().deletePost(postId, userId, title, statuses, posterName);
    });
  }

  showDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text("Delete?",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      content: Text("\nRemove this post from the feed?"),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text("Yeah", style: TextStyle(color: Colors.red)),
          onPressed: () async {
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Home()),
              (Route<dynamic> route) => false,
            ).then(delete());
          },
        ),
        CupertinoDialogAction(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(true),
        )
      ],
    ),
  );
}
