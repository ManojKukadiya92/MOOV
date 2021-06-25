import 'package:MOOV/accountCreation/createAccountLanding.dart';
import 'package:MOOV/pages/NewSearch.dart';
import 'package:MOOV/pages/create_account.dart';
import 'package:MOOV/pages/home.dart';
import 'package:MOOV/utils/themes_styles.dart';
import 'package:MOOV/widgets/progress.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

typedef void Callback(String val);

class GoogleMap extends StatefulWidget {
  final bool fromMOOVMaker;
  final Callback callback;
  final Callback callback2;
  final Callback callback3;
  final List coords;
  final String businessName, businessType;

  GoogleMap(
      {this.fromMOOVMaker,
      this.callback,
      this.callback2,
      this.callback3,
      this.coords,
      this.businessName,
      this.businessType});

  static final kInitialPosition = LatLng(-33.8567844, 151.213108);

  @override
  _GoogleMapState createState() => _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMap> {
  PickResult selectedPlace;
  Future<List<Location>> locationFromAddress(
    String address, {
    String localeIdentifier,
  }) =>
      GeocodingPlatform.instance.locationFromAddress(
        address,
      );

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

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return TextThemes.ndGold;
      }
      return Colors.green;
    }

    determinePosition();
    return (!widget.fromMOOVMaker)
        ? Container(
            height: 300,
            width: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 50),
                  DelayedDisplay(
                    delay: Duration(milliseconds: 200),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ),
                        Text(
                          "Where's your business?",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Expanded(
                    child: Container(
                      height: 500,
                      child: PlacePicker(
                        apiKey: "AIzaSyCXudnefDivWtB4O7nrToB-3Bu13-TEF8A",
                        initialPosition: GoogleMap.kInitialPosition,
                        useCurrentLocation: true,
                        selectInitialPosition: true,

                        //usePlaceDetailSearch: true,
                        onPlacePicked: (result) {
                          selectedPlace = result;
                          // Navigator.of(context).pop();
                          setState(() {});
                        },
                        //forceSearchOnZoomChanged: true,
                        //automaticallyImplyAppBarLeading: false,
                        //autocompleteLanguage: "ko",
                        //region: 'au',
                        //selectInitialPosition: true,
                        selectedPlaceWidgetBuilder:
                            (_, _selectedPlace, state, isSearchBarFocused) {
                          return isSearchBarFocused
                              ? Container()
                              : FloatingCard(
                                  bottomPosition:
                                      0.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                                  leftPosition: 0.0,
                                  rightPosition: 0.0,
                                  width: 100,
                                  height: 30,
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: state == SearchingState.Searching
                                      ? Center(child: linearProgress())
                                      : TextButton(
                                          child: Text("Set Address",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .resolveWith(getColor)),
                                          onPressed: () {
                                            selectedPlace = _selectedPlace;
                                            setState(() {});
                                          },
                                        ),
                                );
                        },
                        // pinBuilder: (context, state) {
                        //   if (state == PinState.Idle) {
                        //     return Icon(Icons.favorite_border);
                        //   } else {
                        //     return Icon(Icons.favorite);
                        //   }
                        // },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  selectedPlace == null
                      ? DelayedDisplay(
                          delay: Duration(milliseconds: 200),
                          child: Text(
                            "Drag the pin to the exact spot",
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : FutureBuilder(
                          future: locationFromAddress(
                              selectedPlace.formattedAddress),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return linearProgress();
                            }
                            if (!snapshot.hasData) {
                              return Container(
                                  child: Text("Can't find an address here!",
                                      style: TextStyle(color: Colors.white)));
                            }

                            List<String> parse =
                                (snapshot.data[0].toString().split(","));
                            String latitude1 = (parse[0]
                                .replaceAll(" ", "")
                                .replaceAll("Latitude:", ""));
                            String longtitude1 = (parse[1]
                                .replaceAll(" ", "")
                                .replaceAll("Longitude:", "")
                                .replaceAll("\n", ""));

                            double latitude = double.parse(latitude1);
                            double longtitude = double.parse(longtitude1);

                            double x = Geolocator.distanceBetween(
                                latitude, longtitude, 41.698399, -86.233917);
                            int y = (x * 3.28084).round();
                            String distancetoStadium =
                                NumberFormat.compact(locale: 'eu').format(y);

                            // BusinessAccountLocationCreation.of(context)
                            //     .businessLocationLatitude = latitude.toString();
                            // BusinessAccountLocationCreation.of(context)
                            //         .businessLocationLongitude =
                            //     longtitude.toString();
                            // BusinessAccountLocationCreation.of(context)
                            //         .businessAddress =
                            //     selectedPlace.formattedAddress;

                            // Future.delayed(Duration(milliseconds: 500), () {
                            //   accountButtonPressed(
                            //       context: context,
                            //       page: BusinessAccountOptionals(widget.businessName, widget.businessType, latitude.(), longtitude.toString(),selectedPlace.formattedAddress, ));
                            // });

                            return Container();

                            // return Padding(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 8.0),
                            //   child: Column(
                            //     children: [
                            //       Text(
                            //         selectedPlace.formattedAddress ?? "",
                            //         textAlign: TextAlign.center,
                            //         style: TextStyle(color: TextThemes.ndGold),
                            //       ),
                            //       SizedBox(height: 5),
                            //       Text(
                            //         "You are $distancetoStadium ft. from Notre Dame Stadium!",
                            //         style: TextStyle(
                            //             fontSize: 8, color: Colors.white),
                            //         textAlign: TextAlign.center,
                            //       )
                            //     ],
                            //   ),
                            // );
                          }),
                  SizedBox(height: 35),
                ],
              ),
            ))
        : Scaffold(
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
            body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GradientText(
                            "Where's",
                            17,
                            gradient: LinearGradient(colors: [
                              Colors.red.shade200,
                              Colors.red.shade900,
                            ]),
                          ),
                          Text(" the MOOV?", style: TextStyle(fontSize: 17)),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text("Public MOOVs are shown on our heatmap!",
                          style: TextStyle(fontSize: 12)),
                      SizedBox(height: 15),
                      Expanded(
                        child: Container(
                          height: 500,
                          child: PlacePicker(
                            apiKey: "AIzaSyCXudnefDivWtB4O7nrToB-3Bu13-TEF8A",
                            initialPosition: GoogleMap.kInitialPosition,
                            useCurrentLocation: true,
                            selectInitialPosition: true,

                            //usePlaceDetailSearch: true,
                            onPlacePicked: (result) {
                              // Navigator.of(context).pop();
                              setState(() {
                                selectedPlace = result;
                              });
                            },
                            //forceSearchOnZoomChanged: true,
                            //automaticallyImplyAppBarLeading: false,
                            //autocompleteLanguage: "ko",
                            //region: 'au',
                            //selectInitialPosition: true,
                            selectedPlaceWidgetBuilder:
                                (_, _selectedPlace, state, isSearchBarFocused) {
                              return isSearchBarFocused
                                  ? Container()
                                  : FloatingCard(
                                      bottomPosition:
                                          0.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                                      leftPosition: 0.0,
                                      rightPosition: 0.0,
                                      width: 100,
                                      height: 50,
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: state == SearchingState.Searching
                                          ? Center(child: linearProgress())
                                          : TextButton(
                                              onPressed: () {
                                                selectedPlace = _selectedPlace;
                                                widget.coords.add(selectedPlace
                                                    .geometry.location);
                                                setState(() {});
                                                Navigator.pop(context);
                                              },
                                              child: Text("Set Address",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith(
                                                              getColor))));
                            },
                            // pinBuilder: (context, state) {
                            //   if (state == PinState.Idle) {
                            //     return Icon(Icons.favorite_border);
                            //   } else {
                            //     return Icon(Icons.favorite);
                            //   }
                            // },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      selectedPlace == null
                          ? Container(
                              height: 50,
                              child: Text("Drag the pin to your exact spot!"))
                          : FutureBuilder(
                              future: locationFromAddress(
                                  selectedPlace.formattedAddress),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState !=
                                    ConnectionState.done) {
                                  return circularProgress();
                                }
                                print(selectedPlace.geometry.location);
                                if (!snapshot.hasData) {
                                  return Container();
                                }

                                List<String> parse =
                                    (snapshot.data[0].toString().split(","));
                                String latitude1 = (parse[0]
                                    .replaceAll(" ", "")
                                    .replaceAll("Latitude:", ""));
                                String longtitude1 = (parse[1]
                                    .replaceAll(" ", "")
                                    .replaceAll("Longitude:", "")
                                    .replaceAll("\n", ""));

                                double latitude = double.parse(latitude1);
                                double longtitude = double.parse(longtitude1);

                                double x = Geolocator.distanceBetween(latitude,
                                    longtitude, 41.698399, -86.233917);
                                int y = (x * 3.28084).round();
                                String distancetoStadium =
                                    NumberFormat.compact(locale: 'eu')
                                        .format(y);

                                CreateAccount.of(context)
                                        .businessLocationLatitude =
                                    latitude.toString();
                                CreateAccount.of(context)
                                        .businessLocationLongitude =
                                    longtitude.toString();
                                CreateAccount.of(context).businessAddress =
                                    selectedPlace.formattedAddress;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        selectedPlace.formattedAddress ?? "",
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(color: TextThemes.ndBlue),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "You are $distancetoStadium ft. from Notre Dame Stadium!",
                                        style: TextStyle(fontSize: 8),
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  ),
                                );
                              }),
                    ],
                  ),
                )),
          );
  }
}
