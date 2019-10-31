import 'package:flutter/material.dart';
import 'package:flutter_web_test/utils/functions.dart';



class PortfolioPage extends StatefulWidget {
  Map<String, List> menu = {
    "Category1": [
      "Subcategory 1"
      "Subcategory 2"
      "Subcategory 3"
    ],
    "Category2": [
      "Subcategory 1"
      "Subcategory 2"
      "Subcategory 3"
    ]
  };

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  List<String> _data = [];
  
  int _index = 0, _subindex = 0;

  double _screenSize = 0;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    _data = widget.menu.keys.toList();
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
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: _buildDrawer(),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text("Portfolio Horizontal"),
            ),
          ),
        ],
      ),
    );
  }
  
  _buildDrawer() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            width: 1.0,
            color: Theme.of(context).textTheme.title.color
          )
        )
      ),
      child: Center(
        child: AnimatedList(
          initialItemCount: _data.length,
          itemBuilder: (context, index, animation) => _buildItem(context, _data[index], index, animation),
        ),
      ),
    );
  }


  Widget _buildItem(BuildContext context, String item, int index, Animation animation) {
    TextStyle textStyle = new TextStyle(fontSize: 20);

    return GestureDetector(
      onTap: () {
        setState(() {
          _index = index;
        });
      },
      child: Column(
        children: <Widget>[
          SizedBox(height: 16.0),
          Text(
            item,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.body2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: _index == index ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153)
            ),
          ),
          SizedBox(height: 8.0),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            width: _index == index ? item.length * 9.0 : 0,
            height: 2.0,
            color: Theme.of(context).textTheme.body2.color,
            curve: Curves.ease,
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatefulWidget {
  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
