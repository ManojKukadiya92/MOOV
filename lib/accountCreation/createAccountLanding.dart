import 'dart:io';
import 'dart:math';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/create_account.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/camera.dart';
import 'package:animations/animations.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CreateAccountNew extends StatelessWidget {
  final bool isBusiness = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: TextThemes.ndBlue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DelayedDisplay(
                delay: Duration(milliseconds: 200),
                child: Text(
                  "Welcome to",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 35.0,
                    color: Colors.white,
                  ),
                ),
              ),
              DelayedDisplay(
                delay: Duration(milliseconds: 1000),
                child: Text("MOOV",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 35.0,
                        color: TextThemes.ndGold)),
              ),
              SizedBox(height: 10),
              DelayedDisplay(
                delay: Duration(milliseconds: 2000),
                child: Text("—Created by ND '22 and ND '23—",
                    style: GoogleFonts.montserrat(
                        fontStyle: FontStyle.italic,
                        // fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                        color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 130.0),
                child: DelayedDisplay(
                  delay: Duration(seconds: 4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Are you a",
                              style: GoogleFonts.montserrat(
                                  // fontStyle: FontStyle.italic,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.white)),
                          Text(" student ",
                              style: GoogleFonts.montserrat(
                                  // fontStyle: FontStyle.italic,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: TextThemes.ndGold)),
                          Text("or a business?",
                              style: GoogleFonts.montserrat(
                                  // fontStyle: FontStyle.italic,
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.white)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Bounce(
                              duration: Duration(milliseconds: 500),
                              onPressed: () {
                                accountButtonPressed(
                                    context: context,
                                    page: _StudentAccountCreation());
                              },
                              child: Container(
                                height: 50.0,
                                width: 150.0,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white),
                                  color: TextThemes.ndGold,
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                child: Center(
                                  child: Text(
                                    "Student",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Bounce(
                              duration: Duration(milliseconds: 500),
                              onPressed: () {
                                accountButtonPressed(
                                    context: context,
                                    page: _BusinessAccountNameCreation());
                              },
                              child: Container(
                                height: 50.0,
                                width: 150.0,
                                decoration: BoxDecoration(
                                  color: TextThemes.ndBlue,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                child: Center(
                                  child: Text(
                                    "Business",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

accountButtonPressed(
    {@required BuildContext context,
    @required Widget page,
    String bizName,
    String bizType,
    String bizLat,
    String bizLong,
    String bizAddress,
    String bizPic,
    String bizDescription}) {
  HapticFeedback.lightImpact();

  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (c, a1, a2) => page,
      transitionsBuilder: (c, anim, a2, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: Duration(milliseconds: 1000),
    ),
  );
}

class _BusinessAccountNameCreation extends StatefulWidget {
  @override
  __BusinessAccountNameCreationState createState() =>
      __BusinessAccountNameCreationState();
}

class __BusinessAccountNameCreationState
    extends State<_BusinessAccountNameCreation> {
  final _formKey = GlobalKey<FormState>();
  final businessNameController = TextEditingController();
  bool _businessNameValid = false;
  String _chosenValue;
  bool _typeChosen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TextThemes.ndBlue,
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DelayedDisplay(
                delay: Duration(milliseconds: 200),
                child: Text(
                  "What's the name?",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
              DelayedDisplay(
                delay: Duration(milliseconds: 700),
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: 40.0, left: 15, right: 15, top: 15),
                  child: TextFormField(
                    style: TextStyle(color: Colors.white),

                    controller: businessNameController,
                    decoration: InputDecoration(
                      hintText: "Business name..",
                      hintStyle: GoogleFonts.montserrat(
                          color: Colors.white.withOpacity(.5)),
                      // suffixIcon: IconButton(
                      //   icon: _incorrect
                      //       ? Icon(Icons.lock, color: Colors.red)
                      //       : Icon(Icons.lock_open, color: Colors.white),
                      //   onPressed: () {
                      //     // _tryUnlock();
                      //     // titleController.clear();
                      //   },
                      // ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          borderSide: BorderSide(
                            color: Colors.teal,
                          )),
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onFieldSubmitted: (value) {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          _businessNameValid = true;
                        });
                      }
                      // _tryUnlock();
                    },

                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Business name?';
                      }
                      if (value.length < 4) {
                        return 'Name is too short';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              _businessNameValid
                  ? DelayedDisplay(
                      delay: Duration(milliseconds: 300),
                      child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 15.0, left: 15, right: 15, top: 0),
                          child: Center(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: TextThemes.ndBlue,
                              ),
                              child: DropdownButton<String>(
                                iconSize: 0,
                                value: _chosenValue,
                                elevation: 5,
                                items: <String>[
                                  'Restaurant/Bar',
                                  'Theatre',
                                  'Night Club',
                                  'Sports Team',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style:
                                              TextStyle(color: Colors.white)));
                                }).toList(),
                                hint: Text(
                                  "What type of business?",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300),
                                ),
                                onChanged: (String value) {
                                  setState(() {
                                    _typeChosen = true;
                                    _chosenValue = value;
                                  });
                                },
                              ),
                            ),
                          )),
                    )
                  : Container(),
              _typeChosen
                  ? Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 200),
                      child: DelayedDisplay(
                        delay: Duration(milliseconds: 200),
                        child: Bounce(
                          duration: Duration(milliseconds: 500),
                          onPressed: () {
                            accountButtonPressed(
                                context: context,
                                page: BusinessAccountLocationCreation(
                                    this.businessNameController.text,
                                    this._chosenValue));
                          },
                          child: Container(
                            height: 50.0,
                            width: 100.0,
                            decoration: BoxDecoration(
                              color: TextThemes.ndBlue,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Center(
                                child: Icon(Icons.arrow_forward,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class BusinessAccountLocationCreation extends StatefulWidget {
  final String businessName, businessType;

  BusinessAccountLocationCreation(this.businessName, this.businessType);

  @override
  _BusinessAccountLocationCreationState createState() =>
      _BusinessAccountLocationCreationState();
  static _BusinessAccountLocationCreationState of(BuildContext context) =>
      context.findAncestorStateOfType<_BusinessAccountLocationCreationState>();
}

class _BusinessAccountLocationCreationState
    extends State<BusinessAccountLocationCreation> {
  double businessLocationLatitude;
  double businessLocationLongitude;
  String businessAddress = "";
  bool _locationValid = false;
  bool _invalidLocation = false;

  Future turnAddressIntoCoordinates(String addressInput) async {
    try {
      List<Location> locations = await locationFromAddress(addressInput);
      businessLocationLatitude = (locations.first.latitude);
      businessLocationLongitude = (locations.first.longitude);
      businessAddress = addressController.text;
      print(businessLocationLatitude);
    } on Exception {
      print('excep');
      setState(() {
        _invalidLocation = true;
      });
      return null;
      // only executed if error is of type Exception
    } catch (error) {
      print('err');
      // executed for errors of all types other than Exception
    }
    setState(() {
      _invalidLocation = false;
      _locationValid = true;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TextThemes.ndBlue,
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: DelayedDisplay(
              delay: Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 30),
                child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.white)),
              ),
            ),
          ),
          DelayedDisplay(
            delay: Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Text(
                "Where's your business located?",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    DelayedDisplay(
                      delay: Duration(milliseconds: 700),
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10.0, left: 15, right: 15, top: 15),
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),

                          controller: addressController,
                          decoration: InputDecoration(
                            hintText: "Business address..",
                            hintStyle: GoogleFonts.montserrat(
                                color: Colors.white.withOpacity(.5)),
                            // suffixIcon: IconButton(
                            //   icon: _incorrect
                            //       ? Icon(Icons.lock, color: Colors.red)
                            //       : Icon(Icons.lock_open, color: Colors.white),
                            //   onPressed: () {
                            //     // _tryUnlock();
                            //     // titleController.clear();
                            //   },
                            // ),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)),
                                borderSide: BorderSide(
                                  color: Colors.teal,
                                )),
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            if (_formKey.currentState.validate()) {}
                            // _tryUnlock();
                          },

                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Business address?';
                            }
                            if (value.length < 4) {
                              return 'Address is too short';
                            }
                            if (turnAddressIntoCoordinates(value) == null) {
                              return 'Cannot find Address';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    DelayedDisplay(
                      delay: Duration(milliseconds: 1800),
                      child: Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: _invalidLocation
                              ? Text(
                                  "Unable to find coordinates from address",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.0,
                                    color: Colors.red,
                                  ),
                                )
                              : Text(
                                  "the more specific the better..",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                )),
                    ),
                    _locationValid
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, left: 200),
                            child: DelayedDisplay(
                              delay: Duration(milliseconds: 200),
                              child: Bounce(
                                duration: Duration(milliseconds: 500),
                                onPressed: () {
                                  accountButtonPressed(
                                      context: context,
                                      page: _AgreeToTermsPage(
                                          widget.businessName,
                                          widget.businessType,
                                          businessLocationLatitude,
                                          businessLocationLongitude,
                                          businessAddress));
                                },
                                child: Container(
                                  height: 50.0,
                                  width: 100.0,
                                  decoration: BoxDecoration(
                                    color: TextThemes.ndBlue,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: Center(
                                      child: Icon(Icons.arrow_forward,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessAccountOptionals extends StatefulWidget {
  final String bizName, bizType, bizAddress;
  final double bizLat, bizLong;
  _BusinessAccountOptionals(
    this.bizName,
    this.bizType,
    this.bizLat,
    this.bizLong,
    this.bizAddress,
  );

  @override
  __BusinessAccountOptionalsState createState() =>
      __BusinessAccountOptionalsState();
}

final String bizDescription = "";
final String bizPic = "";
final businessDescriptionController = TextEditingController();

class __BusinessAccountOptionalsState extends State<_BusinessAccountOptionals> {
  @override
  void initState() {
    _controllerCenterLeft =
        ConfettiController(duration: const Duration(seconds: 2));

    super.initState();
  }

  bool _isUploading = false;
  bool _success = false;

  File _image;
  final picker = ImagePicker();
  ConfettiController _controllerCenterLeft;

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
            "Whaddaya got? 😋",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: TextThemes.ndBlue,
        body: Center(
            child: _isUploading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 150),
                      Text("Asking the MOOV Gods..",
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 10),
                      const SpinKitWave(
                          color: Colors.amber, type: SpinKitWaveType.center),
                    ],
                  )
                : _success
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 300),
                              Text("They said yes!",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
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
                              emissionFrequency:
                                  0.05, // how often it should emit
                              numberOfParticles:
                                  20, // number of particles to emit
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
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Icon(Icons.arrow_back,
                                          color: Colors.white)),
                                )),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 15),
                                    DelayedDisplay(
                                      delay: Duration(milliseconds: 200),
                                      child: Text(
                                        "—Optional Details—",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 20.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    DelayedDisplay(
                                      delay: Duration(milliseconds: 200),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 65, bottom: 15),
                                        child: Text(
                                          "Picture (to go with quick posts)",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 16.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DelayedDisplay(
                                        delay: Duration(milliseconds: 200),
                                        child: GestureDetector(
                                          onTap: () => selectImage(context),
                                          child: Container(
                                            height: 125,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .9,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: _image == null
                                                ? Icon(Icons.add_a_photo,
                                                    color: Colors.white)
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.file(_image,
                                                        fit: BoxFit.cover,
                                                        color: Colors.black45,
                                                        colorBlendMode:
                                                            BlendMode.darken),
                                                  ),
                                          ),
                                        )),
                                    DelayedDisplay(
                                      delay: Duration(milliseconds: 200),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 50.0),
                                        child: Text(
                                          "Business description",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 16.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DelayedDisplay(
                                      delay: Duration(milliseconds: 700),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 40.0,
                                            left: 15,
                                            right: 15,
                                            top: 15),
                                        child: TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 1,
                                          style: TextStyle(color: Colors.white),
                                          controller:
                                              businessDescriptionController,
                                          decoration: InputDecoration(
                                            hintText: "Business description..",
                                            hintStyle: GoogleFonts.montserrat(
                                                color: Colors.white
                                                    .withOpacity(.5)),
                                            // suffixIcon: IconButton(
                                            //   icon: _incorrect
                                            //       ? Icon(Icons.lock, color: Colors.red)
                                            //       : Icon(Icons.lock_open, color: Colors.white),
                                            //   onPressed: () {
                                            //     // _tryUnlock();
                                            //     // titleController.clear();
                                            //   },
                                            // ),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(2)),
                                                borderSide: BorderSide(
                                                  color: Colors.teal,
                                                )),
                                            fillColor: Colors.white,
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DelayedDisplay(
                                      delay: Duration(milliseconds: 700),
                                      child: Bounce(
                                        duration: Duration(milliseconds: 500),
                                        onPressed: () {
                                          _createBusinessInFirestore(
                                              businessName: widget.bizName,
                                              latitude: widget.bizLat,
                                              longtitude: widget.bizLong,
                                              type: widget.bizType,
                                              address: widget.bizAddress,
                                              description:
                                                  businessDescriptionController
                                                      .text);
                                        },
                                        child: Container(
                                          height: 50.0,
                                          width: 150.0,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                                spreadRadius: 5,
                                                blurRadius: 7,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                            border:
                                                Border.all(color: Colors.white),
                                            color: TextThemes.ndGold,
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Create',
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
                              ),
                            ),
                          ])));
  }

  _createBusinessInFirestore({
    String businessName,
    double latitude,
    double longtitude,
    String type,
    String address,
    String description,
  }) async {
    setState(() {
      _isUploading = true;
    });
    final GoogleSignInAccount user = googleSignIn.currentUser;

    String downloadUrl;
    if (_image != null) {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("images/" + user.id + "/header");
      firebase_storage.UploadTask uploadTask;

      uploadTask = ref.putFile(_image);

      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      if (uploadTask.snapshot.state == firebase_storage.TaskState.success) {
        print("added to Firebase Storage");
        downloadUrl = await taskSnapshot.ref.getDownloadURL();
      }
    }

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
      "businessLocation": GeoPoint(latitude, longtitude),
      "businessType": type,
      "menu": [],
      "photoUrl": user.photoUrl,
      "badges": {},
      "bio": description ?? "Create a bio here",
      "header": downloadUrl ?? "",
      "timestamp": timestamp,
      "score": 0,
      "moovMoney": 0,
      "gender": "",
      "race": "",
      "year": "",
      // "businessPostPic": downloadUrl,
      "dorm": address,
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
      "userType": {},
      "isSingle": false,
      "venmoUsername": null,
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
    }).then((value) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _isUploading = false;
          _success = true;
        });
      });
    }).then((value) => Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (c, a1, a2) => Home(),
              transitionsBuilder: (c, anim, a2, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: Duration(milliseconds: 1000),
            ),
          );
        }));
  }
}

