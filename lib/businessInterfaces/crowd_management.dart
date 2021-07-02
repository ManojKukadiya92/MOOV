import 'package:MOOV/pages/MoovMaker.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:worm_indicator/indicator.dart';
import 'package:worm_indicator/shape.dart';

class CrowdManagement extends StatelessWidget {
  CrowdManagement({Key key}) : super(key: key);

  final PageController controller =
      PageController(initialPage: 0, viewportFraction: .8);

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => controller.animateToPage(0,
                    duration: Duration(seconds: 1),
                    curve: Curves.fastOutSlowIn),
                child: Column(
                  children: [
                    GradientIcon(
                        Icons.confirmation_num_outlined,
                        35.0,
                        LinearGradient(
                          colors: <Color>[
                            Colors.red,
                            Colors.yellow,
                            Colors.blue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )),
                    Text("MOOV Over\nPass™", textAlign: TextAlign.center),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.animateToPage(1,
                    duration: Duration(seconds: 1),
                    curve: Curves.fastOutSlowIn),
                child: Column(
                  children: [
                    Icon(
                      Icons.group,
                      size: 35,
                      color: Colors.blue,
                    ),
                    Text("Occupancy\nLimit", textAlign: TextAlign.center),
                  ],
                ),
              )
            ],
          ),
          Expanded(
            child: CrowdPageView(controller),
          )
        ],
      ),
    );
  }
}

class GradientIcon extends StatelessWidget {
  GradientIcon(
    this.icon,
    this.size,
    this.gradient,
  );

  final IconData icon;
  final double size;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      child: SizedBox(
        width: size * 1.2,
        height: size * 1.2,
        child: Icon(
          icon,
          size: size,
          color: Colors.white,
        ),
      ),
      shaderCallback: (Rect bounds) {
        final Rect rect = Rect.fromLTRB(0, 0, size, size);
        return gradient.createShader(rect);
      },
    );
  }
}

class CrowdPageView extends StatefulWidget {
  final PageController controller;
  CrowdPageView(this.controller);

  @override
  _CrowdPageViewState createState() => _CrowdPageViewState();
}

class _CrowdPageViewState extends State<CrowdPageView> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 15),
        WormIndicator(
          length: 2,
          controller: widget.controller,
          shape: Shape(
              width: 135, height: 20, spacing: 0, shape: DotShape.Rectangle),
        ),
        Expanded(
          child: PageView(
            controller: widget.controller,
            children: [
              MoovOverPass(),
              Occupancy(),
            ],
          ),
        ),
      ],
    );
  }
}

class MoovOverPass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              SizedBox(height: 50),
              Card(
                  elevation: 20,
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: SizedBox(
                    width: 300,
                    height: 400,
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        Text('MOOV Over',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: TextThemes.ndBlue)),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                              'Is there ever a wait to get into your place? Profit from it.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: TextThemes.ndBlue)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: TextThemes.ndBlue,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                  'For \$10, let your customers purchase a MOOV Over Pass to skip the wait!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: TextThemes.ndBlue)),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              elevation: 5.0,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();

                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.topToBottom,
                                      child: MoovMaker(fromMoovOver: true)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Set it',
                                  style: TextStyle(color: Colors.white)),
                            ))
                      ],
                    ),
                  )),
            ],
          ),
          Positioned(
              top: 20,
              child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blue[50],
                  child: CircleAvatar(
                      child: GradientIcon(
                          Icons.confirmation_num_outlined,
                          35.0,
                          LinearGradient(
                            colors: <Color>[
                              Colors.red,
                              Colors.yellow,
                              Colors.blue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                      radius: 30,
                      backgroundColor: Colors.white)))
        ],
      ),
    );
  }
}

class Occupancy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              SizedBox(height: 50),
              Card(
                  elevation: 20,
                  color: Colors.red[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: SizedBox(
                    width: 300,
                    height: 400,
                    child: Column(
                      children: [
                        SizedBox(height: 60),
                        Text('Limit Occupancy',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: Colors.red[900])),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                              'Getting swamped? Only want the first few to get your deal?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red[900])),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.red[900],
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                  "Set the max occupancy of your MOOV—it'll lock once it fills.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.red[900])),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              elevation: 5.0,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();

                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.topToBottom,
                                      child: MoovMaker(fromMaxOc: true)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Set it',
                                  style: TextStyle(color: Colors.white)),
                            ))
                      ],
                    ),
                  )),
            ],
          ),
          Positioned(
              top: 20,
              child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.red[50],
                  child: CircleAvatar(
                      child: Icon(Icons.group),
                      radius: 30,
                      backgroundColor: Colors.white)))
        ],
      ),
    );
  }
}
