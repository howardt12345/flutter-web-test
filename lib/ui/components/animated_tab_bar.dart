import 'package:flutter/material.dart';

class AnimatedTabBar extends StatefulWidget {
  final List<String> titles;
  final Duration animationDuration;
  final Function onBarTap;
  final BarStyle barStyle;
  int startingIndex = 0;

  AnimatedTabBar({
    this.titles,
    this.animationDuration = const Duration(milliseconds: 500),
    this.onBarTap,
    this.barStyle,
    this.startingIndex,
  });

  @override
  _AnimatedTabBarState createState() => _AnimatedTabBarState();
}

class _AnimatedTabBarState extends State<AnimatedTabBar>
    with TickerProviderStateMixin {
  int selectedBarIndex = 0;

  @override
  void initState() {
    setState(() {
      selectedBarIndex = widget.startingIndex;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _buildBarItems(),
      ),
    );
  }

  List<Widget> _buildBarItems() {
    var color = Theme.of(context).textTheme.subtitle.color;
    List<Widget> _barItems = List();
    for (int i = 0; i < widget.titles.length; i++) {
      String title = widget.titles[i];
      bool isSelected = selectedBarIndex == i;
      _barItems.add(InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          setState(() {
            selectedBarIndex = i;
            widget.onBarTap(selectedBarIndex);
          });
        },
        child: AnimatedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          duration: widget.animationDuration,
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.75)
                : Color.fromRGBO(255 - color.red, 255 - color.green, 255 - color.blue, color.opacity),
            borderRadius: BorderRadius.all(
                Radius.circular(30)
            )
          ),
          child: Row(
            children: <Widget>[
              AnimatedSize(
                duration: widget.animationDuration,
                curve: Curves.easeInOut,
                vsync: this,
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Color.fromRGBO(255 - color.red, 255 - color.green, 255 - color.blue, color.opacity) : color,
                    fontWeight: widget.barStyle.fontWeight,
                    fontSize: widget.barStyle.fontSize
                  ),
                ),
              )
            ],
          ),
        ),
      ));
    }
    return _barItems;
  }
}

class BarStyle {
  final double fontSize, iconSize;
  final FontWeight fontWeight;

  BarStyle({
    this.fontSize = 18.0,
    this.iconSize = 32,
    this.fontWeight = FontWeight.w600
  });
}