class _AgreeToTermsPage extends StatelessWidget {
  final String name, type, address;
  final double lat, long;
  const _AgreeToTermsPage(
      this.name, this.type, this.lat, this.long, this.address);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: TextThemes.ndBlue,
        body: Center(
            child: DelayedDisplay(
                delay: Duration(milliseconds: 200),
                child: Bounce(
                  duration: Duration(milliseconds: 500),
                  onPressed: () {
                    _openAgreeDialog(context, name, type, lat, long, address);
                  },
                  child: Container(
                    height: 50.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      border: Border.all(color: Colors.white),
                      color: TextThemes.ndBlue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                        child: Text(
                      "Agree to our terms",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    )),
                  ),
                ))));
  }
}

Future _openAgreeDialog(context, name, type, lat, long, address) async {
  String result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return CreateAgreement(name, type, lat, long, address);
      },
      //true to display with a dismiss button rather than a return navigation arrow
      fullscreenDialog: true));
  if (result != null) {
    letsDoSomething(result, context);
  } else {
    print('you could do another action here if they cancel');
  }
}

letsDoSomething(String result, context) {
  print(result); //prints 'User Agreed'
}

class CreateAgreement extends StatelessWidget {
  final String name, type, address;
  final double lat, long;
  CreateAgreement(this.name, this.type, this.lat, this.long, this.address);
  final String pdfText = """
End-User License Agreement ("Agreement")
Last updated: June 25, 2021

Please read this End-User License Agreement carefully before clicking the "AGREE" button, downloading or using MOOV.

Interpretation and Definitions
Interpretation
The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.

Definitions
For the purposes of this End-User License Agreement:

Agreement means this End-User License Agreement that forms the entire agreement between You and the Company regarding the use of the Application. This Agreement has been created with the help of the EULA Generator.

Application means the software program provided by the Company downloaded by You to a Device, named MOOV

Company (referred to as either "the Company", "We", "Us" or "Our" in this Agreement) refers to What's the MOOV, Inc., 11 Woodrow Ln, Smithtown NY, 11787.

Content refers to content such as text, images, or other information that can be posted, uploaded, linked to or otherwise made available by You, regardless of the form of that content.

Country refers to: New York, United States

Device means any device that can access the Application such as a computer, a cellphone or a digital tablet.

Third-Party Services means any services or content (including data, information, applications and other products services) provided by a third-party that may be displayed, included or made available by the Application.

You means the individual accessing or using the Application or the company, or other legal entity on behalf of which such individual is accessing or using the Application, as applicable.

Acknowledgment
By clicking the "AGREE" button, downloading or using the Application, You are agreeing to be bound by the terms and conditions of this Agreement. If You do not agree to the terms of this Agreement, do not click on the "AGREE" button, do not download or do not use the Application.

This Agreement is a legal document between You and the Company and it governs your use of the Application made available to You by the Company.

The Application is licensed, not sold, to You by the Company for use strictly in accordance with the terms of this Agreement.

License
Scope of License
The Company grants You a revocable, non-exclusive, non-transferable, limited license to download, install and use the Application strictly in accordance with the terms of this Agreement.

The license that is granted to You by the Company is solely for your personal, non-commercial purposes strictly in accordance with the terms of this Agreement.

Third-Party Services
The Application may display, include or make available third-party content (including data, information, applications and other products services) or provide links to third-party websites or services.

You acknowledge and agree that the Company shall not be responsible for any Third-party Services, including their accuracy, completeness, timeliness, validity, copyright compliance, legality, decency, quality or any other aspect thereof. The Company does not assume and shall not have any liability or responsibility to You or any other person or entity for any Third-party Services.

You must comply with applicable Third parties' Terms of agreement when using the Application. Third-party Services and links thereto are provided solely as a convenience to You and You access and use them entirely at your own risk and subject to such third parties' Terms and conditions.

Term and Termination
This Agreement shall remain in effect until terminated by You or the Company. The Company may, in its sole discretion, at any time and for any or no reason, suspend or terminate this Agreement with or without prior notice.

This Agreement will terminate immediately, without prior notice from the Company, in the event that you fail to comply with any provision of this Agreement. You may also terminate this Agreement by deleting the Application and all copies thereof from your Device or from your computer.

Upon termination of this Agreement, You shall cease all use of the Application and delete all copies of the Application from your Device.

Termination of this Agreement will not limit any of the Company's rights or remedies at law or in equity in case of breach by You (during the term of this Agreement) of any of your obligations under the present Agreement.

Indemnification
You agree to indemnify and hold the Company and its parents, subsidiaries, affiliates, officers, employees, agents, partners and licensors (if any) harmless from any claim or demand, including reasonable attorneys' fees, due to or arising out of your: (a) use of the Application; (b) violation of this Agreement or any law or regulation; or (c) violation of any right of a third party.

No Warranties
The Application is provided to You "AS IS" and "AS AVAILABLE" and with all faults and defects without warranty of any kind. To the maximum extent permitted under applicable law, the Company, on its own behalf and on behalf of its affiliates and its and their respective licensors and service providers, expressly disclaims all warranties, whether express, implied, statutory or otherwise, with respect to the Application, including all implied warranties of merchantability, fitness for a particular purpose, title and non-infringement, and warranties that may arise out of course of dealing, course of performance, usage or trade practice. Without limitation to the foregoing, the Company provides no warranty or undertaking, and makes no representation of any kind that the Application will meet your requirements, achieve any intended results, be compatible or work with any other software, applications, systems or services, operate without interruption, meet any performance or reliability standards or be error free or that any errors or defects can or will be corrected.

Without limiting the foregoing, neither the Company nor any of the company's provider makes any representation or warranty of any kind, express or implied: (i) as to the operation or availability of the Application, or the information, content, and materials or products included thereon; (ii) that the Application will be uninterrupted or error-free; (iii) as to the accuracy, reliability, or currency of any information or content provided through the Application; or (iv) that the Application, its servers, the content, or e-mails sent from or on behalf of the Company are free of viruses, scripts, trojan horses, worms, malware, timebombs or other harmful components.

Some jurisdictions do not allow the exclusion of certain types of warranties or limitations on applicable statutory rights of a consumer, so some or all of the above exclusions and limitations may not apply to You. But in such a case the exclusions and limitations set forth in this section shall be applied to the greatest extent enforceable under applicable law. To the extent any warranty exists under law that cannot be disclaimed, the Company shall be solely responsible for such warranty.

Limitation of Liability
Notwithstanding any damages that You might incur, the entire liability of the Company and any of its suppliers under any provision of this Agreement and your exclusive remedy for all of the foregoing shall be limited to the amount actually paid by You for the Application or through the Application or 100 USD if You haven't purchased anything through the Application.

To the maximum extent permitted by applicable law, in no event shall the Company or its suppliers be liable for any special, incidental, indirect, or consequential damages whatsoever (including, but not limited to, damages for loss of profits, loss of data or other information, for business interruption, for personal injury, loss of privacy arising out of or in any way related to the use of or inability to use the Application, third-party software and/or third-party hardware used with the Application, or otherwise in connection with any provision of this Agreement), even if the Company or any supplier has been advised of the possibility of such damages and even if the remedy fails of its essential purpose.

Some states/jurisdictions do not allow the exclusion or limitation of incidental or consequential damages, so the above limitation or exclusion may not apply to You.

Severability and Waiver
Severability
If any provision of this Agreement is held to be unenforceable or invalid, such provision will be changed and interpreted to accomplish the objectives of such provision to the greatest extent possible under applicable law and the remaining provisions will continue in full force and effect.

Waiver
Except as provided herein, the failure to exercise a right or to require performance of an obligation under this Agreement shall not effect a party's ability to exercise such right or require such performance at any time thereafter nor shall be the waiver of a breach constitute a waiver of any subsequent breach.

Product Claims
The Company does not make any warranties concerning the Application.

United States Legal Compliance
You represent and warrant that (i) You are not located in a country that is subject to the United States government embargo, or that has been designated by the United States government as a "terrorist supporting" country, and (ii) You are not listed on any United States government list of prohibited or restricted parties.

Changes to this Agreement
The Company reserves the right, at its sole discretion, to modify or replace this Agreement at any time. If a revision is material we will provide at least 30 days' notice prior to any new terms taking effect. What constitutes a material change will be determined at the sole discretion of the Company.

By continuing to access or use the Application after any revisions become effective, You agree to be bound by the revised terms. If You do not agree to the new terms, You are no longer authorized to use the Application.

Governing Law
The laws of the Country, excluding its conflicts of law rules, shall govern this Agreement and your use of the Application. Your use of the Application may also be subject to other local, state, national, or international laws.

Entire Agreement
The Agreement constitutes the entire agreement between You and the Company regarding your use of the Application and supersedes all prior and contemporaneous written or oral agreements between You and the Company.

You may be subject to additional terms and conditions that apply when You use or purchase other Company's services, which the Company will provide to You at the time of such use or purchase.

Contact Us
If you have any questions about this Agreement, You can contact Us:

By phone number: 6315609452
""";

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: TextThemes.ndBlue,
              title: const Text('Terms & Conditions'),
              actions: [
                TextButton(
                    onPressed: () {
                      accountButtonPressed(
                          context: context,
                          page: _BusinessAccountOptionals(
                              name, type, lat, long, address));
                    },
                    child: Text(
                      'AGREE',
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(pdfText),
              ),
            )));
  }
}

