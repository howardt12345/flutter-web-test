import 'package:flutter/material.dart';
import 'package:flutter_web_test/utils/functions.dart';



class PortfolioPage extends StatefulWidget {
  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  double _screenSize = 0;

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

  _buildVerticalLayout() {
    return Container(
      child: Center(
        child: Text("Portfolio Vertical"),
      ),
    );
  }
  _buildHorizontalLayout() {
    return Container(
      child: Center(
        child: Text("Portfolio Horizontal"),
      ),
    );
  }
}
