import 'package:flutter/material.dart';
import 'package:flutter_web_test/ui/main.dart';
import 'package:flutter_web_test/utils/scroll_behavior.dart';

void main() => runApp(MyApp());

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
