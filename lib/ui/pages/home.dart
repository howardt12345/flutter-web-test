import 'package:flutter/material.dart';
import 'package:flutter_web_test/utils/custom_icons.dart';
import 'package:flutter_web_test/utils/functions.dart';
import 'dart:html' as html;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  AnimationController _controller;

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
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
              text: TextSpan(
                text: "Hi, I'm Howard!",
                style: Theme.of(context).textTheme.title.copyWith(
                    fontSize: 72
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                text: "An Engineer, Flutter Developer, and Photographer",
                style: Theme.of(context).textTheme.title.copyWith(
                  fontSize: 23,
                  fontWeight: FontWeight.w300
                ),
              ),
            ),
            ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                      CustomIcons.facebook_squared
                  ),
                  onPressed: () => html.window.open("https://www.facebook.com/howardt12345", "Facebook"),
                ),
                IconButton(
                  icon: Icon(
                      CustomIcons.instagram
                  ),
                  onPressed: () => html.window.open("https://www.instagram.com/howardt12345", "Facebook"),
                ),
                IconButton(
                  icon: Icon(
                      CustomIcons.github_circled
                  ),
                  onPressed: () => html.window.open("https://www.github.com/howardt12345", "Facebook"),
                ),
                IconButton(
                  icon: Icon(
                      CustomIcons.linkedin_squared
                  ),
                  onPressed: () => html.window.open("https://www.linkedin.com/in/howardt12345", "Facebook"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
