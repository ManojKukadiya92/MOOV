import 'dart:collection';

import 'package:MOOV/pages/post_detail.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Event {
  final String title, postId, pic;
  final Map groupStatuses;
  final Timestamp startDate;

  const Event(
      this.title, this.postId, this.pic, this.groupStatuses, this.startDate);

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.

final _kEventSource = {
  DateTime.now(): [
    Event('Today\'s Event 1e', "", "", {}, Timestamp.now()),
    // Event('Today\'s Event 2'),
    Event('Today\'s Event 2e', "", "", {}, Timestamp.now()),
  ],
  // DateTime.now(): [
  //   // Event('Today\'s Event 2'),
  // ],
  // DateTime.now().add(Duration(days: 1)): [
  //   Event('Today\'s Event 1ef'),
  //   Event('Today\'s Event 2'),
  // ]
};

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kNow = DateTime.now();
final kFirstDay = DateTime.now();
final kLastDay = DateTime(kNow.year, kNow.month + 3, kNow.day);

class TableEventsExample extends StatefulWidget {
  final Map eventsDataMap;
  TableEventsExample(this.eventsDataMap);
  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;
  DateTime _rangeStart;
  DateTime _rangeEnd;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    Map<DateTime, List<Event>> myMap =
        Map<DateTime, List<Event>>.from(widget.eventsDataMap);

    // Implementation example
    final kEvents = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(myMap);
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime start, DateTime end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Event>(
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          eventLoader: _getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            // Use `CalendarStyle` to customize the UI
            outsideDaysVisible: false,
          ),
          onDaySelected: _onDaySelected,
          onRangeSelected: _onRangeSelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return CalendarMOOV(value[index]);
                  // return Container(
                  //   margin: const EdgeInsets.symmetric(
                  //     horizontal: 12.0,
                  //     vertical: 4.0,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     border: Border.all(),
                  //     borderRadius: BorderRadius.circular(12.0),
                  //   ),
                  //   child: ListTile(
                  //     onTap: () => print('${value[index]}'),
                  //     title: Text('${value[index]}'),
                  //   ),
                  // );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class CalendarMOOV extends StatelessWidget {
  final Event event;
  const CalendarMOOV(this.event);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            children: [
              Text(
                DateFormat('h:mm').format(event.startDate.toDate()) +
                    "\n" +
                    DateFormat('a').format(event.startDate.toDate()),
                style: TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
                trailing: Transform.translate(
                  offset: Offset(16, 10),
                  child: SizedBox(
                    height: 50,
                    width: 72,
                    child: Row(
                      children: [
                        Icon(Icons.directions_run, color: Colors.green),
                        Icon(Icons.accessibility, color: Colors.yellow[600]),
                        Icon(Icons.directions_walk, color: Colors.red)
                      ],
                    ),
                  ),
                ),
                onTap: () => print(event.postId),
                // title: Text(event.toString()),
                leading: Transform.translate(
                  offset: Offset(-16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 56,
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: OpenContainer(
                        openElevation: 10,
                        transitionType: ContainerTransitionType.fade,
                        transitionDuration: Duration(milliseconds: 500),
                        openBuilder: (context, _) => PostDetail(""),
                        closedElevation: 0,
                        closedBuilder: (context, _) => Stack(children: <Widget>[
                          FractionallySizedBox(
                            widthFactor: 1,
                            child: Container(
                              child: Container(
                                child: CachedNetworkImage(
                                  imageUrl: event.pic,
                                  fit: BoxFit.cover,
                                ),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
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
                            padding: const EdgeInsets.all(0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                alignment: Alignment(0.0, 0.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(0)),
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
                                      event.title,
                                      style: TextStyle(
                                          fontFamily: 'Solway',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 12),
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
                )),
          ),
        ),
      ],
    );
  }
}
