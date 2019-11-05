import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_web_test/ui/components/image_manager.dart';
import 'package:flutter_web_test/utils/functions.dart';

import 'package:http/http.dart' as http;
import 'dart:html' as html;

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  double _screenSize = 0;

  String name, email, subject, body;

  Map<String, String> contact = Map<String, String>();

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
      future: _getContact('https://raw.githubusercontent.com/howardt12345/website/master/contact.json'),
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
            Container(),
            Form(
              key: _formKey,
              autovalidate: _autovalidate,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _buildTitle(true),
                    _buildContactInfo(),
                  ],
                ),
              ),
            ),
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
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 1,
                    child: Form(
                      key: _formKey,
                      autovalidate: _autovalidate,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[

                          ],
                        ),
                      ),
                    ),
                  )
                ],
              )
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
          text: "Contact Me",
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
          GestureDetector(
            onTap: () {
              if(c == 'email'){
                html.window.open('mailto:${contact[c]}', '${Random.secure().nextInt(1000000000)}');
              }
            },
            child: Row(
              children: <Widget>[
                Container(
                  child: Icon(
                    iconMapping[c],
                    size: 16,
                  ),
                  padding: EdgeInsets.only(right: 8.0),
                ),
                RichText(
                  text: TextSpan(
                    text: contact[c],
                    style: Theme.of(context).textTheme.body1,
                  ),
                )
              ],
            ),
          )
      ).toList(),
    );
  }
}
