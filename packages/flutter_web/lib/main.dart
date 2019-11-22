import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_raytracing/pages/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Raytracing',
      theme: ThemeData.dark(),
      home: mainWidget((str) => window.open(str, str)),
    );
  }
}