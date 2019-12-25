import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_web_test/ui/components/icon_bar.dart';
import 'package:flutter_web_test/ui/components/image_manager.dart';
import 'package:flutter_web_test/ui/components/scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_web_test/utils/functions.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_sidekick/flutter_sidekick.dart';


class PortfolioPage extends StatefulWidget {
  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with TickerProviderStateMixin {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  AnimationController _animController;

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionListener = ItemPositionsListener.create();

  ScrollController _scrollController = ScrollController();
  PageController _pageController = PageController();

  PictureManager manager;

  int _index = 1, _subindex = 1, _currentPic = 1, _currentPagePic = 0;

  double _screenSize = 0;

  bool _first = true;

  @override
  void initState() {
    _animController = AnimationController(vsync: this);

    super.initState();
    _initializeManager().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeManager() async {
    manager = await PictureManager.fromUrl(
      jsonUrl: "https://raw.githubusercontent.com/howardt12345/website/test/portfolio.json",
      url: "https://firebasestorage.googleapis.com/v0/b/portfolio-49b69.appspot.com/o/",
      token: "810d1310-0533-4e13-bc33-6fc77ac56ef1",
    );
    return null;
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      _screenSize = screenWidth(context: context);
      _scaffoldKey = new GlobalKey();
    });
    return OrientationBuilder(
        builder: (context, orientation) => Container(
        height: screenHeight(context: context),
        width: screenWidth(context: context),
        child: (/*orientation == Orientation.portrait || */_screenSize <= 900)
            ? _buildVerticalLayout(context)
            : _buildHorizontalLayout(),
        )
    );
  }