class _StudentAccountCreation extends StatefulWidget {
  final bool secondTime;
  _StudentAccountCreation({this.secondTime = false});
  @override
  __StudentAccountCreationState createState() =>
      __StudentAccountCreationState();
}

class __StudentAccountCreationState extends State<_StudentAccountCreation> {
  final _formKey = GlobalKey<FormState>();
  final studentDormController = TextEditingController();
  bool _dormNameValid = false;
  String _yearValue;
  String _genderValue;
  String _raceValue;
  bool _dormChosen = false;
  bool _yearChosen = false;

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Scaffold(
      backgroundColor: TextThemes.ndBlue,
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: widget.secondTime
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: widget.secondTime
                ?
                //these fields populate once the student has submitted the first
                //set of info

                [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child:
                                  Icon(Icons.arrow_back, color: Colors.white)),
                        )),
                    SizedBox(height: 15),
                    DelayedDisplay(
                      delay: Duration(milliseconds: 200),
                      child: Text(
                        "—Optional Details—",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: isLargePhone ? 75 : 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DelayedDisplay(
                          delay: Duration(milliseconds: 200),
                          child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: 15.0, left: 15, right: 15, top: 0),
                              child: Center(
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: TextThemes.ndBlue,
                                  ),
                                  child: DropdownButton<String>(
                                    iconSize: 0,
                                    value: _genderValue,
                                    elevation: 5,
                                    items: <String>[
                                      'Female',
                                      'Male',
                                      'Other',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value,
                                              style: TextStyle(
                                                  color: Colors.white)));
                                    }).toList(),
                                    hint: Text(
                                      "Gender?",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    onChanged: (String value) {
                                      setState(() {
                                        _genderValue = value;
                                      });
                                    },
                                  ),
                                ),
                              )),
                        ),
                        SizedBox(height: 40),
                        DelayedDisplay(
                          delay: Duration(milliseconds: 300),
                          child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: 15.0, left: 15, right: 15, top: 0),
                              child: Center(
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: TextThemes.ndBlue,
                                  ),
                                  child: DropdownButton<String>(
                                    iconSize: 0,
                                    value: _raceValue,
                                    elevation: 5,
                                    items: <String>[
                                      'Black',
                                      'Asian',
                                      'Latino',
                                      'American Indian',
                                      'White',
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value,
                                              style: TextStyle(
                                                  color: Colors.white)));
                                    }).toList(),
                                    hint: Text(
                                      "Race?",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    onChanged: (String value) {
                                      setState(() {
                                        _raceValue = value;
                                      });
                                    },
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ParallaxCommunities(),
                    DelayedDisplay(
                      delay: Duration(milliseconds: 700),
                      child: Bounce(
                        duration: Duration(milliseconds: 500),
                        onPressed: () {
                          // _createBusinessInFirestore(
                          //     businessName: widget.bizName,
                          //     latitude: widget.bizLat,
                          //     longtitude: widget.bizLong,
                          //     type: widget.bizType,
                          //     address: widget.bizAddress,
                          //     description:
                          //         businessDescriptionController
                          //             .text);
                        },
                        child: Container(
                          height: 50.0,
                          width: 150.0,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                            border: Border.all(color: Colors.white),
                            color: TextThemes.ndGold,
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          child: Center(
                            child: Text(
                              'Create',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
                : [
                    DelayedDisplay(
                      delay: Duration(milliseconds: 200),
                      child: Text(
                        "What dorm?",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DelayedDisplay(
                      delay: Duration(milliseconds: 700),
                      child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 40.0, left: 15, right: 15, top: 15),
                        child: TextFormField(
                          style: TextStyle(color: Colors.white),

                          controller: studentDormController,
                          decoration: InputDecoration(
                            hintText: "Dorm name..",
                            hintStyle: GoogleFonts.montserrat(
                                color: Colors.white.withOpacity(.5)),
                            // suffixIcon: IconButton(
                            //   icon: _incorrect
                            //       ? Icon(Icons.lock, color: Colors.red)
                            //       : Icon(Icons.lock_open, color: Colors.white),
                            //   onPressed: () {
                            //     // _tryUnlock();
                            //     // titleController.clear();
                            //   },
                            // ),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)),
                                borderSide: BorderSide(
                                  color: Colors.teal,
                                )),
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                _dormNameValid = true;
                              });
                            }
                            // _tryUnlock();
                          },

                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'No dorm?';
                            }
                            if (value.length < 4) {
                              return 'Name is too short';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    _dormNameValid
                        ? DelayedDisplay(
                            delay: Duration(milliseconds: 300),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: 15.0, left: 15, right: 15, top: 0),
                                child: Center(
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      canvasColor: TextThemes.ndBlue,
                                    ),
                                    child: DropdownButton<String>(
                                      iconSize: 0,
                                      value: _yearValue,
                                      elevation: 5,
                                      items: <String>[
                                        'Freshman',
                                        'Sophomore',
                                        'Junior',
                                        'Senior',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value,
                                                style: TextStyle(
                                                    color: Colors.white)));
                                      }).toList(),
                                      hint: Text(
                                        "What year?",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          _yearChosen = true;
                                          _yearValue = value;
                                        });
                                      },
                                    ),
                                  ),
                                )),
                          )
                        : Container(),
                    _dormNameValid
                        ? DelayedDisplay(
                            delay: Duration(milliseconds: 750),
                            child: Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Text(
                                    "you can hide this info in settings..\nMOOV off the grid",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center)),
                          )
                        : Container(),
                    _yearChosen
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, left: 200),
                            child: DelayedDisplay(
                              delay: Duration(milliseconds: 200),
                              child: Bounce(
                                duration: Duration(milliseconds: 500),
                                onPressed: () {
                                  accountButtonPressed(
                                      context: context,
                                      page: _StudentAccountCreation(
                                          secondTime: true)
                                      //  StudentAccountDemographics(
                                      //     this.studentDormController.text,
                                      //     this._chosenValue)
                                      );
                                },
                                child: Container(
                                  height: 50.0,
                                  width: 100.0,
                                  decoration: BoxDecoration(
                                    color: TextThemes.ndBlue,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: Center(
                                      child: Icon(Icons.arrow_forward,
                                          color: Colors.white)),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
          ),
        ),
      ),
    );
  }
}

