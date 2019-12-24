import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'dart:html' as html;

import 'package:url_launcher/url_launcher.dart';

double screenWidth({BuildContext context}) {
  return MediaQuery.of(context).size.width;
}
double screenHeight({BuildContext context}) {
  return MediaQuery.of(context).size.height;
}

openUrl(String url) async {
  try{
    if(Platform.isAndroid || Platform.isIOS) {
      print("opening link on mobile");
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      print("opening link on web");
      html.window.open(url, '${Random.secure().nextInt(1000000000)}');
    }
  } catch(e) {
    print("opening link on web");
    html.window.open(url, '${Random.secure().nextInt(1000000000)}');
  }
}