  _buildHorizontalLayout() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: screenHeight(context: context) - 56,
        width: 900,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: _buildFullDrawer(),
            ),
            Container(
              width: 675,
              child: AnimatedCrossFade(
                crossFadeState: _first ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: _buildTilesViewer(),
                secondChild: _buildImageViewer(width: 675),
                duration: Duration(milliseconds: 100),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildVerticalLayout(BuildContext context) {
    return Container(
      height: screenHeight(context: context) - 56,
      width: _screenSize,
      child: AnimatedCrossFade(
        crossFadeState: _first ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: _buildTilesViewer(),
        secondChild: _buildImageViewer(width: _screenSize),
        duration: Duration(milliseconds: 100),
      ),
    );
  }

  _buildTilesViewer() {
    return StaggeredGridView.count(
      crossAxisCount: 10,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      staggeredTiles: _getTiles(),
      children: _getWidgets(false),
      padding: const EdgeInsets.all(4.0),
    );
  }

  _buildImageViewer({double width = 900}) {
    double thumbnailSize = 80;
    _pageController = PageController(initialPage: _subindex == 0 ? _currentPic+1 : _currentPic);
    _scrollController = ScrollController();
    var thumbnails = _getWidgets(true, size: thumbnailSize);
    var children = thumbnails.length;
    for(int i = 0; i < ((5 + (_subindex == 0 ? 1 : 0))); i++) {
      thumbnails.insert(i, Container(
        width: thumbnailSize,
        height: thumbnailSize,/*
        child: Text('$i'),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent)
        ),*/
      ));
    }
    for(int i = 0; i < 10; i++) {
      thumbnails.add(Container(width: thumbnailSize, height: thumbnailSize,));
    }
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: screenHeight(context: context) - thumbnailSize - 56,
              width: width,
              child: PageView.builder(
                  controller: _pageController,
                  itemCount: children,
                  itemBuilder: (context, index) {
                    var pic = manager.getPicturesFrom(_index, _subindex)[_subindex == 0 ? index+1 : index];
                    return _DetailCard(
                      pic: pic,
                      url: manager.url,
                      token: manager.token,
                    );
                  },
                onPageChanged: (index) {
                  setState(() {
                    _currentPagePic = _subindex == 0 ? index+1 : index;
                    _first = false;
                  });
                  //itemScrollController.jumpTo(index: _currentPagePic);
                  _scrollController.jumpTo((_currentPagePic) * thumbnailSize + (screenWidth(context: context) >= 900 ? (900 % width)/2 : (900 % screenWidth(context: context))/2));
                },
              ),
            ),
            Container(
              height: thumbnailSize,
              width: width,
              child: Align(
                alignment: Alignment.center,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: thumbnails.length,
                  itemBuilder: (context, index) => thumbnails[index],
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            height: 56,
            width: 56,
            child: IconBarButton(
              iconData: Icons.arrow_back,
              onTap: () {
                setState(() {
                  _first = true;
                });
              },
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _getWidgets(bool thumbnail, {double size}) {
    List<Widget> widgets = [];
    if(_subindex == 0) {
      for(var i = 1; i < manager.getPictures(manager.getCategory(_index), 'icon').length; i++) {
        var pic = manager.getPictures(manager.getCategory(_index), 'icon')[i];
        print('${manager.url}'
            '${pic.path.replaceAll('/', '%2F')}%2F'
            '${pic.title.replaceAll(' ', '%20')}?alt=media&token='
            '${manager.token}');
        widgets.add(
          _ImageTile(
            pic: pic,
            url: manager.url,
            token: manager.token,
            onTap: () {
              setState(() {
                _currentPic = i-1;
                _first = false;
              });
              _pageController.animateToPage(_currentPic, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
            },
            thumbnail: thumbnail,
            size: size,
          )
        );
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
              pic: pic,
              url: manager.url,
              token: manager.token,
              onTap: () {
                setState(() {
                  _currentPic = i;
                  _first = false;
                });
                _pageController.animateToPage(_currentPic, duration: Duration(milliseconds: 250), curve: Curves.easeOut);
              },
              thumbnail: thumbnail,
              size: size,
            )
        );
      }
    }
    return widgets;
  }

  List<StaggeredTile> _getTiles() {
    List<StaggeredTile> tiles = [];
    if(_subindex == 0) {
      for(var i = 1; i < manager.getPictures(manager.getCategory(_index), 'icon').length; i++) {
        var pic = manager.getPictures(manager.getCategory(_index), 'icon')[i];
        tiles.add(
          StaggeredTile.count(
            pic.height.toInt(),
            pic.width
          )
        );
      }
    } else {
      for(var i = 0; i < manager.getPicturesFrom(_index, _subindex).length; i++) {
        var pic = manager.getPicturesFrom(_index, _subindex)[i];
        tiles.add(
          StaggeredTile.count(
            pic.height.toInt(),
            pic.width
          )
        );
      }
    }
    return tiles;
  }

  _buildIconDrawer() {
    return Container(
        height: 56.0,
        decoration: BoxDecoration(
        ),
        child: GestureDetector(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: manager.getCategories().map((c) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _index = manager.getCategories().indexOf(c);
                      _subindex = 0;
                      _first = true;
                    });
                  },
                  icon: Icon(
                    iconMapping[manager.getPictures(c, 'icon')[0].title],
                    color: _index == manager.getCategories().indexOf(c) ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153),
                    size: 24,
                  ),
                );
              }).toList(),
            ),
          ),
        )
    );
  }

  _buildFullDrawer() {
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
          _first = true;
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
                      SizedBox(height: 8.0),
                      Text(
                        item,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: 16,
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
            height: _index == index ? manager.getSubcategoriesFrom(_index).length * 36 : 0,
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
          _first = true;
        });
      },
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              item,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.body2.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _subindex == subindex ? Theme.of(context).textTheme.body2.color : Theme.of(context).textTheme.body2.color.withAlpha(153)
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    this.pic,
    this.url,
    this.token,
    this.onTap,
    this.thumbnail = false,
    this.size = 80.0,
  });

  final pic, url, token, onTap, thumbnail, size;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      margin: EdgeInsets.all(1.0),
      child: new GestureDetector(
        onTap: () {
          onTap();
        },
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                '/images/logo_dark.png',
                width: thumbnail ? size * 0.75 : 125,
                height: thumbnail ? size * 0.75 : 125,
              ),
            ),
            Center(
              child: SizedBox(
                width: thumbnail ? size * 0.15 : 25,
                height: thumbnail ? size * 0.15 : 25,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).textTheme.subtitle.color),
                ),
              )
            ),
            Center(
              child: Hero(
                tag: '${pic.path}/${pic.title}-source',
                child: FadeInImage.memoryNetwork(
                  fit: BoxFit.cover,
                  height: thumbnail ? size : double.infinity,
                  width: thumbnail ? size : double.infinity,
                  alignment: Alignment.center,
                  placeholder: kTransparentImage,
                  image: '$url${pic.path.replaceAll('/', '%2F')}%2F${pic.title.replaceAll(' ', '%20')}?alt=media&token=$token',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatefulWidget {
  final Picture pic;
  final String url, token;

  _DetailCard({
    this.pic,
    this.url,
    this.token,
  });

  @override
  __DetailCardState createState() => __DetailCardState();
}

class __DetailCardState extends State<_DetailCard> {
  bool info = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Stack(
        children: <Widget>[
          Center(
            child: AspectRatio(
              aspectRatio: widget.pic.width/widget.pic.height,
              child: FadeInImage.memoryNetwork(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                placeholder: kTransparentImage,
                image: '${widget.url}${widget.pic.path.replaceAll('/', '%2F')}%2F${widget.pic.title
                    .replaceAll(' ', '%20')}?alt=media&token=${widget.token}',
              ),
            ),
          ),
          AnimatedCrossFade(
              crossFadeState: info ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 250),
              firstChild: Container(),
              secondChild: Center(
                child: AspectRatio(
                  aspectRatio: widget.pic.width/widget.pic.height,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200.withOpacity(0.5)
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                text: widget.pic.description,
                                style: Theme.of(context).textTheme.body1.copyWith(
                                  fontSize: 20,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 56.0,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 24,
                    width: 24,
                    child: widget.pic.download.isNotEmpty
                        ? IconBarButton(
                      url: '${widget.url}${widget.pic.path.replaceAll('/', '%2F')}%2F${widget.pic.title
                          .replaceAll(' ', '%20')}?alt=media&token=${widget.token}',
                      iconData: iconMapping['download'],
                    ) : null,
                  ),
                  Expanded(child: Container(),),
                  Container(
                    height: 24,
                    width: 24,
                    child: widget.pic.buy.isNotEmpty
                        ? IconBarButton(
                      url: widget.pic.buy,
                      iconData: iconMapping['buy'],
                    ) : null,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              height: 56,
              width: 56,
              child: IconBarButton(
                iconData: Icons.info_outline,
                onTap: () {
                  setState(() {
                    info = !info;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

