import 'dart:async';
import 'dart:math';
import 'package:MOOV/helpers/size_config.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/MessagesHub.dart';
import 'package:MOOV/pages/ProfilePageWithHeader.dart';
import 'package:MOOV/pages/other_profile.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/poll2.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MOOV/pages/home.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class Chat extends StatefulWidget {
  final String gid, directMessageId, otherPerson;
  final bool isGroupChat;
  final List<dynamic> members;
  Map<String, String> sendingPost;

  Chat(
      {this.gid,
      this.isGroupChat,
      this.directMessageId,
      this.otherPerson,
      this.members,
      this.sendingPost});

  @override
  ChatState createState() => ChatState(
      gid: this.gid,
      isGroupChat: this.isGroupChat,
      directMessageId: this.directMessageId,
      otherPerson: this.otherPerson,
      members: this.members);
}

class ChatState extends State<Chat> {
  rebuild() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => MessageDetail(
              directMessageId: directMessageId,
              otherPerson: otherPerson,
              isGroupChat: false,
              members: [],
              sendingPost: {}),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    });
  }

  TextEditingController commentController = TextEditingController();
  final String gid, otherPerson;
  String directMessageId;
  final List<dynamic> members;
  final bool isGroupChat;
  final _scrollController = ScrollController();
  bool messages = false;

  ChatState(
      {this.gid,
      this.isGroupChat,
      this.directMessageId,
      this.otherPerson,
      this.members});

  adjustChat() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  buildChat() {
    CollectionReference reference = isGroupChat
        ? messagesRef.doc(gid).collection('chat')
        : messagesRef.doc(directMessageId).collection('chat');
    reference.snapshots().listen((querySnapshot) {
      querySnapshot.docChanges.forEach((change) {
        if (querySnapshot.docs.isNotEmpty) {
          Timer(Duration(milliseconds: 200), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  curve: Curves.easeIn,
                  duration: Duration(milliseconds: 300));
            }
          });
        }
      });
    });
    return StreamBuilder(
        stream: isGroupChat
            ? messagesRef
                .doc(gid)
                .collection('chat')
                // .orderBy("timestamp", descending: false)
                .snapshots()
            : messagesRef.doc(directMessageId).collection('chat').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Loading..."),
                  SizedBox(
                    height: 50.0,
                  ),
                  CircularProgressIndicator()
                ],
              ),
            );
          } else {
            List<Comment> chat = [];
            snapshot.data.docs.forEach((doc) {
              chat.add(Comment.fromDocument(doc));
            });
            return ListView(
              controller: _scrollController,
              children: chat,
            );
          }
        });
  }

  addComment() {
    // Map<String, dynamic> livePosts = {}; //for moovs sent in chats

    if (directMessageId == null) {
      circularProgress();
    }
    if (directMessageId == "nothing" || directMessageId == null) {
      //if this is first message in conversation, we set the message ID
      directMessageId = currentUser.id + otherPerson;
    }

    if (widget.sendingPost != null && widget.sendingPost.isNotEmpty) {
      //if someone is sending the MOOV
      isGroupChat
          ? messagesRef
              .doc(gid)
              .collection("chat")
              .doc(DateTime.now().millisecondsSinceEpoch.toString() +
                  " " +
                  currentUser.id)
              .set({
              "seen": false,
              "displayName": currentUser.displayName,
              "comment": widget.sendingPost['postId'],
              "timestamp": 0,
              "avatarUrl": currentUser.photoUrl,
              "userId": currentUser.id,
              "chatId": DateTime.now().millisecondsSinceEpoch.toString() +
                  " " +
                  currentUser.id,
              "gid": gid,
              "millis": DateTime.now().millisecondsSinceEpoch.toString(),
              "directMessageId": "",
              "isGroupChat": true,
              "postId": widget.sendingPost['postId'],
              "isMoovInChat": true,
              "moovInChatTitle": widget.sendingPost['title'],
              "realPostId": widget.sendingPost['postId'],
              "hasExpired": false
            })
          : messagesRef
              .doc(directMessageId)
              .collection("chat")
              .doc(DateTime.now().millisecondsSinceEpoch.toString() +
                  " " +
                  currentUser.id)
              .set({
              "seen": false,
              "displayName": currentUser.displayName,
              "comment": widget.sendingPost['postId'],
              "timestamp": 0,
              "avatarUrl": currentUser.photoUrl,
              "userId": currentUser.id,
              "chatId": DateTime.now().millisecondsSinceEpoch.toString() +
                  " " +
                  currentUser.id,
              "gid": " ",
              "directMessageId": directMessageId,
              "isGroupChat": false,
              "millis": DateTime.now().millisecondsSinceEpoch.toString(),
              "postId": widget.sendingPost['postId'],
              "isMoovInChat": true,
              "moovInChatTitle": widget.sendingPost['title'],
              "realPostId": widget.sendingPost['postId'],
              "hasExpired": false
            });

      if (commentController.text.isNotEmpty) {
        //the message "Caption" sent with a MOOV accompanies a moov
        isGroupChat
            ? messagesRef
                .doc(gid)
                .collection("chat")
                .doc(DateTime.now()
                        .add(Duration(milliseconds: 1))
                        .millisecondsSinceEpoch
                        .toString() +
                    " " +
                    currentUser.id)
                .set({
                "seen": false,
                "displayName": currentUser.displayName,
                "comment": commentController.text,
                "timestamp": DateTime.now().millisecondsSinceEpoch,
                "avatarUrl": currentUser.photoUrl,
                "userId": currentUser.id,
                "chatId": DateTime.now().millisecondsSinceEpoch.toString() +
                    " " +
                    currentUser.id,
                "gid": gid,
                "millis": DateTime.now().millisecondsSinceEpoch.toString(),
                "directMessageId": "",
                "isGroupChat": true,
                "postId": null,
                "realPostId": null,
                "hasExpired": null
              })
            : messagesRef
                .doc(directMessageId)
                .collection("chat")
                .doc(DateTime.now()
                        .add(Duration(milliseconds: 1))
                        .millisecondsSinceEpoch
                        .toString() +
                    " " +
                    currentUser.id)
                .set({
                "seen": false,
                "displayName": currentUser.displayName,
                "comment": commentController.text,
                "timestamp": DateTime.now().millisecondsSinceEpoch,
                "avatarUrl": currentUser.photoUrl,
                "userId": currentUser.id,
                "chatId": DateTime.now().millisecondsSinceEpoch.toString() +
                    " " +
                    currentUser.id,
                "gid": " ",
                "directMessageId": directMessageId,
                "isGroupChat": false,
                "millis": DateTime.now().millisecondsSinceEpoch.toString(),
                "postId": null,
                "realPostId": null,
                "hasExpired": null
              });
      }

      isGroupChat
          ? messagesRef.doc(gid).set({
              "livePosts":
                  FieldValue.arrayUnion([widget.sendingPost['postId']]),
              "lastMessage": "Sent a MOOV",
              "seen": false,
              "sender": currentUser.id,
              "receiver": otherPerson,
              "timestamp": DateTime.now().millisecondsSinceEpoch,
              "gid": gid,
              "directMessageId": directMessageId,
              "people": members,
              "isGroupChat": true,
            }, SetOptions(merge: true))
          : messagesRef.doc(directMessageId).set({
              "livePosts":
                  FieldValue.arrayUnion([widget.sendingPost['postId']]),
              "lastMessage": "Sent a MOOV",
              "seen": false,
              "sender": currentUser.id,
              "receiver": otherPerson,
              "timestamp": DateTime.now().millisecondsSinceEpoch,
              "gid": "",
              "directMessageId": directMessageId,
              "people": [currentUser.id, otherPerson],
              "isGroupChat": false,
            }, SetOptions(merge: true));

      postsRef.doc(widget.sendingPost['postId']).get().then((value) {
        print(value['postId']);

        isGroupChat
            ? messagesRef
                .doc(gid)
                .collection("pullUpTimeForPosts")
                .doc(value['postId'])
                .set({
                "voters": {"0": 6},
                "choice1": DateFormat.jm()
                        .format(value['startDate']
                            .toDate()
                            .subtract(Duration(minutes: 30)))
                        .toString() +
                    " or earlier",
                "choice2": DateFormat.jm().format(value['startDate'].toDate()),
                "choice3": DateFormat.jm().format(
                    value['startDate'].toDate().add(Duration(minutes: 30))),
                "choice4": DateFormat.jm()
                        .format(value['startDate']
                            .toDate()
                            .add(Duration(minutes: 60)))
                        .toString() +
                    " or later"
              })
            : messagesRef
                .doc(directMessageId)
                .collection("pullUpTimeForPosts")
                .doc(value['postId'])
                .set({
                "voters": {"0": 6},
                "choice1": DateFormat.jm()
                        .format(value['startDate']
                            .toDate()
                            .subtract(Duration(minutes: 30)))
                        .toString() +
                    " or earlier",
                "choice2": DateFormat.jm().format(value['startDate'].toDate()),
                "choice3": DateFormat.jm().format(
                    value['startDate'].toDate().add(Duration(minutes: 30))),
                "choice4": DateFormat.jm()
                        .format(value['startDate']
                            .toDate()
                            .add(Duration(minutes: 60)))
                        .toString() +
                    " or later"
              });
      });

      setState(() {
        widget.sendingPost = null;
      });

      Timer(Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              curve: Curves.easeIn,
              duration: Duration(milliseconds: 200));
        }
      });
      commentController.clear();
    }

    if (commentController.text.isNotEmpty && widget.sendingPost.isEmpty) {
      isGroupChat
          ? messagesRef
              .doc(gid)
              .collection("chat")
              .doc(DateTime.now().millisecondsSinceEpoch.toString() +
                  " " +
                  currentUser.id)
              .set({
              "seen": false,
              "displayName": currentUser.displayName,
              "comment": commentController.text,
              "timestamp": DateTime.now().millisecondsSinceEpoch,
              "avatarUrl": currentUser.photoUrl,
              "userId": currentUser.id,
              "chatId": DateTime.now().millisecondsSinceEpoch.toString() +
                  " " +
                  currentUser.id,
              "gid": gid,
              "millis": DateTime.now().millisecondsSinceEpoch.toString(),
              "directMessageId": "",
              "isGroupChat": true,
              "postId": null,
              "realPostId": null,
              "hasExpired": null
            })
          : messagesRef
              .doc(directMessageId)
              .collection("chat")
              .doc(DateTime.now().millisecondsSinceEpoch.toString() +
                  " " +
                  currentUser.id)
              .set({
              "seen": false,
              "displayName": currentUser.displayName,
              "comment": commentController.text,
              "timestamp": DateTime.now().millisecondsSinceEpoch,
              "avatarUrl": currentUser.photoUrl,
              "userId": currentUser.id,
              "chatId": DateTime.now().millisecondsSinceEpoch.toString() +
                  " " +
                  currentUser.id,
              "gid": " ",
              "directMessageId": directMessageId,
              "isGroupChat": false,
              "millis": DateTime.now().millisecondsSinceEpoch.toString(),
              "postId": null,
              "realPostId": null,
              "hasExpired": null
            });
      isGroupChat
          ? messagesRef.doc(gid).set({
              "lastMessage": widget.sendingPost.isNotEmpty
                  ? "Sent a MOOV"
                  : commentController.text,
              "seen": false,
              "sender": currentUser.id,
              "receiver": otherPerson,
              "timestamp": DateTime.now().millisecondsSinceEpoch,
              "gid": gid,
              "directMessageId": directMessageId,
              "people": members,
              "isGroupChat": true,
            }, SetOptions(merge: true))
          : messagesRef.doc(directMessageId).set({
              "lastMessage": widget.sendingPost.isNotEmpty
                  ? "Sent a MOOV"
                  : commentController.text,
              "seen": false,
              "sender": currentUser.id,
              "receiver": otherPerson,
              "timestamp": DateTime.now().millisecondsSinceEpoch,
              "gid": "",
              "directMessageId": directMessageId,
              "people": [currentUser.id, otherPerson],
              "isGroupChat": false,
            }, SetOptions(merge: true));
      Timer(Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              curve: Curves.easeIn,
              duration: Duration(milliseconds: 200));
        }
      });
      commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    Timer(Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
    return Container(
      height: isLargePhone ? 500 : 370,
      child: Column(
        children: <Widget>[
          Expanded(child: buildChat()),
          Divider(),
          widget.sendingPost != null && widget.sendingPost.isNotEmpty
              ? ChatMOOV(
                  postId: widget.sendingPost['postId'],
                  pic: widget.sendingPost['pic'],
                  title: widget.sendingPost['title'],
                  messageId: isGroupChat ? gid : directMessageId,
                )
              : Container(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: "Talk to 'em..."),
            ),
            trailing: OutlineButton(
                onPressed: () {
                  // if (isGroupChat == false) {
                  //   directMessageId = currentUser.id + otherPerson;
                  //   Timer(
                  //       Duration(milliseconds: 200),
                  //       () => messagesRef.doc(directMessageId).set({
                  //             "lastMessage": commentController.text,
                  //             "seen": false,
                  //             "sender": currentUser.id,
                  //             "receiver": otherPerson,
                  //             "timestamp": timestamp,
                  //             "directMessageId": directMessageId,
                  //             "people": [currentUser.id, otherPerson]
                  //           }));
                  // }

                  isGroupChat
                      ? null
                      : messagesRef
                          .doc(directMessageId)
                          .collection("chat")
                          .get()
                          .then((doc) {
                          if (doc.docs.length <= 1) {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        MessageDetail(
                                            directMessageId: directMessageId,
                                            otherPerson: otherPerson,
                                            members: [],
                                            sendingPost: {}),
                                transitionDuration: Duration(seconds: 0),
                              ),
                            );
                          }
                        });

                  addComment();
                  // adjustChat();
                },
                borderSide: BorderSide.none,
                child: Text("Send", style: TextStyle(color: Colors.blue))),
          ),
        ],
      ),
    );
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }
}

