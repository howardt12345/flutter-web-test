import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
  AnimationController _animController;
  SidekickController _sidekickController;

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionListener = ItemPositionsListener.create();

  ScrollController _scrollController = ScrollController();

  PictureManager manager;

  int _index = 2, _subindex = 0, _currentPic = 0;
  bool _first = true;

  @override
  void initState() {
    _animController = AnimationController(vsync: this);
    _sidekickController = SidekickController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    super.initState();
    _initializeManager().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _sidekickController?.dispose();
    super.dispose();
  }

  Future<void> _initializeManager() async {
    manager = await PictureManager.fromUrl(
      jsonUrl: "https://raw.githubusercontent.com/howardt12345/website/master/portfolio.json",
      url: "https://firebasestorage.googleapis.com/v0/b/portfolio-49b69.appspot.com/o/",
      token: "810d1310-0533-4e13-bc33-6fc77ac56ef1",
    );
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (context, orientation) => Align(
          alignment: Alignment.center,
          child: Container(
            height: screenHeight(context: context) - 56,
            width: 1000,
            child: _first ? _buildTilesViewer() : _buildViewer(),
          ),
        )
    );
  }

  _buildTilesViewer() {
    return StaggeredGridView.count(
      crossAxisCount: 10,
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      staggeredTiles: _getTiles(),
      children: _getWidgets(false),
      padding: const EdgeInsets.all(4.0),
    );
  }

  _buildViewer() {
    var pic = manager.getPicturesFrom(_index, _subindex)[_currentPic];
    var thumbnails = _getWidgets(true);
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Sidekick(
              tag: '${pic.path}/${pic.title}-target',
              child: FadeInImage.memoryNetwork(
                height: screenHeight(context: context) - 200 - 56,
                fit: BoxFit.fill,
                alignment: Alignment.center,
                placeholder: kTransparentImage,
                image: '${manager.url}${pic.path.replaceAll('/', '%2F')}%2F${pic.title.replaceAll(' ', '%20')}?alt=media&token=${manager.token}',
              ),
            ),
            Container(
              height: 100,
              width: 1000,
              child: Align(
                alignment: Alignment.center,
                child: ScrollablePositionedList.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: thumbnails.length,
                  itemBuilder: (context, index) => thumbnails[index],
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionListener,
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _sidekickController.moveToSource(context);
              setState(() {
                _first = true;
              });
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _getWidgets(bool thumbnail) {
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
                _currentPic = i;
                _first = false;
              });
              itemScrollController.scrollTo(index: i-1, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
            },
            thumbnail: thumbnail,
            selected: i == _currentPic,
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
              _sidekickController.moveToTarget(context);
              itemScrollController.scrollTo(
                index: i,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: 1
              );
              setState(() {
                _currentPic = i;
                _first = false;
              });
            },
            thumbnail: thumbnail,
            selected: i == _currentPic,
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
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    this.pic,
    this.url,
    this.token,
    this.onTap,
    this.thumbnail = false,
    this.selected = false
  });

  final pic, url, token, onTap, thumbnail, selected;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      margin: EdgeInsets.all(1.0),
      shape: selected
          ? new RoundedRectangleBorder(
          side: new BorderSide(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(4.0))
          : new RoundedRectangleBorder(
          side: new BorderSide(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(4.0)),
      child: new GestureDetector(
        onTap: () {
          onTap();
          /*Navigator.push(context, MaterialPageRoute(builder: (_) {
            return _DetailScreen(
              pic: pic,
              url: url,
              token: token,
            );
          }));*/
        },
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                '/images/logo_dark.png',
                width: thumbnail ? 75 : 125,
                height: thumbnail ? 75 : 125,
              ),
            ),
            Center(
              child: SizedBox(
                width: thumbnail ? 15 : 25,
                height: thumbnail ? 15 : 25,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).textTheme.subtitle.color),
                ),
              )
            ),
            Center(
              child: Sidekick(
                tag: '${pic.path}/${pic.title}-source',
                targetTag: '${pic.path}/${pic.title}-target',
                child: FadeInImage.memoryNetwork(
                  fit: BoxFit.cover,
                  height: thumbnail ? 100 : double.infinity,
                  width: thumbnail ? 100 : double.infinity,
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