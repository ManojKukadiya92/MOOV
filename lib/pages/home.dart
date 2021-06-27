import 'dart:async';
import 'dart:io';
import 'package:MOOV/accountCreation/createAccountLanding.dart';
import 'package:MOOV/businessInterfaces/BusinessDirectory.dart';
import 'package:MOOV/businessInterfaces/livePassesSheet.dart';
import 'package:MOOV/friendGroups/group_detail.dart';
import 'package:MOOV/helpers/SPHelper.dart';
import 'package:MOOV/helpers/themes.dart';
import 'package:MOOV/models/user.dart';
import 'package:MOOV/moovMoney/moovMoneyAdd.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/MOOVSPage.dart';
import 'package:MOOV/pages/MessagesHub.dart';
import 'package:MOOV/pages/MoovMaker.dart';
import 'package:MOOV/pages/NewSearch.dart';
import 'package:MOOV/pages/ProfilePage.dart';
import 'package:MOOV/pages/TonightsVibe.dart';
import 'package:MOOV/pages/blockedPage.dart';
import 'package:MOOV/pages/create_account.dart';
import 'package:MOOV/pages/leaderboard.dart';
import 'package:MOOV/pages/notification_feed.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/pages/passwordPage.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/studentClubs/studentClubDashboard.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final Reference storageRef = FirebaseStorage.instance.ref();
final usersRef = FirebaseFirestore.instance
    .collection('notreDame')
    .doc('data')
    .collection('users');
final postsRef = FirebaseFirestore.instance
    .collection('notreDame')
    .doc('data')
    .collection('food');
final groupsRef = FirebaseFirestore.instance
    .collection('notreDame')
    .doc('data')
    .collection('friendGroups');
final notificationFeedRef = FirebaseFirestore.instance
    .collection('notreDame')
    .doc('data')
    .collection('notificationFeed');
final chatRef = FirebaseFirestore.instance
    .collection('notreDame')
    .doc('data')
    .collection('chat');
final messagesRef = FirebaseFirestore.instance
    .collection('notreDame')
    .doc('data')
    .collection('directMessages');
final archiveRef = FirebaseFirestore.instance
    .collection('notreDame')
    .doc('data')
    .collection('postArchives');
final wrapupRef = FirebaseFirestore.instance
    .collection('notreDame')
    .doc('data')
    .collection('sundayWrapup');
final clubsRef = FirebaseFirestore.instance
    .collection('notreDame')
    .doc('data')
    .collection('clubs');
final adminRef = FirebaseFirestore.instance
    .collection('notreDame')
    .doc('data')
    .collection('admin');
final communityGroupsRef = FirebaseFirestore.instance
    .collection('notreDame')
    .doc('data')
    .collection('communityGroups');

