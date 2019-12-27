import 'package:flutter/material.dart';

import 'package:firebase/firebase.dart';

import 'package:flutter_web_test/ui/main.dart';
import 'package:flutter_web_test/utils/scroll_behavior.dart';

void main() {
  if(apps.isEmpty) {
    initializeApp(
        apiKey: "AIzaSyCWIxXQ7u9VbNQRg21pOwRYd1p5i7I0xCI",
        authDomain: "portfolio-49b69.firebaseapp.com",
        databaseURL: "https://portfolio-49b69.firebaseio.com",
        projectId: "portfolio-49b69",
        storageBucket: "portfolio-49b69.appspot.com",
        messagingSenderId: "1036625872430",
        appId: "1:1036625872430:web:6a3af1a45a902c208e81bf",
        measurementId: "G-DXQKNZG8HQ"
    );
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: NoGlowBehavior(),
          child: child,
        );
      },
      onGenerateRoute: (settings) {
        switch(settings.name) {
          case "/": return Main.homeRoute();
          case "/about": return Main.aboutRoute();
          case "/portfolio": return Main.portfolioRoute();
          case "/contact": return Main.contactRoute();
          default: return Main.homeRoute();
        }
      },
      initialRoute: "/",
      title: 'Howard Tseng',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Roboto",
      ),
    );
  }
}
