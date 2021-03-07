import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:teamflutterfa_sfhacks2021/main.dart';
import 'package:teamflutterfa_sfhacks2021/src/services/place_service.dart';
import 'package:teamflutterfa_sfhacks2021/src/views/add_address_view.dart';
import 'package:teamflutterfa_sfhacks2021/src/views/extra.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<MyLocation> address = [];
  LocationData _currentPosition;
  Location location = Location();
  final Distance distance = Distance();
  int meterDistance;

  bool _arrived = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, 'Hello From Mask Reminder', 'Wear a mask', platformChannelSpecifics,
        payload: 'item x');
  }

  getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        throw Exception('Location services not enabled');
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission not granted');
      }
    }

    _currentPosition = await location.getLocation();
    print('locationData: $_currentPosition');

    location.onLocationChanged.listen((LocationData currentLocation) async {
      print('Stream: $currentLocation');
      setState(() {
        _currentPosition = currentLocation;
      });
      if (address.isNotEmpty) {
        for (MyLocation temp in address) {
          double meter = distance(
            LatLng(double.parse(temp.place.lat), double.parse(temp.place.lng)),
            LatLng(_currentPosition.latitude, _currentPosition.longitude),
          );
          print('Meter: $meter');
          if (meter < 20) {
            _arrived = true;
            print('I arrived');
          } else if (_arrived && meter > 10 && meter < 30) {
            print('I am leaving here');
            _showNotification();
            _arrived = false;
          }
        }
      }
    });
  }

//changed to pull list from DB
  Widget _listBody() {
    return ListView.builder(
      itemCount: address.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300], blurRadius: 2, spreadRadius: 2)
              ],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Titletext(
                          address[index].name + ' Address',
                          fontweight: FontWeight.w900,
                          size: 18,
                          color: Colors.orange,
                        ),
                        Divider(
                          color: Colors.black,
                          endIndent: MediaQuery.of(context).size.width * 0.25,
                        ),
                        Titletext(
                          address[index].address,
                          maxLine: 2,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        address.removeAt(index);
                      });
                    },
                    child: Icon(Icons.delete),
                  )
                ],
              ),
            ),
          ),
        );
        
      },
    );
  }

  Widget _emptyBody() {
    return Center(
      child: Text('Please add an address'),
    );
  }

  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Addresses'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          // AddAddressView(
                          //       address: address,
                          //     )),
                          MapUI(
                              address: address,
                              currentPosition: _currentPosition)),
                ).then(onGoBack);
              }),
        ],
      ),
      body: address.length > 0 ? _listBody() : _emptyBody(),
    );
  }
}