final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isLoading = false;

  callback() {
    setState(() {});
  }

  AnimationController _hideFabAnimController;
  ScrollController scrollController;

  bool isSelected = false;
  String stringValue = "No value";
  List livePasses = [];

  bool isAuth = false;
  FirebaseMessaging _fcm = FirebaseMessaging();
  PageController pageController;
  int pageIndex = 0;
  StreamSubscription iosSubscription;
  @override
  initState() {
    super.initState();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1,
    );
    scrollController = ScrollController();

    scrollController.addListener(() {
      switch (scrollController.position.userScrollDirection) {
        // Scrolling up - forward the animation (value goes to 1)
        case ScrollDirection.forward:
          _hideFabAnimController.forward();
          break;
        // Scrolling down - reverse the animation (value goes to 0)
        case ScrollDirection.reverse:
          _hideFabAnimController.reverse();
          break;
        // Idle - keep FAB visibility unchanged
        case ScrollDirection.idle:
          break;
      }
    });

    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });

    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account == null) {
      setState(() {
        isAuth = false;
      });
    } else {
      createUserInFirestore();
    }
  }

  configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) getiOSPermission();

    _fcm.getToken().then((token) {
      print('token: $token\n');
      usersRef.doc(user.id).update({'androidNotificationToken': token});
    });

    Future<dynamic> myBackgroundMessageHandler(
        Map<String, dynamic> message) async {
      print("BG?");
      final String pushId = message['link'];
      final String page = message['page'];
      final String recipientId = message['recipient'];
      final String body = message['notification']['title'] +
          ' ' +
          message['notification']['body'];

//      FlutterAppBadger.updateBadgeCount(1);
      if (recipientId == currentUser.id) {
        String otherPerson;

        if (pushId.substring(21) == currentUser.id) {
          otherPerson = pushId.substring(0, 21);
        } else {
          otherPerson = pushId.substring(21);
        }

        print(pushId);
        Flushbar snackbar = Flushbar(
            onTap: (data) {
              // print("DATA ${data}");
              if (page == "post") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostDetail(pushId)));
              }
              if (page == "chat" && _isNumeric(pushId)) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessageDetail(
                            directMessageId: pushId,
                            otherPerson: otherPerson,
                            members: [],
                            sendingPost: {})));
              }
              if (page == "chat" && !_isNumeric(pushId)) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessageDetail(
                            isGroupChat: true,
                            gid: pushId,
                            members: [],
                            sendingPost: {})));
              }

              if (page == "user") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OtherProfile(pushId)));
              }
              if (page == "group") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupDetail(pushId)));
              }
            },
            padding: EdgeInsets.all(20),
            borderRadius: BorderRadius.circular(15),
            flushbarStyle: FlushbarStyle.FLOATING,
            boxShadows: [
              BoxShadow(
                  color: Colors.blue[800],
                  offset: Offset(0.0, 2.0),
                  blurRadius: 3.0)
            ],
            icon: Icon(
              Icons.directions_run,
              color: Colors.green,
            ),
            duration: Duration(seconds: 4),
            flushbarPosition: FlushbarPosition.TOP,
            backgroundColor: Colors.white,
            messageText: Text(body,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black)));
        // SnackBar snackybar = SnackBar(
        //     content: Text(body, overflow: TextOverflow.ellipsis),
        //     backgroundColor: Colors.green);
        // _scaffoldKey.currentState.showSnackBar(snackybar);
        snackbar.show(context);
      }
    }

    _fcm.configure(onLaunch: (Map<String, dynamic> message) async {
      print('message onlaunch: $message');

      String pushId = "";
      String page = "";
      String recipientId = "";
      String body = "";

      if (Platform.isIOS) {
        if (message.containsKey("notification")) {
          pushId = message['link'];
          page = message['page'];
          recipientId = message['recipient'];
          body = message['notification']['title'] +
              ' ' +
              message['notification']['body'];
        } else {
          pushId = message['link'];
          page = message['page'];
          recipientId = message['recipient'];
          body = message["aps"]["alert"]['title'] +
              ' ' +
              message['aps']["alert"]['body'];
        }
      } else {
        pushId = message["data"]['link'];
        page = message["data"]['page'];
        recipientId = message["data"]['recipient'];
      }
      String otherPerson;

      if (pushId.substring(21) == currentUser.id) {
        otherPerson = pushId.substring(0, 21);
      } else {
        otherPerson = pushId.substring(21);
      }

      if (page == "post") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PostDetail(pushId)));
      }
      if (page == "chat" && _isNumeric(pushId)) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MessageDetail(
                    directMessageId: pushId,
                    otherPerson: otherPerson,
                    members: [],
                    sendingPost: {})));
      }
      if (page == "chat" && !_isNumeric(pushId)) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MessageDetail(
                    isGroupChat: true,
                    gid: pushId,
                    members: [],
                    sendingPost: {})));
      }

      if (page == "user") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => OtherProfile(pushId)));
      }
      if (page == "group") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GroupDetail(pushId)));
      }
      print('Notification shown');
    }, onResume: (Map<String, dynamic> message) async {
      print('message resume: $message');
      String pushId = "";
      String page = "";
      String recipientId = "";
      String body = "";

      if (Platform.isIOS) {
        if (message.containsKey("notification")) {
          pushId = message['link'];
          page = message['page'];
          recipientId = message['recipient'];
          body = message['notification']['title'] +
              ' ' +
              message['notification']['body'];
        } else {
          pushId = message['link'];
          page = message['page'];
          recipientId = message['recipient'];
          body = message["aps"]["alert"]['title'] +
              ' ' +
              message['aps']["alert"]['body'];
        }
      } else {
        pushId = message["data"]['link'];
        page = message["data"]['page'];
        recipientId = message["data"]['recipient'];
      }

//      FlutterAppBadger.updateBadgeCount(1);
      // if (page == 'chat') {
      //   Navigator.push(context,
      //       MaterialPageRoute(builder: (context) => MessagesHub()));
      // } else if (page == 'post') {
      //   Navigator.push(context,
      //       MaterialPageRoute(builder: (context) => PostDetail(pushId)));
      // } else if (page == 'group') {
      //   Navigator.push(context,
      //       MaterialPageRoute(builder: (context) => GroupDetail(pushId)));
      // } else if (page == 'user') {
      //   Navigator.push(context,
      //       MaterialPageRoute(builder: (context) => OtherProfile(pushId)));
      // } else {
      //   Navigator.push(context,
      //       MaterialPageRoute(builder: (context) => NotificationFeed()));
      // }
//          if (recipientId == currentUser.id) {
      print('Notification shown');
      print(page);
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => PostDetail("MEB1KyztxCHY50VT29wL")));
      // print("DATA ${data}");

      String otherPerson;

      if (pushId.substring(21) == currentUser.id) {
        otherPerson = pushId.substring(0, 21);
      } else {
        otherPerson = pushId.substring(21);
      }

      if (page == "post") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PostDetail(pushId)));
      }
      if (page == "chat" && _isNumeric(pushId)) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MessageDetail(
                    directMessageId: pushId,
                    otherPerson: otherPerson,
                    members: [],
                    sendingPost: {})));
      }
      if (page == "chat" && !_isNumeric(pushId)) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MessageDetail(
                    isGroupChat: true,
                    gid: pushId,
                    members: [],
                    sendingPost: {})));
      }

      if (page == "user") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => OtherProfile(pushId)));
      }
      if (page == "group") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GroupDetail(pushId)));
      }
      //No more flushbar

