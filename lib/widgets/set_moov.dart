import 'dart:async';
import 'package:MOOV/helpers/common.dart';
import 'package:MOOV/main.dart';
import 'package:MOOV/pages/NewSearch.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/services/database.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:algolia/algolia.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class SearchSetMOOV extends StatefulWidget {
  final String groupId, groupName;
  final bool pickMOOV;

  SearchSetMOOV({this.groupId, this.groupName, this.pickMOOV = false});

  @override
  _SearchSetMOOVState createState() => _SearchSetMOOVState();
}

class _SearchSetMOOVState extends State<SearchSetMOOV> {
  final TextEditingController searchController = TextEditingController();
  final textFieldFocusNode = FocusNode();

  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  String _searchTerm;

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("events").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  clearSearch() {
    searchController.clear();

    setState(() {
      _searchTerm = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          TextField(
              style: TextStyle(fontSize: 20),
              controller: searchController,
              onChanged: (val) {
                setState(() {
                  _searchTerm = val;
                });
              },
              // Set Focus Node
              focusNode: textFieldFocusNode,
              decoration: InputDecoration(
                labelStyle: TextStyle(fontSize: 20),
                border: InputBorder.none,
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                suffixIcon: GestureDetector(
                    onTap: () {
                      clearSearch();
                      // Unfocus all focus nodes
                      textFieldFocusNode.unfocus();

                      // Disable text field's focus node request
                      textFieldFocusNode.canRequestFocus = false;

                      //Enable the text field's focus node request after some delay
                      Future.delayed(Duration(milliseconds: 10), () {
                        textFieldFocusNode.canRequestFocus = true;
                      });
                    },
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.clear,
                          color: Colors.black,
                        ))),
              )),
          StreamBuilder<List<AlgoliaObjectSnapshot>>(
              stream: Stream.fromFuture(_operation(_searchTerm)),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data.length == 0 ||
                    _searchTerm == null)
                  return FutureBuilder(
                      future: postsRef.get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        String privacy = snapshot.data.docs[0]["privacy"];
                        Map statuses = snapshot.data.docs[0]["statuses"];
                        bool hide = false;
                        if ((snapshot.data.docs[0]["userId"] !=
                                    currentUser.id) &&
                                privacy == "Friends Only" ||
                            privacy == "Invite Only") {
                          hide = true;
                        }

                        if (statuses.keys.contains(widget.groupId)) {
                          hide = false;
                        }

                        if (hide == true) {
                          return Container();
                        }
                        return (widget.pickMOOV)
                            ? PickMOOV(
                                postId: snapshot.data.docs[0]['postId'],
                                groupName: widget.groupName)
                            : SetMOOVResult(
                                snapshot.data.docs[0]['title'],
                                snapshot.data.docs[0]['userId'],
                                snapshot.data.docs[0]['description'],
                                snapshot.data.docs[0]['type'],
                                snapshot.data.docs[0]['image'],
                                snapshot.data.docs[0]['postId'],
                                widget.groupId,
                                widget.groupName);
                      });

                List<AlgoliaObjectSnapshot> currSearchStuff = snapshot.data;

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Container();
                  default:
                    if (!snapshot.hasData)
                      return new Text('Error: ${snapshot.error}');
                    else
                      return CustomScrollView(
                        shrinkWrap: true,
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              // ignore: missing_return
                              (context, index) {
                                String privacy =
                                    currSearchStuff[index].data["privacy"];
                                Map statuses =
                                    currSearchStuff[index].data["statuses"];
                                bool hide = false;
                                if (privacy == "Friends Only" ||
                                    privacy == "Invite Only") {
                                  hide = true;
                                }

                                if (currSearchStuff[index].data["userId"] ==
                                    currentUser.id) {
                                  hide = false;
                                }

                                if (statuses.keys.contains(widget.groupId)) {
                                  hide = false;
                                }
                                if (widget.pickMOOV && hide == false) {
                                  return PickMOOV(
                                      postId:
                                          currSearchStuff[index].data["postId"],
                                      groupName: widget.groupName);
                                }
                                if (!widget.pickMOOV) {
                                  return _searchTerm != null && hide == false
                                      ? SetMOOVResult(
                                          currSearchStuff[index].data["title"],
                                          currSearchStuff[index].data["userId"],
                                          currSearchStuff[index]
                                              .data["description"],
                                          currSearchStuff[index].data["type"],
                                          currSearchStuff[index].data["image"],
                                          currSearchStuff[index].data["postId"],
                                          widget.groupId,
                                          widget.groupName)
                                      : Container();
                                }
                              },
                              childCount: currSearchStuff.length ?? 0,
                            ),
                          ),
                        ],
                      );
                }
              }),
        ]),
      ),
    );
  }
}

class SetMOOVResult extends StatefulWidget {
  final String title;
  final String userId;
  final String description;
  final String type;
  final String image;
  final String moov, gid, groupName;

