import 'package:flutter/material.dart';
import 'package:flutter_web_test/ui/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'howardt12345',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Roboto"
      ),
      home: Main(),
    );
  }
}
