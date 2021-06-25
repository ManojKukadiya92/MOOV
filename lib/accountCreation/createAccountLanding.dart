import 'dart:io';
import 'dart:math';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/camera.dart';
import 'package:MOOV/widgets/progress.dart';
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
                                    context: context, page: Home());
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

  Future turnAddressIntoCoordinates(String addressInput) async {
    try {
      List<Location> locations = await locationFromAddress(addressInput);
      businessLocationLatitude = (locations.first.latitude);
      businessLocationLongitude = (locations.first.longitude);
      businessAddress = addressController.text;
      print(businessLocationLatitude);
    } on Exception {
      print('excep');
      return null;
      // only executed if error is of type Exception
    } catch (error) {
      print('err');
      // executed for errors of all types other than Exception
    }
    setState(() {
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
                        child: Text(
                          "the more specific the better..",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
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
                                      page: _BusinessAccountOptionals(
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
          .child("images/" + user.id + "/businessPostPic");
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
      "header": "",
      "timestamp": timestamp,
      "score": 0,
      "moovMoney": 0,
      "gender": "",
      "race": "",
      "year": "",
      "businessPostPic": downloadUrl,
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
