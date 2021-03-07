import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:teamflutterfa_sfhacks2021/src/services/address_search.dart';
import 'package:teamflutterfa_sfhacks2021/src/services/place_service.dart';
import 'package:uuid/uuid.dart';

class MapUI extends StatefulWidget {
  final List<MyLocation> address;
  final LocationData currentPosition;

  MapUI({
    Key key,
    this.address,
    this.currentPosition,
  }) : super(key: key);

  @override
  _MapUIState createState() => _MapUIState();
}

List<bool> addressTypebool = [true, false, false];
String addressType = "Home";

class _MapUIState extends State<MapUI> {
  TextEditingController addressController = TextEditingController();
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  String addressText = "";
  GoogleMapController _controller;
  bool locationFound = false;
  double latitude;
  double longitude;
  double height;
  double width;

  CameraPosition initialLocation;
  Suggestion suggestion;

  void updateMarkerAndCircle(
      LocationData newLocalData, LatLng newLocalDatalatlng) async {
    LatLng latlng = newLocalDatalatlng;

    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: 0,
          draggable: true,
          zIndex: 2,
          anchor: Offset(0.5, 0.5));
    });
  }

  Future getCurrentLocation(LatLng locationlatlng) async {
    try {
      var location;
      if (locationlatlng == null) {
        location = await _locationTracker.getLocation();
        getAddress(
            coordinates: Coordinates(location.latitude, location.longitude));
      } else {
        location = locationlatlng;
        await getAddress(
            coordinates: Coordinates(location.latitude, location.longitude));
      }
      await _controller.animateCamera(CameraUpdate.newCameraPosition(
          new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(location.latitude, location.longitude),
              tilt: 30.2,
              zoom: 18.00)));
      updateMarkerAndCircle(
          null, LatLng(location.latitude, location.longitude));

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  Future getAddress({Coordinates coordinates}) async {
    latitude = coordinates.latitude;
    longitude = coordinates.longitude;
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses?.first;
    addressText = '${first.addressLine ?? ""}';
    addressText.replaceAll("null", " ");
  }

  @override
  void initState() {
    super.initState();
    //getCurrentLocation(LatLng(widget.currentPosition.latitude, widget.currentPosition.longitude));
    initialLocation = CameraPosition(
      target: LatLng(
          widget.currentPosition.latitude, widget.currentPosition.longitude),
      zoom: 14.4,
    );
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  Widget locationMap() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          height: height * 0.5,
          child: GoogleMap(
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            onTap: (value) async {
              await getCurrentLocation(value).then((value) => {});

              setState(() {});
            },
            mapType: MapType.normal,
            initialCameraPosition: initialLocation,
            compassEnabled: false,
            markers: Set.of((marker != null) ? [marker] : []),
            circles: Set.of((circle != null) ? [circle] : []),
            onMapCreated: (GoogleMapController controller) async {
              _controller = controller;
              await getCurrentLocation(null)
                  .then((value) => {locationFound = true});
              setState(() {});
            },
          ),
        ),
        Positioned.fill(
            child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                child: BackIconBackGroundBlur(
                  backIconColor: Colors.grey[900],
                ),
              )),
        ))
      ],
    );
  }

  Widget mapButtom() {
    return Container(
      height: height * 0.08,
      width: width,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.grey[300], blurRadius: 1, spreadRadius: 1)
      ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
        child: locationFound
            ? Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.search,
                    ),
                    color: Colors.orange,
                    onPressed: () async {
                      final Suggestion result = await showSearch(
                        context: context,
                        delegate: AddressSearch(Uuid().v4()),
                      );
                      if (result != null) {
                        final placeDetails = await PlaceApiProvider(Uuid().v4())
                            .getPlaceDetailFromId(result.placeId);
                        setState(() {
                          addressText = result.description;
                          suggestion = result;
                          getCurrentLocation(LatLng(
                              double.parse(placeDetails.lat),
                              double.parse(placeDetails.lng)));
                        });
                      }
                    },
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                    width: width * 0.65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Titletext(
                          addressText,
                          size: 18,
                          fontweight: FontWeight.bold,
                        ),
                        Titletext(
                            "Tap anywhere on the map to change the location",
                            size: 12,
                            color: Colors.grey)
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Titletext(
                        "Please Wait...",
                        size: 18,
                        fontweight: FontWeight.w900,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Titletext(
                      "while we automatically get your location",
                      size: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget locationDetailsSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: addressController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_city),
                labelText: "Flat No, Area, Landmark etc.",
                labelStyle: TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(10)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.orange, width: 4.0),
                )),
          ),
          SizedBox(
            height: height * 0.025,
          ),
          Titletext(
            "Save Address As",
            color: Colors.black,
            fontweight: FontWeight.w900,
            size: 18,
          ),
          SizedBox(
            height: height * 0.015,
          ),
          Container(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                InkWell(
                  onTap: () {
                    addressType = "Home";
                    addressTypebool = [true, false, false];
                    setState(() {});
                  },
                  child: Container(
                    width: 100,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color:
                              addressTypebool[0] ? Colors.orange : Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[300],
                                blurRadius: 1,
                                spreadRadius: 1)
                          ]),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home,
                              color: addressTypebool[0]
                                  ? Colors.white
                                  : Colors.orange,
                              size: 20,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Titletext(
                              "Home",
                              color: addressTypebool[0]
                                  ? Colors.white
                                  : Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: InkWell(
                    onTap: () {
                      addressType = "Office";

                      addressTypebool = [false, true, false];
                      setState(() {});
                    },
                    child: Container(
                      width: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[300],
                                blurRadius: 1,
                                spreadRadius: 1)
                          ],
                          color:
                              addressTypebool[1] ? Colors.orange : Colors.white,
                        ),
                        height: 50,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.work,
                                color: addressTypebool[1]
                                    ? Colors.white
                                    : Colors.orange,
                                size: 20,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Titletext(
                                "Office",
                                color: addressTypebool[1]
                                    ? Colors.white
                                    : Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    addressType = "Other";

                    addressTypebool = [false, false, true];
                    setState(() {});
                  },
                  child: Container(
                    width: 100,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color:
                              addressTypebool[2] ? Colors.orange : Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[300],
                                blurRadius: 1,
                                spreadRadius: 1)
                          ]),
                      height: 50,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map,
                                size: 20,
                                color: addressTypebool[2]
                                    ? Colors.white
                                    : Colors.orange),
                            SizedBox(
                              width: 4,
                            ),
                            Titletext(
                              "Other",
                              color: addressTypebool[2]
                                  ? Colors.white
                                  : Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: height * 0.05,
          ),
          InkWell(
            onTap: () async {},
            child: Container(
              width: width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.orange),
              height: height * 0.075,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      FlutterIcons.add_location_mdi,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Titletext(
                      "Add Address",
                      color: Colors.white,
                      size: 18,
                      fontweight: FontWeight.w900,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              locationMap(),
              mapButtom(),
              SizedBox(
                height: height * 0.01,
              ),
              locationDetailsSelector(),
            ],
          ),
        ),
      ),
    );
  }
}

