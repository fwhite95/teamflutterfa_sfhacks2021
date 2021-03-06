import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:teamflutterfa_sfhacks2021/src/util/config.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String> address = [];

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
        return ListTile(
          title: Text(address[index]),
        );
      },
    );
  }

  Widget _emptyBody() {
    return Center(
      child: Text('Please add an address'),
    );
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
                
              }),
        ],
      ),
      body: address.length > 0 ? _listBody() : _emptyBody(),
    );
  }
}
