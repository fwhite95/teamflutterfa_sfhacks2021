import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:teamflutterfa_sfhacks2021/main.dart';
import 'package:teamflutterfa_sfhacks2021/src/services/place_service.dart';
import 'package:teamflutterfa_sfhacks2021/src/views/add_address_view.dart';

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

    location.onLocationChanged.listen((LocationData currentLocation) async{
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
          if(meter < 20){
            _arrived = true;
            print('I arrived');
          }else if(_arrived && meter > 10 && meter < 30){
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
        return Container(
          child: ListTile(
            title: Text(address[index].name),
            subtitle: Text(
                'lat: ${address[index].place.lat.toString()} , lng: ${address[index].place.lng.toString()}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  address.removeAt(index);
                });
              },
            ),
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
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
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddAddressView(
                            address: address,
                          )),
                ).then(onGoBack);
              }),
        ],
      ),
      body: address.length > 0 ? _listBody() : _emptyBody(),
    );
  }
}
