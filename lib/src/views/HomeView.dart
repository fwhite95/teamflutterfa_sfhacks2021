import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  
  
  @override
  State<StatefulWidget> createState() => _HomeViewState();

}

class _HomeViewState extends State<HomeView> {

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Added Addresses'),
      ),
      body: Center(
        child: Text('Hello World'),
      ),
    );
  }
  
}