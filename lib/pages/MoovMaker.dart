import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:MOOV/accountCreation/createAccountLanding.dart';
import 'package:MOOV/businessInterfaces/CrowdManagement.dart';
import 'package:MOOV/businessInterfaces/featureDeal.dart';
import 'package:MOOV/friendGroups/OtherGroup.dart';
import 'package:MOOV/friendGroups/group_detail.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/businessInterfaces/BusinessTab.dart';
import 'package:MOOV/pages/CalendarPage.dart';
import 'package:MOOV/widgets/google_map.dart';
import 'package:MOOV/widgets/sundayWrapup.dart';
import 'package:confetti/confetti.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/widgets/add_users_post.dart';
import 'package:MOOV/widgets/camera.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:page_transition/page_transition.dart';
import 'home.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:image_cropper/image_cropper.dart';

class MoovMaker extends StatefulWidget {
  final bool fromPostDeal, fromMoovOver, fromMaxOc;
  MoovMaker(
      {this.fromPostDeal = false,
      this.fromMoovOver = false,
      this.fromMaxOc = false});

  @override
  _MoovMakerState createState() => _MoovMakerState();
}

class _MoovMakerState extends State<MoovMaker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(alignment: Alignment.center, children: <Widget>[
                Padding(
                  padding: currentUser.isBusiness
                      ? const EdgeInsets.only(bottom: 0)
                      : const EdgeInsets.only(bottom: 15.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.17,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      child: ClipRRect(
                        child: Image.asset(
                          'lib/assets/motd.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      margin: EdgeInsets.only(
                          left: 0, top: 0, right: 0, bottom: 7.5),
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
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Container(
                        child: Text("MOOV Maker",
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 25.0)))),
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      icon: Icon(Icons.arrow_drop_up_outlined,
                          color: Colors.white, size: 35),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
              ]),
              MoovMakerForm(
                  fromPostDeal: widget.fromPostDeal,
                  fromMoovOver: widget.fromMoovOver,
                  fromMaxOc: widget.fromMaxOc)
            ]),
      ),
    );
  }
}

class MoovMakerForm extends StatefulWidget {
  final bool fromPostDeal, fromMoovOver, fromMaxOc;

  MoovMakerForm(
      {this.fromPostDeal = false,
      this.fromMoovOver = false,
      this.fromMaxOc = false});

  @override
  _MoovMakerFormState createState() => _MoovMakerFormState();
}

