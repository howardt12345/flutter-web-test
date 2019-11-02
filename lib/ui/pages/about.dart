import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_web_test/ui/components/image_manager.dart';

import 'package:flutter_web_test/utils/functions.dart';
import 'package:flutter_web_test/utils/list_animation.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  ListAnimation _listAnimation;

  double _screenSize = 0;

  String _about;
  Map<String, String> contact = Map<String, String>();

  @override
  void initState() {
    _controller = new AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _listAnimation = new ListAnimation(
      controller: _controller,
      items: 3,
    );
    _controller.forward();
    super.initState();
  }

  Future<void> _getInfo() async {
    _about = await _getAbout('https://raw.githubusercontent.com/howardt12345/flutter-web-test/master/about.txt');
    await _getContact('https://raw.githubusercontent.com/howardt12345/flutter-web-test/master/contact.json');
    return null;
  }

  Future<String> _getAbout(String url) async {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return response.body;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load about info');
    }
  }

  Future<void> _getContact(String url) async {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      var data = json.decode(response.body);
      data.keys.forEach((e) => contact[e] = data[e]);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load about info');
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _screenSize = screenWidth(context: context);
    });
    return FutureBuilder(
      future: _getInfo(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if(snapshot.connectionState == ConnectionState.done){
          return OrientationBuilder(
            builder: (context, orientation) =>
            (orientation == Orientation.portrait || _screenSize <= 600)
                ? _buildVerticalLayout()
                : _buildHorizontalLayout(),
          );
        } else {
          return Center(
            child: Text("oop"),
          );
        }
      },
    );
  }

  _buildVerticalLayout() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildTitle(true),
            _buildContactInfo(),
            _buildAboutInfo(),
            buildIconBar(),
            buildCopyrightText(),
          ],
        ),
      ),
    );
  }

  _buildHorizontalLayout() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        width: 800,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(height: 56.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildTitle(false),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildContactInfo(),
                  ),
                ],
              ),
              Container(height: 8.0),
              _buildAboutInfo(),
              buildIconBar(),
              buildCopyrightText(),
            ],
          ),
        ),
      ),
    );
  }
  _buildTitle(bool isPortrait) => Container(
    child: Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: "About Me",
          style: Theme.of(context).textTheme.title.copyWith(
              fontSize: isPortrait ? 46 : 56
          ),
        ),
      ),
    ),
  );

  
  _buildContactInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contact.keys.map((c) =>
          Row(
            children: <Widget>[
              Icon(
                  iconMapping[c]
              ),
              RichText(
                text: TextSpan(
                  text: contact[c],
                  style: Theme.of(context).textTheme.body1,
                ),
              )
            ],
          )
      ).toList(),
    );
  }
  
  _buildAboutInfo() {
    return Container(
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          text: _about,
          style: Theme.of(context).textTheme.body1.copyWith(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
