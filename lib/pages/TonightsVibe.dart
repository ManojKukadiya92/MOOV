import 'package:MOOV/helpers/SPHelper.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/SPHelper.dart';

Scaffold tonightsVibe(today) {
  return Scaffold(backgroundColor: TextThemes.ndBlue, body: _Contents(today));
}

class _Contents extends StatefulWidget {
  final int today;
  _Contents(this.today);

  @override
  __ContentsState createState() => __ContentsState();
}

class __ContentsState extends State<_Contents> {
  bool _visible = true;
  bool _revealPopularButton = false;
  bool _revealSomethingButton = false;
  bool _revealChillButton = false;

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Column(
      children: [
        Stack(children: [
          Padding(
            padding: isLargePhone
                ? const EdgeInsets.only(top: 90)
                : const EdgeInsets.only(top: 40),
            child: Center(
              child: AnimatedOpacity(
                  opacity: _visible ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: Text("TONIGHT'S\nVIBE?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isLargePhone ? 35 : 24))),
            ),
          ),
          Positioned(
              bottom: 5,
              right: 15,
              child: GestureDetector(
                  onTap: () => goPressed("All"),
                  child: Text("Not sure\nyet...",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(color: Colors.white))))
        ]),
        Padding(
          padding: isLargePhone
              ? const EdgeInsets.only(top: 50.0)
              : const EdgeInsets.only(top: 20.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.all(2.5),
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(seconds: 2),
                curve: Curves.fastOutSlowIn,
                child: Container(
                  width: MediaQuery.of(context).size.width * .48,
                  height: isLargePhone ? 370.0 : 340,
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _revealPopularButton = !_revealPopularButton;
                          });
                        },
                        child: Column(
                          children: [
                            Image.asset('lib/assets/popularSpots.png',
                                height: isLargePhone ? 90 : 70),
                            SizedBox(height: 10),
                            Text("The Popular\nSpots",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    fontSize: isLargePhone ? 20 : 15)),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      AnimatedOpacity(
                        opacity: _revealPopularButton ? 1.0 : 0.0,
                        duration: const Duration(seconds: 2),
                        curve: Curves.fastOutSlowIn,
                        child: Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .4,
                              height: 30,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: AlwaysScrollableScrollPhysics(),
                                children: [
                                  Image.asset(
                                    'lib/assets/montLogo.png',
                                    height: 30,
                                  ),
                                  SizedBox(width: 10),
                                  Image.asset(
                                    'lib/assets/newfsLogo.png',
                                    height: 30,
                                  ),
                                  SizedBox(width: 12),
                                  Image.asset(
                                    'lib/assets/BrothersLogo.png',
                                    height: 25,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 25),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white)),
                              child: Padding(
                                padding: isLargePhone
                                    ? const EdgeInsets.all(20)
                                    : const EdgeInsets.all(15),
                                child: Text(
                                  "Skip the lines!\n Order ahead!",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: isLargePhone ? 14 : 12),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.amber[700],
                                  elevation: 5.0,
                                ),
                                onPressed: () {
                                  goPressed("Pop");
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Go',
                                      style: TextStyle(color: Colors.white)),
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.5),
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(seconds: 2),
                curve: Curves.fastOutSlowIn,
                child: Container(
                  width: MediaQuery.of(context).size.width * .48,
                  height: isLargePhone ? 370.0 : 340,
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _revealSomethingButton = !_revealSomethingButton;
                          });
                        },
                        child: Column(
                          children: [
                            Image.asset('lib/assets/SomethingNew.png',
                                height: isLargePhone ? 90 : 70),
                            SizedBox(height: 10),
                            Text("Something\nNew",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    fontSize: isLargePhone ? 20 : 15)),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      AnimatedOpacity(
                        opacity: _revealSomethingButton ? 1.0 : 0.0,
                        duration: const Duration(seconds: 2),
                        curve: Curves.fastOutSlowIn,
                        child: Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .4,
                              height: 30,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                physics: AlwaysScrollableScrollPhysics(),
                                children: [
                                  Image.asset(
                                    'lib/assets/montLogo.png',
                                    height: 30,
                                  ),
                                  SizedBox(width: 10),
                                  Image.asset(
                                    'lib/assets/newfsLogo.png',
                                    height: 30,
                                  ),
                                  SizedBox(width: 12),
                                  Image.asset(
                                    'lib/assets/BrothersLogo.png',
                                    height: 25,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 25),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white)),
                              child: Padding(
                                padding: isLargePhone
                                    ? const EdgeInsets.all(20)
                                    : const EdgeInsets.all(15),
                                child: Text(
                                  "Exclusive deals!\nLowkey gold!",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: isLargePhone ? 14 : 12),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.yellow[700],
                                  elevation: 5.0,
                                ),
                                onPressed: () {
                                  goPressed("New");
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Go',
                                      style: TextStyle(color: Colors.white)),
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _revealChillButton = !_revealChillButton;
            });
          },
          child: Column(
            children: [
              Image.asset('lib/assets/relax.png',
                  height: isLargePhone ? 90 : 70),
              SizedBox(height: 10),
              Text("Chill/Relax\nNight",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: isLargePhone ? 20 : 15)),
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: _revealChillButton ? 1.0 : 0.0,
          duration: const Duration(seconds: 2),
          curve: Curves.fastOutSlowIn,
          child: Column(
            children: [
              Text(
                "\nJust chillin', you?",
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 5),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange[700],
                    elevation: 5.0,
                  ),
                  onPressed: () {
                    goPressed("Rel");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Go', style: TextStyle(color: Colors.white)),
                  )),
            ],
          ),
        )
      ],
    );
  }

  goPressed(String vibeType) {
    HapticFeedback.lightImpact();
    SPHelper.setInt("Day", widget.today);
    SPHelper.setString("vibeType", vibeType);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => Home(),
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 2000),
      ),
    );
  }
}
