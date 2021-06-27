import 'package:MOOV/main.dart';
import 'package:MOOV/pages/HomePage.dart';
import 'package:MOOV/pages/NewSearch.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/pages/post_detail.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

///Map import
// ignore: import_of_legacy_library_into_null_safe
import 'package:syncfusion_flutter_maps/maps.dart';

/// Renders the map widget with OSM map.
class Heatmap extends SampleView {
  /// Creates the map widget with OSM map.
  @override
  _TileLayerSampleState createState() => _TileLayerSampleState();
}

class _TileLayerSampleState extends SampleViewState {
  PageController _pageViewController;
  MapTileLayerController _mapController;

  MapZoomPanBehavior _zoomPanBehavior;

  List<_WonderDetails> _worldWonders;

  int _currentSelectedIndex;
  int _previousSelectedIndex;
  int _tappedMarkerIndex;

  double _cardHeight;

  bool _canUpdateFocalLatLng;
  bool _canUpdateZoomLevel;
  bool _isDesktop = false;
  bool legendClosed = false;

  @override
  void initState() {
    super.initState();
    _currentSelectedIndex = 0;
    _canUpdateFocalLatLng = true;
    _canUpdateZoomLevel = true;
    _mapController = MapTileLayerController();
    _worldWonders = <_WonderDetails>[];

    _zoomPanBehavior = MapZoomPanBehavior(
      minZoomLevel: 15,
      maxZoomLevel: 20,
      // focalLatLng: MapLatLng(_worldWonders[_currentSelectedIndex].latitude,
      //     _worldWonders[_currentSelectedIndex].longitude),
    );
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    _mapController.dispose();
    _worldWonders.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLargePhone = Screen.diagonal(context) > 766;

    if (_canUpdateZoomLevel) {
      _canUpdateZoomLevel = false;
    }
    _cardHeight = (MediaQuery.of(context).orientation == Orientation.landscape)
        ? (_isDesktop ? 120 : 90)
        : 110;
    _pageViewController = PageController(
        initialPage: _currentSelectedIndex,
        viewportFraction:
            (MediaQuery.of(context).orientation == Orientation.landscape)
                ? (_isDesktop ? 0.5 : 0.7)
                : 0.8);
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
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        backgroundColor: TextThemes.ndBlue,
        flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(top: isLargePhone ? 50 : 30),
            title: Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    GradientText(
                      "MOOV Heatmap",
                      20,
                      gradient: LinearGradient(colors: [
                        Colors.red.shade200,
                        Colors.red.shade900,
                      ]),
                    ),
                    Text(
                      "Find tonight's hottest MOOVs, on and off campus",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontStyle: FontStyle.italic),
                    )
                  ],
                ))),
      ),
      body: FutureBuilder(
          future: postsRef.where("privacy", isEqualTo: "Public").get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return loadingMOOVs();
            }
            for (int i = 0; i < snapshot.data.docs.length; i++) {
              String title = snapshot.data.docs[i]['title'];
              double latitude = snapshot.data.docs[i]['location'].latitude;
              double longtitude = snapshot.data.docs[i]['location'].longitude;
              String description = snapshot.data.docs[i]['description'];
              String pic = snapshot.data.docs[i]['image'];
              String id = snapshot.data.docs[i]['postId'];
              int goingCount = snapshot.data.docs[i]['goingCount'];

              _worldWonders.add(_WonderDetails(
                  title: title,
                  id: id,
                  latitude: latitude,
                  longitude: longtitude,
                  description: description,
                  goingCount: goingCount,
                  imagePath: pic,
                  tooltipImagePath: pic));
            }

            _zoomPanBehavior = MapZoomPanBehavior(
              minZoomLevel: 15,
              maxZoomLevel: 25,
              focalLatLng: MapLatLng(
                  _worldWonders[_currentSelectedIndex].latitude,
                  _worldWonders[_currentSelectedIndex].longitude),
            );
            return Stack(children: [
              SfMaps(
                layers: [
                  MapTileLayer(
                    /// URL to request the tiles from the providers.
                    ///
                    /// The [urlTemp] accepts the URL in WMTS format i.e. {z} —
                    /// zoom level, {x} and {y} — tile coordinates.
                    ///
                    /// We will replace the {z}, {x}, {y} internally based on the
                    /// current center point and the zoom level.
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    zoomPanBehavior: _zoomPanBehavior,
                    controller: _mapController,
                    initialMarkersCount: _worldWonders.length,
                    tooltipSettings: MapTooltipSettings(
                      color: Colors.transparent,
                    ),
                    markerTooltipBuilder: (BuildContext context, int index) {
                      if (_isDesktop) {
                        return ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              width: 150,
                              height: 80,
                              color: Colors.grey,
                              child: Image.network(
                                _worldWonders[index].tooltipImagePath,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ]),
                        );
                      }

                      return SizedBox();
                    },
                    markerBuilder: (BuildContext context, int index) {
                      final _WonderDetails item = _worldWonders[index];
                      int heat = 50;
                      if (item.goingCount > 5) {
                        heat = 100;
                      }
                      if (item.goingCount > 10) {
                        heat = 400;
                      }
                      if (item.goingCount > 30) {
                        heat = 900;
                      }
                      if (item.goingCount > 50) {
                        heat = 900;
                      }
                      return MapMarker(
                        latitude: _worldWonders[index].latitude,
                        longitude: _worldWonders[index].longitude,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_currentSelectedIndex != index) {
                                  _canUpdateFocalLatLng = false;
                                  _tappedMarkerIndex = index;
                                  _pageViewController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Opacity(
                                opacity: .7,
                                child: Icon(Icons.circle,
                                    color: Colors.red[heat], size: 30.0),
                              ),
                            ),
                            SizedBox(
                              height:
                                  (_currentSelectedIndex == index ? 40 : 25),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: _cardHeight,
                  padding: EdgeInsets.only(bottom: 10),

                  /// PageView which shows the world wonder details at the bottom.
                  child: PageView.builder(
                    itemCount: _worldWonders.length,
                    onPageChanged: _handlePageChange,
                    controller: _pageViewController,
                    itemBuilder: (BuildContext context, int index) {
                      final _WonderDetails item = _worldWonders[index];
                      return Transform.scale(
                          scale: index == _currentSelectedIndex ? 1 : 0.85,
                          child: OpenContainer(
                            openShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            transitionType: ContainerTransitionType.fade,
                            transitionDuration: Duration(milliseconds: 500),
                            openBuilder: (context, _) => PostDetail(item.id),
                            closedElevation: 0,
                            closedBuilder: (context, _) =>
                                Stack(children: <Widget>[
                              FractionallySizedBox(
                                widthFactor: 1,
                                child: Container(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: OptimizedCacheImage(
                                      imageUrl: item.tooltipImagePath,
                                      fit: BoxFit.cover,
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
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  alignment: Alignment(0.0, 0.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: <Color>[
                                          Colors.black.withAlpha(15),
                                          Colors.black,
                                          Colors.black12,
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .7),
                                        child: Text(
                                          item.title,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ));
                    },
                  ),
                ),
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: legendClosed
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              legendClosed = false;
                            });
                          },
                          child: Icon(Icons.close_fullscreen))
                      : Opacity(
                          opacity: .7,
                          child: Stack(children: [
                            Container(
                                height: 125,
                                width: 120,
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        "People going",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.circle,
                                            color: Colors.red[50]),
                                        Text(" 1-5"),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.circle,
                                            color: Colors.red[100]),
                                        Text(" 6-10"),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.circle,
                                            color: Colors.red[400]),
                                        Text(" 11-30"),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.circle,
                                            color: Colors.red[900]),
                                        Text(" 30+"),
                                      ],
                                    ),
                                  ],
                                )),
                            Positioned(
                                right: 0,
                                bottom: 0,
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        legendClosed = true;
                                      });
                                    },
                                    child: Icon(Icons.close_fullscreen))),
                          ])))
            ]);
          }),
    );
  }

  void _handlePageChange(int index) {
    /// While updating the page viewer through interaction, selected position's
    /// marker should be moved to the center of the maps. However, when the
    /// marker is directly clicked, only the respective card should be moved to
    /// center and the marker itself should not move to the center of the maps.
    if (!_canUpdateFocalLatLng) {
      if (_tappedMarkerIndex == index) {
        _updateSelectedCard(index);
      }
    } else if (_canUpdateFocalLatLng) {
      _updateSelectedCard(index);
    }
  }

  void _updateSelectedCard(int index) {
    setState(() {
      _previousSelectedIndex = _currentSelectedIndex;
      _currentSelectedIndex = index;
    });

    /// While updating the page viewer through interaction, selected position's
    /// marker should be moved to the center of the maps. However, when the
    /// marker is directly clicked, only the respective card should be moved to
    /// center and the marker itself should not move to the center of the maps.
    if (_canUpdateFocalLatLng) {
      _zoomPanBehavior.focalLatLng = MapLatLng(
          _worldWonders[_currentSelectedIndex].latitude,
          _worldWonders[_currentSelectedIndex].longitude);
    }

    /// Updating the design of the selected marker. Please check the
    /// `markerBuilder` section in the build method to know how this is done.
    _mapController
        .updateMarkers([_currentSelectedIndex, _previousSelectedIndex]);
    _canUpdateFocalLatLng = true;
  }
}