class Comment extends StatefulWidget {
  final String displayName;
  final String userId;
  final String avatarUrl;
  final String comment;
  final int timestamp;
  final String chatId;
  final String gid;
  final String millis;
  final String directMessageId, postId, realPostId;
  final bool isGroupChat, hasExpired;

  Comment(
      {this.displayName,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.timestamp,
      this.chatId,
      this.gid,
      this.millis,
      this.directMessageId,
      this.isGroupChat,
      this.postId,
      this.realPostId,
      this.hasExpired});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      displayName: doc['displayName'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
      chatId: doc['chatId'],
      gid: doc['gid'],
      millis: doc['millis'],
      directMessageId: doc['directMessageId'],
      isGroupChat: doc['isGroupChat'],
      postId: doc['postId'],
      realPostId: doc['realPostId'],
      hasExpired: doc['hasExpired'],
    );
  }

  @override
  _CommentState createState() => _CommentState(
      this.displayName,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.timestamp,
      this.chatId,
      this.gid,
      this.millis,
      this.directMessageId,
      this.isGroupChat,
      this.postId,
      this.realPostId,
      this.hasExpired);
}

class _CommentState extends State<Comment> {
  final String displayName;
  final String userId;
  final String avatarUrl;
  final String comment;
  final int timestamp;
  final String chatId;
  final String gid;
  final String millis, postId;
  String directMessageId, realPostId;
  final bool isGroupChat, hasExpired;