class _MoovMakerFormState extends State<MoovMakerForm>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    _controllerCenterLeft =
        ConfettiController(duration: const Duration(seconds: 2));
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = Tween(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.repeat(reverse: true);

    super.initState();
  }

  bool isUploading = false;
  bool _isSuccessful = false;

  File _image;
  var placeholderImage;
  final picker = ImagePicker();

  void openCamera(context) async {
    final image = await CustomCamera.openCamera();
    setState(() {
      _image = image;
      //  fileName = p.basename(_image.path);
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

  void openGallery(context) async {
    final image = await CustomCamera.openGallery();
    setState(() {
      _image = image;
    });
    _cropImage();
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('lib/assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  void openPlaceholders(context) async {
    Random random = new Random();
    int randomNumber = random.nextInt(4);
    if (typeDropdownValue == 'Hangouts') {
      placeholderImage = 'placeholderparty' + randomNumber.toString() + '.jpg';
    } else if (typeDropdownValue == 'Bars') {
      placeholderImage = 'placeholderbar' + randomNumber.toString() + '.jpg';
    } else if (typeDropdownValue == 'Food/Drink') {
      placeholderImage = 'placeholderfood' + randomNumber.toString() + '.jpg';
    } else {
      placeholderImage = 'random.jpg';
    }

    final image = await getImageFileFromAssets('$placeholderImage');

    setState(() {
      _image = image;
    });
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "Whaddaya got? 📸",
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
                "Use a Placeholder",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                openPlaceholders(context);
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

  final _formKey = GlobalKey<FormState>();
  final privacyList = ["Public", "Friends Only", "Invite Only"];
  final listOfTypes = [
    "Food/Drink",
    "Hangouts",
    "Clubs",
    "Sports",
    "Shows",
    "Recreation",
    "Games",
    "Music",
    "Study",
    "Student Gov",
    "Mass",
    "Service"
  ];

  final List<String> clubList =
      List<String>.from(currentUser.userType['clubExecutive'] ?? []);
  Map<String, String> clubNameMap = {};
  Map<String, String> clubIdMap = {};
  List previousPosts = [];
  bool ran = false;

  clubNamer() {
    //gets club names for execs posting meetings
    List<String> n = [];
    List<String> m = [];

    for (int i = 0; i < clubList.length; i++) {
      clubsRef
          .doc(currentUser.userType['clubExecutive'][i])
          .get()
          .then((value) {
        n.add(value['clubName']);
        m.add(value['clubId']);

        setState(() {});

        n.forEach((clubName) => clubNameMap[clubName] = value['clubId']);
        clubNameMap['No'] = null;
      });
    }
  }

  List recurringSearcher() {
    //sees if a business has posted before
    if (currentUser.isBusiness && ran == false) {
      archiveRef
          .where("userId", isEqualTo: currentUser.id)
          .orderBy("startDate")
          .get()
          .then((value) {
        List postTitles = [];
        for (int i = 0; i < value.docs.length; i++) {
          if (value.docs.isNotEmpty && !previousPosts.contains(value.docs)) {
            previousPosts.add(value.docs);
            postTitles.add(value.docs[i]['title']);
          }

          // print(previousPosts[i][i])
          // print(previousPosts[i][i]['title']);
          // print(value.docs[i]['title']);
          setState(() {
            ran = true;
          });
        }
        setState(() {});
      });
      return previousPosts;
    } else {
      return previousPosts;
    }
  }

  ConfettiController _controllerCenterLeft;

  DateTime currentValue = DateTime.now();
  DateTime currentValues;
  // DateTime endTime = DateTime.now().add(Duration(minutes: 120));
  // DateTime endTimes;
  String privacyDropdownValue = 'Public';
  String typeDropdownValue = 'Hangouts';
  String clubPostValue = 'No';

  // String locationDropdownValue = 'Off Campus';
  final titleController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final startDateController = DatePicker().startDate1;
  final maxOccupancyController = TextEditingController();
  final paymentAmountController = TextEditingController();
  final dealCostController = TextEditingController();
  final dealLimitController = TextEditingController();

  final format = DateFormat("EEE, MMM d,' at' h:mm a");
  Map<String, int> invitees = {};
  List<String> inviteesNameList = [];
  String userName;
  String userPic;
  int id = 0;
  bool noImage = false;
  bool barcode = false;
  String maxOccupancy;
  int maxOccupancyInt;
  String paymentAmount;
  int paymentAmountInt;
  bool noHeight = true;
  List<String> groupList = [];
  List groupMembers = [];
  bool push = true;
  int detailLength = 0;
  bool _moovOver = false;
  bool _dailyRecurring = false;
  bool _weeklyRecurring = false;
  bool _biweeklyRecurring = false;
  bool _monthlyRecurring = false;
  String dealCost;
  int dealCostInt;
  String dealLimit;
  int dealLimitInt;

  bool _item1 = true;
  bool _item2 = true;
  bool _item3 = true;

  void refreshData() {
    id++;
  }

  FutureOr onGoBack(dynamic value) {
    refreshData();
    setState(() {});
  }

  List coords = [];
  bool postANewMOOVPressed = false;
  bool _isDeal = false;
  List<String> tags = [];

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 300), () {
      //this gets the club names for posting club execs posting meetings
      clubNamer();
    });
    if (recurringSearcher().isNotEmpty && !postANewMOOVPressed) {
      List previousPosts = recurringSearcher();
      return Column(
        children: [
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: Ink(
                  decoration: BoxDecoration(
                      color: TextThemes.ndGold,
                      borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    width: 200,
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      'Post a new MOOV',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    postANewMOOVPressed = true;
                  });
                }),
          ),
          SizedBox(height: 30),
          Container(height: 500, child: Biz(previousPosts)),
        ],
      );
    }

    bool isLargePhone = Screen.diagonal(context) > 766;
    List pushList = currentUser.pushSettings.values.toList();
    if (pushList[0] == false) {
      push = false;
    }
    return Form(
      key: _formKey,
      child: isUploading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 300),
                Text("Asking the MOOV Gods..",
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                const SpinKitWave(
                    color: Colors.blue, type: SpinKitWaveType.center),
              ],
            )
          : _isSuccessful
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 300),
                        Text("They said yes!",
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 10),
                        // SpinKitWave(
                        //     duration: Duration(milliseconds: 1),
                        //     color: TextThemes.ndGold,
                        //     type: SpinKitWaveType.center),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ConfettiWidget(
                        confettiController: _controllerCenterLeft,
                        blastDirection: pi, // radial value - LEFT
                        particleDrag: 0.05, // apply drag to the confetti
                        emissionFrequency: 0.05, // how often it should emit
                        numberOfParticles: 20, // number of particles to emit
                        gravity: 0.05, // gravity - or fall speed
                        shouldLoop: false,
                        colors: [
                          TextThemes.ndBlue,
                          TextThemes.ndGold
                          // Colors.pink
                        ], // manually specify the colors to be used
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(children: <Widget>[
                    //posting on behalf of student club
                    currentUser.userType['clubExecutive'] != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 18.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * .45,
                              child: ButtonTheme(
                                child: DropdownButtonFormField(
                                  style: isLargePhone
                                      ? null
                                      : TextStyle(
                                          fontSize: 12.5, color: Colors.black),
                                  value: clubPostValue,
                                  icon: Icon(Icons.corporate_fare,
                                      color: TextThemes.ndGold),
                                  decoration: InputDecoration(
                                    labelText: "Posting your club meeting?",
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  items: clubNameMap.keys
                                      .toList()
                                      .map((dynamic value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      clubPostValue = newValue;
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
                          )
                        : Container(),

                    //option for biz to make MOOVs recurring
                    currentUser.isBusiness
                        ? Padding(
                            padding: const EdgeInsets.only(
                                top: 0.0, left: 55, right: 67.5, bottom: 15),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: TextThemes.ndBlue,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: ExpansionTile(
                                    trailing: Container(width: 1),
                                    initiallyExpanded:
                                        widget.fromMaxOc || widget.fromMoovOver
                                            ? true
                                            : false,
                                    title: Text(
                                      "Make this MOOV recurring?",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          SizedBox(width: 10),
                                          GradientIcon(
                                              Icons.calendar_today,
                                              25.0,
                                              LinearGradient(
                                                colors: <Color>[
                                                  Colors.blue,
                                                  Colors.blue[500],
                                                  Colors.blue,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )),
                                          Expanded(
                                            child: CheckboxListTile(
                                                title: Text("Daily"),
                                                value: _dailyRecurring,
                                                onChanged: (bool value) =>
                                                    setState(() =>
                                                        _dailyRecurring =
                                                            value)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width: 10),
                                          GradientIcon(
                                              Icons.calendar_today,
                                              25.0,
                                              LinearGradient(
                                                colors: <Color>[
                                                  Colors.purple[700],
                                                  Colors.purple[200],
                                                  Colors.blue,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )),
                                          Expanded(
                                            child: CheckboxListTile(
                                                title: Text("Weekly"),
                                                value: _weeklyRecurring,
                                                onChanged: (bool value) =>
                                                    setState(() =>
                                                        _weeklyRecurring =
                                                            value)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width: 10),
                                          GradientIcon(
                                              Icons.calendar_today,
                                              25.0,
                                              LinearGradient(
                                                colors: <Color>[
                                                  Colors.purple,
                                                  Colors.purple[500],
                                                  Colors.blue[900],
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )),
                                          Expanded(
                                            child: CheckboxListTile(
                                                title: Text("Bi-Weekly"),
                                                value: _biweeklyRecurring,
                                                onChanged: (bool value) =>
                                                    setState(() =>
                                                        _biweeklyRecurring =
                                                            value)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width: 10),
                                          GradientIcon(
                                              Icons.calendar_today,
                                              25.0,
                                              LinearGradient(
                                                colors: <Color>[
                                                  Colors.purple[800],
                                                  Colors.purple[500],
                                                  Colors.purple,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )),
                                          Expanded(
                                            child: CheckboxListTile(
                                                title: Text("Monthly"),
                                                value: _monthlyRecurring,
                                                onChanged: (bool value) =>
                                                    setState(() =>
                                                        _monthlyRecurring =
                                                            value)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),

                    Padding(
                      padding: EdgeInsets.only(
                          bottom: currentUser.isBusiness ? 5 : 15.0,
                          left: 15,
                          right: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(
                                icon: Icon(
                                  Icons.create,
                                  color: TextThemes.ndGold,
                                ),
                                labelText: "MOOV Title",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Title?';
                                }
                                return null;
                              },
                            ),
                          ),
                          currentUser.isBusiness
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 30,
                                        child: Checkbox(
                                            value: _isDeal,
                                            onChanged: (bool value) => setState(
                                                () => _isDeal = value)),
                                      ),
                                      Text(
                                        "Is this\na deal?",
                                        style:
                                            TextStyle(height: 1, fontSize: 11),
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    _isDeal
                        ? Padding(
                            padding: const EdgeInsets.only(left: 27.0),
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                child: DelayedDisplay(
                                    delay: Duration(milliseconds: 200),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                      'Cost to be paid\nin advance?'),
                                                  SizedBox(
                                                    width: 50,
                                                    child: TextField(
                                                      textAlign:
                                                          TextAlign.center,
                                                      inputFormatters: [
                                                        CurrencyTextInputFormatter(
                                                          decimalDigits: 0,
                                                          symbol: '\$',
                                                        )
                                                      ],
                                                      controller:
                                                          dealCostController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) =>
                                                          setState(() =>
                                                              dealCost = value),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Row(children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 12.0,
                                                          right: 12),
                                                  child: Text('Person\nlimit?'),
                                                ),
                                                SizedBox(
                                                    width: 50,
                                                    child: TextField(
                                                      textAlign:
                                                          TextAlign.center,
                                                      controller:
                                                          dealLimitController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) =>
                                                          setState(() =>
                                                              dealLimit =
                                                                  value),

                                                      // your TextField's Content
                                                    ))
                                              ]),
                                            ),
                                          ]),
                                    ))),
                          )
                        : Container(),
                    currentUser.isBusiness
                        ? Container()
                        : Padding(
                            padding:
                                EdgeInsets.only(top: 5, bottom: 15.0, left: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10.0, left: 8),
                                  child: Icon(Icons.question_answer,
                                      color: TextThemes.ndGold),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .45,
                                  child: ButtonTheme(
                                    child: DropdownButtonFormField(
                                      style: isLargePhone
                                          ? null
                                          : TextStyle(
                                              fontSize: 12.5,
                                              color: Colors.black),
                                      value: typeDropdownValue,
                                      icon: Icon(Icons.museum,
                                          color: TextThemes.ndGold),
                                      decoration: InputDecoration(
                                        labelText: "Select Event Type",
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      items: listOfTypes.map((String value) {
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
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .35,
                                    child: ButtonTheme(
                                      child: DropdownButtonFormField(
                                        style: isLargePhone
                                            ? null
                                            : TextStyle(
                                                fontSize: 12.5,
                                                color: Colors.black),
                                        value: privacyDropdownValue,
                                        icon: Icon(Icons.privacy_tip_outlined,
                                            color: TextThemes.ndGold),
                                        decoration: InputDecoration(
                                          labelText: "Visibility",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        items: privacyList.map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            privacyDropdownValue = newValue;
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
                                ),
                              ],
                            ),
                          ),
                    !currentUser.isBusiness
                        ? Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 15.0, right: 0, top: 5, bottom: 5),
                                  child: TextFormField(
                                    controller: addressController,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.place,
                                          color: TextThemes.ndGold),
                                      labelText: "Location or Address",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    // The validator receives the text that the user has entered.
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return "Where's it at?";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: coords.isEmpty
                                    ? () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => GoogleMap(
                                                  fromMOOVMaker: true,
                                                  coords: coords,
                                                )))
                                        .then(onGoBack)
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Column(
                                    children: [
                                      coords.isEmpty
                                          ? Image.asset(
                                              'lib/assets/mapIcon.png',
                                              height: 30)
                                          : Icon(Icons.check,
                                              color: Colors.green),
                                      SizedBox(height: 5),
                                      coords.isEmpty
                                          ? Text("Map?")
                                          : Text("Got it!")
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        : Container(),

                    widget.fromPostDeal
                        ? AnimatedBuilder(
                            animation: _animation,
                            builder: (context, _) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.all(15),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                      boxShadow: [
                                        for (int i = 1; i <= 2; i++)
                                          BoxShadow(
                                            color: TextThemes.ndGold
                                                .withOpacity(
                                                    _animationController.value /
                                                        2),
                                            spreadRadius: _animation.value * i,
                                          )
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: TextFormField(
                                        controller: descriptionController,
                                        decoration: InputDecoration(
                                          icon: Icon(
                                            Icons.description,
                                            color: TextThemes.ndGold,
                                          ),
                                          labelText: "Details about the MOOV",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        // The validator receives the text that the user has entered.
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return "What's going down?";
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          print(value);
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    right: 25,
                                    child: GestureDetector(
                                      onTap: () => showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return FeatureDealDialog(
                                              description:
                                                  """MOOV exists to spotlight local businesses to college students."""
                                                  """\n\nThe better your deal, the more likely they'll come.""",
                                            );
                                          }),
                                      child: Text(
                                        "Sweeten the deal..",
                                        style: TextStyle(
                                            color: TextThemes.ndBlue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            })
                        : Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(15.0),
                                child: TextFormField(
                                  controller: descriptionController,
                                  decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.description,
                                      color: TextThemes.ndGold,
                                    ),
                                    labelText: "Details about the MOOV",
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  // The validator receives the text that the user has entered.
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return "What's going down?";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => _onChanged(value),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                right: 25,
                                child: GestureDetector(
                                  onTap: () => showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return FeatureDealDialog(
                                          description:
                                              """MOOV can fill your event with students, especially if it's featured."""
                                              """\n\nYou might want to set your max occupancy, so you don't get swamped!""",
                                        );
                                      }),
                                  child: detailLength < 16
                                      ? Text(
                                          "Feature..",
                                          style: TextStyle(
                                              color: TextThemes.ndBlue,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : Container(),
                                ),
                              )
                            ],
                          ),

                    // Padding(
                    //   padding: EdgeInsets.all(20.0),
                    //   child: DropdownButtonFormField(
                    //     value: locationDropdownValue,
                    //     icon: Icon(Icons.arrow_downward, color: TextThemes.ndGold),
                    //     decoration: InputDecoration(
                    //       labelText: "Select Location",
                    //       enabledBorder: OutlineInputBorder(
                    //         borderRadius: BorderRadius.circular(10.0),
                    //       ),
                    //     ),
                    //     items: listOfLocations.map((String value) {
                    //       return new DropdownMenuItem<String>(
                    //         value: value,
                    //         child: new Text(value),
                    //       );
                    //     }).toList(),
                    //     onChanged: (String newValue) {
                    //       setState(() {
                    //         locationDropdownValue = newValue;
                    //       });
                    //     },
                    //     validator: (value) {
                    //       if (value.isEmpty) {
                    //         return 'Select Event Type';
                    //       }
                    //       return null;
                    //     },
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.only(
                          top: 5, left: 55, bottom: 10, right: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: DateTimeField(
                                format: format,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                    labelText: 'Enter Start Time',
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always),
                                onChanged: (DateTime newValue) {
                                  setState(() {
                                    currentValue = currentValues; // = newValue;
                                    //   newValue = currentValue;
                                  });
                                },
                                onShowPicker: (context, currentValue) async {
                                  final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    initialDate: DateTime.now(),
                                    lastDate: DateTime(2023),
                                    builder:
                                        (BuildContext context, Widget child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          primaryColor: TextThemes.ndGold,
                                          accentColor: TextThemes.ndGold,
                                          colorScheme: ColorScheme.light(
                                              primary: TextThemes.ndBlue),
                                          buttonTheme: ButtonThemeData(
                                              textTheme:
                                                  ButtonTextTheme.primary),
                                        ),
                                        child: child,
                                      );
                                    },
                                  );
                                  if (date != null) {
                                    final time = await showTimePicker(
                                      initialEntryMode:
                                          TimePickerEntryMode.input,
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          currentValue ?? DateTime.now()),
                                      builder:
                                          (BuildContext context, Widget child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            primaryColor: TextThemes.ndGold,
                                            accentColor: TextThemes.ndGold,
                                            colorScheme: ColorScheme.light(
                                                primary: TextThemes.ndBlue),
                                            buttonTheme: ButtonThemeData(
                                                textTheme:
                                                    ButtonTextTheme.primary),
                                          ),
                                          child: child,
                                        );
                                      },
                                    );
                                    currentValues =
                                        DateTimeField.combine(date, time);
                                    return currentValues;
                                  } else {
                                    return currentValue;
                                  }
                                },
                              ),
                            ),
                          ),
                          // GestureDetector(
                          //   onTap: coords.isEmpty
                          //       ? () => Navigator.of(context)
                          //           .push(MaterialPageRoute(
                          //               builder: (context) => CalendarPage(
                          //                   currentValue ?? DateTime.now())))
                          //           .then(onGoBack)
                          //       : null,
                          //   child: Padding(
                          //     padding:
                          //         const EdgeInsets.symmetric(horizontal: 12.0),
                          //     child: Column(
                          //       children: [
                          //         Icon(Icons.calendar_today,
                          //             color: TextThemes.ndGold, size: 30),
                          //         SizedBox(height: 5),
                          //         Text("Overlap?")
                          //       ],
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                    currentUser.mobileOrderMenu != null &&
                            currentUser.mobileOrderMenu['item1'].isNotEmpty
                        ? Stack(
                            children: [
                              Container(
                                height: 104,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0, right: 0, top: 37),
                                  child: Row(
                                    children: [
                                      currentUser.mobileOrderMenu['item1']
                                              .isNotEmpty
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .333,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 30,
                                                    child: Checkbox(
                                                        value: _item1,
                                                        onChanged:
                                                            (bool value) =>
                                                                setState(() =>
                                                                    _item1 =
                                                                        value)),
                                                  ),
                                                  SizedBox(
                                                    height: 34,
                                                    child: Text(
                                                        currentUser
                                                                .mobileOrderMenu[
                                                            'item1']['name'],
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                        maxLines: 2),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      currentUser.mobileOrderMenu['item2']
                                              .isNotEmpty
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .333,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 29,
                                                    child: Checkbox(
                                                        value: _item2,
                                                        onChanged:
                                                            (bool value) =>
                                                                setState(() =>
                                                                    _item2 =
                                                                        value)),
                                                  ),
                                                  SizedBox(
                                                    height: 34,
                                                    child: Text(
                                                        currentUser
                                                                .mobileOrderMenu[
                                                            'item2']['name'],
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                        maxLines: 2),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      currentUser.mobileOrderMenu['item3']
                                              .isNotEmpty
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .333,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 30,
                                                    child: Checkbox(
                                                        value: _item3,
                                                        onChanged:
                                                            (bool value) =>
                                                                setState(() =>
                                                                    _item3 =
                                                                        value)),
                                                  ),
                                                  SizedBox(
                                                    height: 34,
                                                    child: Text(
                                                        currentUser
                                                                .mobileOrderMenu[
                                                            'item3']['name'],
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                        maxLines: 2),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Offer Mobile Ordering?",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0.0, left: 40, right: 12.5),
                      child: Column(
                        children: <Widget>[
                          ExpansionTile(
                            initiallyExpanded:
                                widget.fromMaxOc || widget.fromMoovOver
                                    ? true
                                    : false,
                            title: Text(
                              "Optional Details",
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            children: <Widget>[
                              widget.fromMoovOver
                                  ? AnimatedBuilder(
                                      animation: _animation,
                                      builder: (context, _) {
                                        return Container(
                                          margin: EdgeInsets.all(7.5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                            boxShadow: [
                                              for (int i = 1; i <= 2; i++)
                                                BoxShadow(
                                                  color: TextThemes.ndGold
                                                      .withOpacity(
                                                          _animationController
                                                                  .value /
                                                              2),
                                                  spreadRadius:
                                                      _animation.value * i / 2,
                                                )
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 10),
                                              GradientIcon(
                                                  Icons
                                                      .confirmation_num_outlined,
                                                  25.0,
                                                  LinearGradient(
                                                    colors: <Color>[
                                                      Colors.red,
                                                      Colors.yellow,
                                                      Colors.blue,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )),
                                              Expanded(
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    CheckboxListTile(
                                                        title: Text(
                                                            "MOOV Over Pass™"),
                                                        value: _moovOver,
                                                        onChanged:
                                                            (bool value) =>
                                                                setState(() =>
                                                                    _moovOver =
                                                                        value)),
                                                    Positioned(
                                                        top: 15,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 60.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () =>
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (_) =>
                                                                        CupertinoAlertDialog(
                                                                          title:
                                                                              Text("No more waiting"),
                                                                          content:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(top: 8.0),
                                                                            child:
                                                                                Text("A MOOV Over Pass will allow customers to skip the line in exchange for \$10."),
                                                                          ),
                                                                        ),
                                                                    barrierDismissible:
                                                                        true),
                                                            child: Icon(Icons
                                                                .info_outline),
                                                          ),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                  : Row(
                                      children: [
                                        SizedBox(width: 10),
                                        GradientIcon(
                                            Icons.confirmation_num_outlined,
                                            25.0,
                                            LinearGradient(
                                              colors: <Color>[
                                                Colors.red,
                                                Colors.yellow,
                                                Colors.blue,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )),
                                        Expanded(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CheckboxListTile(
                                                  title:
                                                      Text("MOOV Over Pass™"),
                                                  value: _moovOver,
                                                  onChanged: (bool value) =>
                                                      setState(() =>
                                                          _moovOver = value)),
                                              Positioned(
                                                  top: 15,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 60.0),
                                                    child: GestureDetector(
                                                      onTap: () => showDialog(
                                                          context: context,
                                                          builder: (_) =>
                                                              CupertinoAlertDialog(
                                                                title: Text(
                                                                    "No more waiting"),
                                                                content:
                                                                    Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 8.0),
                                                                  child: Text(
                                                                      "A MOOV Over Pass™ will allow customers to skip the line in exchange for \$10."),
                                                                ),
                                                              ),
                                                          barrierDismissible:
                                                              true),
                                                      child: Icon(
                                                          Icons.info_outline),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                              widget.fromMaxOc
                                  ? AnimatedBuilder(
                                      animation: _animation,
                                      builder: (context, _) {
                                        return Container(
                                          margin: EdgeInsets.all(7.5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                            boxShadow: [
                                              for (int i = 1; i <= 2; i++)
                                                BoxShadow(
                                                  color: TextThemes.ndGold
                                                      .withOpacity(
                                                          _animationController
                                                                  .value /
                                                              2),
                                                  spreadRadius:
                                                      _animation.value * i / 2,
                                                )
                                            ],
                                          ),
                                          child: ListTile(
                                            title: Row(
                                              children: <Widget>[
                                                Expanded(
                                                    flex: 4,
                                                    child:
                                                        Text('Limit Capacity')),
                                                Expanded(
                                                  flex: 1,
                                                  child: TextField(
                                                    textAlign: TextAlign.center,
                                                    controller:
                                                        maxOccupancyController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) =>
                                                        setState(() =>
                                                            maxOccupancy =
                                                                value),

                                                    // your TextField's Content
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                  : ListTile(
                                      title: Row(
                                        children: <Widget>[
                                          Expanded(
                                              flex: 4,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  RichText(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    text: TextSpan(
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                "Limit Capacity",
                                                            style: TextStyle(),
                                                          ),
                                                          TextSpan(
                                                              text:
                                                                  '\nYour MOOV will show "full"',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                fontSize: 10,
                                                              )),
                                                        ]),
                                                  ),
                                                ],
                                              )),
                                          Expanded(
                                            flex: 1,
                                            child: TextField(
                                              textAlign: TextAlign.center,
                                              controller:
                                                  maxOccupancyController,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) => setState(
                                                  () => maxOccupancy = value),

                                              // your TextField's Content
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ListTile(
                                title: Row(
                                  children: <Widget>[
                                    Expanded(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              overflow: TextOverflow.ellipsis,
                                              text: TextSpan(
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: "Cost per Person",
                                                      style: TextStyle(),
                                                    ),
                                                    TextSpan(
                                                        text:
                                                            '\nex: Cover Charge/Ticket Cost',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 10,
                                                        )),
                                                  ]),
                                            ),
                                          ],
                                        )),
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        inputFormatters: [
                                          CurrencyTextInputFormatter(
                                            decimalDigits: 0,
                                            symbol: '\$',
                                          )
                                        ],
                                        controller: paymentAmountController,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) => setState(
                                            () => paymentAmount = value),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // CheckboxListTile(
                              //     title: new Text("Needs a Barcode (Verification)"),
                              //     value: barcode,
                              //     onChanged: (bool value) =>
                              //         setState(() => barcode = value)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.bottomToTop,
                                        child:
                                            SearchUsersPost(inviteesNameList)))
                                .then(onGoBack);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 5),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                          splashColor:
                                              Color.fromRGBO(220, 180, 57, 1.0),
                                          onPressed: () {
                                            Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        type: PageTransitionType
                                                            .bottomToTop,
                                                        child: SearchUsersPost(
                                                            inviteesNameList)))
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
                                    width: inviteesNameList.length == 0
                                        ? 0
                                        : MediaQuery.of(context).size.width *
                                            .74,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        itemCount: inviteesNameList.length,
                                        itemBuilder: (_, index) {
                                          bool hide = false;
                                          if (!_isNumeric(
                                              inviteesNameList[index])) {
                                            hide = true;
                                          }
                                          return (hide == false)
                                              ? StreamBuilder(
                                                  stream: usersRef
                                                      .doc(inviteesNameList[
                                                          index])
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    // bool isLargePhone = Screen.diagonal(context) > 766;

                                                    if (!snapshot.hasData)
                                                      return CircularProgressIndicator();

                                                    userName = snapshot
                                                        .data['displayName'];
                                                    userPic = snapshot
                                                        .data['photoUrl'];

                                                    // userMoovs = snapshot.data['likedMoovs'];

                                                    return Container(
                                                      height: 50,
                                                      child: Column(
                                                        children: <Widget>[
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(context).push(
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          OtherProfile(
                                                                            inviteesNameList[index],
                                                                          )));
                                                            },
                                                            child: CircleAvatar(
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
                                                  })
                                              : Container();
                                        }),
                                  ),
                                ]),
                          ),
                        )),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 23.0),
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: inviteesNameList.length,
                            itemBuilder: (_, index) {
                              bool hide = false;
                              if (_isNumeric(inviteesNameList[index])) {
                                hide = true;
                              }
                              if (inviteesNameList.length == 0) {
                                noHeight = true;
                              }
                              if (inviteesNameList.length != 0) {
                                noHeight = false;
                              }
                              return (hide == false)
                                  ? StreamBuilder(
                                      stream: groupsRef
                                          .doc(inviteesNameList[index])
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        // bool isLargePhone = Screen.diagonal(context) > 766;

                                        if (!snapshot.hasData)
                                          return CircularProgressIndicator();

                                        userName = snapshot.data['groupName'];
                                        userPic = snapshot.data['groupPic'];
                                        String groupId =
                                            snapshot.data['groupId'];
                                        List members = snapshot.data['members'];

                                        // userMoovs = snapshot.data['likedMoovs'];

                                        return Container(
                                          height: 50,
                                          child: Column(
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () => Navigator.of(
                                                        context)
                                                    .push(MaterialPageRoute(
                                                        builder: (context) =>
                                                            members.contains(
                                                                    currentUser
                                                                        .id)
                                                                ? GroupDetail(
                                                                    groupId)
                                                                : OtherGroup(
                                                                    groupId))),
                                                child: Stack(
                                                    alignment: Alignment.center,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: isLargePhone
                                                            ? MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.3
                                                            : MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.3,
                                                        height: isLargePhone
                                                            ? MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.09
                                                            : MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.07,
                                                        child: Container(
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl: userPic,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  top: 0,
                                                                  right: 10,
                                                                  bottom: 0),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  10),
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                spreadRadius: 5,
                                                                blurRadius: 7,
                                                                offset: Offset(
                                                                    0,
                                                                    3), // changes position of shadow
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
                                                                  Radius
                                                                      .circular(
                                                                          20)),
                                                          gradient:
                                                              LinearGradient(
                                                            begin: Alignment
                                                                .topCenter,
                                                            end: Alignment
                                                                .bottomCenter,
                                                            colors: <Color>[
                                                              Colors.black
                                                                  .withAlpha(0),
                                                              Colors.black,
                                                              Colors.black12,
                                                            ],
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: ConstrainedBox(
                                                            constraints: BoxConstraints(
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .2),
                                                            child: Text(
                                                              userName,
                                                              maxLines: 2,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Solway',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      isLargePhone
                                                                          ? 11.0
                                                                          : 9),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Positioned(
                                                      //   bottom: isLargePhone ? 0 : 0,
                                                      //   right: 55,
                                                      //   child: Row(
                                                      //     mainAxisAlignment:
                                                      //         MainAxisAlignment
                                                      //             .center,
                                                      //     children: [
                                                      //       Stack(children: [
                                                      //         Padding(
                                                      //             padding:
                                                      //                 const EdgeInsets
                                                      //                     .all(4.0),
                                                      //             child: members
                                                      //                         .length >
                                                      //                     1
                                                      //                 ? CircleAvatar(
                                                      //                     radius:
                                                      //                         25.0,
                                                      //                     backgroundImage:
                                                      //                         NetworkImage(
                                                      //                       course[1][
                                                      //                           'photoUrl'],
                                                      //                     ),
                                                      //                   )
                                                      //                 : Container()),
                                                      //         Padding(
                                                      //             padding:
                                                      //                 const EdgeInsets
                                                      //                         .only(
                                                      //                     top: 4,
                                                      //                     left: 25.0),
                                                      //             child: CircleAvatar(
                                                      //               radius: 25.0,
                                                      //               backgroundImage:
                                                      //                   NetworkImage(
                                                      //                 course[0][
                                                      //                     'photoUrl'],
                                                      //               ),
                                                      //             )),
                                                      //         Padding(
                                                      //           padding:
                                                      //               const EdgeInsets
                                                      //                       .only(
                                                      //                   top: 4,
                                                      //                   left: 50.0),
                                                      //           child: CircleAvatar(
                                                      //             radius: 25.0,
                                                      //             child:
                                                      //                 members.length >
                                                      //                         2
                                                      //                     ? Text(
                                                      //                         "+" +
                                                      //                             (length.toString()),
                                                      //                         style: TextStyle(
                                                      //                             color:
                                                      //                                 TextThemes.ndGold,
                                                      //                             fontWeight: FontWeight.w500),
                                                      //                       )
                                                      //                     : Text(
                                                      //                         (members
                                                      //                             .length
                                                      //                             .toString()),
                                                      //                         style: TextStyle(
                                                      //                             color:
                                                      //                                 TextThemes.ndGold,
                                                      //                             fontWeight: FontWeight.w500),
                                                      //                       ),
                                                      //             backgroundColor:
                                                      //                 TextThemes
                                                      //                     .ndBlue,
                                                      //           ),
                                                      //         ),
                                                      //       ])
                                                      //     ],
                                                      //   ),
                                                      // ),
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

                    _image != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 18.0),
                            child:
                                Stack(alignment: Alignment.center, children: [
                              Container(
                                height: 125,
                                width: MediaQuery.of(context).size.width * .8,
                                child: Center(
                                    child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Image.file(_image,
                                              fit: BoxFit.cover),
                                        ))),
                              ),
                              GestureDetector(
                                  onTap: () => selectImage(context),
                                  child: Icon(Icons.camera_alt))
                            ]),
                          )
                        : ElevatedButton(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Upload Image/GIF',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            ),
                            onPressed: () => selectImage(context),
                            style: ElevatedButton.styleFrom(
                                primary: TextThemes.ndBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)))),

                    noImage == true && _image == null
                        ? Text(
                            "No pic, no fun.",
                            style: TextStyle(color: Colors.red),
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 30),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15))),
                          child: Ink(
                            decoration: BoxDecoration(
                                color: TextThemes.ndGold,
                                borderRadius: BorderRadius.circular(15)),
                            child: Container(
                              width: 115,
                              height: 40,
                              alignment: Alignment.center,
                              child: Text(
                                'Post!',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            GeoPoint location;

                            if (coords.isNotEmpty) {
                              List parse = coords.toString().split(",");
                              String parse0 = parse[0].replaceAll("[", "");

                              String parse2 = parse[1].replaceAll("]", "");
                              double latitude = double.parse(parse0);

                              double longitude = double.parse(parse2);

                              location = GeoPoint(latitude, longitude);
                            }

                            HapticFeedback.lightImpact();

                            // for (int i = 0;
                            //     i < inviteesNameList.length;
                            //     i++) {
                            //   if (!_isNumeric(inviteesNameList[i]) &&
                            //       inviteesNameList.length > 0) {
                            //     final DocumentSnapshot result =
                            //         await groupsRef
                            //             .doc(inviteesNameList[i])
                            //             .get();
                            //     result.data()['members'].forEach(
                            //         (element) => groupList.add(element));
                            //   }
                            // }
                            // print(groupList);

                            if (_image == null) {
                              setState(() {
                                noImage = true;
                              });
                            }
                            if (_formKey.currentState.validate() &&
                                _image != null) {
                              setState(() {
                                isUploading = true;
                              });
                            }

                            final GoogleSignInAccount user =
                                googleSignIn.currentUser;
                            final strUserId = user.id;
                            if (inviteesNameList.length == 0) {
                              print("EMTPY");
                            }
                            if (_formKey.currentState.validate()) {
                              if (_image != null) {
                                firebase_storage.Reference ref =
                                    firebase_storage.FirebaseStorage.instance
                                        .ref()
                                        .child("images/" +
                                            user.id +
                                            titleController.text);
                                if (maxOccupancyController.text.isEmpty) {
                                  maxOccupancyInt = 8000000;
                                }

                                if (maxOccupancyController.text.isNotEmpty) {
                                  maxOccupancyInt =
                                      int.parse(maxOccupancyController.text);
                                }
                                if (paymentAmountController.text.isNotEmpty) {
                                  String x =
                                      paymentAmountController.text.substring(1);
                                  paymentAmountInt = int.parse(x);
                                }
                                if (dealLimitController.text.isNotEmpty) {
                                  dealLimitInt =
                                      int.parse(dealLimitController.text);
                                }
                                if (dealCostController.text.isNotEmpty) {
                                  String x =
                                      dealCostController.text.substring(1);
                                  dealCostInt = int.parse(x);
                                }

                                String recurringType = "";

                                if (currentUser.isBusiness) {
                                  if (_monthlyRecurring != false) {
                                    recurringType = "monthly";
                                  }
                                  if (_biweeklyRecurring != false) {
                                    recurringType = "biweekly";
                                  }
                                  if (_weeklyRecurring != false) {
                                    recurringType = "weekly";
                                  }
                                  if (_dailyRecurring != false) {
                                    recurringType = "daily";
                                  }
                                }

                                //mobile ordering menu
                                if (currentUser.mobileOrderMenu != null) {
                                  if (currentUser
                                          .mobileOrderMenu['item1'].isEmpty ||
                                      !_item1) {
                                    _item1 = false;
                                  }
                                  if (currentUser
                                          .mobileOrderMenu['item2'].isEmpty ||
                                      !_item2) {
                                    _item2 = false;
                                  }
                                  if (currentUser
                                          .mobileOrderMenu['item3'].isEmpty ||
                                      !_item3) {
                                    _item3 = false;
                                  }
                                }

                                firebase_storage.UploadTask uploadTask;

                                uploadTask = ref.putFile(_image);

                                firebase_storage.TaskSnapshot taskSnapshot =
                                    await uploadTask;
                                if (uploadTask.snapshot.state ==
                                    firebase_storage.TaskState.success) {
                                  if (_isDeal) {
                                    tags = ['deal'];
                                  }
                                  print("added to Firebase Storage");
                                  final String postId =
                                      generateRandomString(20);
                                  final String downloadUrl =
                                      await taskSnapshot.ref.getDownloadURL();
                                  currentUser.isBusiness
                                      ? Database().createBusinessPost(
                                          title: titleController.text,
                                          type: currentUser.businessType ==
                                                  "Restaurant/Bar"
                                              ? "Food/Drink"
                                              : currentUser.businessType ==
                                                      "Theatre"
                                                  ? "Shows"
                                                  : "Recreation",
                                          privacy: "Public",
                                          description:
                                              descriptionController.text,
                                          address: currentUser.dorm,
                                          startDate: currentValue,
                                          unix: currentValue
                                              .millisecondsSinceEpoch,
                                          startDateSimpleString:
                                              DateFormat('yMd')
                                                  .format(currentValue),
                                          statuses: inviteesNameList,
                                          maxOccupancy: maxOccupancyInt,
                                          paymentAmount: paymentAmountInt,
                                          dealCost: dealCostInt,
                                          dealLimit: dealLimitInt,
                                          imageUrl: downloadUrl,
                                          userId: strUserId,
                                          postId: postId,
                                          recurringType: recurringType,
                                          posterName: currentUser.displayName,
                                          push: push,
                                          moovOver: _moovOver,
                                          mobileOrderMenu: {
                                            "item1": _item1,
                                            "item2": _item2,
                                            "item3": _item3
                                          },
                                          tags: tags)
                                      : Database().createPost(
                                          title: titleController.text,
                                          type: typeDropdownValue,
                                          privacy: privacyDropdownValue,
                                          description:
                                              descriptionController.text,
                                          address: addressController.text,
                                          startDate: currentValue,
                                          startDateSimpleString:
                                              DateFormat('yMd')
                                                  .format(currentValue),
                                          clubId: clubNameMap[clubPostValue],
                                          unix: currentValue
                                              .millisecondsSinceEpoch,
                                          statuses: inviteesNameList,
                                          maxOccupancy: maxOccupancyInt,
                                          paymentAmount: paymentAmountInt,
                                          imageUrl: downloadUrl,
                                          userId: strUserId,
                                          postId: postId,
                                          posterName: currentUser.displayName,
                                          push: push,
                                          location: location,
                                          moovOver: _moovOver);

                                  nextSunday().then((value) {
                                    wrapupRef
                                        .doc(currentUser.id)
                                        .collection('wrapUp')
                                        .doc(value)
                                        .set({
                                      "ownMOOVs": FieldValue.arrayUnion([
                                        {
                                          "pic": downloadUrl,
                                          "postId": postId,
                                          "title": titleController.text
                                        }
                                      ]),
                                    }, SetOptions(merge: true));
                                  });
                                  _controllerCenterLeft.play();
                                  HapticFeedback.lightImpact();

                                  setState(() {
                                    isUploading = false;
                                    _isSuccessful = true;
                                  });
                                }
                                Future.delayed(Duration(seconds: 2), () {
                                  Navigator.pop(context);
                                });
                              }
                            }
                          }),
                    ),
                  ]),
                ),
    );
  }

  _onChanged(String value) {
    setState(() {
      detailLength = value.length;
    });
    print(detailLength);
  }

  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controllerCenterLeft.dispose();
    super.dispose();
    addressController.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }
}

