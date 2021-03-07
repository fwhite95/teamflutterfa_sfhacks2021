import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:teamflutterfa_sfhacks2021/src/services/place_service.dart';
import 'package:teamflutterfa_sfhacks2021/src/util/config.dart';
import 'package:teamflutterfa_sfhacks2021/src/views/add_address_view.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<MyLocation> address = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
