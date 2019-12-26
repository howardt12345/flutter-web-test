import 'dart:convert';

import 'package:easy_google_maps/easy_google_maps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_test/ui/components/image_manager.dart';
import 'package:flutter_web_test/ui/pages/home.dart';
import 'package:flutter_web_test/utils/functions.dart';

import 'package:http/http.dart' as http;

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
      throw Exception('Failed to load contact info');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            (/*orientation == Orientation.portrait || */screenWidth(context: context) <= 600)
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
                    _buildContactInfo(),
                  ],
                ),
              ),
            ),
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
          child: Container(
            width: 800,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: buildIconInfoBar(),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildContactInfo(),
                          ),
                          Container(height: 12.0,),
                          Container(
                            width: 300,
                            height: 350,
                            color: Colors.green,
                            /*child: EasyGoogleMaps(
                            apiKey: 'AIzaSyCFHFzyeZZhepypQ_IypfDKiSxRLQA97GE',
                            address: '240 Friel Street, Ottawa, Ontario',
                            title: 'Location',
                          ),*/
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                buildCopyrightText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildContactInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contact.keys.map((c) =>
          GestureDetector(
            onTap: () {
              if(c == 'email'){
                openUrl('mailto:${contact[c]}');
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