class BackIconBackGroundBlur extends StatelessWidget {
  final double size;
  final Color circleColor;
  final Color backIconColor;
  BackIconBackGroundBlur(
      {this.size = 25, this.circleColor, this.backIconColor});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Stack(
            children: [
              Container(
                width: size + 20,
                height: size + 20,
                child: Center(
                    child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: backIconColor ?? Colors.white,
                  size: 20,
                )),
                decoration: BoxDecoration(
                  color: circleColor ?? Colors.grey.withOpacity(.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Titletext extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final double minSize;
  final TextStyle customStyle;
  final double letterSpacing;
  final TextAlign textAlign;
  final int maxLine;
  final TextOverflow textFlow;
  final FontWeight fontweight;
  Titletext(this.text,
      {this.textFlow,
      this.textAlign,
      this.customStyle,
      this.letterSpacing,
      this.color,
      this.minSize,
      this.size,
      this.fontweight,
      this.maxLine});
  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      textAlign: textAlign ?? null,
      style: customStyle ??
          TextStyle(
              fontSize: size ?? 16,
              color: color ?? Colors.black,
              letterSpacing: letterSpacing ?? 1,
              fontWeight: fontweight ?? FontWeight.normal),
      maxLines: maxLine ?? 1,
      overflow: textFlow ?? TextOverflow.ellipsis,
    );
  }
}
