import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teamflutterfa_sfhacks2021/src/views/add_address_view.dart';
import 'package:teamflutterfa_sfhacks2021/src/views/home_view.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterFA',
      home: HomeView(), //AddAddressView(),
    );
  }
}
