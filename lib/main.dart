import 'package:flutter/material.dart';

import 'package:house_helper/blocker_route.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internet Blocker',
      debugShowCheckedModeBanner: false,
      home: BlockerRoute(),
    );
  }
}