class _WonderDetails {
  const _WonderDetails(
      {@required this.title,
      @required this.id,
      @required this.imagePath,
      @required this.latitude,
      @required this.longitude,
      @required this.description,
      @required this.goingCount,
      @required this.tooltipImagePath});

  final String title;
  final String id;
  final double latitude;
  final double longitude;
  final String description;
  final int goingCount;
  final String imagePath;
  final String tooltipImagePath;
}

abstract class SampleView extends StatefulWidget {
  /// base class constructor of sample's stateful widget class
  const SampleView({Key key}) : super(key: key);
}

/// Base class of the sample's state class
abstract class SampleViewState extends State<SampleView> {
  /// Holds the SampleModel information

  /// Holds the information of current page is card view or not
  bool isCardView;

  @override
  void initState() {
    super.initState();
  }

  @override

  /// Must call super.
  void dispose() {
    super.dispose();
  }

  /// Get the settings panel content.
  Widget buildSettings(BuildContext context) {
    return null;
  }
}

///Chart sample data
class ChartSampleData {
  /// Holds the datapoint values like x, y, etc.,
  ChartSampleData(
      {this.x,
      this.y,
      this.xValue,
      this.yValue,
      this.secondSeriesYValue,
      this.thirdSeriesYValue,
      this.pointColor,
      this.size,
      this.text,
      this.open,
      this.close,
      this.low,
      this.high,
      this.volume});

  /// Holds x value of the datapoint
  final dynamic x;

  /// Holds y value of the datapoint
  final num y;

  /// Holds x value of the datapoint
  final dynamic xValue;

  /// Holds y value of the datapoint
  final num yValue;

  /// Holds y value of the datapoint(for 2nd series)
  final num secondSeriesYValue;

  /// Holds y value of the datapoint(for 3nd series)
  final num thirdSeriesYValue;

  /// Holds point color of the datapoint
  final Color pointColor;

  /// Holds size of the datapoint
  final num size;

  /// Holds datalabel/text value mapper of the datapoint
  final String text;

  /// Holds open value of the datapoint
  final num open;

  /// Holds close value of the datapoint
  final num close;

  /// Holds low value of the datapoint
  final num low;

  /// Holds high value of the datapoint
  final num high;

  /// Holds open value of the datapoint
  final num volume;
}

/// Chart Sales Data
class SalesData {
  /// Holds the datapoint values like x, y, etc.,
  SalesData(this.x, this.y, [this.date, this.color]);

  /// X value of the data point
  final dynamic x;

  /// y value of the data point
  final dynamic y;

  /// color value of the data point
  final Color color;

  /// Date time value of the data point
  final DateTime date;
}
