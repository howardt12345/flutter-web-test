import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import "package:flutter/material.dart";

import 'package:flutter_web_test/ui/pages/about.dart';
import 'package:flutter_web_test/ui/pages/contact.dart';
import 'package:flutter_web_test/ui/pages/home.dart';
import 'package:flutter_web_test/ui/pages/portfolio_new.dart';

import 'package:flutter_web_test/utils/functions.dart';
import 'package:flutter_web_test/utils/route.dart';

import 'components/animated_tab_bar.dart';
import 'components/scrollable_positioned_list/scrollable_positioned_list.dart';

class Main extends StatefulWidget {
  int initialPage;

  Main({this.initialPage});


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

  double _screenSize = 0;
  int selectedBarIndex;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    _tabController = TabController(length: widget.pages.length, vsync: this);
    selectedBarIndex = widget.initialPage;
    itemPositionListener.itemPositions.addListener(() async {
      await Future.delayed(Duration(milliseconds: 200));
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

        int currentIndex = ((min + max)/2).floor().toInt();

        if(selectedBarIndex != currentIndex) {
          _tabController.animateTo(currentIndex);
          setState(() {
            selectedBarIndex = currentIndex;
          });
        }
    });
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(seconds: 1));
      itemScrollController.scrollTo(index: widget.initialPage, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
    });
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
      builder: (context, orientation) {
        return _buildPage(orientation == Orientation.portrait || _screenSize <= 600);
      },
    );
  }

  _buildTabBar() {
    var color = Theme.of(context).textTheme.subtitle.color;
    return TabBar(
      labelColor: Color.fromRGBO(255 - color.red, 255 - color.green, 255 - color.blue, color.opacity),
      unselectedLabelColor: color,
      indicator: BubbleTabIndicator(
        indicatorHeight: 25.0,
        indicatorColor: color.withOpacity(0.75),
        tabBarIndicatorSize: TabBarIndicatorSize.tab,
      ),
      controller: _tabController,
      tabs: widget.titles.map((title) => Tab(text: title,)).toList(),
      onTap: (index) {
        setState(() {
          selectedBarIndex = index;
          itemScrollController.scrollTo(index: index, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
        });
      },
    );
  }

  _buildList() => ScrollablePositionedList.builder(
    itemCount: widget.pages.length,
    itemBuilder: (context, index) => widget.pages[index],
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
            child: _buildList()
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

  _buildHorizontalLayout() {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child: _buildList()
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: widget.titles.length * 100.0,
              child: _buildTabBar(),
            ),
          ),
        ],
      ),
      /*Stack(
          children: <Widget>[
            Container(
              child: ScrollablePositionedList.builder(
                itemCount: widget.pages.length,
                itemBuilder: (context, index) => Container(child: widget.pages[index], height: screenHeight(context: context)),
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionListener
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                width: 400,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 100,
                      width: 100,
                      child: FlatButton(
                        onPressed: () => itemScrollController.scrollTo(index: 2, duration: Duration(milliseconds: 250)),
                        child: Image.asset(
                          'images/logo.png',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    _buildTabBar(currentIndex)
                  ],
                ),
              ),
            ),
          ],
        )*/
      /*Stack(
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
        )*/
    );
  }
}
