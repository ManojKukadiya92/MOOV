import 'dart:math';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/EditArchive.dart';
import 'package:MOOV/pages/archiveDetail.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:worm_indicator/indicator.dart';
import 'package:worm_indicator/shape.dart';

class Biz extends StatefulWidget {
  final List previousPosts;
  Biz(this.previousPosts);
  @override
  State<StatefulWidget> createState() {
    return _BizState();
  }
}

class _BizState extends State<Biz> {
  PageController _controller;
  int pageNumber = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: .7);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _onPageViewChange(int page) {
    setState(() {
      pageNumber = page;
    });
  }

  Widget buildPageView(previousPosts, count, _controller) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return PageView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: _controller,
      onPageChanged: _onPageViewChange,
      itemBuilder: (BuildContext context, int pos) {
        List course = previousPosts[pos];
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                // width: width * 0.8,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: isLargePhone ? 120 : 100,
                        child: OpenContainer(
                          transitionType: ContainerTransitionType.fade,
                          transitionDuration: Duration(milliseconds: 500),
                          openBuilder: (context, _) =>
                              ArchiveDetail(course[pos]['postId']),
                          closedElevation: 0,
                          closedBuilder: (context, _) =>
                              Stack(children: <Widget>[
                            FractionallySizedBox(
                              widthFactor: 1,
                              child: Container(
                                child: Container(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: course[pos]['image'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment(0.0, 0.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: <Color>[
                                          Colors.black.withAlpha(0),
                                          Colors.black,
                                          Colors.black12,
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        course[pos]['title'],
                                        style: TextStyle(
                                            fontFamily: 'Solway',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 20.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Positioned(
                            //     right: 5,
                            //     top: 5,
                            //     child: EditButton(course[pos]['postId']))
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: count,
    );
  }

  Widget buildSuggestionsIndicatorWithShapeAndBottomPos(
      Shape shape, double bottomPos, count, controller) {
    return Positioned(
      bottom: bottomPos,
      left: 0,
      right: 0,
      child: WormIndicator(
        length: count,
        controller: controller,
        shape: shape,
      ),
    );
  }

  final format = DateFormat("EEE, MMM d,' at' h:mm a");
  bool isUploading = false;
  bool needDate = false;
  DateTime currentValue = DateTime.now();
  DateTime currentValues;
  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    final Shape circleShape = Shape(
      size: 8,
      shape: DotShape.Circle,
      spacing: 8,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: (!isUploading)
          ? Stack(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                  padding: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      border: Border(top: BorderSide(width: 1.0))),
                  height: isLargePhone
                      ? MediaQuery.of(context).size.height / 2.5
                      : MediaQuery.of(context).size.height / 2.75,
                  child: Column(children: [
                    Container(
                      height: isLargePhone ? 150 : 140,
                      child: buildPageView(widget.previousPosts,
                          widget.previousPosts.length, _controller),
                    ),
                    SizedBox(height: 7),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 58,
                            width: 230,
                            child: DateTimeField(
                              format: format,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: needDate
                                        ? Colors.red
                                        : TextThemes.ndGold,
                                  ),
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
                                            textTheme: ButtonTextTheme.primary),
                                      ),
                                      child: child,
                                    );
                                  },
                                );
                                if (date != null) {
                                  final time = await showTimePicker(
                                    initialEntryMode: TimePickerEntryMode.input,
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
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: GestureDetector(
                              onTap: () {
                                QueryDocumentSnapshot course = widget
                                    .previousPosts[pageNumber][pageNumber];

                                HapticFeedback.lightImpact();

                                if (DateTime.now()
                                        .subtract(Duration(hours: 1))
                                        .isBefore(currentValue) &&
                                    DateTime.now()
                                        .add(Duration(hours: 1))
                                        .isAfter(currentValue)) {
                                  setState(() {
                                    needDate = true;
                                  });
                                } else {
                                  setState(() {
                                    isUploading = true;
                                  });

                                  Database().createBusinessPost(
                                      title: course['title'],
                                      type: course['type'],
                                      privacy: course['privacy'],
                                      description: course['description'],
                                      address: course['address'],
                                      startDate: currentValue,
                                      startDateSimpleString: DateFormat('yMd')
                                          .format(currentValue),
                                      unix: currentValue.millisecondsSinceEpoch,
                                      statuses: [],
                                      maxOccupancy: course['maxOccupancy'],
                                      paymentAmount: course['paymentAmount'],
                                      imageUrl: course['image'],
                                      userId: course['userId'],
                                      postId: generateRandomString(20),
                                      recurringType: course['recurringType'],
                                      posterName: currentUser.displayName,
                                      moovOver: course['moovOver'],
                                      push: course['push'],
                                      mobileOrderMenu:
                                          course['mobileOrderMenu'],
                                      noArchive: true);

                                  setState(() {
                                    isUploading = false;
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: TextThemes.ndGold,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Post!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25)
                  ]),
                ),
                Positioned(
                    left: 50,
                    top: 12,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                      color: Colors.white,
                      child: Text(
                        'Or post again!',
                        style:
                            GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                      ),
                    )),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Asking the MOOV Gods..",
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                const SpinKitWave(
                    color: Colors.blue, type: SpinKitWaveType.center),
              ],
            ),
    );
  }
}

class QuickPost extends StatefulWidget {
  QuickPost({Key key}) : super(key: key);

  @override
  _QuickPostState createState() => _QuickPostState();
}

class _QuickPostState extends State<QuickPost> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: archiveRef.where("userId", isEqualTo: currentUser.id).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Container(
              height: 100,
              child: Center(
                  child: Text(
                "Post yoccur",
                style: TextStyle(
                    color: TextThemes.ndBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
              )),
            );
          }
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (_, index) {
                if (snapshot.data.docs.length == 0) {
                  return Container(
                    height: 100,
                    child: Center(
                        child: Text(
                      "Post yoccur",
                      style: TextStyle(
                          color: TextThemes.ndBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    )),
                  );
                }
                DocumentSnapshot course = snapshot.data.docs[index];

                return Container(
                  alignment: Alignment.center,
                  // width: width * 0.8,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 100,
                          child: OpenContainer(
                            transitionType: ContainerTransitionType.fade,
                            transitionDuration: Duration(milliseconds: 500),
                            openBuilder: (context, _) =>
                                ArchiveDetail(course['postId']),
                            closedElevation: 0,
                            closedBuilder: (context, _) =>
                                Stack(children: <Widget>[
                              FractionallySizedBox(
                                widthFactor: 1,
                                child: Container(
                                  child: Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: course['image'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    alignment: Alignment(0.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: <Color>[
                                            Colors.black.withAlpha(0),
                                            Colors.black,
                                            Colors.black12,
                                          ],
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          course['title'],
                                          style: TextStyle(
                                              fontFamily: 'Solway',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 20.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }
}

class EditButton extends StatelessWidget {
  String postId;
  EditButton(this.postId);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => EditArchive(postId))),
      child: Container(
        height: 45,
        width: 70,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.red[300],
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            Text(
              "Edit",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
