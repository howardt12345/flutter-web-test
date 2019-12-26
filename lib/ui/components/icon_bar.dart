
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_web_test/utils/functions.dart';

class IconBarButton extends StatefulWidget {
  const IconBarButton({
    Key key,
    this.url,
    this.iconData,
    this.onTap,
    this.color,
  }) : super(key: key);

  final String url;
  final IconData iconData;
  final Function onTap;
  final Color color;

  @override
  _IconBarButtonState createState() => _IconBarButtonState();
}

class _IconBarButtonState extends State<IconBarButton> {
  Color _color = Colors.black;

  void initState() {
    _color = widget.color ?? Colors.black;
    super.initState();
  }

  void _onTap() {
    if(widget.url != null) {
      openUrl(widget.url);
    }
    if(widget.onTap != null) {
      widget.onTap();
    }
  }

  void _changeButtonColor(Color color) {
    setState(() {
      _color = color;
    });
  }

  void _onPointerExit(PointerExitEvent event) {
    _changeButtonColor(widget.color ?? Theme.of(context).textTheme.button.color);
  }

  void _onPointerHover(PointerHoverEvent event) {
    _changeButtonColor(Theme.of(context).buttonColor);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: _onPointerExit,
      onHover: _onPointerHover,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          child: Icon(
            widget.iconData,
            color: _color,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class IconButtonInfo extends StatefulWidget {
  const IconButtonInfo({
    Key key,
    this.url,
    this.title = '',
    this.iconData,
    this.onTap,
    this.color,
  }) : super(key: key);

  final String url, title;
  final IconData iconData;
  final Function onTap;
  final Color color;

  @override
  _IconButtonInfoState createState() => _IconButtonInfoState();
}

class _IconButtonInfoState extends State<IconButtonInfo> {
  Color _color = Colors.black;
  bool _expand = false;

  void initState() {
    _color = widget.color ?? Colors.black;
    super.initState();
  }

  void _onTap() {
    if(widget.url != null) {
      openUrl(widget.url);
    }
    if(widget.onTap != null) {
      widget.onTap();
    }
  }

  void _changeButtonColor(Color color) {
    setState(() {
      _color = color;
    });
  }

  void _onPointerExit(PointerExitEvent event) {
    setState(() {
      _expand = false;
    });
    _changeButtonColor(widget.color ?? Theme.of(context).textTheme.button.color);
  }

  void _onPointerHover(PointerHoverEvent event) {
    setState(() {
      _expand = true;
    });
    _changeButtonColor(Theme.of(context).buttonColor);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: _onPointerExit,
      onHover: _onPointerHover,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: _onTap,
            child: Container(
              child: Icon(
                widget.iconData,
                color: _color,
                size: 24,
              ),
            ),
          ),
          Container(
            height: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                duration: Duration(milliseconds: 100),
                width: _expand ? widget.title.length * 16 : 0,
                height: 20,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: widget.title,
                      style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