//      Flushbar snackbar = Flushbar(
//          onTap: (data) {
////            page == "post" ?
//            Navigator.push(context,
//                MaterialPageRoute(builder: (context) => PostDetail(pushId)));
////                 page == "user" ?  Navigator.push(context,
////                MaterialPageRoute(builder: (context) => OtherProfile(pushId))) : page == "group" ?  Navigator.push(context,
////                MaterialPageRoute(builder: (context) => GroupDetail(pushId))) : null;
//          },
//          flushbarStyle: FlushbarStyle.FLOATING,
//          boxShadows: [
//            BoxShadow(
//                color: Colors.blue[800],
//                offset: Offset(0.0, 2.0),
//                blurRadius: 3.0)
//          ],
//          backgroundGradient:
//              LinearGradient(colors: [TextThemes.ndGold, TextThemes.ndGold]),
//          icon: Icon(
//            Icons.directions_run,
//            color: Colors.green[700],
//          ),
//          duration: Duration(seconds: 4),
//          flushbarPosition: FlushbarPosition.TOP,
//          backgroundColor: Colors.green,
//          messageText: Text(body,
//              overflow: TextOverflow.ellipsis,
//              style: TextStyle(color: Colors.white)));
//      // SnackBar snackybar = SnackBar(
//      //     content: Text(body, overflow: TextOverflow.ellipsis),
//      //     backgroundColor: Colors.green);
//      // _scaffoldKey.currentState.showSnackBar(snackybar);
//      snackbar.show(context);

      // Get.snackbar(recipientId, body, backgroundColor: Colors.green);