class DatePicker extends StatefulWidget {
  DatePicker({this.startDate1});
  DateTime startDate1 = DateTime.now();
  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime startDate1 = DateTime.now();
  // DateTime _endDate = DateTime.now().add(Duration(days: 7));

  Future displayDateRangePicker(BuildContext context) async {
    final List<DateTime> picked = await DateRangePicker.showDatePicker(
        context: context,
        initialFirstDate: startDate1,
        initialLastDate: null,
        // initialLastDate: _endDate,
        firstDate: new DateTime(DateTime.now().year),
        lastDate: new DateTime(DateTime.now().year + 10));
    if (picked != null && picked.length == 2) {
      setState(() {
        startDate1 = picked[0];
        // _endDate = picked[1];
      });
    } else if (picked.length == 1) {
      setState(() {
        startDate1 = picked[0];
        // _endDate = picked[0];
      });
    }
  }

  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Text("Location ${widget.postModel.title}"),
        RaisedButton(
          color: Colors.amber[300],
          child: Text("Select Dates"),
          onPressed: () async {
            await displayDateRangePicker(context);
          },
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                    "Start Date: ${DateFormat('EEE, MM/dd').format(startDate1).toString()}"),
                // Text(
                //     "End Date: ${DateFormat('EEE, MM/dd').format(_endDate).toString()}"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String generateRandomString(int len) {
  var r = Random();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}
