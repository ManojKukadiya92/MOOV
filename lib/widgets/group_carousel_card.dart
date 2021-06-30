import 'package:MOOV/friendGroups/group_detail.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/create_group.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class GroupCarousel extends StatelessWidget {
  final String userId;
  GroupCarousel(this.userId);

  // int i = 0;

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount user = googleSignIn.currentUser;
    final userId = user.id;

    bool isLargePhone = Screen.diagonal(context) > 766;

    return (currentUser.friendGroups.isEmpty)
        ? Container(
            height: 110,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 35.0),
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupForm()));
                      },
                      color: TextThemes.ndBlue,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people, color: TextThemes.ndGold),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Create Friend Group',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                            ),
                          ],
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                ],
              ),
            )))
        : Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: Container(
                child: StreamBuilder(
                    stream: groupsRef
                        .where('members', arrayContains: user.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      if (snapshot.data.docs.length == 0 ||
                          currentUser.friendGroups.length == 0) {
                        return Container();
                      }
                      DocumentSnapshot course = snapshot.data.docs[0];
                      int length = course['members'].length - 2;

                      return StreamBuilder(
                          stream: usersRef
                              .where('friendGroups',
                                  arrayContains: course['groupId'])
                              .snapshots(),
                          builder: (context, snapshot3) {
                            if (!snapshot3.hasData)
                              return CircularProgressIndicator();
                            if (snapshot3.hasError || snapshot3.data == null)
                              return CircularProgressIndicator();

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .33,
                                    // color: Colors.white,
                                    child: Stack(
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GroupDetail(course[
                                                            'groupId'])));
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20)),
                                                      border: Border.all(
                                                        color:
                                                            TextThemes.ndBlue,
                                                        width: 3,
                                                      )),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                15)),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          course['groupPic'],
                                                      fit: BoxFit.cover,
                                                      height: isLargePhone
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.08
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.12,
                                                      width: isLargePhone
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.33
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.33,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          bottom: isLargePhone ? 25 : 25,
                                          right: 0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Stack(children: [
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: course['members']
                                                                .length >
                                                            1
                                                        ? CircleAvatar(
                                                            radius: 15.0,
                                                            backgroundImage:
                                                                NetworkImage(
                                                              snapshot3.data
                                                                      .docs[1]
                                                                  ['photoUrl'],
                                                            ),
                                                          )
                                                        : Container()),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4, left: 20.0),
                                                    child: CircleAvatar(
                                                      radius: 15.0,
                                                      backgroundImage:
                                                          NetworkImage(
                                                        snapshot3.data.docs[0]
                                                            ['photoUrl'],
                                                      ),
                                                    )),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4, left: 40.0),
                                                  child: CircleAvatar(
                                                    radius: 15.0,
                                                    child:
                                                        course['members']
                                                                    .length >
                                                                2
                                                            ? Text(
                                                                "+" +
                                                                    (length
                                                                        .toString()),
                                                                style: TextStyle(
                                                                    color: TextThemes
                                                                        .ndGold,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              )
                                                            : Text(
                                                                (course['members']
                                                                    .length
                                                                    .toString()),
                                                                style: TextStyle(
                                                                    color: TextThemes
                                                                        .ndGold,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                    backgroundColor:
                                                        TextThemes.ndBlue,
                                                  ),
                                                ),
                                              ]),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                StreamBuilder(
                                    stream: groupsRef
                                        .doc(course['groupId'])
                                        .collection("suggestedMOOVs")
                                        .snapshots(),
                                    builder: (context, snapshot2) {
                                      if (!snapshot2.hasData)
                                        return CircularProgressIndicator();
                                      if (snapshot2.data.docs.length == 0 ||
                                          currentUser.friendGroups.length ==
                                              0) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20.0, left: 10),
                                          child: Text(
                                            "needs a MOOV \ntonight!",
                                            style: TextStyle(fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }
                                      DocumentSnapshot course2 =
                                          snapshot2.data.docs[0];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 35.0),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0),
                                              child: Text(
                                                " Next MOOV: ",
                                                style: TextStyle(fontSize: 16),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            StreamBuilder(
                                                stream: postsRef
                                                    .doc(course2['nextMOOV'])
                                                    .snapshots(),
                                                builder: (context, snapshot3) {
                                                  if (!snapshot3.hasData)
                                                    return CircularProgressIndicator();
                                                  if (!snapshot3.hasData ||
                                                      currentUser.friendGroups
                                                              .length ==
                                                          0) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 0.0),
                                                      child: Text(
                                                        "  needs one \ntonight!",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: TextThemes
                                                                .ndBlue),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    );
                                                  }
                                                  return GestureDetector(
                                                    onTap: () => Navigator.of(
                                                            context)
                                                        .push(MaterialPageRoute(
                                                            builder: (context) =>
                                                                PostDetail(course2[
                                                                    'nextMOOV']))),
                                                    child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 15.0),
                                                            child: SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.33,
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
                                                                      0.13,
                                                              child: Container(
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    memCacheHeight:
                                                                        100,
                                                                    memCacheWidth:
                                                                        100,
                                                                    imageUrl: snapshot3
                                                                            .data[
                                                                        'image'],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10,
                                                                        top: 0,
                                                                        right:
                                                                            10,
                                                                        bottom:
                                                                            0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                                  ),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.5),
                                                                      spreadRadius:
                                                                          5,
                                                                      blurRadius:
                                                                          7,
                                                                      offset: Offset(
                                                                          0,
                                                                          3), // changes position of shadow
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 10.0),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20)),
                                                                gradient:
                                                                    LinearGradient(
                                                                  begin: Alignment
                                                                      .topCenter,
                                                                  end: Alignment
                                                                      .bottomCenter,
                                                                  colors: <
                                                                      Color>[
                                                                    Colors.black
                                                                        .withAlpha(
                                                                            0),
                                                                    Colors
                                                                        .black,
                                                                    Colors
                                                                        .black12,
                                                                  ],
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        4.0),
                                                                child:
                                                                    ConstrainedBox(
                                                                  constraints: BoxConstraints(
                                                                      maxWidth: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .25),
                                                                  child: Text(
                                                                    snapshot3
                                                                            .data[
                                                                        'title'],
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
                                                                        fontSize: isLargePhone
                                                                            ? 14.0
                                                                            : 11),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                  );

                                                  //   return SizedBox(
                                                  //     width: MediaQuery.of(context).size.width * .33,
                                                  //     child: GradientText(" " +snapshot.data['title'],   gradient: LinearGradient(colors: [
                                                  //     Colors.purple.shade400,
                                                  //     Colors.purple.shade900,
                                                  // ]),),
                                                  //   );
                                                })
                                          ],
                                        ),
                                      );
                                    })
                              ],
                            );
                          });
                    })),
          );
  }
}
