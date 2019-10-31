import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_web_test/utils/functions.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:transparent_image/transparent_image.dart';

// ignore: must_be_immutable
class PortfolioPage extends StatefulWidget {
  Map<String, List<String>> menu = {
    "Category1": [
      "Subcategory 1",
      "Subcategory 2",
      "Subcategory 3",
    ],
    "Category2": [
      "Subcategory 1",
      "Subcategory 2",
      "Subcategory 3",
    ],
    "Category3": [
      "Subcategory 1",
      "Subcategory 2",
      "Subcategory 3",
      "Subcategory 4",
      "Subcategory 5",

    ]
  };

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  AnimationController _animController;
  ScrollController _scrollController = ScrollController();
  List<String> _data = [];
  int _index = 0, _subindex = 0;
  double _screenSize = 0;

  List<Widget> _tiles = [];

  List<StaggeredTile> _staggeredTiles = const <StaggeredTile>[
    const StaggeredTile.count(12, 2),
    const StaggeredTile.count(4, 5),
    const StaggeredTile.count(4, 3),
    const StaggeredTile.count(4, 5),
    const StaggeredTile.count(4, 3),
    const StaggeredTile.count(4, 5),
    const StaggeredTile.count(4, 3),
    const StaggeredTile.count(4, 5),
    const StaggeredTile.count(4, 3),
    const StaggeredTile.count(4, 5),
    const StaggeredTile.count(4, 3),
  ];

  @override
  void initState() {
    _animController = AnimationController(vsync: this);
    _data = widget.menu.keys.toList();
    super.initState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _tiles = _getWidgets(true);
      _screenSize = screenWidth(context: context);
    });

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
        child: _buildViewer(true),
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
            child: _buildViewer(false),
          ),
        ],
      ),
    );
  }

  _buildViewer(bool portrait) {
    return Container(
      child: StaggeredGridView.count(
        shrinkWrap: true,
        crossAxisCount: portrait ? 8 : 12,
        staggeredTiles: _staggeredTiles,
        children: _tiles,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: const EdgeInsets.all(4.0),
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
          key: _listKey,
          shrinkWrap: true,
          initialItemCount: _data.length,
          itemBuilder: (context, index, animation) => _buildItem(context, _data[index], index, animation),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String item, int index, Animation animation) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _index = index;
          _subindex = 0;
        });
      },
      child: Column(
        children: <Widget>[
          SizedBox(height: 16.0),
          Text(
            item,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.body2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: _index == index ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153)
            ),
          ),
          SizedBox(height: 8.0),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: _index == index ? item.length * 9.0 : 0,
            height: 2.0,
            color: Theme.of(context).textTheme.body2.color,
            curve: Curves.ease,
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _index == index ? widget.menu[_data[index]].length * 48 : 0,
            curve: Curves.ease,
            child: _index == index ? Column(
              children: widget.menu[_data[index]].map((s) => _buildSubMenu(context, s, widget.menu[_data[index]].indexOf(s))).toList(),
            ) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenu(BuildContext context, String item, int subindex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _subindex = subindex;
        });
      },
      child: Column(
        children: <Widget>[
          SizedBox(height: 16.0),
          Text(
            item,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.body2.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: _subindex == subindex ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153)
            ),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }

  List<Widget> _getWidgets(bool portrait) {
    List<Widget> tiles = [
      Align(
        alignment: Alignment.centerLeft,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(8.0),
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: _data[_index],
                  style: Theme.of(context).textTheme.body1.copyWith(
                    fontSize: 40,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  text: widget.menu[_data[_index]][_subindex],
                  style: Theme.of(context).textTheme.body1.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    ];

    for(var i = 0; i < 10; i++) {
      tiles.add(_ImageTile('https://picsum.photos/${Random.secure().nextInt(500)}/300/?random'));
    }
    return tiles;
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile(this.gridImage);

  final gridImage;

  @override
  Widget build(BuildContext context) {
    return new Card(
      color: const Color(0x00000000),
      elevation: 3.0,
      child: new GestureDetector(
        onTap: () {
          print("hello");
        },
        child: new Container(
          decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
          ),
          child: Stack(
            children: [
              Center(child: CircularProgressIndicator()),
              Center(
                child: FadeInImage.memoryNetwork(
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                  placeholder: kTransparentImage,
                  image: gridImage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Example01Tile extends StatelessWidget {
  const _Example01Tile(this.backgroundColor, this.iconData);  final Color backgroundColor;
  final IconData iconData;  @override
  Widget build(BuildContext context) {
    return new Card(
      color: backgroundColor,
      child: new InkWell(
        onTap: () {},
        child: new Center(
          child: new Padding(
            padding: const EdgeInsets.all(4.0),
            child: new Icon(
              iconData,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}