//          }
      print('Notification not shown :(');
    }, onMessage: (Map<String, dynamic> message) async {
      print('message onmessage: $message');

      String pushId = "";
      String page = "";
      String recipientId = "";
      String body = "";
      String name = "";

      if (message.containsKey("notification")) {
        pushId = message['link'];
        page = message['page'];
        recipientId = message['recipient'];
        body = message['notification']['title'] +
            ' ' +
            message['notification']['body'];
        name = message['notification']['title'];
      } else {
//        pushId = message['link'];
//        page = message['page'];
//        recipientId = message['recipient'];
        body = message["aps"]["alert"]['title'] +
            ' ' +
            message['aps']["alert"]['body'];
        name = message['aps']['alert']['title'];
      }
      if (body.contains("thisWillTurnIntoAStatusGoing")) {
        body = "$name is going to <moovTitle>";
      }
      if (body.contains("thisWillTurnIntoAStatusUndecided")) {
        body = "$name is undecided about <moovTitle>";
      }
      if (body.contains("thisWillTurnIntoAStatusNotGoing")) {
        body = "$name is not going to <moovTitle>";
      }

      usersRef.doc(user.id).update({'test': message.toString()});

      String otherPerson;

      if (pushId.substring(21) == currentUser.id) {
        otherPerson = pushId.substring(0, 21);
      } else {
        otherPerson = pushId.substring(21);
      }

      Flushbar snackbar = Flushbar(
          onTap: (data) {
            // print("DATA ${data}");
            if (page == "post") {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PostDetail(pushId)));
            }
            if (page == "chat" && _isNumeric(pushId)) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MessageDetail(
                          directMessageId: pushId,
                          otherPerson: otherPerson,
                          members: [],
                          sendingPost: {})));
            }
            if (page == "chat" && !_isNumeric(pushId)) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MessageDetail(
                          isGroupChat: true,
                          gid: pushId,
                          members: [],
                          sendingPost: {})));
            }

            if (page == "user") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OtherProfile(pushId)));
            }
            if (page == "group") {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GroupDetail(pushId)));
            }
          },
          padding: EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(15),
          flushbarStyle: FlushbarStyle.FLOATING,
          boxShadows: [
            BoxShadow(
                color: Colors.blue[800],
                offset: Offset(0.0, 2.0),
                blurRadius: 3.0)
          ],
          icon: Icon(
            Icons.directions_run,
            color: Colors.green,
          ),
          duration: Duration(seconds: 4),
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: Colors.white,
          messageText: //send moov in chat
              Text(body,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black)));

      snackbar.show(context);

      usersRef.doc(user.id).update({'snackbar': message.toString()});

      print('Notification not shown :(');
    });
  }

  getiOSPermission() {
    _fcm.requestNotificationPermissions(IosNotificationSettings());
    _fcm.onIosSettingsRegistered.listen((settings) {
      print('settings: $settings');
    });
  }

  createUserInFirestore() async {
    setState(() {
      isLoading = true;
    });
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;

    DocumentSnapshot doc = await usersRef.doc(user.id).get();

    DocumentSnapshot adminDoc = await adminRef.doc('login').get();
    bool blocked = false;
    bool locked = true;

    if (!doc.exists) {
      // checking if a business or nd.edu address or staff
      List whiteList =
          adminDoc.data()['whiteList']; //businesses can get through screening
      List blackList = adminDoc.data()['blackList']; // staff/faculty blocked

      if (blackList.contains(user.email)) {
        blocked = true;
        print("staff/faculty. get fucked");
      }
      if (!user.email.contains('@nd.edu') && !whiteList.contains(user.email)) {
        blocked = true;
        print("not a student or a business. get fucked");
      }

      if (whiteList.contains(user.email)) {
        locked = false;
      }

      if (locked) {
        print("H");
        final result = await Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(pageBuilder: (_, __, ___) => PasswordPage()),
          (Route<dynamic> route) => false,
        );
      }
      if (blocked) {
        final result = await Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(pageBuilder: (_, __, ___) => BlockedPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        final result = await Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(pageBuilder: (_, __, ___) => CreateAccountNew()),
          (Route<dynamic> route) => false,
        );

        doc = await usersRef.doc(user.id).get();
      }
    }
    currentUser = User.fromDocument(doc);

    setState(() {
      isAuth = true;
    });
    configurePushNotifications();
  }

  int currentIndex = 0;

  bool _isNumeric(String result) {
    if (result == null) {
      return false;
    }
    return double.tryParse(result) != null;
  }

  @override
  void dispose() {
    pageController.dispose();
    _hideFabAnimController.dispose();
    scrollController.dispose();

    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  login() {
    HapticFeedback.lightImpact();
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.jumpToPage(pageIndex);
    setState(() {
      currentIndex = pageIndex;
    });
  }

//// i think this may be a solution to the cache/memory problem?? ////
  // void _checkMemory() {
  //   ImageCache _imageCache = PaintingBinding.instance.imageCache;
  //   if (_imageCache.liveImageCount >= 2) {
  //           print(_imageCache.currentSizeBytes);

  //     print(_imageCache.maximumSizeBytes);
  //     _imageCache.clear();
  //     _imageCache.clearLiveImages();
  //   }
  // }
  ////       /////

  Scaffold buildAuthScreen() {
    // Future<String> randomPostMaker() async {
    //   String randomPost;
    //   print(randomAlpha(1));

    //   final QuerySnapshot result = await postsRef
    //       .where("postId", isGreaterThanOrEqualTo: randomAlpha(1))
    //       .where("privacy", isEqualTo: "Public")
    //       .orderBy("postId")
    //       .limit(1)
    //       .get();
    //   if (result.docs != null && result.docs.first['privacy'] == "Public")
    //     randomPost = await result.docs.first['postId'];
    //   print(result.docs.first['privacy']);
    //   return randomPost;
    // }

    // locationCheckIn(context, callback);

    //ask Tonights Vibe
    // final today = DateTime.now().day;
    // int day = SPHelper.getInt("Day");

    // if (day != today && !currentUser.isBusiness) {
    //has not set Tonights Vibe

    // return tonightsVibe(today);
    // } else {
    //vibe has been set. lets roll.

    // _checkMemory();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FutureBuilder(
          future: usersRef.doc(currentUser.id).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Container();
            }
            int moovMoneyBalance = snapshot.data['moovMoney'];
            if (snapshot.data.data()['livePasses'] != null) {
              livePasses = snapshot.data['livePasses'];
            }

            return Scaffold(
              floatingActionButton: FutureBuilder(
                  future: usersRef
                      .doc(currentUser.id)
                      .collection('livePasses')
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Container();
                    }
                    List livePasses = snapshot.data.docs;
                    return FabRow(livePasses);
                  }),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              appBar: AppBar(
                leadingWidth: 115,
                leading: Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        padding: EdgeInsets.only(left: 9.0),
                        icon: Row(
                          children: [
                            Icon(Icons.monetization_on_outlined),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(moovMoneyBalance.toString(),
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        color: Colors.white,
                        splashColor: Colors.transparent,
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      MoovMoneyAdd(0, moovMoneyBalance)));
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.insert_chart_outlined),
                      color: Colors.white,
                      splashColor: Colors.transparent,
                      onPressed: () async {
                        // Implement navigation to leaderboard page here...
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LeaderBoardPage()));
                      },
                    ),
                    // Expanded(
                    //   child: CarouselSlider(
                    //     options: CarouselOptions(
                    //       height: 400,
                    //       aspectRatio: 16 / 9,
                    //       viewportFraction: 1,
                    //       initialPage: 0,
                    //       enableInfiniteScroll: true,
                    //       scrollPhysics: NeverScrollableScrollPhysics(),
                    //       pauseAutoPlayOnTouch: false,
                    //       reverse: false,
                    //       autoPlay: false,
                    //       autoPlayInterval: Duration(seconds: 4),
                    //       autoPlayAnimationDuration: Duration(milliseconds: 800),
                    //       autoPlayCurve: Curves.fastOutSlowIn,
                    //       enlargeCenterPage: true,
                    //       // onPageChanged: callbackFunction,
                    //       scrollDirection: Axis.horizontal,
                    //     ),
                    //     items: [
                    //       IconButton(
                    //         padding: EdgeInsets.only(left: 5.0),
                    //         icon: Icon(Icons.insert_chart_outlined),
                    //         color: Colors.white,
                    //         splashColor: Color.fromRGBO(220, 180, 57, 1.0),
                    //         onPressed: () async {
                    //           // Implement navigation to leaderboard page here...
                    //           Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                   builder: (context) => LeaderBoardPage()));
                    //         },
                    //       ),
                    //       // GestureDetector(
                    //       //   onTap: () async {
                    //       //     var randomPost = await randomPostMaker();
                    //       //     Navigator.push(
                    //       //         context,
                    //       //         MaterialPageRoute(
                    //       //             builder: (context) => PostDetail(randomPost)));
                    //       //   },
                    //       //   child: Container(
                    //       //     margin: const EdgeInsets.all(7.0),
                    //       //     padding: const EdgeInsets.all(7.0),
                    //       //     decoration: BoxDecoration(
                    //       //         border: Border.all(color: Colors.white),
                    //       //         borderRadius: BorderRadius.circular(7)),
                    //       //     child: Text(
                    //       //       "Surprise",
                    //       //       style: TextStyle(fontSize: 14.0, color: Colors.white),
                    //       //     ),
                    //       //   ),
                    //       // ),
                    //       // FocusedMenuHolder(
                    //       //   menuWidth: MediaQuery.of(context).size.width * .95,

                    //       //   blurSize: 5.0,
                    //       //   menuItemExtent: 200,
                    //       //   menuBoxDecoration: BoxDecoration(
                    //       //       color: Colors.grey,
                    //       //       borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    //       //   duration: Duration(milliseconds: 100),
                    //       //   animateMenuItems: true,
                    //       //   blurBackgroundColor: Colors.black54,
                    //       //   openWithTap:
                    //       //       true, // Open Focused-Menu on Tap rather than Long Press
                    //       //   menuOffset:
                    //       //       10.0, // Offset value to show menuItem from the selected item
                    //       //   bottomOffsetHeight:
                    //       //       80.0, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
                    //       //   menuItems: <FocusedMenuItem>[
                    //       //     // Add Each FocusedMenuItem  for Menu Options

                    //       //     FocusedMenuItem(
                    //       //         title: Center(
                    //       //             child: Text(
                    //       //           "     Lowkey / Chill",
                    //       //           style: GoogleFonts.robotoSlab(fontSize: 40),
                    //       //         )),
                    //       //         // trailingIcon: Icon(Icons.edit),
                    //       //         onPressed: () {
                    //       //           navigateToCategoryFeed(context, "Shows");
                    //       //         }),
                    //       //     FocusedMenuItem(
                    //       //         backgroundColor: Colors.red[50],
                    //       //         title: Text("          Rage",
                    //       //             style: GoogleFonts.yeonSung(
                    //       //                 fontSize: 50, color: Colors.red)),
                    //       //         onPressed: () {
                    //       //           navigateToCategoryFeed(context, "Parties");
                    //       //         }),
                    //       //   ],
                    //       //   onPressed: () {},
                    //       //   child: Container(
                    //       //     margin: const EdgeInsets.all(7.0),
                    //       //     padding: const EdgeInsets.all(7.0),
                    //       //     decoration: BoxDecoration(
                    //       //         border: Border.all(color: Colors.white),
                    //       //         borderRadius: BorderRadius.circular(7)),
                    //       //     child: Text(
                    //       //       "Mood",
                    //       //       style: TextStyle(fontSize: 14.0, color: Colors.white),
                    //       //     ),
                    //       //   ),
                    //       // ),
                    //     ].map((i) {
                    //       return Builder(
                    //         builder: (BuildContext context) {
                    //           return Container(
                    //               width: MediaQuery.of(context).size.width * 3,
                    //               margin: EdgeInsets.symmetric(horizontal: 5.0),
                    //               decoration: BoxDecoration(),
                    //               child: Center(
                    //                 child: i,
                    //               ));
                    //         },
                    //       );
                    //     }).toList(),
                    //   ),
                    // ),
                  ],
                ),
                backgroundColor: TextThemes.ndBlue,
                actions: <Widget>[
                  NamedIconMessages(
                      iconData: Icons.mail_outline,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MessageList()));
                      }),
                  NamedIcon(
                      iconData: Icons.notifications_active_outlined,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationFeed()));
                        Database().setNotifsSeen();
                      }),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.all(5),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {},
                        child: Bounce(
                          duration: Duration(milliseconds: 50),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => Home()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Image.asset(
                            'lib/assets/moovblue.png',
                            fit: BoxFit.cover,
                            height: 50.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              body: PageView(
                physics: NeverScrollableScrollPhysics(),
                children: currentUser.userType.containsKey("clubExecutive")
                    ? <Widget>[
                        HomePage(),
                        SearchBar(),
                        StudentClubDashboard(),
                        MOOVSPage(),
                        ProfilePage()
                      ]
                    : currentUser.isBusiness
                        ? <Widget>[
                            HomePage(),
                            BusinessDirectory(),
                            ProfilePage()
                          ]
                        : <Widget>[
                            HomePage(),
                            SearchBar(),
                            MOOVSPage(),
                            ProfilePage()
                          ],
                controller: pageController,
                onPageChanged: onPageChanged,
              ),
              bottomNavigationBar:
                  currentUser.userType.containsKey("clubExecutive")
                      ? CupertinoTabBar(
                          inactiveColor: Colors.black,
                          currentIndex: currentIndex,
                          onTap: onTap,
                          activeColor: TextThemes.ndGold,
                          items: [
                              BottomNavigationBarItem(
                                  icon: Icon(Icons.home_outlined)),
                              BottomNavigationBarItem(
                                  icon: Icon(Icons.search_outlined)),
                              BottomNavigationBarItem(
                                  icon: Icon(Icons.corporate_fare)),
                              BottomNavigationBarItem(
                                  icon: Icon(Icons.group_outlined)),
                              BottomNavigationBarItem(
                                  icon: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: pageIndex == 3
                                          ? TextThemes.ndGold
                                          : Colors.black,
                                      child: currentUser.photoUrl != null
                                          ? CircleAvatar(
                                              radius: 14,
                                              backgroundImage: NetworkImage(
                                                  currentUser.photoUrl))
                                          : CircleAvatar(
                                              radius: 14,
                                              backgroundImage: AssetImage(
                                                  'lib/assets/incognitoPic.jpg')))
                                  // CircleAvatar(
                                  //   backgroundImage: NetworkImage(currentUser.photoUrl),
                                  //   radius: 13)
                                  ),
                            ])
                      : currentUser.isBusiness
                          ? CupertinoTabBar(
                              inactiveColor: Colors.black,
                              currentIndex: currentIndex,
                              onTap: onTap,
                              activeColor: TextThemes.ndGold,
                              items: [
                                  BottomNavigationBarItem(
                                      icon: Icon(Icons.home_outlined)),
                                  BottomNavigationBarItem(
                                      icon: Icon(Icons.business)),
                                  BottomNavigationBarItem(
                                      icon: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: pageIndex == 3
                                              ? TextThemes.ndGold
                                              : Colors.black,
                                          child: currentUser.photoUrl != null
                                              ? CircleAvatar(
                                                  radius: 14,
                                                  backgroundImage: NetworkImage(
                                                      currentUser.photoUrl))
                                              : CircleAvatar(
                                                  radius: 14,
                                                  backgroundImage: AssetImage(
                                                      'lib/assets/incognitoPic.jpg')))
                                      // CircleAvatar(
                                      //   backgroundImage: NetworkImage(currentUser.photoUrl),
                                      //   radius: 13)
                                      ),
                                ])
                          : CupertinoTabBar(
                              inactiveColor: Colors.black,
                              currentIndex: currentIndex,
                              onTap: onTap,
                              activeColor: TextThemes.ndGold,
                              items: [
                                  BottomNavigationBarItem(
                                      icon: Icon(Icons.home_outlined)),
                                  BottomNavigationBarItem(
                                      icon: Icon(Icons.search_outlined)),
                                  BottomNavigationBarItem(
                                      icon: Icon(Icons.group_outlined)),
                                  BottomNavigationBarItem(
                                      icon: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: pageIndex == 3
                                              ? TextThemes.ndGold
                                              : Colors.black,
                                          child: currentUser.photoUrl != null
                                              ? CircleAvatar(
                                                  radius: 14,
                                                  backgroundImage: NetworkImage(
                                                      currentUser.photoUrl))
                                              : CircleAvatar(
                                                  radius: 14,
                                                  backgroundImage: AssetImage(
                                                      'lib/assets/incognitoPic.jpg')))),
                                ]),
            );
          }),
    );
    // }
  }

  Scaffold buildUnAuthScreen() {
    bool isTablet = false;
    if (Device.get().isTablet) {
      isTablet = true;
    }
    return (isLoading)
        ? Scaffold(
            backgroundColor: TextThemes.ndBlue,
            body: Center(
              child: Image.asset(
                'lib/assets/runningGif.gif',
                height: 200,
              ),
            ))
        : Scaffold(
            body: Container(
            color: TextThemes.ndBlue,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height:
                      isTablet ? MediaQuery.of(context).size.height * .7 : null,
                  child: Image.asset(
                    'lib/assets/landingpage.png',
                    scale: .5,
                  ),
                ),
                GestureDetector(
                  onTap: login,
                  child: Container(
                    height: 50.0,
                    width: 300.0,
                    decoration: BoxDecoration(
                      color: TextThemes.ndGold,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Sign in",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ));
  }

  @override
  Widget build(BuildContext context) {
    return (isAuth == true) ? buildAuthScreen() : buildUnAuthScreen();
  }
}

class NamedIconMessages extends StatelessWidget {
  final IconData iconData;
  final int messages;
  final VoidCallback onTap;
  final int messageCount;

  NamedIconMessages({
    Key key,
    this.onTap,
    this.messages,
    @required this.iconData,
    this.messageCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount user = googleSignIn.currentUser;

    return StreamBuilder(
        stream: messagesRef
            .where("receiver", isEqualTo: currentUser.id)
            .where('seen', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          int notifs = snapshot.data.docs.length;

          return InkWell(
            splashColor: Colors.transparent,
            onTap: onTap,
            child: Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(iconData, color: Colors.white),
                  notifs != 0
                      ? Positioned(
                          top: 8,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            alignment: Alignment.center,
                            child: Text("$notifs",
                                style: TextStyle(color: Colors.white)),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          );
        });
  }
}

class NamedIcon extends StatelessWidget {
  final IconData iconData;
  final int notifs;
  final VoidCallback onTap;
  final int notificationCount;

  NamedIcon({
    Key key,
    this.onTap,
    this.notifs,
    @required this.iconData,
    this.notificationCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GoogleSignInAccount user = googleSignIn.currentUser;

    return StreamBuilder(
        stream: notificationFeedRef
            .doc(user.id)
            .collection('feedItems')
            .where('seen', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          int notifs = snapshot.data.docs.length;

          return InkWell(
            onTap: onTap,
            child: Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(iconData, color: Colors.white),
                  notifs != 0
                      ? Positioned(
                          top: 8,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            alignment: Alignment.center,
                            child: Text("$notifs",
                                style: TextStyle(color: Colors.white)),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          );
        });
  }
}

class FabRow extends StatefulWidget {
  final List livePasses;
  FabRow(this.livePasses);

  @override
  _FabRowState createState() => _FabRowState();
}

class _FabRowState extends State<FabRow> {
  bool showFab = true;
  @override
  Widget build(BuildContext context) {
    return (showFab)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.livePasses.isNotEmpty
                  ? FloatingActionButton.extended(
                      heroTag: "passBtn",
                      backgroundColor: Colors.green,
                      onPressed: () {
                        // for (int i = 0; i < widget.livePasses.length; i++) {
                        //   if (widget.livePasses[i]['tip'] > 0)
                        // }
                        //     Navigator.push(
                        // context,
                        // MaterialPageRoute(
                        //     builder: (context) => LivePassesWalletSheet()));
                        HapticFeedback.lightImpact();

                        var bottomSheetController = showBottomSheet(
                            context: context,
                            // backgroundColor: Colors.green,

                            builder: (context) =>
                                LivePassesWalletSheet(widget.livePasses));
                        showFoatingActionButton(false);
                        bottomSheetController.closed.then((value) {
                          showFoatingActionButton(true);
                        });
                      },
                      label: Row(
                        children: [
                          Text("LIVE PASSES ",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                          Icon(Icons.confirmation_num, color: Colors.white),
                        ],
                      ))
                  : Container(height: 1),
              FloatingActionButton.extended(
                  heroTag: "postBtn",
                  onPressed: () {
                    HapticFeedback.lightImpact();

                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.topToBottom,
                            child: MoovMaker(fromPostDeal: false)));
                  },
                  label: Row(
                    children: [
                      Text("Post ",
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                      Icon(Icons.directions_run, color: Colors.white),
                    ],
                  )),
            ],
          )
        : Container();
  }

  void showFoatingActionButton(bool value) {
    setState(() {
      showFab = value;
    });
  }
}
