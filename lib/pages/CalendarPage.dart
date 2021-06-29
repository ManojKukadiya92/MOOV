import 'package:MOOV/helpers/common.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class CalendarPage extends StatelessWidget {
  final DateTime proposedStartDate;
  const CalendarPage(this.proposedStartDate);

  List<_MOOVsOnCalendar> _getDataSource(AsyncSnapshot<dynamic> snapshot) {
    var _moovs = <_MOOVsOnCalendar>[];
    for (int i = 0; i < snapshot.data.docs.length; i++) {
      final String title = snapshot.data.docs[i]['title'];
      final String image = snapshot.data.docs[i]['image'];
      final String postId = snapshot.data.docs[i]['postId'];

      final DateTime startDate = snapshot.data.docs[i]['startDate'].toDate();
      final DateTime endDate = startDate.add(const Duration(hours: 2));
      _moovs.add(_MOOVsOnCalendar(
          title, startDate, endDate, postId, image, Colors.blue[100], false));
      _moovs.add(_MOOVsOnCalendar(
          "YOUR MOOV",
          proposedStartDate,
          proposedStartDate.add(const Duration(hours: 2)),
          null,
          image,
          TextThemes.ndGold,
          false));
    }
    return _moovs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(),
        body: FutureBuilder(
            future: postsRef
                // .where("privacy", isEqualTo: "Public")
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              return SfCalendar(
                initialDisplayDate: proposedStartDate,
                onTap: (calendarTapDetails) {
                  if (calendarTapDetails.appointments != null) {
                    String postId =
                        calendarTapDetails.appointments.first.postId;

                    if (postId != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostDetail(
                                  calendarTapDetails
                                      .appointments.first.postId)));
                    }
                  }
                },

                appointmentBuilder:
                    (BuildContext context, CalendarAppointmentDetails details) {
                  final _MOOVsOnCalendar meeting = details.appointments.first;
                  String postId = details.appointments.first.postId;
                  // final String image = _getImage();

                  return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5)),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              decoration: BoxDecoration(
                                  color: postId != null
                                      ? Colors.blue
                                      : Colors.red),
                              duration: Duration(seconds: 1),
                              curve: Curves.fastOutSlowIn,
                              width: 1,
                            ),
                          ),
                          Stack(alignment: Alignment.center, children: <Widget>[
                            Container(
                              width: 43,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  memCacheHeight: 100,
                                  memCacheWidth: 100,
                                  imageUrl: meeting.image,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                            ),

                            Align(
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
                                        meeting.eventName,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        softWrap: false,
                                        style: TextStyle(
                                            fontFamily: 'Solway',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 6.0),
                                      ),
                                    ),
                                  ),
                                )),
                            // Text(
                            //   // 'Time: ${DateFormat('hh:mm a').format(meeting.startTime)} - ' +
                            //   //     '${DateFormat('hh:mm a').format(meeting.endTime)}',
                            //   'hu',
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 10,
                            //   ),
                            // ),
                          ]),
                          Expanded(
                            child: Container(
                              width: 1,
                              color: postId == null ? Colors.red : Colors.blue,
                            ),
                          ),
                        ],
                      ));
                },

                //     Container(
                //       height: details.bounds.height - 70,
                //       padding: EdgeInsets.fromLTRB(3, 5, 3, 2),
                //       color: Colors.blue,
                //       alignment: Alignment.topLeft,
                //       child: SingleChildScrollView(
                //           child: Column(
                //         mainAxisAlignment: MainAxisAlignment.start,
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Padding(
                //               padding: EdgeInsets.symmetric(vertical: 5),
                //               child: Image(
                //                   // image: ExactAssetImage(
                //                   //     'images/' + image + '.png'),
                //                   image: AssetImage('lib/assets/bouts.jpg'),
                //                   fit: BoxFit.contain,
                //                   width: details.bounds.width,
                //                   height: 60)),
                //           Text(
                //             meeting.eventName,
                //             style: TextStyle(
                //               color: Colors.purple,
                //               fontSize: 10,
                //             ),
                //           )
                //         ],
                //       )),
                //     ),
                //     Container(
                //       height: 20,
                //       decoration: BoxDecoration(
                //         shape: BoxShape.rectangle,
                //         borderRadius: BorderRadius.only(
                //             bottomLeft: Radius.circular(5),
                //             bottomRight: Radius.circular(5)),
                //         color: Colors.blue,
                //       ),
                //     ),
                //   ],
                // ));

                view: CalendarView.week,
                dataSource: MeetingDataSource(_getDataSource(snapshot)),
                scheduleViewSettings: ScheduleViewSettings(
                    appointmentTextStyle: GoogleFonts.montserrat()),
                monthViewSettings: MonthViewSettings(
                    agendaStyle: AgendaStyle(),
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.appointment),
              );
            }));
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<_MOOVsOnCalendar> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getPostId(int index) {
    return appointments[index].postId;
  }

  @override
  String getImage(int index) {
    return appointments[index].image;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

class _MOOVsOnCalendar {
  _MOOVsOnCalendar(this.eventName, this.from, this.to, this.postId, this.image,
      this.background, this.isAllDay);

  String eventName, postId, image;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
