import 'package:MOOV/pages/NewSearch.dart';
import 'package:MOOV/pages/archiveDetail.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class MOOVMemories extends StatelessWidget {
  const MOOVMemories({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          titlePadding: EdgeInsets.all(7.5),
          title: Padding(
            padding: EdgeInsets.all(10),
            child: GradientText(
              "MOOV Memories",
              16.5,
              gradient: LinearGradient(colors: [
                Colors.blue.shade400,
                Colors.blue.shade900,
              ]),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: archiveRef
                  .where("memories", arrayContains: currentUser.id)
                  .orderBy("startDate")
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "lib/assets/clouds.jpeg",
                        width: MediaQuery.of(context).size.width,
                      ),
                      Text(
                        "No memories yet.",
                        style: TextThemes.headlineWhite,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 175.0, left: 20, right: 20),
                        child: Text("Go make some!",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white, fontSize: 13)),
                      )
                    ],
                  );
                }
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data.docs.length + 1,
                      itemBuilder: (_, index) {
                        if (snapshot.data.docs.length == 0) {
                          return Container(
                            height: 100,
                            child: Center(
                                child: Text(
                              "Error :(",
                              style: TextStyle(
                                  color: TextThemes.ndBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30),
                            )),
                          );
                        }
                        if (index == 0) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                "lib/assets/clouds.jpeg",
                                width: MediaQuery.of(context).size.width,
                              ),
                              Text(
                                "Yours forever.",
                                style: TextThemes.headlineWhite,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 175.0, left: 20, right: 20),
                                child: Text(
                                    """MOOVs delete one hour after start time for privacy. """
                                    """\
                    But those you save to memory will stay here, \nfor your eyes only.""",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13)),
                              )
                            ],
                          );
                        }
                        DocumentSnapshot course = snapshot.data.docs[index - 1];

                        return Container(
                          alignment: Alignment.center,
                          // width: width * 0.8,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 200,
                                    child: OpenContainer(
                                      transitionType:
                                          ContainerTransitionType.fade,
                                      transitionDuration:
                                          Duration(milliseconds: 500),
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: CachedNetworkImage(
                                                  imageUrl: course['image'],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
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
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    course['title'],
                                                    style: TextStyle(
                                                        fontFamily: 'Solway',
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                );
              })
        ],
      ),
    );
  }
}
