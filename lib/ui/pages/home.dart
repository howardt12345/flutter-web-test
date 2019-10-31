import 'package:flutter/material.dart';
import 'package:flutter_web_test/ui/components/icon_bar.dart';
import 'package:flutter_web_test/utils/custom_icons.dart';
import 'dart:html' as html;

import 'package:flutter_web_test/utils/functions.dart';
import 'package:flutter_web_test/utils/list_animation.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  ListAnimation _listAnimation;

  double _screenSize = 0, _offset = -10;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() => _screenSize = screenWidth(context: context));
    return AnimatedBuilder(
      builder: (context, child) => _buildPage(context, child),
      animation: _controller,
    );
  }

  Widget _buildPage(BuildContext context, Widget child) {
    return OrientationBuilder(
      builder: (context, orientation) => Stack(
        children: <Widget>[
          Opacity(
            opacity: _listAnimation.animations.map((a) => a.value * 1 / _listAnimation.animations.length).fold(0, (p, c) => p + c),
            child: Image.network(
              "https://raw.githubusercontent.com/howardt12345/Portfolio/master/Nature/(Canon%20EOS%2077D)%202019_10_15%2007_18_05-Edited%20(Web)_.jpg?token=AEATPTFLYQIHGGLLMMVIUZK5YN6CC",
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Transform.translate(
                  offset: Offset(0, _offset + (-_listAnimation.animations[0].value * _offset)),
                  child: Opacity(
                    opacity: _listAnimation.animations[0].value,
                    child: _buildTitle((orientation == Orientation.portrait || _screenSize <= 600)),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, _offset + (-_listAnimation.animations[1].value * _offset)),
                  child: Opacity(
                    opacity: _listAnimation.animations[1].value,
                    child: _buildSubtitle((orientation == Orientation.portrait || _screenSize <= 600)),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, _offset + (-_listAnimation.animations[2].value * _offset)),
                  child: Opacity(
                    opacity: _listAnimation.animations[2].value,
                    child: _buildIconBar(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildTitle(bool isPortrait) => RichText(
    text: TextSpan(
      text: "Hi, I'm Howard!",
      style: Theme.of(context).textTheme.title.copyWith(
          fontSize: isPortrait ? 46 : 56
      ),
    ),
  );
  _buildSubtitle(bool isPortrait) => RichText(
    text: TextSpan(
      text: "An Engineer, Flutter Developer, and Photographer",
      style: Theme.of(context).textTheme.title.copyWith(
          fontSize: isPortrait ? 14 : 18
      ),
    ),
  );

  _buildIconBar() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Padding(
        padding: EdgeInsets.all(12.0),
        child: IconBarButton(
          iconData: CustomIcons.facebook_squared,
          url: "https://www.facebook.com/howardt12345page",
        ),
      ),
      Padding(
        padding: EdgeInsets.all(12.0),
        child: IconBarButton(
          iconData: CustomIcons.instagram,
          url: "https://www.instagram.com/howardt12345",
        ),
      ),
      Padding(
        padding: EdgeInsets.all(12.0),
        child: IconBarButton(
          iconData: CustomIcons.github_circled,
          url: "https://www.github.com/howardt12345",
        ),
      ),
      Padding(
        padding: EdgeInsets.all(12.0),
        child: IconBarButton(
          iconData: CustomIcons.linkedin_squared,
          url: "https://www.linkedin.com/in/howardt12345",
        ),
      ),
    ],
  );

  _buildIconBarOld() => ButtonBar(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      IconButton(
        icon: Icon(
            CustomIcons.facebook_squared
        ),
        onPressed: () =>
            html.window.open(
                "https://www.facebook.com/howardt12345page",
                "Facebook"),
      ),
      IconButton(
        icon: Icon(
            CustomIcons.instagram
        ),
        onPressed: () =>
            html.window.open(
                "https://www.instagram.com/howardt12345",
                "Instagram"),
      ),
      IconButton(
        icon: Icon(
            CustomIcons.github_circled
        ),
        onPressed: () =>
            html.window.open(
                "https://www.github.com/howardt12345", "Github"),
      ),
      IconButton(
        icon: Icon(
            CustomIcons.linkedin_squared
        ),
        onPressed: () =>
            html.window.open(
                "https://www.linkedin.com/in/howardt12345",
                "Linkedin"),
      ),
    ],
  );
}