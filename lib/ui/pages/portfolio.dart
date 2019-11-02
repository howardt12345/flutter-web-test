import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_web_test/ui/components/image_manager.dart';
import 'package:flutter_web_test/utils/functions.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:transparent_image/transparent_image.dart';



// ignore: must_be_immutable
class PortfolioPage extends StatefulWidget {

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  AnimationController _animController;
  List<String> _data = [];
  int _index = 0, _subindex = 1;
  double _screenSize = 0;

  List<Widget> _tiles = [];

  PictureManager manager;

  List<StaggeredTile> _staggeredTiles = [];

  @override
  void initState() {
    _animController = AnimationController(vsync: this);
    super.initState();
    _initializeManager();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initializeManager() async {
    manager = await PictureManager.fromUrl(
      jsonUrl: "https://raw.githubusercontent.com/howardt12345/flutter-web-test/master/portfolio.json",
      url: "https://firebasestorage.googleapis.com/v0/b/portfolio-49b69.appspot.com/o/",
      token: "810d1310-0533-4e13-bc33-6fc77ac56ef1",
    );
    return null;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _screenSize = screenWidth(context: context);
    });
    return FutureBuilder(
      future: _initializeManager(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if(snapshot.connectionState == ConnectionState.done){
          return OrientationBuilder(
            builder: (context, orientation) =>
            (orientation == Orientation.portrait || _screenSize <= 600)
                ? _buildVerticalLayout()
                : _buildHorizontalLayout(),
          );
        } else {
          return Center(
            child: Text("oop"),
          );
        }
      },
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
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                      children: [
                        TextSpan(
                          text: manager.getCategories()[_index],
                          style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: 40,
                          ),
                        ),
                        TextSpan(
                          text: ": ${_subindex == 0 ? "All" : manager.getSubcategoriesFrom(_index)[_subindex]}",
                          style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: 20,
                          ),
                        ),
                      ]
                  ),
                ),
              ),
            ),
            StaggeredGridView.count(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              crossAxisCount: portrait ? 8 : 12,
              staggeredTiles: _getTiles(),
              children: _getWidgets(),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              padding: const EdgeInsets.all(4.0),
            ),
          ],
        ),
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
          initialItemCount: manager.getCategories().length,
          itemBuilder: (context, index, animation) => _buildItem(context, manager.getCategory(index), index, animation),
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
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 16.0),
                      Text(
                        item,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: _index == index ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153)
                        ),
                      ),
                      SizedBox(height: 8.0),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: _index == index ? item.length * 10 : 0,
                        height: 2.0,
                        color: Theme.of(context).textTheme.body2.color,
                        curve: Curves.ease,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  iconMapping[manager.getPictures(manager.getCategory(index), 'icon')[0].title],
                  color: _index == index ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153),
                  size: 24,
                ),
              ),
            ],
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _index == index ? manager.getSubcategoriesFrom(_index).length * 40 : 0,
            curve: Curves.ease,
            child: _index == index ? Column(
              children: manager.getSubcategoriesFrom(index).map((s) {
                if(manager.getSubcategoriesFrom(index).indexOf(s) == 0) {
                  return _buildSubMenu(context, "All", 0);
                } else {
                  return _buildSubMenu(context, s,
                      manager.getSubcategoriesFrom(index).indexOf(s));
                }
              }).toList(),
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
                fontWeight: FontWeight.w400,
                color: _subindex == subindex ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153)
            ),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }

  List<Widget> _getWidgets() {
    List<Widget> widgets = [];
    if(_subindex == 0) {
      for(var h = 1; h < (manager.getSubcategoriesFrom(_index).length); h++) {
        for(var i = 0; i < manager.getPicturesFrom(_index, h).length; i++) {
          var pic = manager.getPicturesFrom(_index, h)[i];
          widgets.add(
              _ImageTile(
                  '${manager.url}'
                      '${pic.path.replaceAll('/', '%2F')}%2F'
                      '${pic.title.replaceAll(' ', '%20')}?alt=media&token='
                      '${manager.token}'
              )
          );
        }
      }
    } else {
      for(var i = 0; i < manager.getPicturesFrom(_index, _subindex).length; i++) {
        var pic = manager.getPicturesFrom(_index, _subindex)[i];
        print('${manager.url}'
            '${pic.path.replaceAll('/', '%2F')}%2F'
            '${pic.title.replaceAll(' ', '%20')}?alt=media&token='
            '${manager.token}');
        widgets.add(
            _ImageTile(
                '${manager.url}'
                    '${pic.path.replaceAll('/', '%2F')}%2F'
                    '${pic.title.replaceAll(' ', '%20')}?alt=media&token='
                    '${manager.token}'
            )
        );
      }
    }
    return widgets;
  }

  List<StaggeredTile> _getTiles() {
    List<StaggeredTile> tiles = [];

    if(_subindex == 0) {
      for(var h = 1; h < (manager.getSubcategoriesFrom(_index).length); h++) {
        for(var i = 0; i < manager.getPicturesFrom(_index, h).length; i++) {
          var pic = manager.getPicturesFrom(_index, h)[i];
          tiles.add(
              StaggeredTile.count(
                  pic.width,
                  pic.height
              )
          );
        }
      }
    } else {
      for(var i = 0; i < manager.getPicturesFrom(_index, _subindex).length; i++) {
        var pic = manager.getPicturesFrom(_index, _subindex)[i];
        tiles.add(
            StaggeredTile.count(
                pic.width,
                pic.height
            )
        );
      }
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
      elevation: 0.0,
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
