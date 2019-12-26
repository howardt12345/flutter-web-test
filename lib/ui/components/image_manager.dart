

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Map<String, IconData> iconMapping = {
  'buy': Icons.add_shopping_cart,
  'download': Icons.file_download,

  'email': Icons.email,
  'school': Icons.school,
  'location': Icons.location_on,
  'phone': Icons.phone,

  'landscape': Icons.landscape,
  'portraits': Icons.portrait,
  'nature': Icons.nature_people,
  'misc': Icons.more_horiz,
  'events': Icons.event,
  'travel': Icons.card_travel,
};

class PictureManager {
  String url, token;
  Map<String, Map<String, List<Picture>>> menu;

  PictureManager({
    this.url,
    this.token,
    this.menu
  });

  factory PictureManager.fromJson({Map<String, dynamic> json, String url, String token}) {
    Map<String, Map<String, List<Picture>>> tmpMenu = Map<String, Map<String, List<Picture>>>();
    for(var category in json['categories']) {
      String categoryName = category['category'];
      String iconName = category['icon'];


      Map<String, List<Picture>> subTmp = Map<String, List<Picture>>();

      subTmp['icon'] = [Picture(title: iconName, time: DateTime.now())];

      if(category['subcategories'].length != 0) {
        List<dynamic> subcategories = category['subcategories'];
        subcategories.forEach((subcategory) {
          String subcategoryName = subcategory['name'];
          List<dynamic> images = subcategory['images'];
          List<Picture> pictures = [];
          images.forEach((image) {
            print(image);
            pictures.add(Picture.fromJson(image, '$categoryName/$subcategoryName'));
          });
          pictures.sort((a,b) => b.time.compareTo(a.time));
          subTmp[subcategoryName] = pictures;
          subTmp['icon'].addAll(pictures);
        });
      } else {
        List<dynamic> images = category['images'];
        images.forEach((image) {
          print(image);
          subTmp['icon'].add(Picture.fromJson(image, '$categoryName'));
        });
        subTmp['icon'].sort((a,b) => b.time.compareTo(a.time));
      }

      tmpMenu[categoryName] = subTmp;
    }
    return PictureManager(
      url: url,
      token: token,
      menu: tmpMenu,
    );
  }

  static Future<PictureManager> fromUrl({String jsonUrl, String url, String token}) async {
    final response = await http.get(jsonUrl);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return PictureManager.fromJson(
        json: json.decode(response.body),
        url: url,
        token: token,
      );
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  List<String> getCategories() => menu.keys.toList();
  String getCategory(int index) => menu.keys.toList()[index];

  List<String> getSubcategories(String category) => menu[category].keys.toList();
  List<String> getSubcategoriesFrom(int index) => menu[menu.keys.toList()[index]].keys.toList();

  List<Picture> getPictures(String category, String subcategory) => menu[category][subcategory];
  List<Picture> getPicturesFrom(int category, int subcategory)
    => menu[menu.keys.toList()[category]][menu[menu.keys.toList()[category]].keys.toList()[subcategory]];

  List<Picture> getAllPicturesAt(String category) {
    List<Picture> tmp = [];
    menu[category].values.map((s) => tmp.addAll(s));
    tmp.sort((a,b) => b.time.compareTo(a.time));
    return tmp;
  }
  List<Picture> getAllPicturesFrom(int index) {
    List<Picture> tmp = [];
    menu[menu.keys.toList()[index]].values.map((s) => tmp.addAll(s));
    tmp.sort((a,b) => b.time.compareTo(a.time));
    return tmp;
  }
  List<Picture> getAllPictures() {
    List<Picture> tmp = [];
    for(var h = 0; h < menu.keys.toList().length; h++) {
      for(var i = 1; i < getPictures(getCategory(h), 'icon').length; i++) {
        tmp.add(getPictures(getCategory(h), 'icon')[i]);
      }
    }
    tmp.sort((a,b) => b.time.compareTo(a.time));
    return tmp;
  }
}

class Picture {
  final String title, path, description, buy, download;
  final int width;
  final double height;
  final DateTime time;

  Picture({
    this.path,
    this.title,
    this.width,
    this.height,
    this.description,
    this.buy,
    this.download,
    this.time,
  });

  factory Picture.fromJson(Map<String, dynamic> json, String path) => Picture(
    title: json['title'],
    width: json['width'],
    height: json['height'],
    description: json['description'],
    buy: json['buy'],
    download: json['download'],
    time: json['time'] != '' ? DateTime.parse(json['time']) : DateTime.utc(1989, 11, 9),
    path: path,
  );
}
