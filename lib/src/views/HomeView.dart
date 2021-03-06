import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  
  
  @override
  State<StatefulWidget> createState() => _HomeViewState();

}

class _HomeViewState extends State<HomeView> {
  List<String> address = [];

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          IconButton(icon: Icon(Icons.add), onPressed: () {

          }),
        ],
      ),
      body: Center(
        child: Text('Hello World'),
      ),
    );
  }
  
}