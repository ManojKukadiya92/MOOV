import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class PostStats extends StatefulWidget {
  final String postId;
  PostStats(this.postId);

  @override
  PostStatsState createState() => PostStatsState();
}

class PostStatsState extends State<PostStats> {
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
      body: FutureBuilder(
          future: postsRef.doc(widget.postId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Container();
            }
            bool isMoovMountain;
            return Column(
              children: [
                SizedBox(height: 30),
                Center(
                  child: Text("MOOV Stats",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                ),
                Text('"Ratio!"'),
                SizedBox(height: 30),
                Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width * .7,
                      child: Center(
                          child: SfCircularChart(
                              legend: Legend(isVisible: true),
                              series: <PieSeries<PieData, String>>[
                            PieSeries<PieData, String>(
                                explode: true,
                                explodeIndex: 0,
                                dataSource: [
                                  PieData("Guys", 2),
                                  PieData("Girls", 1)
                                ],
                                xValueMapper: (PieData data, _) => data.xData,
                                yValueMapper: (PieData data, _) => data.yData,
                                dataLabelMapper: (PieData data, _) => data.text,
                                dataLabelSettings: DataLabelSettings(
                                    isVisible: true,
                                    textStyle: TextStyle(fontSize: 20)))
                          ])),
                    ),
                    Positioned(
                        top: 10,
                        left: 0,
                        child: Column(
                          children: [
                            Text("Ratio"),
                            Text(
                              "Going List",
                              style: TextStyle(fontSize: 8),
                            )
                          ],
                        ))
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(thickness: 2),
                ),

                //MOOV Mountain Indicator
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, right: 8),
                      child: Image.asset(
                        'lib/assets/greenmountain.png',
                        height: 40,
                        color: Colors.grey,
                      ),
                    ),
                    Text("not ", style: TextStyle(color: Colors.red)),
                    Text("a MOOV Mountain event."),
                    SizedBox(width: 7.5),
                    GestureDetector(
                      onTap: () => showDialog(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                                  title: Text("Make a Difference."),
                                  content: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                        "MOOV Mountain events are those considered to be forces for good. \n\nGo to these and earn sweet rewards!"),
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                        child: Text(
                                          "Recommend for Mountain",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                        onPressed: () => Navigator.pop(context))
                                  ]),
                          barrierDismissible: true),
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.teal,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            "Why?",
                            style: TextStyle(fontSize: 8),
                          ),
                          radius: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                //race pie chart
                Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width * .7,
                      child: Center(
                          child: SfCircularChart(
                              palette: [
                                Colors.brown[400],
                                Colors.orange[300],
                                Colors.red[200],
                                Colors.amber[50],
                                Colors.blue[100]
                              ],
                              legend: Legend(isVisible: true),
                              series: <PieSeries<PieData, String>>[
                                PieSeries<PieData, String>(
                                    // explode: true,
                                    // explodeIndex: 0,
                                    dataSource: [
                                      PieData("Black", 1),
                                      PieData("Latino", 1),
                                      PieData("Asian", 1),
                                      PieData("White", 2),
                                      PieData("Other", 2)
                                    ],
                                    xValueMapper: (PieData data, _) =>
                                        data.xData,
                                    yValueMapper: (PieData data, _) =>
                                        data.yData,
                                    dataLabelMapper: (PieData data, _) =>
                                        data.text,
                                    dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                        textStyle: TextStyle(fontSize: 20)))
                              ])),
                    ),
                    Positioned(
                        top: 10,
                        left: 0,
                        child: Column(
                          children: [
                            Text("Diversity"),
                            Text(
                              "Going List",
                              style: TextStyle(fontSize: 8),
                            )
                          ],
                        ))
                  ],
                ),
                Text("The more diverse the pie, \nthe bigger your reward!", textAlign: TextAlign.center),
                SizedBox(height: 4),
                Text("—Must be on Going List, 10+ people—", style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic))
              ],
            );
          }),
    );
  }
}

class PieData {
  PieData(this.xData, this.yData, [this.text]);
  final String xData;
  final num yData;
  final String text;
}