class ParallaxCommunities extends StatefulWidget {
  @override
  _ParallaxCommunitiesState createState() => _ParallaxCommunitiesState();
}

class _ParallaxCommunitiesState extends State<ParallaxCommunities> {
  PageController pageController;
  double pageOffset = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.7);
    pageController.addListener(() {
      setState(() {
        pageOffset = pageController.page;
      });
    });
  }

  List<Map> communitiesMap = [
    {
      'image': 'lib/assets/wachaIntoPics/new.jpg',
      'name': 'discovering\nnew spots',
      'id': 'new'
    },
    {
      'image': 'lib/assets/wachaIntoPics/sports.jpg',
      'name': 'sports',
      'id': 'sports'
    },
    {
      'image': 'lib/assets/wachaIntoPics/bars.jpeg',
      'name': 'bars',
      'id': 'bars'
    },
    {
      'image': 'lib/assets/wachaIntoPics/shows.jpg',
      'name': 'shows',
      'id': 'shows'
    },
    {
      'image': 'lib/assets/wachaIntoPics/board.jpg',
      'name': 'board/video games',
      'id': 'board'
    },
    {
      'image': 'lib/assets/wachaIntoPics/outdoors.gif',
      'name': 'outdoors',
      'id': 'outdoors'
    },
    // {'image': 'lib/assets/editclub.jpeg', 'name': 'Service', 'id': 'service'},
  ];

  final List communityJoinList = [];
  final List communityNotificationList = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 350,
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage("assets/clouds.jpeg"),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 20),
                child: Text(
                  'wacha into?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                height: 300,
                padding: EdgeInsets.only(bottom: 30),
                child: PageView.builder(
                    itemCount: communitiesMap.length,
                    controller: pageController,
                    itemBuilder: (context, i) {
                      return Transform.scale(
                        scale: 1,
                        child: Container(
                          padding: EdgeInsets.only(right: 20),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: OpenContainer(
                                  transitionType: ContainerTransitionType.fade,
                                  transitionDuration:
                                      Duration(milliseconds: 500),
                                  openBuilder: (context, _) => CommunityPreview(
                                      communitiesMap[i]['image'],
                                      communitiesMap[i]['name'],
                                      communitiesMap[i]['id'],
                                      communityJoinList,
                                      communityNotificationList),
                                  closedElevation: 0,
                                  closedBuilder: (context, _) => Image.asset(
                                    communitiesMap[i]['image'],
                                    height: 250,
                                    fit: BoxFit.cover,
                                    alignment:
                                        Alignment(-pageOffset.abs() + i, 0),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 10,
                                bottom: 25,
                                right: 10,
                                child: Text(
                                  communitiesMap[i]['name'],
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 27,
                                    // fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class CommunityPreview extends StatelessWidget {
  final String pic, name, id;
  final List communityJoinList, communityNotificationList;
  CommunityPreview(this.pic, this.name, this.id, this.communityJoinList,
      this.communityNotificationList);

  final scrollController = ScrollController();
  final int listItemCount = 4;

  @override
  Widget build(BuildContext context) {
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
              );
            },
          ),
          flexibleSpace: Image.asset(
            pic,
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
            color: Colors.black38,
          ),
          title: RichText(
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: name,
                    style: GoogleFonts.montserrat(
                        color: Colors.white, fontSize: 20),
                  ),
                ]),
          ),
        ),
        body: // With predefined options
            FutureBuilder(
                future:
                    communityGroupsRef.where("tags", arrayContains: id).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return CustomScrollView(
                    // Must add scrollController to sliver root
                    controller: scrollController,

                    slivers: <Widget>[
                      LiveSliverGrid(
                        // And attach root sliver scrollController to widgets
                        controller: scrollController,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (
                          BuildContext context,
                          int index,
                          Animation<double> animation,
                        ) =>
                            FadeTransition(
                                opacity: Tween<double>(
                                  begin: 0,
                                  end: 1,
                                ).animate(animation),
                                // And slide transition
                                child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(0, -0.1),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    // Paste you Widget
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            left: 6,
                                            top: 20,
                                            right: 6,
                                            bottom: 10),
                                        height: double.infinity,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
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
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                  child: Container(
                                                    child: Image.network(
                                                      //this is where I believe the issue is for example
                                                      //this widget is showing the "Pool Hangout" you see at the top
                                                      snapshot.data.docs[index]
                                                          ['groupPic'],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )),
                                            ),
                                            _JoinNotifRow(
                                                snapshot.data.docs[index],
                                                communityJoinList,
                                                communityNotificationList)
                                          ],
                                        )))),

                        // buildAnimatedItem,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: .5,
                          mainAxisSpacing: 10,
                        ),
                      ),
                    ],
                  );
                }));
  }
}

