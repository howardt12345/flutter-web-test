import "package:flutter/material.dart";

import 'package:flutter_web_test/ui/pages/home.dart';
import 'package:flutter_web_test/ui/pages/portfolio.dart';
import 'package:flutter_web_test/utils/functions.dart';

import 'components/animated_tab_bar.dart';

class Main extends StatefulWidget {
  final List<BarItem> barItems = [
    BarItem(
      text: "Home",
      iconData: Icons.home,
      color: Colors.indigo,
    ),
    BarItem(
      text: "About",
      iconData: Icons.person,
      color: Colors.pinkAccent,
    ),
    BarItem(
      text: "Portfolio",
      iconData: Icons.folder_open,
      color: Colors.yellow.shade900,
    ),
    BarItem(
      text: "Contact",
      iconData: Icons.email,
      color: Colors.teal,
    ),
  ];
  final List<Widget> pages = [
    HomePage(),
    Container(
      decoration: BoxDecoration(
        color: Colors.amber,
      ),
      child: Center(
        child: Text("Page 2"),
      ),
    ),
    PortfolioPage(),
    Container(
      decoration: BoxDecoration(
        color: Colors.teal,
      ),
      child: Center(
        child: Text("Page 4"),
      ),
    ),
  ];

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  double _screenSize = 0;
  int selectedBarIndex = 0;

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
      builder: (context, orientation) =>
          (orientation == Orientation.portrait || _screenSize <= 600)
              ? _buildVerticalLayout()
              : _buildHorizontalLayout(),
    );
  }

  _buildTabBar(index) => AnimatedTabBar(
    startingIndex: index,
    barItems: widget.barItems,
    animationDuration: const Duration(milliseconds: 150),
    barStyle: BarStyle(fontSize: 16.0, iconSize: 24.0),
    onBarTap: (index) {
      setState(() {
        selectedBarIndex = index;
      });
    }
  );

  _buildVerticalLayout() {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              child: widget.pages[selectedBarIndex],
            ),
            Material(
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 8.0,
                ),
                child: _buildTabBar(selectedBarIndex),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildHorizontalLayout() {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              child: widget.pages[selectedBarIndex],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                  width: 400 + _screenSize/16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 40.0,
                      right: _screenSize/16,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    child: _buildTabBar(selectedBarIndex),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
