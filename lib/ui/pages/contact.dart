import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_web_test/ui/components/picture_manager.dart';
import 'package:flutter_web_test/ui/pages/home.dart';
import 'package:flutter_web_test/utils/functions.dart';

import 'package:easy_google_maps/easy_google_maps.dart';
import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart' as fs;

import 'package:http/http.dart' as http;

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _subjectController = new TextEditingController();
  final TextEditingController _bodyController = new TextEditingController();

  FocusNode _focusNodeName = new FocusNode();
  FocusNode _focusNodeEmail = new FocusNode();
  FocusNode _focusNodeSubject = new FocusNode();
  FocusNode _focusNodeBody = new FocusNode();

  bool _autovalidate = false, _formWasEdited = false, _submitted = false;

  double _screenSize = 0;

  Map<String, String> contact = Map<String, String>();


  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
    _focusNodeName.dispose();
    _focusNodeEmail.dispose();
    _focusNodeSubject.dispose();
    _focusNodeBody.dispose();

    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
  }

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
                      child: Container(
                        width: 400,
                        height: 500,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 24.0,
                            ),
                            _buildContactForm(),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 16.0,
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
                            height: 350,
                            child: EasyGoogleMaps(
                              apiKey: 'AIzaSyCFHFzyeZZhepypQ_IypfDKiSxRLQA97GE',
                              address: 'K1N 1H6, Ottawa, Ontario',
                              title: 'Location',
                            ),
                          ),
                          buildIconBar(hover: false),
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
                    size: 24,
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

  _buildContactForm() {
    return Form(
      key: _formKey,
      autovalidate: _autovalidate,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.text,
              focusNode: _focusNodeName,
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name *',
              ),
              maxLines: 1,
              validator: _validateName,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(_focusNodeEmail);
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              focusNode: _focusNodeEmail,
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email *',
              ),
              maxLines: 1,
              validator: _validateEmail,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(_focusNodeSubject);
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              keyboardType: TextInputType.text,
              focusNode: _focusNodeSubject,
              controller: _subjectController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Subject *',
              ),
              maxLines: 1,
              validator: _validateSubject,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(_focusNodeBody);
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              keyboardType: TextInputType.multiline,
              focusNode: _focusNodeBody,
              controller: _bodyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Body *',
              ),
              maxLines: 5,
              validator: _validateBody,
            ),
            SizedBox(height: 8.0),
            Text(
              '* indicates required field',
              style: Theme.of(context).textTheme.caption,
            ),
            SizedBox(height: 8.0),
            Center(
              child: !_submitted ? RaisedButton(
                elevation: 0.0,
                child: const Text('SUBMIT'),
                onPressed: _handleSubmitted,
              ) : ListTile(
                title: Text("Thanks for submitting!"),
                trailing: FlatButton(
                  child: Text("OK"),
                  onPressed: () => setState(() => _submitted = false),
                ),
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true;
    } else {
      form.save();
      var name = _nameController.text.trim();
      var email = _emailController.text.trim();
      var subject = _subjectController.text;
      var body = _bodyController.text;

      fs.Firestore store = firestore();
      fs.CollectionReference ref = store.collection("messages");
      ref.doc().set({
        'name': name,
        'email': email,
        'subject': subject,
        'body': body,
        'date': DateTime.now(),
      }).catchError((e) => print(e));

      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _bodyController.clear();

      setState(() {
        _submitted = true;
      });
    }
  }

  String _validateName(String value) {
    _formWasEdited = true;
    if (value.isEmpty)
      return 'Name is required.';
    return null;
  }

  String _validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Email is invalid.';
    else
      return null;
  }

  String _validateSubject(String value) {
    _formWasEdited = true;
    if (value.isEmpty)
      return 'Subject is required.';
    return null;
  }

  String _validateBody(String value) {
    _formWasEdited = true;
    if (value.isEmpty)
      return 'Body is required.';
    return null;
  }

  String randomString(int length) {
    const chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < length; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
  }
}