  SetMOOVResult(this.title, this.userId, this.description, this.type,
      this.image, this.moov, this.gid, this.groupName);

  @override
  _SetMOOVResultState createState() => _SetMOOVResultState();
}

class _SetMOOVResultState extends State<SetMOOVResult> {
  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return StreamBuilder(
        stream: usersRef.doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          if (snapshot.data == null) return Container();
          String proPic = snapshot.data['photoUrl'];
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostDetail(widget.moov))),
              child: Stack(alignment: Alignment.center, children: <Widget>[
                SizedBox(
                  width: isLargePhone
                      ? MediaQuery.of(context).size.width * 0.8
                      : MediaQuery.of(context).size.width * 0.8,
                  height: isLargePhone
                      ? MediaQuery.of(context).size.height * 0.15
                      : MediaQuery.of(context).size.height * 0.17,
                  child: Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: OptimizedCacheImage(
                        imageUrl: widget.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    margin:
                        EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
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
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * .4),
                      child: Text(
                        widget.title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Solway',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: isLargePhone ? 17.0 : 14),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8.5,
                  right: isLargePhone ? 60 : 55,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: TextThemes.ndGold,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20.0,
                          offset: Offset(5.0, 5.0),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                        radius: 20,
                        backgroundColor: TextThemes.ndGold,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(proPic),
                          radius: 18,
                          backgroundColor: TextThemes.ndBlue,
                        )),
                  ),
                ),
                Positioned(
                  bottom: 7.5,
                  child: StreamBuilder(
                      stream: groupsRef
                          .doc(widget.gid)
                          .collection("suggestedMOOVs")
                          .snapshots(),
                      builder: (context, snapshot4) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        for (int i = 0; i < snapshot4.data.docs.length; i++) {
                          String suggestedAlready =
                              snapshot4.data.docs[i]["postId"];
                          bool isSuggested = false;
                          if (suggestedAlready == widget.moov) {
                            isSuggested = true;
                          }

                          return GestureDetector(
                            onTap: isSuggested
                                ? null
                                : () {
                                    HapticFeedback.lightImpact();

                                    Database().suggestMOOV(widget.gid,
                                        widget.moov, widget.groupName);

                                    Navigator.pop(context, widget.moov);
                                  },
                            child: Container(
                              height: 30,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  gradient: isSuggested
                                      ? LinearGradient(
                                          colors: [
                                            Colors.red[400],
                                            Colors.red[300]
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            TextThemes.ndBlue,
                                            TextThemes.ndBlue
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 2.0, right: 2.0),
                                child: isSuggested
                                    ? Text(
                                        "Suggested Already",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      )
                                    : Text(
                                        "Suggest",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                              ),
                            ),
                          );
                        }
                      }),
                ),
              ]),
            ),
          );
        });
  }
}

class PickMOOV extends StatefulWidget {
  final String postId, groupName;

  PickMOOV({this.postId, this.groupName});

  @override
  _PickMOOVState createState() => _PickMOOVState();
}

class _PickMOOVState extends State<PickMOOV> {
  bool inCommunity = false;
  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    return StreamBuilder(
        stream: postsRef.doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          String title = snapshot.data['title'];
          String pic = snapshot.data['image'];
          List tags = snapshot.data['tags'];

          if (tags.contains("m/" + widget.groupName.toLowerCase())) {
            inCommunity = true;
          }
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostDetail(widget.postId))),
              child: Stack(alignment: Alignment.center, children: <Widget>[
                SizedBox(
                  width: isLargePhone
                      ? MediaQuery.of(context).size.width * 0.8
                      : MediaQuery.of(context).size.width * 0.8,
                  height: isLargePhone
                      ? MediaQuery.of(context).size.height * 0.15
                      : MediaQuery.of(context).size.height * 0.17,
                  child: Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: OptimizedCacheImage(
                        imageUrl: pic,
                        fit: BoxFit.cover,
                      ),
                    ),
                    margin:
                        EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
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
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * .4),
                      child: Text(
                        title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Solway',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: isLargePhone ? 17.0 : 14),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 7.5,
                    child: GestureDetector(
                      onTap: inCommunity
                          ? null
                          : () {
                              postsRef.doc(snapshot.data['postId']).set({
                                "tags": FieldValue.arrayUnion(
                                    ["m/" + widget.groupName.toLowerCase()])
                              }, SetOptions(merge: true)).then(
                                  (value) => Navigator.pop(context));
                            },
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            gradient: inCommunity
                                ? LinearGradient(
                                    colors: [
                                      Colors.green[400],
                                      Colors.green[300]
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      TextThemes.ndBlue,
                                      TextThemes.ndBlue
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                          child: inCommunity
                              ? Text(
                                  "In Commmunity",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                )
                              : Text(
                                  "Add",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                        ),
                      ),
                    )),
              ]),
            ),
          );
        });
  }
}
