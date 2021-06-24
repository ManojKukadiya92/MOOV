import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:google_fonts/google_fonts.dart';

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
                                accountButtonPressed(context, Home(), "");
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
                                accountButtonPressed(context,
                                    _BusinessAccountNameCreation(), "");
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

accountButtonPressed(BuildContext context, Widget page, String userInput) {
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
  String _typeDropDownValue = "Restaurant/Bar";
  List _typeDropDownList = [
    "Restaurant/Bar",
    "Theatre",
    "Night Club",
    "Sports Team"
  ];
  String _chosenValue;

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
                      bottom: 15.0, left: 15, right: 15, top: 15),
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
                            bottom: 15.0, left: 15, right: 15, top: 15),
                    child:  Center(
        child: Container(
          padding: const EdgeInsets.all(0.0),
          child: DropdownButton<String>(
            value: _chosenValue,
            //elevation: 5,
            style: TextStyle(color: Colors.black),

            items: <String>[
              'Restaurant/Bar',
              'Theatre',
              'Night Club',
              'Sports Team',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Colors.white)),
              );
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
                _chosenValue = value;
              });
            },
          ),
        ),
      
    )
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