  _CommentState(
      this.displayName,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.timestamp,
      this.chatId,
      this.gid,
      this.millis,
      this.directMessageId,
      this.isGroupChat,
      this.postId,
      this.realPostId,
      this.hasExpired);

  final Map<String, dynamic> chatPostResponses = {};

  @override
  Widget build(BuildContext context) {
    var now = new DateTime.now();
    var format = new DateFormat('').add_jm();
    var format2 = new DateFormat('EEE').add_jm();

    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    String timeAgo = '';

    timeAgo = format.format(date);

    if (1440 <= diff.inMinutes && diff.inMinutes <= 2880) {
      timeAgo = format2.format(date);
    }

    bool middleFinger = false;
    int status = -1;
    // List reactionValues = reactions.values.toList();
    // if (reactions.isNotEmpty && reactionValues[0] == 0) {
    //   middleFinger = true;
    // }
    if (timestamp == 0) {
      timeAgo = "";
    }

    String chatStatus = "";
    String title = "";

    if (postId != null) {
      postId.contains("goingxxx")
          ? chatStatus = " is GOING to"
          : postId.contains("undecidedxxx")
              ? chatStatus = " is UNDECIDED on"
              : postId.contains("notxxx")
                  ? chatStatus = " is NOT GOING to"
                  : chatStatus = "";
      title = postId
          .replaceAll("goingxxx", "")
          .replaceAll("undecidedxxx", "")
          .replaceAll("notxxx", "");
    }

    return Column(
      children: <Widget>[
        Container(
          child: postId != null &&
                  (postId.contains("goingxxx") ||
                      postId.contains("undecidedxxx") ||
                      postId.contains("notxxx"))
              ? Column(children: [
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(text: "——— "),
                          TextSpan(
                            text: displayName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text: chatStatus,
                              style: TextStyle(
                                  color: chatStatus == " is GOING to"
                                      ? Colors.green[600]
                                      : chatStatus == " is UNDECIDED on"
                                          ? Colors.yellow[600]
                                          : Colors.red[600],
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: title,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextSpan(text: " ———"),
                        ]),
                  ),
                  isGroupChat
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: !hasExpired
                              ? ExpandablePanel(
                                  collapsed: null,
                                  // controller: _expandableController,
                                  theme: const ExpandableThemeData(
                                    useInkWell: false,
                                    hasIcon: false,
                                    tapHeaderToExpand: true,
                                    headerAlignment:
                                        ExpandablePanelHeaderAlignment.center,
                                    tapBodyToCollapse: true,
                                  ),
                                  header: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 3),
                                      child: Text(
                                        "View all statuses",
                                        style: TextStyle(
                                            color: Colors.blue, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  expanded: ChatStatuses(realPostId, gid))
                              : Container())
                      : Container()
                ])
              : Container(
                  child: (userId != currentUser.id)
                      ? Container(
                          child: realPostId != null &&
                                  !postId.contains("goingxxx") &&
                                  !postId.contains("undecidedxxx") &&
                                  !postId.contains("notxxx") &&
                                  !hasExpired
                              ? FutureBuilder(
                                  future: postsRef.doc(realPostId).get(),
                                  builder: (context, snapshot3) {
                                    if (!snapshot3.hasData ||
                                        snapshot3.data == null) {
                                      Container();
                                    }
                                    if (snapshot3.connectionState !=
                                        ConnectionState.done) {
                                      return circularProgress();
                                    }

                                    return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0, right: 8),
                                            child: CircleAvatar(
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      avatarUrl),
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              ChatMOOV(
                                                  postId: postId,
                                                  pic:
                                                      snapshot3.data['image'] ??
                                                          "",
                                                  title:
                                                      snapshot3.data['title'] ??
                                                          "",
                                                  messageId: isGroupChat
                                                      ? gid
                                                      : directMessageId),
                                              timeAgo == ""
                                                  ? Container()
                                                  : Text(
                                                      timeAgo,
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    ),
                                            ],
                                          ),
                                        ]);
                                  })
                              : postId != null && //MOOV expired or deleted
                                      !postId.contains("goingxxx") &&
                                      !postId.contains("undecidedxxx") &&
                                      !postId.contains("notxxx") &&
                                      hasExpired
                                  ? FutureBuilder(
                                      future: archiveRef.doc(postId).get(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData ||
                                            snapshot.data == null) {
                                          Container();
                                        }
                                        if (snapshot.connectionState !=
                                            ConnectionState.done) {
                                          return circularProgress();
                                        }
                                        return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  ChatMOOV(
                                                      postId: realPostId,
                                                      pic: snapshot
                                                              .data['image'] ??
                                                          "",
                                                      title: snapshot
                                                          .data['title'],
                                                      hasButtons: false,
                                                      messageId: isGroupChat
                                                          ? gid
                                                          : directMessageId),
                                                  timeAgo == ""
                                                      ? Container()
                                                      : Text(
                                                          timeAgo,
                                                          style: TextStyle(
                                                              fontSize: 10),
                                                        ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12.0, right: 8),
                                                child: CircleAvatar(
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                          avatarUrl),
                                                ),
                                              ),
                                            ]);
                                      })
                                  : ListTile(
                                      title: ChatBubble(
                                          alignment: Alignment.centerLeft,
                                          clipper: ChatBubbleClipper5(
                                              type: BubbleType.receiverBubble),
                                          backGroundColor: Colors.grey[200],
                                          margin: EdgeInsets.only(top: 5),
                                          child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                              ),
                                              child: Text(comment))),
                                      // :
                                      // FlutterReactionButtonCheck(
                                      //     onReactionChanged: (reaction, index, isChecked) {
                                      //       // FLIPPED OFF NOTIF HERE
                                      //       // if (reactionValues[0] == 0) {
                                      //       //   setState(() {
                                      //       //     middleFinger = false;
                                      //       //   });
                                      //       // } else
                                      //       //  if (reactionValues[0] == 1) {
                                      //       //   setState(() {
                                      //       //     middleFinger = false;
                                      //       //   });
                                      //       // }
                                      //       // // } else {
                                      //       // //   setState(() {
                                      //       // //     reactionValues[0] = -1;
                                      //       // //   });
                                      //       // // }
                                      //       // Database().chatReaction(currentUser.id,
                                      //       //     directMessageId, chatId, index, false);
                                      //       // setState(() {
                                      //       //   middleFinger = !middleFinger;
                                      //       // });

                                      //       // print(reactionValues[0]);
                                      //       // print(middleFinger);
                                      //     },
                                      //     reactions: [
                                      //         Reaction(
                                      //             previewIcon: Padding(
                                      //                 padding: const EdgeInsets.only(
                                      //                     right: 8.0, top: 6, bottom: 6, left: 8),
                                      //                 child: Text("Coming soon")),
                                      //             // previewIcon: Padding(
                                      //             //   padding: const EdgeInsets.only(
                                      //             //       right: 8.0, top: 4, bottom: 6),
                                      //             //   child: Image.asset(
                                      //             //     'lib/assets/middleFinger.gif',
                                      //             //     height: 40,
                                      //             //   ),
                                      //             // ),
                                      //             // title: Text("Flip 'em off"),
                                      //             icon: Stack(children: [
                                      //               ChatBubble(
                                      //                   alignment: Alignment.centerLeft,
                                      //                   clipper: ChatBubbleClipper5(
                                      //                       type: BubbleType.receiverBubble),
                                      //                   backGroundColor: Colors.grey[200],
                                      //                   margin: EdgeInsets.only(top: 5),
                                      //                   child: Container(
                                      //                       constraints: BoxConstraints(
                                      //                         maxWidth: MediaQuery.of(context)
                                      //                                 .size
                                      //                                 .width *
                                      //                             0.7,
                                      //                       ),
                                      //                       child: Text(comment))),
                                      //               Positioned(
                                      //                   left: comment.length < 25
                                      //                       ? comment.length.toDouble() * 8
                                      //                       : comment.length < 40
                                      //                           ? comment.length.toDouble() * 6
                                      //                           : 220,
                                      //                   child: middleFinger
                                      //                       ? Image.asset(
                                      //                           'lib/assets/middleFinger.gif',
                                      //                           height: 40,
                                      //                         )
                                      //                       : Container())
                                      //             ])
                                      //             ),
                                      //         // Reaction(
                                      //         //     // previewIcon: Padding(
                                      //         //     //   padding: const EdgeInsets.only(
                                      //         //     //       right: 8.0, top: 4, bottom: 6),
                                      //         //     //   child: Image.asset(
                                      //         //     //     'lib/assets/chens.jpg',
                                      //         //     //     height: 40,
                                      //         //     //   ),
                                      //         //     // ),
                                      //         //     // title: Text("Flip 'em off"),
                                      //         //     icon: Stack(children: [
                                      //         //       ChatBubble(
                                      //         //           alignment: Alignment.centerLeft,
                                      //         //           clipper: ChatBubbleClipper5(
                                      //         //               type: BubbleType.receiverBubble),
                                      //         //           backGroundColor: Colors.grey[200],
                                      //         //           margin: EdgeInsets.only(top: 5),
                                      //         //           child: Container(
                                      //         //               constraints: BoxConstraints(
                                      //         //                 maxWidth: MediaQuery.of(context)
                                      //         //                         .size
                                      //         //                         .width *
                                      //         //                     0.7,
                                      //         //               ),
                                      //         //               child: Text(comment))),
                                      //         //       Positioned(
                                      //         //           left: comment.length < 25
                                      //         //               ? comment.length.toDouble() * 8
                                      //         //               : comment.length < 40
                                      //         //                   ? comment.length.toDouble() * 6
                                      //         //                   : 220,
                                      //         //           child: middleFinger
                                      //         //               ? Image.asset(
                                      //         //                   'lib/assets/middleFinger.gif',
                                      //         //                   height: 40,
                                      //         //                 )
                                      //         //               : Container())
                                      //         //     ])),
                                      //       ]),
                                      leading: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: CircleAvatar(
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  avatarUrl),
                                        ),
                                      ),
                                      subtitle: timeAgo == ""
                                          ? Container()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                timeAgo,
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ),
                                      trailing: Text(''),
                                    ),
                        )
                      : Container(
                          child: postId != null &&
                                  !postId.contains("going") &&
                                  !postId.contains("undecided") &&
                                  !postId.contains("notGoing") &&
                                  !hasExpired
                              ? FutureBuilder(
                                  future: postsRef.doc(postId).get(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return circularProgress();
                                    }
                                    if (snapshot.connectionState !=
                                        ConnectionState.done) {
                                      return circularProgress();
                                    }
                                    return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              ChatMOOV(
                                                  postId: postId,
                                                  pic: snapshot.data['image'] ??
                                                      "",
                                                  title: snapshot.data['title'],
                                                  messageId: isGroupChat
                                                      ? gid
                                                      : directMessageId),
                                              timeAgo == ""
                                                  ? Container()
                                                  : Text(
                                                      timeAgo,
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 12.0, left: 8),
                                            child: CircleAvatar(
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      avatarUrl),
                                            ),
                                          ),
                                        ]);
                                  })
                              : postId != null &&
                                      !postId.contains("going") &&
                                      !postId.contains("undecided") &&
                                      !postId.contains("notGoing") &&
                                      hasExpired
                                  ? FutureBuilder(
                                      future: archiveRef.doc(postId).get(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData ||
                                            snapshot.connectionState !=
                                                ConnectionState.done ||
                                            snapshot.data == null) {
                                          return circularProgress();
                                        }
                                        if (snapshot.connectionState !=
                                            ConnectionState.done) {
                                          return circularProgress();
                                        }
                                        return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  ChatMOOV(
                                                      postId: postId,
                                                      pic: snapshot
                                                              .data['image'] ??
                                                          "",
                                                      title: snapshot
                                                          .data['title'],
                                                      hasButtons: false,
                                                      messageId: isGroupChat
                                                          ? gid
                                                          : directMessageId),
                                                  timeAgo == ""
                                                      ? Container()
                                                      : Text(
                                                          timeAgo,
                                                          style: TextStyle(
                                                              fontSize: 10),
                                                        ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 12.0, left: 8),
                                                child: CircleAvatar(
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                          avatarUrl),
                                                ),
                                              ),
                                            ]);
                                      })
                                  : Stack(
                                      children: [
                                        ListTile(
                                          // tileColor: Colors.blue[100],
                                          title: GestureDetector(
                                              onLongPress: () => {
                                                    showAlertDialog(
                                                        context,
                                                        chatId,
                                                        gid,
                                                        millis,
                                                        isGroupChat,
                                                        directMessageId)
                                                  },
                                              child: Stack(children: [
                                                ChatBubble(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    clipper: ChatBubbleClipper5(
                                                        type: BubbleType
                                                            .sendBubble),
                                                    backGroundColor:
                                                        Colors.blue[400],
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                        ),
                                                        child: Text(comment,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)))),
                                                Positioned(
                                                    right: comment.length < 25
                                                        ? comment.length
                                                                .toDouble() *
                                                            8
                                                        : comment.length < 40
                                                            ? comment.length
                                                                    .toDouble() *
                                                                6
                                                            : 220,
                                                    child: status == 0
                                                        ? Image.asset(
                                                            'lib/assets/middleFinger.gif',
                                                            height: 40,
                                                          )
                                                        : Container())
                                              ])),
                                          subtitle: timeAgo == ""
                                              ? Container()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child: Text(
                                                    timeAgo,
                                                    textAlign: TextAlign.right,
                                                    style:
                                                        TextStyle(fontSize: 10),
                                                  ),
                                                ),
                                          trailing: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: CircleAvatar(
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      avatarUrl),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                        )),
        )
      ],
    );
  }

  void showAlertDialog(
      BuildContext context, chatId, gid, millis, isGroupChat, directMessageId) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Delete?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        content: Text("\nRegret sending that message?"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text("Yeah", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              isGroupChat
                  ? messagesRef
                      .doc(gid)
                      .collection("chat")
                      .doc(millis + " " + currentUser.id)
                      .delete()
                  : messagesRef
                      .doc(directMessageId)
                      .collection("chat")
                      .doc(millis + " " + currentUser.id)
                      .delete();
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
}

class ChatMOOV extends StatelessWidget {
  final String postId, pic, title, messageId;
  final bool hasButtons;
  ChatMOOV(
      {this.postId,
      this.pic,
      this.title,
      this.hasButtons = true,
      this.messageId});

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return Container(
      //this is for sending a MOOV or image message
      // width: width * 0.8,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Container(
              height: isLargePhone
                  ? SizeConfig.blockSizeVertical * 09
                  : SizeConfig.blockSizeVertical * 10,
              width: 200,
              child: hasButtons
                  ? OpenContainer(
                      transitionType: ContainerTransitionType.fade,
                      transitionDuration: Duration(milliseconds: 500),
                      openBuilder: (context, _) => PostDetail(postId),
                      closedElevation: 0,
                      closedBuilder: (context, _) => Stack(children: <Widget>[
                        FractionallySizedBox(
                          widthFactor: 1,
                          child: Container(
                            child: Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: OptimizedCacheImage(
                                  imageUrl: pic,
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
                                    title,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontFamily: 'Solway',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    )
                  : Opacity(
                      //expired/deleted MOOV
                      opacity: .5,
                      child: Stack(children: <Widget>[
                        FractionallySizedBox(
                          widthFactor: 1,
                          child: Container(
                            child: Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: OptimizedCacheImage(
                                  imageUrl: pic,
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
                                    title,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontFamily: 'Solway',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 14.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
            ),
            hasButtons ? Buttons(moovId: postId) : Container(),
            hasButtons
                ? Container(
                    width: MediaQuery.of(context).size.width * .75,
                    child: Row(
                      children: [
                        Expanded(
                          child: ExpandablePanel(
                              collapsed: null,
                              // controller: _expandableController,
                              theme: const ExpandableThemeData(
                                useInkWell: false,
                                hasIcon: false,
                                tapHeaderToExpand: true,
                                headerAlignment:
                                    ExpandablePanelHeaderAlignment.center,
                                tapBodyToCollapse: true,
                              ),
                              header: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0.0, bottom: 3),
                                  child: Text(
                                    "Vote on pull-up time",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 12),
                                  ),
                                ),
                              ),
                              expanded: PullUpPoll(messageId, postId)),
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}

class ChatStatuses extends StatelessWidget {
  final String postId, gid;
  ChatStatuses(this.postId, this.gid);

  @override
  Widget build(BuildContext context) {
    String firstName;

    return FutureBuilder(
        future: groupsRef.doc(gid).get(),
        builder: (context, snapshot0) {
          if (!snapshot0.hasData) {
            return Container();
          }
          List members = snapshot0.data['members'];
          return StreamBuilder(
              stream: postsRef.doc(postId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                Map<String, dynamic> statuses = snapshot.data['statuses'];
                List<String> statusInGroup = statuses.keys
                    .toList()
                    .where((element) => members.contains(element))
                    .toList();
                List<String> greenList = [];
                List<String> yellowList = [];
                List<String> redList = [];

                for (var entry in statuses.entries) {
                  if (entry.value == 3 && statusInGroup.contains(entry.key)) {
                    greenList.add(entry.key);
                  }
                  if (entry.value == 2 && statusInGroup.contains(entry.key)) {
                    yellowList.add(entry.key);
                  }
                  if (entry.value == 1 && statusInGroup.contains(entry.key)) {
                    redList.add(entry.key);
                  }
                }

                return StreamBuilder(
                    stream: usersRef
                        .where("friendGroups", arrayContains: gid)
                        .snapshots(),
                    builder: (context, snapshot1) {
                      if (!snapshot1.hasData) {
                        return Container();
                      }
                      return Center(
                        child: Container(
                            height: 100.0,
                            width: MediaQuery.of(context).size.width * .95,
                            color: Colors.transparent,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      child: ListView.builder(
                                          itemCount: snapshot1.data.docs.length,
                                          itemBuilder: (context, index) {
                                            bool hide = false;

                                            DocumentSnapshot course =
                                                snapshot1.data.docs[index];

                                            if (!redList
                                                .contains(course['id'])) {
                                              hide = true;
                                            }
                                            firstName = firstNameMaker(
                                                course['displayName']);

                                            return (hide == false)
                                                ? GestureDetector(
                                                    onTap: course['id'] ==
                                                            currentUser.id
                                                        ? () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    ProfilePageWithHeader()))
                                                        : () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    OtherProfile(
                                                                        course[
                                                                            'id']))),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: CircleAvatar(
                                                            radius: 18,
                                                            backgroundColor:
                                                                TextThemes
                                                                    .ndBlue,
                                                            child: CircleAvatar(
                                                              radius: 17,
                                                              backgroundColor:
                                                                  TextThemes
                                                                      .ndBlue,
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        course[
                                                                            'photoUrl']),
                                                                radius: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          firstName,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container();
                                          }),
                                      height: 75,
                                      width: MediaQuery.of(context).size.width *
                                          .3,
                                      decoration: BoxDecoration(
                                          color: Colors.red[100],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                    ),
                                    Container(
                                      child: ListView.builder(
                                          itemCount: snapshot1.data.docs.length,
                                          itemBuilder: (context, index) {
                                            bool hide = false;

                                            DocumentSnapshot course =
                                                snapshot1.data.docs[index];

                                            if (!yellowList
                                                .contains(course['id'])) {
                                              hide = true;
                                            }
                                            firstName = firstNameMaker(
                                                course['displayName']);

                                            return (hide == false)
                                                ? GestureDetector(
                                                    onTap: course['id'] ==
                                                            currentUser.id
                                                        ? () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    ProfilePageWithHeader()))
                                                        : () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    OtherProfile(
                                                                        course[
                                                                            'id']))),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: CircleAvatar(
                                                            radius: 18,
                                                            backgroundColor:
                                                                TextThemes
                                                                    .ndBlue,
                                                            child: CircleAvatar(
                                                              radius: 17,
                                                              backgroundColor:
                                                                  TextThemes
                                                                      .ndBlue,
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        course[
                                                                            'photoUrl']),
                                                                radius: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          firstName,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container();
                                          }),
                                      height: 75,
                                      width: MediaQuery.of(context).size.width *
                                          .3,
                                      decoration: BoxDecoration(
                                          color: Colors.yellow[100],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                    ),
                                    Container(
                                      child: ListView.builder(
                                          itemCount: snapshot1.data.docs.length,
                                          itemBuilder: (context, index) {
                                            bool hide = false;

                                            DocumentSnapshot course =
                                                snapshot1.data.docs[index];

                                            if (!greenList
                                                .contains(course['id'])) {
                                              hide = true;
                                            }
                                            firstName = firstNameMaker(
                                                course['displayName']);

                                            return (hide == false)
                                                ? GestureDetector(
                                                    onTap: course['id'] ==
                                                            currentUser.id
                                                        ? () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    ProfilePageWithHeader()))
                                                        : () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    OtherProfile(
                                                                        course[
                                                                            'id']))),
                                                    child: Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: CircleAvatar(
                                                            radius: 18,
                                                            backgroundColor:
                                                                TextThemes
                                                                    .ndBlue,
                                                            child: CircleAvatar(
                                                              radius: 17,
                                                              backgroundColor:
                                                                  TextThemes
                                                                      .ndBlue,
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        course[
                                                                            'photoUrl']),
                                                                radius: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          firstName,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container();
                                          }),
                                      height: 75,
                                      width: MediaQuery.of(context).size.width *
                                          .3,
                                      decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                    )
                                  ],
                                ))),
                      );
                    });
              });
        });
  }

  String firstNameMaker(String fullName) {
    List<String> tempList = fullName.split(" ");
    int start = 0;
    int end = tempList.length;
    if (end > 1) {
      end = 1;
    }
    final selectedWords = tempList.sublist(start, end);
    String firstName = selectedWords.join(" ");
    return firstName;
  }
}
