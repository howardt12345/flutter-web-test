import "package:flutter/material.dart";
import 'package:flutter_web_test/utils/functions.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  double _screenSize = 0;


  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() => _screenSize = screenWidth(context: context));


    return OrientationBuilder(
      builder: (context, orientation) => Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("Test"),
          ),
        ),
        body: Container(
          child: Center(
            child: Text("Hello, web!"),
          ),
        ),
      ),
    );
  }
}