class _JoinNotifRow extends StatefulWidget {
  final QueryDocumentSnapshot course;
  final List communityJoinList, communityNotificationList;
  _JoinNotifRow(
      this.course, this.communityJoinList, this.communityNotificationList);

  @override
  __JoinNotifRowState createState() => __JoinNotifRowState();
}

class __JoinNotifRowState extends State<_JoinNotifRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Bounce(
          duration: Duration(milliseconds: 500),
          onPressed: () {
            widget.communityJoinList.add(widget.course['groupId']);
            setState(() {});
          },
          child: Container(
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                  )),
              child: Center(
                child:
                    widget.communityJoinList.contains(widget.course['groupId'])
                        ? Icon(Icons.check, color: Colors.white)
                        : Text("JOIN",
                            style: GoogleFonts.montserrat(color: Colors.white)),
              )),
        ),
        Container(
            width: 40,
            child: Center(
                child: Bounce(
                    duration: Duration(milliseconds: 500),
                    onPressed: () {
                      widget.communityNotificationList
                          .add(widget.course['groupId']);
                      setState(() {});
                    },
                    child: widget.communityNotificationList
                            .contains(widget.course['groupId'])
                        ? Icon(Icons.notifications)
                        : Icon(Icons.notifications_outlined))))
      ],
    );
  }
}
