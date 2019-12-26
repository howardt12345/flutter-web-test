import 'dart:html' as html;

import "package:flutter/material.dart";

import 'package:flutter_web_test/ui/pages/about.dart';
import 'package:flutter_web_test/ui/pages/contact.dart';
import 'package:flutter_web_test/ui/pages/home.dart';
import 'package:flutter_web_test/ui/pages/portfolio_new.dart';

import 'package:flutter_web_test/utils/functions.dart';
import 'package:flutter_web_test/utils/route.dart';

import 'components/animated_tab_bar.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'components/scrollable_positioned_list/scrollable_positioned_list.dart';

class Main extends StatefulWidget {
  int initialPage;

  Main({this.initialPage = 0});


  static Route<dynamic> homeRoute() {
    return SimpleRoute(
      name: '/',
      title: 'Howard Tseng',
      builder: (_) => Main(initialPage: 0,),
    );
  }
  static Route<dynamic> aboutRoute() {
    return SimpleRoute(
      name: '/about',
      title: 'Howard Tseng',
      builder: (_) => Main(initialPage: 1,),
    );
  }
  static Route<dynamic> portfolioRoute() {
    return SimpleRoute(
      name: '/portfolio',
      title: 'Howard Tseng',
      builder: (_) => Main(initialPage: 2,),
    );
  }
  static Route<dynamic> contactRoute() {
    return SimpleRoute(
      name: '/contact',
      title: 'Howard Tseng',
      builder: (_) => Main(initialPage: 3,),
    );
  }

  final List<String> titles = [
    "Home",
    "About",
    "Portfolio",
    "Contact",
  ];
  final List<String> paths = [
    "",
    "about",
    "portfolio",
    "contact",
  ];
  final List<Widget> pages = [
    HomePage(),
    AboutPage(),
    PortfolioPage(),
    ContactPage(),
  ];

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> with TickerProviderStateMixin {
  AnimationController _controller;
  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionListener = ItemPositionsListener.create();
  TabController _tabController;

  int selectedBarIndex = 0;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    _tabController = TabController(length: widget.pages.length, vsync: this);
    selectedBarIndex = widget.initialPage;
    itemPositionListener.itemPositions.addListener(() async {
      await Future.delayed(Duration(milliseconds: 500));
      int min = itemPositionListener.itemPositions.value.where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce((ItemPosition min, ItemPosition position) =>
      position.itemTrailingEdge < min.itemTrailingEdge
          ? position
          : min)
          .index;
      int max = itemPositionListener.itemPositions.value
          .where((ItemPosition position) => position.itemLeadingEdge < 1)
          .reduce((ItemPosition max, ItemPosition position) =>
      position.itemLeadingEdge > max.itemLeadingEdge
          ? position
          : max)
          .index;

      int currentIndex = min == 0
          ? 0
          : max == widget.pages.length-1
            ? widget.pages.length-1
            : min;

      if(selectedBarIndex != currentIndex) {
        _tabController.animateTo(currentIndex);
        setState(() {
          selectedBarIndex = currentIndex;
        });
      }

      html.window.history.pushState("", widget.titles[currentIndex], currentIndex == 0 ? '/' : "/#/${widget.paths[currentIndex].toLowerCase()}");
    });
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 500));
      itemScrollController.scrollTo(index: widget.initialPage, duration: Duration(milliseconds: 500), curve: Curves.easeInOutQuint);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return _buildPage(orientation == Orientation.portrait || screenWidth(context: context) <= 600);
      },
    );
  }

  _buildTabBar() {
    var color = Theme.of(context).textTheme.subtitle.color;
    return TabBar(
      labelColor: Color.fromRGBO(255 - color.red, 255 - color.green, 255 - color.blue, color.opacity),
      unselectedLabelColor: color,
      indicator: BubbleTabIndicator(
        indicatorHeight: 32.0,
        indicatorColor: color.withOpacity(0.75),
        tabBarIndicatorSize: TabBarIndicatorSize.tab,
      ),
      controller: _tabController,
      tabs: widget.titles.map((title) => Tab(text: title,)).toList(),
      onTap: (index) {
        setState(() {
          selectedBarIndex = index;
        });
        itemScrollController.scrollTo(index: index, duration: Duration(milliseconds: 500), curve: Curves.easeInOutQuint);
      },
    );
  }

  _buildList(bool isPortrait) => ScrollablePositionedList.builder(
    itemCount: widget.pages.length,
    itemBuilder: (context, index) => index == 0 ? widget.pages[index] : Container(
      child: Column(
        children: <Widget>[
          Container(
            width: 800,
            padding: EdgeInsets.only(
              top: 24.0,
              left: 8.0,
              right: 8.0
            ),
            child: _buildTitle(
                isPortrait: isPortrait,
                title: widget.titles[index],
                alignment: index % 2 == 1 ? Alignment.topLeft : Alignment.topRight
            ),
          ),
          widget.pages[index],
        ],
      ),
    ),
    itemScrollController: itemScrollController,
    itemPositionsListener: itemPositionListener,
  );

  _buildPage(bool isPortrait) {
    return Scaffold(
      appBar: isPortrait ? PreferredSize(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 8.0,
            ),
            child: _buildTabBar(),
          ),
        ),
        preferredSize: new Size.fromHeight(56.0),
      ) : null,
      body: Stack(
        children: <Widget>[
          Container(
            child: _buildList(isPortrait)
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: widget.titles.length * 100.0,
              child: !isPortrait ? _buildTabBar() : null,
            ),
          ),
        ],
      )
    );
  }

  _buildTitle({bool isPortrait, String title, Alignment alignment}) => Align(
    alignment: alignment,
    child: RichText(
      text: TextSpan(
        text: title,
        style: Theme.of(context).textTheme.title.copyWith(
            fontSize: isPortrait ? 46 : 56
        ),
      ),
    ),
  );
}
