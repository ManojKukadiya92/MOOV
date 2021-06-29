import 'dart:async';

import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration/duration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

typedef void Callback(String val);

void locationCheckIn(BuildContext context, Function callback) {
  postsRef.where("going", arrayContains: currentUser.id).get().then((value) {
    for (int i = 0; i < value.docs.length; i++) {
      if (value.docs[i]['businessPost'] == false) {
        return null;
      }
      String title = value.docs[i]['title'];
      String postId = value.docs[i]['postId'];
      Map checkInMap = value.docs[i]['checkInMap'];
      final anHourAgo = (new DateTime.now())
          .subtract(new Duration(minutes: Duration.minutesPerHour));
      final anHourPast = (new DateTime.now())
          .add(new Duration(minutes: Duration.minutesPerHour));
      DateTime startDate =
          DateTime.fromMillisecondsSinceEpoch(value.docs[i]['unix']);
      bool openWindow =
          (startDate.isBefore(anHourPast) && startDate.isAfter(anHourAgo));

      if (openWindow &&
          value.docs[i]['businessPost'] &&
          !checkInMap.keys.contains(currentUser.id) &&
          value.docs[i]['userId'] != currentUser.id) {
        //ask for location
        determinePosition();

        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
            .then((pos) {
          var distance = Geolocator.distanceBetween(
              pos.latitude,
              pos.longitude,
              value.docs[i]['businessLocation'].latitude,
              value.docs[i]['businessLocation'].longitude);
          if (distance > 600) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialogBox(
                    title: "Check In",
                    description:
                        "Check into your MOOV to redeem any offers and/or get credit!",
                    choice1: "Check In",
                    choice1Action: (context) {
                      postsRef.doc(postId).get().then((value) {
                        postsRef.doc(postId).set({
                          "checkInMap": {currentUser.id: 1}
                        }, SetOptions(merge: true));
                      });
                      postsRef.doc(postId).set({
                        "statuses": {currentUser.id: 4}
                      }, SetOptions(merge: true));
                      FirebaseFirestore.instance
                          .collection("notreDame")
                          .doc('data')
                          .collection("checkIns")
                          .doc(postId)
                          .set({
                        "checkInList": FieldValue.arrayUnion([currentUser.id])
                      }, SetOptions(merge: true));
                    },
                    choice2Action: (context) {
                      postsRef.doc(postId).get().then((value) {
                        postsRef.doc(postId).set({
                          "checkInMap": {currentUser.id: 0}
                        }, SetOptions(merge: true));
                      });
                      Timer(Duration(seconds: 60), () {
                        postsRef.doc(postId).set({
                          "checkInMap": {currentUser.id: FieldValue.delete()}
                        }, SetOptions(merge: true));
                      });
                    },
                    choice2: "Later",
                    image: value.docs[i]['image'],
                    postTitle: value.docs[i]['title'],
                  );
                });

            HapticFeedback.lightImpact();

            //        showDialog(
            // context: context,
            // builder: (context) => CupertinoAlertDialog(
            //           title: Text("Check In",
            //               style: TextStyle(
            //                   color: Colors.black, fontWeight: FontWeight.bold)),
            //           content: RichText(
            //               textAlign: TextAlign.center,
            //               text: TextSpan(style: TextThemes.mediumbody, children: [
            //                 TextSpan(
            //                     text: "\nCheck into your MOOV, ",
            //                     style: TextStyle(fontWeight: FontWeight.w400)),
            //                 TextSpan(
            //                     text: title,
            //                     style: TextStyle(
            //                         color: Colors.green,
            //                         fontWeight: FontWeight.w700)),
            //                 TextSpan(
            //                     text: " to redeem any offers and/or get credit!",
            //                     style: TextStyle(fontWeight: FontWeight.w400)),
            //               ])),
            //           actions: [
            //             CupertinoDialogAction(
            //                 isDefaultAction: true,
            //                 isDestructiveAction: true,
            //                 child: Text("Check in",
            //                     style: TextStyle(color: Colors.green)),
            //                 onPressed: () {
            //                   postsRef.doc(postId).get().then((value) {
            //                     postsRef.doc(postId).set({
            //                       "checkInMap": {currentUser.id: 1}
            //                     }, SetOptions(merge: true));
            //                   });
            //                   postsRef.doc(postId).set({
            //                     "statuses": {currentUser.id: 4}
            //                   }, SetOptions(merge: true));
            //                   FirebaseFirestore.instance
            //                       .collection("notreDame")
            //                       .doc('data')
            //                       .collection("checkIns")
            //                       .doc(postId)
            //                       .set({
            //                     "checkInList": FieldValue.arrayUnion([currentUser.id])
            //                   }, SetOptions(merge: true));

            //                   Navigator.of(context).pop(true);
            //                 }),
            //             CupertinoDialogAction(
            //                 child: Text("Later"),
            //                 onPressed: () {
            //                   postsRef.doc(postId).get().then((value) {
            //                     postsRef.doc(postId).set({
            //                       "checkInMap": {currentUser.id: 0}
            //                     }, SetOptions(merge: true));
            //                   });
            //                   Navigator.of(context).pop(true);
            //                 })
            //           ],
            //         ),
            //       );
          }
        });
      }

      // if (value.docs.data['postLimit'] >= 1) {
      //   print(value['postLimit']);
      //   usersRef
      //       .doc(currentUser.id)
      //       .update({"postLimit": FieldValue.increment(-1)});
      //   usersRef
      //       .doc(currentUser.id)
      //       .update({"score": FieldValue.increment(100)});
      // }

    }
  });
}

typedef MyEventCallback = Function(BuildContext context);

class CustomDialogBox extends StatefulWidget {
  final String title, description, choice1, choice2, image, postTitle;

  final MyEventCallback choice1Action, choice2Action;

  const CustomDialogBox(
      {Key key,
      this.title,
      this.description,
      this.choice1,
      this.choice2,
      this.image,
      this.choice1Action,
      this.choice2Action,
      this.postTitle});

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  bool isChecking = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 10,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: isChecking ? Colors.green : Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 110,
              ),
              isChecking
                  ? Icon(Icons.check, size: 45, color: Colors.white)
                  : Text(
                      widget.title,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
              SizedBox(
                height: 15,
              ),
              Text(
                widget.description,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 22,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        widget.choice1Action(context);
                        setState(() {
                          isChecking = true;
                        });
                        Timer(Duration(seconds: 1), () {
                          Navigator.of(context).pop();
                        });
                      },
                      child: Text(
                        widget.choice1,
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      )),
                  TextButton(
                      onPressed: () {
                        widget.choice2Action(context);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        widget.choice2,
                        style: TextStyle(fontSize: 18),
                      )),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Container(
            child: Stack(alignment: Alignment.center, children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: OptimizedCacheImage(
                  imageUrl: widget.image,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.15,
                  width: MediaQuery.of(context).size.width * 0.75,
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
                        borderRadius: BorderRadius.all(Radius.circular(20)),
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
                          widget.postTitle,
                          style: TextStyle(
                              fontFamily: 'Solway',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 18.0),
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
    );
  }
}
