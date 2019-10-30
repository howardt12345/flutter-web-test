import 'package:flutter/animation.dart';

class ListAnimation {
  final AnimationController controller;
  final List<Animation<double>> animations = new List<Animation<double>>();

  ListAnimation({
    this.controller,
    int items,
  }) {
    for(int i = 0; i < items; i++) {
      animations.add(
        new Tween(begin: 0.0, end: 1.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              i/items,
              (i+1)/items,
              curve: Curves.linear,
            ),
          ),
        ),
      );
    }
  }
}